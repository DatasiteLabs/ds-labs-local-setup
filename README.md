# ds-labs-local-setup

General tools and/or setup scripts. This is a very base-level setup.

## Supported OS

✅ MacOS (brew)

*nix would be relatively easy to add support for if desired.

## Installing

I encourage you to view [the script](https://raw.githubusercontent.com/DatasiteLabs/ds-labs-local-setup/HEAD/install.sh) in your browser before executing it.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DatasiteLabs/ds-labs-local-setup/HEAD/install.sh)"
```

**NOTE**: during development of this script you may want to replace HEAD with the branch name to avoid caching/delays in updates. Opening a fresh terminal tab also helps.

### What the install script does

The general idea is the script checks for dependencies and installs or updates. The scripts is idempotent, so you can run it multiple times. It will check to see if directories exist and skip steps as needed. 

1. Prompts the user to confirm a data directory to install this repository to. This directory can also house your work. If thhe directory does not exist, it will be created.
1. Checks the OS software update for updates and prompts you to install them.
1. Checks for the package manager and installs it if it is not found. It will pause so you can execute any commands instructed by the package manager. Once complete you can type 'cont' to continue.
1. Output the next steps to continue installing from the newly downloaded repository.

## Background Information

This repo is open source / public and is intended to provide the base machine configuration for Datasite employees. It may provide limited value to others, or serve as an example.

## Running Locally

> [!WARNING]
> Testing locally manually or with bats is at your own risk. This is intended to be a machine setup and mistakes might be a bit destructive while developing. Bats will use /tmp and create a directory for testing. Other steps may affect machine level items.

I recommend something like [UTM](https://mac.getutm.app/) with a separate image to test MacOS or a Docker image for linux to run the tests locally without modifying your local machine.

I will likely add a Docker test image when linux support is added.

> [!TIP]
>Once confident on the changes it might be ideal to run locally to ensure the scripts are idempotent and work as expected.

To run bats you will need to get the submodules.

```bash
git submodule init
git submodule update
```

## CI

A non-destructive way to run tests.

GitHub actions will run the tests in the `test` directory.

- Shellcheck (https://github.com/koalaman/shellcheck)
- bats (https://github.com/bats-core/bats-core)

