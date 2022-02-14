#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

__dir="$(pwd)"
log_file="${__dir}/install.log"

echo date >"${log_file}"

if ! pwd | grep -q "${HOME}"; then
  echo "Scripts must be run from within your ${HOME} directory"
fi

echo ""
read -r -p "Running in ${__dir}, this will be your DATASITE_HOME. Press [enter] to continue."
echo ""
read -r -p "enable script editor and terminal: https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/AutomatetheUserInterface.html. press [enter] to continue after complete"
echo ""
# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# run a script to allow terminal to control apps
sleep 2
osascript <<EOD
  tell application "System Events"
      activate
      display dialog "This should allow scripts to execute after you allow access."
  end tell
EOD

echo "Follow the prompts to install xcode command line tools."

if [[ $(uname -s) == "Darwin" ]]; then
  if ! xcode-select -v; then
    sleep 2
    xcode-select --install
    read -r -p "Wait for the xcode installer to complete. Press [enter] to continue."
    if ! xcode-select -v; then
      echo "xcode-select tools did not complete."
      exit 1
    fi
  fi

  # ensure pip is available
  python3 -m ensurepip --default-pip

  # upgrade pip3
  python3 -m pip install --upgrade pip setuptools wheel

  # recommended ansible install for mac: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#from-pip3
  python3 -m pip install --user ansible | tee -a "${log_file}"

  # # deps for ansible
  python3 -m pip install --user passlib | tee -a "${log_file}"
  python3 -m pip install --user pexpect | tee -a "${log_file}"

  DATASITE_HOME=${__dir} "$(python3 -m site --user-base)"/bin/ansible-pull --url https://github.com/DatasiteLabs/ds-labs-local-setup -i hosts

  exec -l "$SHELL"

#  if test ! "$(command -v brew)"; then
#    # python3 requires xcode select tools which is easiest installed with brew.
#    echo "[INSTALL]: homebrew" | tee -a "${log_file}"
#    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" | tee -a
#    "${log_file}"
#  fi

else
  echo "Your machine is not supported yet for this script. See https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems for details and update to add support." | tee -a "${log_file}"
fi

echo ''
exit 0
