#!/usr/bin/env python3
"""Popup pane listing the user's open PRs with check and review status.

Sources come from $HERDR_PLUGIN_CONFIG_DIR/sources (one per line:
"github", "meteorite"). Defaults to "github" when the file is absent,
so a fresh machine needs no configuration.

Keys: up/down (or j/k) select, Enter opens the PR in a browser,
r refreshes, q/Esc closes.
"""

import json
import os
import re
import select
import subprocess
import sys
import termios
import tty
from datetime import datetime

CLEAR = "\033[2J\033[H"
DIM = "\033[2m"
BOLD = "\033[1m"
REVERSE = "\033[7m"
GREEN = "\033[32m"
RED = "\033[31m"
YELLOW = "\033[33m"
RESET = "\033[0m"

# Global PR search: no repo context needed, unlike `gh pr list`, which only
# sees the cwd's repository (the popup pane runs from the plugin dir).
GITHUB_QUERY = (
    "query { search(query: \"is:pr is:open author:@me\", type: ISSUE, first: 50) {"
    " issueCount nodes { ... on PullRequest { number title url updatedAt isDraft"
    " reviewDecision headRefName repository { nameWithOwner }"
    " commits(last: 1) { nodes { commit { statusCheckRollup { contexts(last: 20)"
    " { nodes { __typename ... on CheckRun { status conclusion }"
    " ... on StatusContext { state } } } } } } } } } } }"
)


def load_sources():
    config_dir = os.environ.get("HERDR_PLUGIN_CONFIG_DIR")
    if config_dir:
        path = os.path.join(config_dir, "sources")
        if os.path.isfile(path):
            with open(path) as fh:
                sources = [
                    line.strip()
                    for line in fh
                    if line.strip() and not line.strip().startswith("#")
                ]
            if sources:
                return sources
    return ["github"]


def run(argv):
    return subprocess.run(
        argv, capture_output=True, text=True, timeout=60
    )


def rollup_symbol(checks):
    """One summary symbol for a PR's combined check status."""
    if not checks:
        return f"{DIM}–{RESET}"
    failures = pendings = 0
    for check in checks:
        if check.get("__typename") == "CheckRun":
            if check.get("status") != "COMPLETED":
                pendings += 1
            elif check.get("conclusion") in ("SUCCESS", "SKIPPED", "NEUTRAL"):
                continue
            else:
                failures += 1
        else:  # StatusContext
            state = check.get("state", "")
            if state in ("SUCCESS", "EXPECTATION_PASSED"):
                continue
            if state in ("PENDING", "EXPECTED", "IN_PROGRESS"):
                pendings += 1
            else:
                failures += 1
    if failures:
        return f"{RED}✗{RESET}"
    if pendings:
        return f"{YELLOW}•{RESET}"
    return f"{GREEN}✓{RESET}"


def review_symbol(decision):
    return {
        "APPROVED": f"{GREEN}+{RESET}",
        "CHANGES_REQUESTED": f"{RED}-{RESET}",
        "REVIEW_REQUIRED": f"{DIM}…{RESET}",
    }.get(decision, " ")


def fetch_github():
    result = run(["gh", "api", "graphql", "-f", f"query={GITHUB_QUERY}"])
    if result.returncode != 0:
        detail = result.stderr.strip().splitlines()[-1] if result.stderr else "gh failed"
        return [f"{RED}github: {detail}{RESET}"]
    try:
        search = json.loads(result.stdout)["data"]["search"]
    except (json.JSONDecodeError, KeyError, TypeError):
        return [f"{RED}github: unexpected gh response{RESET}"]
    rows = []
    prs = search.get("nodes") or []
    prs.sort(key=lambda pr: pr.get("updatedAt", ""), reverse=True)
    for pr in prs:
        checks = []
        for commit_node in (pr.get("commits") or {}).get("nodes") or []:
            contexts = ((commit_node.get("commit") or {})
                        .get("statusCheckRollup") or {}).get("contexts") or {}
            checks.extend(contexts.get("nodes") or [])
        updated = pr.get("updatedAt", "")[:16].replace("T", " ")
        rows.append({
            "source": "github",
            "ref": pr["number"],
            "repo": (pr.get("repository") or {}).get("nameWithOwner", "?"),
            "branch": pr.get("headRefName", ""),
            "flags": "{}{}".format(
                f"{DIM}draft{RESET} " if pr.get("isDraft") else "",
                f"{rollup_symbol(checks)}"
                f"{review_symbol(pr.get('reviewDecision'))}",
            ),
            "title": pr["title"],
            "updated": updated,
            "url": pr.get("url", ""),
        })
    return rows


GS_ROW = re.compile(
    r"^#(\d+)\s{2,}(\S+)\s{2,}(\S+)\s{2,}(\S+)\s{2,}(.*)$"
)


def fetch_meteorite():
    result = run(["gs", "pr", "list"])
    if result.returncode != 0:
        detail = result.stderr.strip().splitlines()[-1] if result.stderr else "gs failed"
        return [f"{RED}meteorite: {detail}{RESET}"]
    rows = []
    for line in result.stdout.splitlines():
        match = GS_ROW.match(line)
        if not match:
            continue
        number, state, head, _base, title = match.groups()
        rows.append({
            "source": "meteorite",
            "ref": number,
            "repo": "meteorite",
            "branch": head,
            "flags": f"{DIM}{state}{RESET}",
            "title": title.strip(),
            "updated": "",
            "url": "",
        })
    return rows


FETCHERS = {"github": fetch_github, "meteorite": fetch_meteorite}


def collect_rows(sources):
    rows = []
    for source in sources:
        fetch = FETCHERS.get(source)
        if fetch:
            rows.extend(fetch())
        else:
            rows.append(f"{RED}unknown source: {source}{RESET}")
    return rows


def open_row(row):
    """Open a PR in the browser; returns a status-line message."""
    if not isinstance(row, dict):
        return "Nothing to open on that row."
    try:
        if row.get("url"):
            opener = "open" if sys.platform == "darwin" else "xdg-open"
            result = subprocess.run(
                [opener, row["url"]],
                capture_output=True, text=True, timeout=15,
            )
            label = f"{row['repo']}#{row['ref']}"
        else:
            result = subprocess.run(
                ["gs", "pr", "open", str(row["ref"])],
                capture_output=True, text=True, timeout=15,
            )
            label = f"meteorite#{row['ref']}"
    except (OSError, subprocess.TimeoutExpired) as exc:
        return f"{RED}open failed: {exc}{RESET}"
    if result.returncode != 0:
        detail = result.stderr.strip().splitlines()[-1] if result.stderr else "failed"
        return f"{RED}open {label}: {detail}{RESET}"
    return f"Opened {label} in browser."


def strip_ansi(text):
    return re.sub(r"\033\[[0-9;]*m", "", text)


def table_line(row, widths):
    if isinstance(row, dict):
        cells = (
            "#{}".format(row["ref"]), row["repo"], row["branch"],
            row["flags"], row["title"], row["updated"],
        )
    else:
        cells = (row, "", "", "", "", "")
    return "  ".join(
        cell.ljust(w) for cell, w in zip(cells, widths)
    )


def render(rows, selected, error=None, status=None):
    now = datetime.now().strftime("%H:%M:%S")
    print(CLEAR, end="")
    print(f"{BOLD}My open PRs{RESET} {DIM}· {now} · "
          f"↑↓ select · ↵ open · r refresh · q close{RESET}")
    print()
    if error:
        print(f"{RED}{error}{RESET}")
    if status:
        print(f"{BOLD}{status}{RESET}")
    if not rows:
        print(f"{DIM}No open PRs.{RESET}")
        return
    headers = ("PR", "REPO", "BRANCH", "", "TITLE", "UPDATED")
    # Column widths from the widest visible cell, ignoring ANSI escapes.
    widths = [len(h) for h in headers]
    for row in rows:
        if isinstance(row, dict):
            cells = ("#{}".format(row["ref"]), row["repo"], row["branch"],
                     strip_ansi(row["flags"]), row["title"], row["updated"])
        else:
            cells = (strip_ansi(row), "", "", "", "", "")
        widths = [max(w, len(c)) for w, c in zip(widths, cells)]
    print("  ".join(f"{BOLD}{h.ljust(w)}{RESET}"
                    for h, w in zip(headers, widths)))
    for index, row in enumerate(rows):
        line = table_line(row, widths)
        if index == selected:
            print(f"{REVERSE}❯ {line}{RESET}")
        else:
            print(f"  {line}")


def read_key():
    """Read one logical key: 'up', 'down', 'esc', or a single character."""
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        ch = sys.stdin.read(1)
        if ch != "\x1b":
            return ch
        sequence = ""
        while select.select([sys.stdin], [], [], 0.05)[0]:
            sequence += sys.stdin.read(1)
            if sequence[-1:].isalpha():
                break
        if sequence == "[A":
            return "up"
        if sequence == "[B":
            return "down"
        return "esc"
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)


def main():
    if not sys.stdin.isatty():
        # Non-interactive (tests, pipes): render once and exit.
        render(collect_rows(load_sources()), 0)
        return
    sources = load_sources()
    rows = collect_rows(sources)
    selected = 0
    error = None
    status = None
    print("\033[?25l", end="")  # hide cursor
    try:
        while True:
            render(rows, selected, error, status)
            error = None
            status = None
            if not rows:
                key = read_key()
                if key in ("q", "\x03", "esc"):
                    return
                if key == "r":
                    rows = collect_rows(sources)
                    selected = 0
                continue
            key = read_key()
            if key in ("q", "\x03", "esc"):
                return
            if key == "r":
                rows = collect_rows(sources)
                selected = min(selected, len(rows) - 1)
            elif key in ("up", "k"):
                selected = max(0, selected - 1)
            elif key in ("down", "j"):
                selected = min(len(rows) - 1, selected + 1)
            elif key in ("\r", "\n"):
                status = open_row(rows[selected])
    except BrokenPipeError:
        return
    finally:
        print("\033[?25h", end="")  # show cursor


if __name__ == "__main__":
    main()
