#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
[[ ${DEBUG:-} == true ]] && set -o xtrace
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CI=${CI:-false}

# global because bash 3 doesn't support local -n and mac defaults to bash 3 
declare -a filters=()

if [[ ${CI} == false ]]; then
  # shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
  end () { [[ $? = 0 ]] && return; echo "[FAILED] Script failed, check the output."; exit 1; }
  trap end EXIT 
fi

usage() {
  cat <<END
usage: [DEBUG=true] ${0} [-h|--help] [--filter package] [--filter other_package] 
--filter package: specify packages to run. Invalid packages will be ignored. Pass one or many filters.

  packages: 
    essential: only bare minimum setup.

    all available packages:
    $(find "${__dir}/packages" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)

DEBUG=true prints each command with a + in front before executing it. Vars are evaluated in the print.

-h|--help: show help
END
}

filter_opts() {
  while getopts ":h-:" opt; do
      case "${opt}" in
          -)
              case "${OPTARG}" in
                  filter)
                    if find "${__dir}/packages" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | grep -q "^${!OPTIND}$"; then
                      filters+=("${!OPTIND}")
                    else
                      echo "[WARN] Removing invalid filter: ${!OPTIND}"
                    fi
                    OPTIND=$(( OPTIND + 1 ))
                    ;;
                  help)
                    usage
                    exit 0
                    ;;
                  *)
                    echo "Invalid option: --${OPTARG}" >&2
                    usage
                    return 1
                    ;;
              esac
              ;;
          h)
              usage
              exit 0
              ;;
          \?)
              echo "Invalid option: -$OPTARG" >&2
              usage
              return 1
              ;;
      esac
  done
}

run_essential() {
  echo "[RUN] filter=essential"
  bash "${__dir}/packages/install.sh"
  find "${__dir}/packages/essential" -type file -name "config.sh" -exec bash {} \;
}

main() {
  echo "[CONFIG] Configuring macOS"
  declare -a filtered=()

  # remove essential from filters if it exists
  if (( ${#filters[@]} > 0 )); then # bash < 4.3
    filtered=("${filters[@]}")
  fi
  filters=()

  if (( ${#filtered[@]} > 0 )); then # bash < 4.3
    for filter in "${filtered[@]}"; do
      if [[ "${filter}" != "essential" ]]; then
        filters+=("${filter}")
      else
        # run essential first and regardless since other things could depend on it
        run_essential
      fi
    done
  fi

  if (( ${#filters[@]} > 0 )); then
    echo "[RUN] additional filters=(${filters[*]})"

    for filter in "${filters[@]}"; do
      echo "[RUN] filter=${filter}"
      bash "${__dir}/packages/install.sh" "${filter}"
      # run configs if they exist
      find "${__dir}/packages/${filter}" -type file -name "config.sh" -exec bash {} \;
    done 
  else
    run_essential
    echo "[INSTRUCTION] To run additional filters, run the script again with --filter <package>. Use -h for a list of available packages to filter on."
  fi

}

if [[ ${CI} == false ]]; then
  filter_opts "$@"

  main

  echo ''
  exit 0
fi