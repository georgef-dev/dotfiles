#!/usr/bin/env python3
"""Create a named workspace with Neovim left and two shells right."""
import json
import os
from pathlib import Path
import subprocess
import sys
import time


def herdr(*args):
    result = subprocess.run(
        [os.environ.get('HERDR_BIN_PATH') or 'herdr', *args],
        check=True, capture_output=True, text=True,
    )
    return json.loads(result.stdout)['result']


def wait_for_shell(pane_id):
    deadline = time.monotonic() + 8
    while time.monotonic() < deadline:
        pane = herdr('pane', 'get', pane_id)['pane']
        # Matches the readiness check used by the existing Herdr test strategy.
        if pane.get('revision', 0) > 0 or pane.get('terminal_title'):
            return
        time.sleep(0.1)
    raise TimeoutError('The new editor shell did not become ready.')


def main():
    if os.environ.get('HERDR_ENV') != '1':
        print('Open this launcher from a Herdr pane.', file=sys.stderr)
        return 1
    workspace_id = None
    completed = False
    try:
        cwd = Path(os.environ.get('HERDR_ACTIVE_PANE_CWD') or Path.cwd()).resolve(strict=True)
        if not cwd.is_dir():
            raise ValueError('The invoking pane directory is not a directory.')
        default_name = cwd.name or 'workspace'
        name = input(f'Workspace name [{default_name}]: ').strip() or default_name
        created = herdr('workspace', 'create', '--cwd', str(cwd), '--label', name, '--no-focus')
        workspace_id = created['workspace']['workspace_id']
        editor = created['root_pane']['pane_id']
        herdr('tab', 'rename', created['tab']['tab_id'], 'work')
        right = herdr('pane', 'split', '--pane', editor, '--direction', 'right',
                      '--ratio', '0.6', '--cwd', str(cwd), '--no-focus')['pane']['pane_id']
        herdr('pane', 'split', '--pane', right, '--direction', 'down',
              '--ratio', '0.7', '--cwd', str(cwd), '--no-focus')
        wait_for_shell(editor)
        herdr('pane', 'run', editor, 'nvim')
        herdr('workspace', 'focus', workspace_id)
        completed = True
        return 0
    except EOFError:
        return 0
    except KeyboardInterrupt:
        return 130
    except (subprocess.CalledProcessError, OSError, ValueError, KeyError, TimeoutError) as error:
        detail = error.stderr if isinstance(error, subprocess.CalledProcessError) else str(error)
        print(f'Workspace setup failed: {detail}', file=sys.stderr)
        return 1
    finally:
        if workspace_id and not completed:
            try:
                herdr('workspace', 'close', workspace_id)
            except (subprocess.CalledProcessError, OSError, ValueError, KeyError):
                print(f'New workspace {workspace_id} remains open; close it manually.', file=sys.stderr)


if __name__ == '__main__':
    sys.exit(main())
