import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location(
    'herdr_workspace', Path(__file__).resolve().parents[1] / 'herdr/workspace/open.py')
launcher = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(launcher)


class WorkspaceLauncherTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='project with spaces ')
        self.addCleanup(self.directory.cleanup)
        self.cwd = str(Path(self.directory.name).resolve())
        self.environment = patch.dict(os.environ, HERDR_ENV='1', HERDR_ACTIVE_PANE_CWD=self.cwd)
        self.environment.start()
        self.addCleanup(self.environment.stop)
        self.calls = []

    def fake_herdr(self, *args):
        self.calls.append(args)
        if args[:2] == ('workspace', 'create'):
            return {'workspace': {'workspace_id': 'new-space'},
                    'tab': {'tab_id': 'new-tab'}, 'root_pane': {'pane_id': 'new-editor'}}
        if args[:2] == ('pane', 'split'):
            return {'pane': {'pane_id': 'new-shell'}}
        if args[:2] == ('pane', 'get'):
            return {'pane': {'revision': 1}}
        return {}

    def run_launcher(self, response='Personal workspace', api=None):
        with patch('builtins.input', return_value=response), \
                patch.object(launcher, 'herdr', side_effect=api or self.fake_herdr), \
                contextlib.redirect_stderr(io.StringIO()):
            return launcher.main()

    def test_layout_uses_only_new_ids_and_preserves_cwd(self):
        self.assertEqual(self.run_launcher(), 0)
        self.assertEqual(self.calls[0], ('workspace', 'create', '--cwd', self.cwd,
                                        '--label', 'Personal workspace', '--no-focus'))
        splits = [call for call in self.calls if call[:2] == ('pane', 'split')]
        self.assertEqual(splits, [
            ('pane', 'split', '--pane', 'new-editor', '--direction', 'right',
             '--ratio', '0.6', '--cwd', self.cwd, '--no-focus'),
            ('pane', 'split', '--pane', 'new-shell', '--direction', 'down',
             '--ratio', '0.7', '--cwd', self.cwd, '--no-focus'),
        ])
        self.assertIn(('pane', 'run', 'new-editor', 'nvim'), self.calls)
        self.assertEqual(self.calls[-1], ('workspace', 'focus', 'new-space'))
        self.assertNotIn(('workspace', 'close', 'new-space'), self.calls)

    def test_silent_cli_success_does_not_remove_completed_workspace(self):
        def cli_response(argv, **kwargs):
            args = tuple(argv[1:])
            result = self.fake_herdr(*args)
            silent = args[:2] in (('pane', 'run'), ('workspace', 'focus'))
            stdout = '' if silent else json.dumps({'result': result})
            return subprocess.CompletedProcess(argv, 0, stdout=stdout)

        with patch('builtins.input', return_value='Personal workspace'), \
                patch.object(launcher.subprocess, 'run', side_effect=cli_response):
            self.assertEqual(launcher.main(), 0)
        self.assertIn(('pane', 'run', 'new-editor', 'nvim'), self.calls)
        self.assertEqual(self.calls[-1], ('workspace', 'focus', 'new-space'))
        self.assertNotIn(('workspace', 'close', 'new-space'), self.calls)

    def test_empty_name_uses_directory_name(self):
        self.assertEqual(self.run_launcher(''), 0)
        self.assertIn(Path(self.cwd).name, self.calls[0])

    def test_cancel_before_creation_changes_nothing(self):
        with patch('builtins.input', side_effect=EOFError), patch.object(launcher, 'herdr') as api:
            self.assertEqual(launcher.main(), 0)
            api.assert_not_called()

    def test_outside_herdr_changes_nothing(self):
        with patch.dict(os.environ, HERDR_ENV=''), patch.object(launcher, 'herdr') as api, \
                contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(launcher.main(), 1)
            api.assert_not_called()

    def test_failure_closes_only_created_workspace(self):
        def fail_split(*args):
            if args[:2] == ('pane', 'split'):
                raise subprocess.CalledProcessError(1, 'herdr', stderr='split failed')
            return self.fake_herdr(*args)
        self.assertEqual(self.run_launcher(api=fail_split), 1)
        self.assertEqual(self.calls[-1], ('workspace', 'close', 'new-space'))
        self.assertFalse(any(call[:2] == ('workspace', 'focus') for call in self.calls))

    def test_shell_timeout_does_not_start_editor(self):
        with patch.object(launcher.time, 'monotonic', side_effect=[0, 9]):
            self.assertEqual(self.run_launcher(), 1)
        self.assertEqual(self.calls[-1], ('workspace', 'close', 'new-space'))
        self.assertFalse(any(call[:2] == ('pane', 'run') for call in self.calls))

    def test_cli_arguments_are_passed_without_shell_interpolation(self):
        with patch.object(launcher.subprocess, 'run', return_value=subprocess.CompletedProcess(
                [], 0, stdout='{"result": {}}')) as command:
            launcher.herdr('workspace', 'create', '--cwd', '/tmp/project; touch unexpected')
        self.assertEqual(command.call_args.args[0][-1], '/tmp/project; touch unexpected')
        self.assertNotIn('shell', command.call_args.kwargs)


if __name__ == '__main__':
    unittest.main()
