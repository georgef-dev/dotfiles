                     __ 
                     / _|
                __ _| |_ 
               / _` |  _|
              | (_| | |  
               \__, |_|  
                __/ |    
               |___/    

# Steup

Run `install`

The sequence of steps executed by either script is:

1. Run Dotbot's `install` wrapper that reads `install.conf.yaml` and not only installs Dotbot but also creates the base structure of directories and sym links for configuration files.
2. Once Dotbot is done, the script will execute an additional `brew bundle` using either `Brewfile.mas.work` or `Brewfile.mas.personal` depending on the trigger script. This step installs Mac App Store specific apps. 

# Setup Github SSH Key

```bash
# SEE: https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
# SEE: https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account
```

# Install GPG and Keybase keys

```bash
keybase login
chmod 700 ~/.gnupg
keybase pgp list
keybase pgp export -q <ID_FROM_ABOVE> | gpg --import
keybase pgp export -q <ID_FROM_ABOVE> --secret | gpg --allow-secret-key-import --import
```
# Install App Store Apps

```bash
brew bundle --file Brewfile.mas.<work||personal>
```