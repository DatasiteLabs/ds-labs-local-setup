#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

__dir="$(pwd)"

if ! pwd | grep -q "${HOME}"; then
  echo "Scripts must be run from within your ${HOME} directory"
fi

echo ""
read -r -p "Running in ${__dir}, this will be your DATASITE_HOME. Press [enter] to continue."
echo ""

if test ! "$(command -v brew)"; then
  # install brew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo ""

  if test ! "$(command -v brew)"; then
    read -r -p "Check the output of brew to make sure it was successful. Follow suggestions on adding to path and reload your terminal than re-run this script if it exits. Press [enter] to continue."
  fi

  echo ""
  brew doctor
  echo ""
  read -r -p "Check the output of the 'brew doctor' command above. Fix any issues and re-run 'brew doctor'. Press [enter] to continue if there were no issues."
  echo ""
else
  echo "SKIP brew already installed."
  echo "UPDATE updating brew"
  brew upgrade
  brew cleanup
fi

brew --version

# get latest python3 and manage with brew
brew install python
# update default tools
python3 -m pip install --upgrade pip setuptools wheel

if test ! "$(command -v ansible)"; then
  #   brew install ansible
  # recommended ansible install for mac: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#from-pip3
  python3 -m pip install --user ansible
else
  echo "SKIP ansible already installed."
  echo "UPDATE updating ansible"
  python3 -m pip install --user --upgrade ansible
#   brew upgrade ansible
fi

# # validation
# ansible --version

# validate installs
if ! xcode-select -p; then
  echo "xcode-select tools did not complete."
  exit 1
else
  echo "xcode-select tools installed."
fi

# ensure pip is available
# python3 -m ensurepip --default-pip
# python3 -m pip install --user --upgrade pip setuptools wheel venv
# # upgrade pip3
# python3 -m pip install --upgrade pip setuptools wheel

#   # # deps for ansible
# python3 -m pip install --user passlib
# python3 -m pip install --user pexpect

export SDKMAN_DIR="${HOME}/.sdkman"
# shellcheck disable=SC1091
[[ -s "${HOME}/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"
if test ! "$(command -v sdk)"; then
  curl -s "https://get.sdkman.io" | bash
  read -r -p "Check the output of sdkman to make sure it was successful. Follow suggestions than reload the terminal and re-run script to continue. Press [enter] to continue."
else
  echo "SKIP sdkman already installed."
  echo "UPDATE updating sdkman"
  sdk selfupdate
  sdk update
fi

export DATASITE_HOME=${__dir}
ANSIBLE_PATH="$(python3 -m site --user-base)/bin"
if [[ ! -d "${DATASITE_HOME}/ds-labs-local-setup" ]]; then
  git clone https://github.com/DatasiteLabs/ds-labs-local-setup.git
fi

cd "${DATASITE_HOME}/ds-labs-local-setup"
"${ANSIBLE_PATH}/ansible-galaxy" install -r requirements.yml
"${ANSIBLE_PATH}/ansible-playbook" -i "localhost," -c local local.yml -vvv --ask-become-pass
# ansible-pull --url https://github.com/DatasiteLabs/ds-labs-local-setup.git --connection local -i 127.0.0.1 --directory "${DATASITE_HOME}/ds-labs-local-setup" -vvv local.yml

exec -l "$SHELL"

echo ''
exit 0
