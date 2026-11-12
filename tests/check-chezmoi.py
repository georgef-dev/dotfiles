#!/usr/bin/env python3
"""Render every profile and exercise the Omarchy apply without installing packages."""
import hashlib
import io
import json
import os
import shlex
from pathlib import Path
import subprocess
import tempfile
import tomllib
import tarfile

REPO = Path(__file__).resolve().parents[1]


def run(*args, **kwargs):
    return subprocess.run(args, check=True, text=True, capture_output=True, **kwargs)


for profile in ('omarchy', 'personal-mac', 'dev-vm', 'work-mac'):
    with tempfile.TemporaryDirectory(prefix='dotfiles-chezmoi-') as directory:
        root = Path(directory)
        home = root / 'home'
        home.mkdir()
        config = root / 'chezmoi.toml'
        config.write_text(f'''sourceDir = "{REPO}"
[data]
profile = "{profile}"
gitName = "Test User"
gitEmail = "test@example.com"
gitSigningKey = ""
''')
        # Exercise archive deployment without network access or third-party code.
        archive = root / 'navigation.tar.gz'
        with tarfile.open(archive, 'w:gz') as tar:
            manifest = b'id = "vim-herdr-navigation"\n'
            member = tarfile.TarInfo('fixture/herdr-plugin.toml')
            member.size = len(manifest)
            tar.addfile(member, io.BytesIO(manifest))
        override = json.dumps({'herdr_navigation': {
            'url': archive.as_uri(), 'sha256': hashlib.sha256(archive.read_bytes()).hexdigest()}})
        args = ('chezmoi', '--cache', str(root / 'cache'), '--override-data', override, '--config', str(config), '--destination', str(home),
                '--persistent-state', str(root / 'state.boltdb'))
        script = run(*args, 'execute-template', input=(
            REPO / 'chezmoi/run_onchange_before_install-packages.sh.tmpl').read_text()).stdout
        script_path = root / 'install.sh'
        script_path.write_text(script)
        run('shellcheck', str(script_path))
        managed = run(*args, 'managed').stdout
        if profile != 'omarchy':
            assert '.bashrc' not in managed and '.config/git/config' not in managed
            assert '.config/herdr/config.toml' not in managed
            result = subprocess.run(('sh', str(script_path)), capture_output=True, text=True)
            assert result.returncode == 1 and 'not migrated' in result.stderr
        else:
            # Install scripts require the actual target OS. Other platforms only render.
            os_release = Path('/etc/os-release')
            if os_release.exists() and 'ID=omarchy' in os_release.read_text():
                bin_dir = root / 'bin'
                bin_dir.mkdir()
                log = root / 'package-calls'
                plugin_log = root / 'plugin-calls'
                stub = bin_dir / 'omarchy'
                stub.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$PACKAGE_LOG"\n')
                stub.chmod(0o755)
                herdr_stub = bin_dir / 'herdr'
                herdr_stub.write_text('#!/bin/sh\nset -eu\ntest -f "$3/herdr-plugin.toml"\nprintf "%s\\n" "$*" >> "$PLUGIN_LOG"\n')
                herdr_stub.chmod(0o755)
                env = dict(os.environ, PATH=f'{bin_dir}:{os.environ["PATH"]}',
                           PACKAGE_LOG=str(log), PLUGIN_LOG=str(plugin_log))
                run(*args, 'apply', env=env)
                git_config = home / '.config/git/config'
                assert run('git', 'config', '--file', str(git_config), 'user.email').stdout.strip() == 'test@example.com'
                assert run('git', 'config', '--file', str(git_config), 'init.defaultBranch').stdout.strip() == 'main'
                run('bash', '-n', str(home / '.bashrc'))
                run(*args, 'apply', env=env)
                assert len(log.read_text().splitlines()) == 1, 'installer reran on unchanged apply'
                # The always-run directory safety check is intentionally shown as a script.
                drift = run(*args, 'diff', '--exclude', 'scripts', '--no-pager', env=env).stdout
                assert drift == '', drift
                assert len(plugin_log.read_text().splitlines()) == 3, 'plugin setup reran on unchanged apply'
                herdr_dir = home / '.config/herdr'
                settings = tomllib.loads((herdr_dir / 'config.toml').read_text())
                disabled = tomllib.loads((home / '.config/mise/config.toml').read_text())['settings']['disable_tools']
                assert {'gh', 'opencode'} <= set(disabled)
                assert not {'claude', 'codex'} & set(disabled), 'keep the selected Omarchy AI tools enabled'
                assert settings['keys']['prefix'] == 'ctrl+s'
                assert settings['keys']['goto'] == 'prefix+alt+g', 'pane search must not shadow lazygit'
                lazygit_command = next(entry for entry in settings['keys']['command'] if entry['key'] == 'prefix+g')
                assert lazygit_command['type'] == 'popup'
                assert shlex.split(lazygit_command['command']) == [str(REPO / 'herdr/lazygit/open.sh')]
                workspace_command = next(entry['command'] for entry in settings['keys']['command'] if entry['key'] == 'prefix+v')
                assert shlex.split(workspace_command) == ['python3', str(REPO / 'herdr/workspace/open.py')]
                assert settings['experimental']['pane_history'] is False
                assert '/Users/' not in (herdr_dir / 'config.toml').read_text()
                assert not herdr_dir.is_symlink()
                assert (home / '.local/share/dotfiles/herdr/vim-herdr-navigation/herdr-plugin.toml').is_file()
                assert '.config/nvim' not in managed, 'Neovim must remain unmanaged'
                run('herdr', 'config', 'check', env=dict(os.environ, HERDR_CONFIG_PATH=str(herdr_dir / 'config.toml')))
                state = herdr_dir / 'session.json'
                state.write_text('unmanaged-runtime-state')
                run(*args, 'apply', env=env)
                assert state.read_text() == 'unmanaged-runtime-state'
                prompt = run('bash', '--noprofile', '--norc', '-c',
                             'PROMPT_COMMAND=(existing_hook); source "$1"; source "$1"; declare -p PROMPT_COMMAND',
                             'bash', str(home / '.config/dotfiles/bash.sh')).stdout
                assert 'existing_hook' in prompt and prompt.count('_dotfiles_herdr_sidebar_prompt') == 1
                python_stub = bin_dir / 'python3'
                python_stub.write_text('#!/bin/sh\nsleep 0.2\n')
                python_stub.chmod(0o755)
                jobs = run('bash', '--noprofile', '--norc', '-c',
                           'set -m; source "$1"; HERDR_PANE_ID=test; _dotfiles_herdr_sidebar_prompt; jobs -p',
                           'bash', str(home / '.config/dotfiles/bash.sh'), env=env).stdout
                assert jobs == '', 'sidebar refresh must not remain in the interactive job table'
                # A folded directory must fail before modifying its target.
                runtime = root / 'runtime'
                herdr_dir.rename(runtime)
                herdr_dir.symlink_to(runtime, target_is_directory=True)
                result = subprocess.run((*args, 'apply'), env=env, capture_output=True, text=True)
                assert result.returncode != 0 and 'symlink' in result.stderr
                assert state.read_text() == 'unmanaged-runtime-state'
        print(f'{profile}: passed')
