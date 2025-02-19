#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI=${CI:-false}
declare filter=${1:-essential}

if [[ ${CI} == false ]]; then
  # shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
  end () { [[ $? = 0 ]] && return; echo "[FAILED] Script failed, check the output."; exit 1; }
  trap end EXIT 
fi

update_brew() {
  echo "[UPDATE] Updating homebrew."
  brew update

  read -r -p "Would you like to upgrade homebrew packages? [y/n]"
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "[UPDATE] Updating homebrew packages."
    brew upgrade
  fi
  echo
}

install_brew_packages() {
  echo "[INSTALL] Installing homebrew packages."
  
  mapfile -t formulas < <(grep '^- ' "${__dir}/${filter}/brew.txt" | sed 's/^- //;s/[[:space:]]*$//')

  for formula in "${formulas[@]}"; do
    if ! brew list --formula --versions "${formula}"; then
      brew install "${formula}" 
    fi
  done
  echo
}

install_brew_casks() {
  declare -a skipped_casks=()
  echo "[INSTALL] Installing homebrew casks."

  mapfile -t casks < <(grep '^- ' "${__dir}/${filter}/brew-casks.txt" | sed 's/^- //;s/[[:space:]]*$//')

  for cask in "${casks[@]}"; do
    if ! brew list --cask --versions "${cask}"; then
      output=$(brew install --cask "${cask}" 2>&1 || true)
      echo "${output}"
      if [[ "${output}" == *"already an App at"* ]]; then
        skipped_casks+=("${cask}")
      fi
    fi
  done

  if (( ${#skipped_casks[@]} > 0 )); then
    echo -e "\n\t[SKIP] The following list of applications are already installed outside of brew. Remove the application and re-run to install with brew.\n"
    for cask in "${skipped_casks[@]}"; do
      echo -e "\t• ${cask}"
    done
  fi
  echo
}

if [[ ${CI} == false ]]; then
  case "$OSTYPE" in
      "darwin"*)
        update_brew 
        install_brew_packages
        install_brew_casks
      ;;
      # "linux"*)
      #     TODO: add linux support likely apt or apt-get, yum for some.
      # ;;
      *)
          printf '%s\n' "[ERROR] Unsupported OS detected, aborting..." >&2
          return 1
      ;;
  esac

  echo "[SUCCESS] ${filter} packages installed."
  echo ''
  exit 0
fi