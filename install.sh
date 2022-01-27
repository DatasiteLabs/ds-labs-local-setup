#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

__dir="$(pwd)"
log_file="${__dir}/install.log"

echo date > "${log_file}"

if ! pwd | grep -q "${HOME}"; then
  echo "Scripts must be run from within your ${HOME} directory"
fi

read -r -p "Running in ${__dir}, this will be your DATASITE_HOME. Press [enter] to continue."

if [[ $(uname -s) == "Darwin" ]]; then
  if ! xcode-select -p; then
    xcode-select --install
    sleep 1
    osascript <<EOD
      tell application "System Events"
        tell process "Install Command Line Developer Tools"
          keystroke return
          click button "Agree" of window "License Agreement"
        end tell
      end tell
EOD
    read -r -p "Wait for the xcode installer to complete. Press [enter] to continue."
    if ! xcode-select -p; then
      echo "xcode-select tools did not complete."
      exit 1
    fi
  fi
  
  if ! which pip3; then
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py | tee -a "${log_file}"
    python3 get-pip.py --user | tee -a "${log_file}"
  fi
  
  # upgrade pip3
  python3 -m pip install --upgrade pip
  
  # recommended ansible install for mac: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#from-pip3
  python3 -m pip install --user ansible | tee -a "${log_file}"
  
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
