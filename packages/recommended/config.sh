#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI=${CI:-false}

if [[ ${CI} == false ]]; then
  # shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
  end () { [[ $? = 0 ]] && return; echo "[FAILED] Script failed, check the output."; exit 1; }
  trap end EXIT 
fi

1password_config() {
    echo "[CONFIG] Configuring 1Password CLI."
    echo "[INSTRUCTION] Visit https://developer.1password.com/docs/cli/get-started/#step-2-turn-on-the-1password-desktop-app-integration to finish configuring the 1Password CLI."
    echo "[INSTRUCTION] Visit https://1password.com/downloads/browser-extension in your browser of choice to install the 1Password browser extention."
    read -r -p "Press enter to continue..."
}

if [[ ${CI} == false ]]; then
  1password_config

  echo ''
  exit 0
fi