#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_file="${__dir}/install.log"

if [[ $(uname -s) == "Darwin" ]]; then
    # recommended ansible install for mac: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#from-pip
    if !which pip; then
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py | tee -a "${logfile}"
        python get-pip.py --user | tee -a "${logfile}"
    fi

    python -m pip install --user ansible | tee -a "${logfile}"
else
    echo "Your machine is not supported yet for this script. See https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-specific-operating-systems for details and update to add support." | tee -a "${logfile}"
fi

echo ''
exit 0
