# ds-labs-local-setup

General tools and/or setup scripts. This is a very base-level setup.

## Supported OS

✅ MacOS (brew)

*nix would be relatively easy to add support for if desired.

## Usage

I encourage you to view [the script](https://raw.githubusercontent.com/DatasiteLabs/ds-labs-local-setup/HEAD/install.sh) in your browser before executing it.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DatasiteLabs/ds-labs-local-setup/HEAD/install.sh)"
```

> [!NOTE]
> During development of this script you may want to replace HEAD with the branch name to avoid caching/delays in updates. Opening a fresh terminal tab also helps.

### What the install script does

The general idea is the script checks for dependencies and installs or updates. The script is idempotent, so you can run it multiple times. It will check to see if directories exist and skip steps as needed. 

1. Prompts the user to confirm a data directory to install this repository to. This directory can also house your work. If thhe directory does not exist, it will be created.
1. Checks the OS software update for updates and prompts you to install them.
1. Checks for the package manager and installs it if it is not found. It will pause so you can execute any commands instructed by the package manager. Once complete you can type 'cont' to continue.
1. Output the next steps to continue installing from the newly downloaded repository.

> [!NOTE]
> Follow the instructions in the output to continue from within the downloaded repository.

### What the bootstrap script does

The install script will prompt you to run [./bootstrap.sh](./bootstrap.sh) at the end. This script is idempotent and meant to be run whenver you want to update the scripts from the directory the repository is installed. 

The biggest piece of this is the ability to run a 'filter', which is a package name to apply. This allows us to have users contribute a 'package' such as recommended, python, java, kotlin, etc. which are the things engineers using those languages need. 

`-h` will show the help and be the most up to date. It will list all available packages to filter by. If no filters are provided it will run the default 'essential' package.

The essential package is the bare minimum all engineering needs.

Multiple filters can be provided. e.g. `./bootstrap.sh --filter essential --filter recommended`

- For each package the install script is called with that filter applied.
- After that the config.sh for each package is called if provided.

## Background Information

This repo is open source / public and is intended to provide the base machine configuration for Datasite employees. It may provide limited value to others, or serve as an example.

## Structure

```text
.
├── logs # output from scripts
├── packages 
│   ├── <package>
│   │   ├── <package_manager>-casks.txt # list of gui apps to install, installed differently, for brew only
│   │   └── <package_manager>.txt # list of packages to install
│   └── install.sh # main install script, called for all packages
├── template
│   └── config.sh # example config file for package
└── test
    ├── test_helper # common test code
    │   ├── bats-assert # bats library
    │   ├── bats-file # bats library
    │   ├── bats-support # bats library
    │   └── common-setup.bash
    ├── test_<package>_config.bats # test for config script
    └── test_template_config.bats # test example config file for package
```

## Contributing to Existing Packages

Edit the packages `<package_manager>.txt`, `<package_manager>-casks.txt`, or `config.sh` files.

Config files can be tested, update/add tests if changing the config.sh script.

Lookup packages on the package manager's website.

- [Homebrew](https://brew.sh/)

> [!NOTE]
> For Brew, GUI apps are installed differently. When searching the package if it has `--cask` in the name it is a GUI app and should be added to the `brew-cask.txt` file instead of the `brew.txt` file. e.g. `brew install --cask google-chrome`

## Adding a New Package

There is a template script to help get started. It's setup in a way that can be tested.

- The code inside this condition `if [[ ${CI} == false ]]; then` is for running locally and interactively.
- Tests will always set `CI=true` so the code inside that condition will not run.

```bash
package_name=my_new_package
package_manager=brew
mkdir packages/${package_name}
touch packages/${package_name}/${package_manager}.txt
```

Optional steps

```bash
# Only needed if you need to install brew GUI apps
touch packages/${package_name}/brew-cask.txt

# if you need to add configuration use the template
cp template/config.sh packages/${package_name}/config.sh
# there are two spots to replace with your own code. Check out the example and then replace the 
# code between '##### replace with your own code when creating a new script #####' with your own functions.

# Add tests for config.sh. Setup/teardown is already setup. 
cp test/test_template_config.bats test/test_${package_name}_config.bats
sed -i '' "s/template/packages\/${package_name}/g" test/test_${package_name}_config.bats
# There are simple examples to help get started, replace with your own.
``` 

See the [Contributing to Existing Packages](#Contributing-to-Existing-Packages) section for details on the `*.txt` files.

### Template config.sh

#### Header Block

```bash
#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI=${CI:-false}
```

This sets up error handling and debugging and defaults the CI variable to false.

#### Exit Trap

```bash
if [[ ${CI} == false ]]; then
  # shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
  end () { [[ $? = 0 ]] && return; echo "[FAILED] Script failed, check the output."; exit 1; }
  trap end EXIT 
fi
```

The trap catches the exit code that is not 0 and prints a message to the user. Returning non-zero from a function or calling exit with a non-zero exit code will trigger this.

#### Functions

```bash
##### replace with your own code when creating a new script #####
# shellcheck disable=SC2120
say_hello() {
    # ...
}
##### replace with your own code when creating a new script #####
```

Functions are a good way to allow the tests to run safely. Normally these are overkill for a simple script. The test will call just the functions you tell it to.

Remember to replace the block between '##### replace with your own code when creating a new script #####' with your own function definitions. The shellcheck disable=SC2120 is to allow the function to be called without arguments, this is likely not needed for your function and can also be removed.

#### End Block

```bash
if [[ ${CI} == false ]]; then
  ##### replace with your own code when creating a new script #####
  say_hello
  ##### replace with your own code when creating a new script #####

  echo ''
  exit 0
fi
```

This will only run without CI and is meant to be interactive. Call whatever functions you define to have them executed.

Remember to replace the block between '##### replace with your own code when creating a new script #####' with your own function calls.

## Adding a New Package Manager

There are a couple of places to look at adding support.

[./packages/install.sh](./packages/install.sh) specically the part the mentions ` case "$OSTYPE" in`.

Adding a new txt file in the package for that package manager is also required. Casks is a concept only required for brew.

Optionally if you have additional config steps that differ check the package config.sh. Most *nix systems operate very similar and we should be able to keep it agnostic.

## Updating and Testing

### Testing Manually

> [!WARNING]
> Testing locally manually or with bats is at your own risk. This is intended to be a machine setup and mistakes might be a bit destructive while developing. Bats will use /tmp and create a directory for testing. Other steps may affect machine level items.

I recommend something like [UTM](https://mac.getutm.app/) with a separate image to test MacOS or a Docker image for linux to run the tests locally without modifying your local machine.

I will likely add a Docker test image when linux support is added.

> [!TIP]
>Once confident on the changes it might be ideal to run locally to ensure the scripts are idempotent and work as expected.

### CI

A non-destructive way to run tests.

GitHub actions will run the tests in the `test` directory.

- Shellcheck (https://github.com/koalaman/shellcheck)
- bats (https://github.com/bats-core/bats-core)

### Testing with bats

Uses bats. Use the local tag to only run safe local tests. You can run all or other tags if you are confident they are safe for your machine. See [Testing Manually](#testing-manually) for more info on safer ways to test machine level changes.

To run bats you will need to get the submodules.

```bash
git submodule init
git submodule update
```

```bash
bats --filter-tags "local" test 
```

Debugging with print should write to handle 3. e.g. `ls -la "${install_dir}/new-dir/ds-labs-local-setup" >&3`
