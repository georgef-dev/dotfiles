                     __
                     / _|
                __ _| |_
               / _` |  _|
              | (_| | |
               \__, |_|
                __/ |
               |___/

# Steup

Run `scripts/bootStrap`
Follow on-screen instructions to have `brew` added to `$PATH`

Run `install`

# iTerm

- Import preferences from local folder
- Import profile JSON

# nvim

Open nvim and run: `:PlugInstall`

# Python

Install needed Python versions using `pyenv`.

- 3.10.0 -> `pyenv install 3.10.0`

# Setup Github SSH Key

```bash
# SEE: https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
# SEE: https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account
```

# Install GPG and Keybase keys

```bash
# SEE: https://github.com/pstadler/keybase-gpg-github
# SEE: https://stackoverflow.com/questions/39494631/gpg-failed-to-sign-the-data-fatal-failed-to-write-commit-object-git-2-10-0
```

```bash
keybase login
chmod 700 ~/.gnupg
keybase pgp list
keybase pgp export -q <ID_FROM_ABOVE> | gpg --import
keybase pgp export -q <ID_FROM_ABOVE> --secret | gpg --allow-secret-key-import --import
```
