import json
import os
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

PLUGIN_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PLUGIN_ROOT))

import active_pane_sidebar as sidebar


class FakeRunner:
    def __init__(self, responses=None):
        self.responses = responses or {}
        self.calls = []

    def __call__(self, command):
        self.calls.append(command)
        for needle, response in self.responses.items():
            if needle in " ".join(command):
                return response
        return 1, "", "unexpected command"


class ActivePaneSidebarTest(unittest.TestCase):
    def test_resolves_nested_event_pane_id(self):
        event = {"event": "pane_created", "data": {"pane": {"pane_id": "w1:p2"}}}
        with patch.dict(
            os.environ,
            {"HERDR_PLUGIN_EVENT_JSON": json.dumps(event)},
            clear=True,
        ):
            self.assertEqual("w1:p2", sidebar.resolve_pane_id(None))

    def test_world_git_metadata_is_repo_relative(self):
        cwd = "/Users/george/world/trees/feature/src/areas/core/shopify"
        runner = FakeRunner(
            {
                "rev-parse --show-toplevel": (0, "/Users/george/world/trees/feature/src\n", ""),
                "rev-parse --path-format=absolute --git-dir": (0, "/Users/george/world/git/worktrees/feature\n", ""),
                "symbolic-ref --quiet --short HEAD": (0, "feature/sidebar\n", ""),
                "status --porcelain=v1": (0, " M config.toml\n", ""),
                "rev-list --left-right --count": (0, "1 2\n", ""),
            }
        )

        metadata = sidebar.git_metadata(cwd, runner)

        self.assertEqual("📁 areas/core/shopify", metadata["active_dir"])
        self.assertEqual("🌳 feature", metadata["worktree"])
        self.assertEqual("⎇ feature/sidebar", metadata["branch"])
        self.assertEqual("● ↑2 ↓1", metadata["git_state"])

    def test_non_git_metadata_clears_git_tokens(self):
        runner = FakeRunner()
        with patch.object(Path, "home", return_value=Path("/Users/george")):
            metadata = sidebar.git_metadata("/Users/george/tmp/example", runner)

        self.assertEqual("📁 ~/tmp/example", metadata["active_dir"])
        self.assertEqual("", metadata["worktree"])
        self.assertEqual("", metadata["branch"])
        self.assertEqual("", metadata["git_state"])

    def test_report_uses_token_and_clear_arguments(self):
        runner = FakeRunner({"workspace report-metadata": (0, "{}", "")})

        result = sidebar.report_workspace(
            "herdr",
            "w1",
            {
                "active_dir": "📁 areas/core/shopify",
                "worktree": "🌳 feature",
                "branch": "",
                "git_state": "",
                "pane_context": "editor · pi:working",
            },
            runner,
        )

        self.assertTrue(result)
        command = runner.calls[0]
        self.assertIn("active_dir=📁 areas/core/shopify", command)
        self.assertIn("worktree=🌳 feature", command)
        self.assertIn("branch", command)
        self.assertIn("git_state", command)
        self.assertEqual(2, command.count("--clear-token"))

    def test_refresh_reports_only_focused_pane(self):
        unfocused = FakeRunner(
            {
                "pane get w1:p1": (
                    0,
                    json.dumps(
                        {
                            "result": {
                                "pane": {
                                    "pane_id": "w1:p1",
                                    "workspace_id": "w1",
                                    "focused": False,
                                    "cwd": "/tmp",
                                }
                            }
                        }
                    ),
                    "",
                )
            }
        )
        self.assertFalse(sidebar.refresh("herdr", "w1:p1", unfocused))
        self.assertFalse(any("report-metadata" in call for call in unfocused.calls))

    def test_resumed_agent_uses_foreground_world_worktree(self):
        pane = {
            "agent": "pi",
            "cwd": "/Users/george/world/trees/root/src/areas/core/shopify",
            "foreground_cwd": "/Users/george/world/trees/po-public-api/src/areas/core/shopify",
        }

        self.assertEqual(
            "/Users/george/world/trees/po-public-api/src/areas/core/shopify",
            sidebar.effective_pane_cwd(pane),
        )

    def test_agent_pane_uses_launch_cwd_instead_of_tool_cwd(self):
        responses = {
            "pane get w1:p1": (
                0,
                json.dumps(
                    {
                        "result": {
                            "pane": {
                                "pane_id": "w1:p1",
                                "workspace_id": "w1",
                                "focused": True,
                                "cwd": "/project/root",
                                "foreground_cwd": "/private/tmp/tool-call",
                                "agent": "pi",
                            }
                        }
                    }
                ),
                "",
            ),
            "git -C /project/root rev-parse --show-toplevel": (1, "", "not git"),
            "workspace report-metadata": (0, "{}", ""),
        }
        runner = FakeRunner(responses)

        self.assertTrue(sidebar.refresh("herdr", "w1:p1", runner))
        self.assertTrue(any("git -C /project/root" in " ".join(call) for call in runner.calls))
        self.assertFalse(any("git -C /private/tmp/tool-call" in " ".join(call) for call in runner.calls))

    def test_refresh_unwraps_herdr_json_and_reports_context(self):
        responses = {
            "pane get w1:p1": (
                0,
                json.dumps(
                    {
                        "result": {
                            "pane": {
                                "pane_id": "w1:p1",
                                "workspace_id": "w1",
                                "tab_id": "w1:t1",
                                "focused": True,
                                "foreground_cwd": "/tmp/project",
                                "agent": "pi",
                                "agent_status": "working",
                            }
                        }
                    }
                ),
                "",
            ),
            "rev-parse --show-toplevel": (1, "", "not git"),
            "tab get w1:t1": (
                0,
                json.dumps({"result": {"tab": {"label": "editor"}}}),
                "",
            ),
            "workspace report-metadata": (0, "{}", ""),
        }
        runner = FakeRunner(responses)

        self.assertTrue(sidebar.refresh("herdr", "w1:p1", runner))
        report = next(call for call in runner.calls if "report-metadata" in call)
        self.assertIn("pane_context=editor · pi:working", report)


if __name__ == "__main__":
    unittest.main()
