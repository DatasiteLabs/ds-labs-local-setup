# ds-labs-local-setup

General tools and/or setup scripts. This is a very base level setup.

## Installing

I encourage you to view [the script](https://raw.githubusercontent.com/DatasiteLabs/ds-labs-local-setup/HEAD/install.sh) in your browser before executing.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DatasiteLabs/ds-labs-local-setup/HEAD/install.sh)"
```

**NOTE**: during development of this script you may want to replace HEAD with the branch name to avoid caching/delays in updates. Opening a fresh terminal tab also helps.

### What the install script does

The general idea is the script checks for dependencies and installs or updates.

1. Installs brew (now includes xcode select tools)
1. Installs ansible with brew
    - This ensures the python version and ansible play nice together
1. Verifies xcode-select was successful
1. Has the user setup a "DATASITE_HOME", a directory where all data can live
1. Sets up ansible playbook dependencies and executes the local ansible script
1. Finally force reload the shell

## Background Information

This repo is open source / public and is intended to provide the setup scripts that don't need authentication to get
started. This is primarily the base setup to allow Datasite employees to execute other setups. It may provide limited value to others, or serve as an example.

Installing brew and xcode tools have been the trickiest part of our machine setups with OS changes and hardware changes. If you get a machine with brew and xcode tools already setup it's significantly easier and faster. The script will check for installs and do updates if already installed.

### Pre-Requisites

1. Allow permissions for automation

    Due to apple script security model you will need to enable/allow scripting before running. [Full Details](https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/AutomatetheUserInterface.html)

    1. Launch System Preferences and click Security & Privacy.
    1. Click the Privacy tab.
    1. Click Accessibility.
    1. Click the Add button (+).
    1. Choose an app (`/Applications/Utilities/Terminal`) and click Open.

      ![Script Editor Permissions Screen](./image/script-editor-permissions.jpg)

    1. Select the checkbox to the left of the app.
    1. Quit the System Preferences application (`command + q`)

1. Configure a data home directory. Co-locating things makes relative path-ing easier.

    a. Launch a terminal and run the following to use `~/data` as your home for our scripts and code

      ```bash
      mkdir ~/data # can be any dir you want, in your user directory (~)
      cd ~/data # cd into that dir, run code here, the scripts will walk you through
      ```

### Run the Script

  During the script there are a few prompts to setup privileges, follow the instructions. If you see a dialog like the following click 'OK', you may have to re-run the script.

  ![Script Editor Permissions](./image/security-approval-window.jpg)

## Running Ansible locally

  ```bash
  python3 -m pip install --user -r requirements.txt
  "$(python3 -m site --user-base)"/bin/pre-commit install 
  ```
