#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

__dir="$(pwd)"
# log_file="${__dir}/install.log"

# echo date >"${log_file}"

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

# read -r -p "enable script editor and terminal: https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/AutomatetheUserInterface.html. press [enter] to continue after complete"
# echo ""
# # Close any open System Preferences panes, to prevent them from overriding
# # settings we’re about to change
# osascript -e 'tell application "System Preferences" to quit'

# # run a script to allow terminal to control apps
# sleep 2
# osascript <<EOD
#   tell application "System Events"
#       activate
#       display dialog "This should allow scripts to execute after you allow access."
#   end tell
# EOD

# echo "Follow the prompts to install xcode command line tools."

# if [[ $(uname -s) == "Darwin" ]]; then
#   if ! xcode-select -v; then
#     sleep 2
#     xcode-select --install
#     read -r -p "Wait for the xcode installer to complete. Press [enter] to continue."
#     if ! xcode-select -v; then
#       echo "xcode-select tools did not complete."
#       exit 1
#     fi
#   fi

# ensure pip is available
# python3 -m ensurepip --default-pip
# python3 -m pip install --user --upgrade pip setuptools wheel venv
# # upgrade pip3
# python3 -m pip install --upgrade pip setuptools wheel

#   # # deps for ansible
# python3 -m pip install --user passlib
# python3 -m pip install --user pexpect

export DATASITE_HOME=${__dir}
ANSIBLE_PATH="$(python3 -m site --user-base)/bin"
git clone https://github.com/DatasiteLabs/ds-labs-local-setup.git
cd "${DATASITE_HOME}/ds-labs-local-setup"
"${ANSIBLE_PATH}/ansible-galaxy" install -r requirements.yml
"${ANSIBLE_PATH}/ansible-playbook" -i "localhost," -c local local.yml -vvv
# ansible-pull --url https://github.com/DatasiteLabs/ds-labs-local-setup.git --connection local -i 127.0.0.1 --directory "${DATASITE_HOME}/ds-labs-local-setup" -vvv local.yml

exec -l "$SHELL"

#  if test ! "$(command -v brew)"; then
#    # python3 requires xcode select tools which is easiest installed with brew.
#    echo "[INSTALL]: homebrew"
#    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" | tee -a
#    "${log_file}"
#  fi

echo ''
exit 0
