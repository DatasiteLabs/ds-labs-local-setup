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

update_shells() {
  if command -v brew > /dev/null; then
    BREW_PREFIX=$(brew --prefix)
    # adding shells
    if ! grep -F --quiet "${BREW_PREFIX}/bin/bash" /etc/shells; then
      echo "[CONFIG] Adding bash to shells"
      echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
    fi

    # add zsh and Switch to using brew-installed zsh as default shell
    if ! grep -F --quiet "${BREW_PREFIX}/bin/zsh" /etc/shells; then
      echo "[CONFIG] Adding zsh to shells and setting as default shell."
      echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
      # default shell in mac is zsh
      chsh -s "${BREW_PREFIX}/bin/zsh"
    fi
  fi
}

if [[ ${CI} == false ]]; then
  update_shells

  echo ''
  exit 0
fi