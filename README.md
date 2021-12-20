                     __ 
                     / _|
                __ _| |_ 
               / _` |  _|
              | (_| | |  
               \__, |_|  
                __/ |    
               |___/    

# Home

Storing my public config files

# First time

Run either `install.work` or `install.personal`, sit back and wait.

The sequence of steps executed by either script is:

1. Run Dotbot's `install` wrapper that reads `install.conf.yml` and not only installs Dotbot but also creates the base structure of directories and sym links for configuration files.
2. Once Dotbot is done, the script will execute an additional `brew bundle` using either `Brewfile.mas.work` or `Brewfile.mas.personal` depending on the trigger script. This step installs Mac App Store specific apps. 
