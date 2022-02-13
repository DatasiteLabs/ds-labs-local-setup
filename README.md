# ds-labs-local-setup

General tools and/or setup scripts

## Getting Started

This repo is open source / public and is intended to provide the setup scripts that don't need authentication to get
started.

If you have a brand new machine, this script will install pip and setup ansible and clone this repo. From that point on the repo/ansible will control your setup.

I encourage you to view [the script](https://raw.githubusercontent.com/DatasiteLabs/ds-labs-local-setup/main/install.sh) in your browser before executing.

```bash
mkdir ~/data # can be any dir you want, in your user directory (~)
cd ~/data # cd into that dir, run code here, the scripts will walk you through
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DatasiteLabs/ds-labs-local-setup/HEAD/install.sh)"
```

## Running ansbile locally

```bash
python3 -m pip install --user -r requirements.txt
```
