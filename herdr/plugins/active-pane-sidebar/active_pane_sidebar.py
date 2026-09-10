#!/usr/bin/env python3
"""Report focused-pane context as Herdr workspace sidebar metadata."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from typing import Any, Callable

SOURCE = "georgef.active-pane-sidebar"
TOKEN_LIMIT = 80
TOKEN_NAMES = ("active_dir", "worktree", "branch", "git_state", "pane_context")
DIRECTORY_ICON = "📁"
WORKTREE_ICON = "🌳"
BRANCH_ICON = "⎇"
WORLD_TREE_RE = re.compile(r"/world/trees/([^/]+)/src(?:/|$)")
GENERIC_WORKTREE_RE = re.compile(r"/worktrees/([^/]+)(?:/|$)")
TRANSIENT_CWD_PREFIXES = (
    "/private/var/folders/",
    "/private/tmp/",
    "/var/folders/",
    "/tmp/",
    "/var/tmp/",
)

Runner = Callable[[list[str]], tuple[int, str, str]]


def run(command: list[str]) -> tuple[int, str, str]:
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=3,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as error:
        return 1, "", str(error)
    return result.returncode, result.stdout, result.stderr


def herdr_binary() -> str | None:
    configured = os.environ.get("HERDR_BIN_PATH")
    if configured:
        path = Path(configured).expanduser()
        if path.is_file() and os.access(path, os.X_OK):
            return str(path)
        candidate = path / "herdr"
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    return shutil.which("herdr")


def truncate(value: str, limit: int = TOKEN_LIMIT) -> str:
    value = " ".join(value.split())
    if len(value) <= limit:
        return value
    if limit <= 1:
        return value[:limit]
    return f"{value[: limit - 1]}…"


def event_payload() -> dict[str, Any]:
    raw = os.environ.get("HERDR_PLUGIN_EVENT_JSON", "")
    if not raw:
        return {}
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        return {}
    return parsed if isinstance(parsed, dict) else {}


def context_payload() -> dict[str, Any]:
    raw = os.environ.get("HERDR_PLUGIN_CONTEXT_JSON", "")
    if not raw:
        return {}
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        return {}
    return parsed if isinstance(parsed, dict) else {}


def resolve_pane_id(argument: str | None) -> str | None:
    if argument:
        return argument
    if pane_id := os.environ.get("HERDR_PANE_ID"):
        return pane_id

    event = event_payload()
    data = event.get("data", event)
    if isinstance(data, dict):
        if isinstance(data.get("pane_id"), str):
            return data["pane_id"]
        pane = data.get("pane")
        if isinstance(pane, dict):
            for key in ("pane_id", "id"):
                if isinstance(pane.get(key), str):
                    return pane[key]

    context = context_payload()
    for key in ("focused_pane_id", "pane_id"):
        if isinstance(context.get(key), str):
            return context[key]
    return None


def cli_json(binary: str, arguments: list[str], runner: Runner = run) -> dict[str, Any] | None:
    code, stdout, _stderr = runner([binary, *arguments])
    if code != 0:
        return None
    try:
        payload = json.loads(stdout)
    except json.JSONDecodeError:
        return None
    if not isinstance(payload, dict):
        return None
    result = payload.get("result", payload)
    return result if isinstance(result, dict) else None


def pane_info(binary: str, pane_id: str, runner: Runner = run) -> dict[str, Any] | None:
    result = cli_json(binary, ["pane", "get", pane_id], runner)
    if not result:
        return None
    pane = result.get("pane", result)
    return pane if isinstance(pane, dict) else None


def tab_label(binary: str, tab_id: str, runner: Runner = run) -> str:
    result = cli_json(binary, ["tab", "get", tab_id], runner)
    if not result:
        return ""
    tab = result.get("tab", result)
    if not isinstance(tab, dict):
        return ""
    label = tab.get("label")
    return label if isinstance(label, str) else ""


def git_output(cwd: str, arguments: list[str], runner: Runner = run) -> str | None:
    code, stdout, _stderr = runner(["git", "-C", cwd, *arguments])
    return stdout.strip() if code == 0 else None


def abbreviated_path(path: str) -> str:
    home = str(Path.home())
    if path == home:
        return "~"
    if path.startswith(f"{home}/"):
        path = f"~/{path[len(home) + 1:]}"
    if len(path) <= TOKEN_LIMIT:
        return path
    return f"…/{'/'.join(Path(path).parts[-3:])}"


def with_icon(icon: str, value: str) -> str:
    return truncate(f"{icon} {value}") if value else ""


def worktree_name(cwd: str, git_dir: str | None) -> str:
    if match := WORLD_TREE_RE.search(cwd):
        return match.group(1)
    if git_dir and (match := GENERIC_WORKTREE_RE.search(git_dir)):
        return match.group(1)
    return ""


def git_metadata(cwd: str, runner: Runner = run) -> dict[str, str]:
    repo_root = git_output(cwd, ["rev-parse", "--show-toplevel"], runner)
    if not repo_root:
        return {
            "active_dir": with_icon(DIRECTORY_ICON, abbreviated_path(cwd)),
            "worktree": "",
            "branch": "",
            "git_state": "",
        }

    try:
        relative = os.path.relpath(cwd, repo_root)
    except ValueError:
        relative = cwd
    active_dir = Path(repo_root).name if relative == "." else relative

    git_dir = git_output(cwd, ["rev-parse", "--path-format=absolute", "--git-dir"], runner)
    branch = git_output(cwd, ["symbolic-ref", "--quiet", "--short", "HEAD"], runner)
    if not branch:
        short_head = git_output(cwd, ["rev-parse", "--short", "HEAD"], runner)
        branch = f"detached:{short_head}" if short_head else ""

    status = git_output(cwd, ["status", "--porcelain=v1", "--untracked-files=no"], runner)
    state_parts = ["●"] if status else []
    counts = git_output(cwd, ["rev-list", "--left-right", "--count", "@{upstream}...HEAD"], runner)
    if counts:
        try:
            behind, ahead = (int(value) for value in counts.split())
        except (TypeError, ValueError):
            behind = ahead = 0
        if ahead:
            state_parts.append(f"↑{ahead}")
        if behind:
            state_parts.append(f"↓{behind}")

    return {
        "active_dir": with_icon(DIRECTORY_ICON, active_dir),
        "worktree": with_icon(WORKTREE_ICON, worktree_name(cwd, git_dir)),
        "branch": with_icon(BRANCH_ICON, branch),
        "git_state": truncate(" ".join(state_parts) or "✓"),
    }


def effective_pane_cwd(pane: dict[str, Any]) -> str:
    launch_cwd = pane.get("cwd")
    foreground_cwd = pane.get("foreground_cwd")

    if isinstance(foreground_cwd, str) and foreground_cwd:
        # Herdr follows the running process, which matters when Pi resumes a
        # session from a different worktree than the pane's creation directory.
        # Ignore only known temporary tool-call directories when a stable launch
        # cwd is available as a fallback.
        transient = foreground_cwd.startswith(TRANSIENT_CWD_PREFIXES)
        has_launch_cwd = isinstance(launch_cwd, str) and bool(launch_cwd)
        if not pane.get("agent") or not transient or not has_launch_cwd:
            return foreground_cwd
    return launch_cwd if isinstance(launch_cwd, str) else ""


def pane_context(pane: dict[str, Any], tab: str) -> str:
    parts: list[str] = []
    if tab:
        parts.append(tab)
    agent = pane.get("agent") or pane.get("display_agent")
    status = pane.get("agent_status")
    if isinstance(agent, str) and agent:
        agent_text = agent
        if isinstance(status, str) and status:
            agent_text = f"{agent_text}:{status}"
        parts.append(agent_text)
    elif title := pane.get("terminal_title_stripped"):
        if isinstance(title, str):
            parts.append(title)
    return truncate(" · ".join(parts))


def report_workspace(
    binary: str,
    workspace_id: str,
    tokens: dict[str, str],
    runner: Runner = run,
) -> bool:
    command = [
        binary,
        "workspace",
        "report-metadata",
        workspace_id,
        "--source",
        SOURCE,
    ]
    for name in TOKEN_NAMES:
        value = truncate(tokens.get(name, ""))
        if value:
            command.extend(["--token", f"{name}={value}"])
        else:
            command.extend(["--clear-token", name])
    code, _stdout, _stderr = runner(command)
    return code == 0


def refresh(binary: str, pane_id: str, runner: Runner = run) -> bool:
    pane = pane_info(binary, pane_id, runner)
    if not pane or pane.get("focused") is not True:
        return False

    workspace_id = pane.get("workspace_id")
    cwd = effective_pane_cwd(pane)
    if not isinstance(workspace_id, str) or not cwd:
        return False

    tokens = git_metadata(cwd, runner)
    tab_id = pane.get("tab_id")
    tab = tab_label(binary, tab_id, runner) if isinstance(tab_id, str) else ""
    tokens["pane_context"] = pane_context(pane, tab)
    return report_workspace(binary, workspace_id, tokens, runner)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pane-id")
    args = parser.parse_args(argv)

    binary = herdr_binary()
    pane_id = resolve_pane_id(args.pane_id)
    if not binary or not pane_id:
        return 0
    refresh(binary, pane_id)
    return 0


if __name__ == "__main__":
    sys.exit(main())
