#!/usr/bin/env python3
"""Render every profile and exercise the Omarchy apply without installing packages."""
import os
from pathlib import Path
import subprocess
import tempfile

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
        args = ('chezmoi', '--config', str(config), '--destination', str(home),
                '--persistent-state', str(root / 'state.boltdb'))
        script = run(*args, 'execute-template', input=(
            REPO / 'chezmoi/run_onchange_before_install-packages.sh.tmpl').read_text()).stdout
        script_path = root / 'install.sh'
        script_path.write_text(script)
        run('shellcheck', str(script_path))
        managed = run(*args, 'managed').stdout
        if profile != 'omarchy':
            assert '.bashrc' not in managed and '.config/git/config' not in managed
            result = subprocess.run(('sh', str(script_path)), capture_output=True, text=True)
            assert result.returncode == 1 and 'not migrated' in result.stderr
        else:
            # Install scripts require the actual target OS. Other platforms only render.
            os_release = Path('/etc/os-release')
            if os_release.exists() and 'ID=omarchy' in os_release.read_text():
                bin_dir = root / 'bin'
                bin_dir.mkdir()
                log = root / 'package-calls'
                stub = bin_dir / 'omarchy'
                stub.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$PACKAGE_LOG"\n')
                stub.chmod(0o755)
                env = dict(os.environ, PATH=f'{bin_dir}:{os.environ["PATH"]}', PACKAGE_LOG=str(log))
                run(*args, 'apply', env=env)
                git_config = home / '.config/git/config'
                assert run('git', 'config', '--file', str(git_config), 'user.email').stdout.strip() == 'test@example.com'
                assert run('git', 'config', '--file', str(git_config), 'init.defaultBranch').stdout.strip() == 'main'
                run('bash', '-n', str(home / '.bashrc'))
                run(*args, 'apply', env=env)
                assert len(log.read_text().splitlines()) == 1, 'installer reran on unchanged apply'
                assert run(*args, 'diff', '--no-pager', env=env).stdout == '', 'reapply left drift'
        print(f'{profile}: passed')
