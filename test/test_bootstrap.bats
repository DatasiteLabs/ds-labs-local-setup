#!/usr/bin/env bats
declare PROJECT_ROOT

setup() {
    load 'test_helper/common-setup'
    _common_setup
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/bootstrap.sh"

    # prevent overwrite local logs
    export log_file="${PROJECT_ROOT}/test/test_helper/install.log"
    export brew_caveats_log="${PROJECT_ROOT}/test/test_helper/brew_caveats.log"

    if [[ -f "${brew_caveats_log}" ]]; then
      rm "${brew_caveats_log}"
    fi
    touch "${log_file}"
    
    brew() {
      # shellcheck disable=SC2317
      echo "brew $*"
    }
    export -f brew
    declare -a filters
}

teardown() {
    _common_teardown
    
    unset filters
}

# bats test_tags=local,ci
@test "filter_opts should show help with -h" { 
  run  filter_opts -h

  assert_output --partial "usage: [DEBUG=true] ${0} [-h|--help] [--filter package]"
  assert_success
}

# bats test_tags=local,ci
@test "filter_opts should show help with --help" { 
  run filter_opts --help

  assert_output --partial "usage: [DEBUG=true] ${0} [-h|--help] [--filter package]"
  assert_success
}

# bats test_tags=local,ci
@test "filter_opts should show help and error with unknown option" { 
  run filter_opts --yo

  assert_output --partial "usage: [DEBUG=true] ${0} [-h|--help] [--filter package]"
  assert_failure
}

# # bats test_tags=local,ci
# @test "filter_opts should require a filters variable" { 
#   run filter_opts

#   assert_output --partial "[ERROR] the first argument is required to be an array to store filters"
#   assert_failure
# }

# bats test_tags=local,ci
@test "filter_opts should handle no filters" { 
  # shellcheck disable=SC2030
  filters=()
  filter_opts

  assert [ ${#filters[@]} -eq 0 ]
}

# bats test_tags=local,ci
@test "filter_opts should handle single filter" { 
  filter_opts --filter essential

  assert [ "${filters[*]}" = 'essential' ]
}

# bats test_tags=local,ci
@test "filter_opts should handle multiple filters" { 
  filter_opts --filter essential --filter recommended

  assert [ "${filters[*]}" = 'essential recommended' ]
}

# bats test_tags=local,ci
@test "filter_opts should handle invalid filters" { 
  filter_opts  --filter essential --filter yo

  assert [ "${filters[*]}" = 'essential' ]
}

# bats test_tags=local,ci
@test "main should handle no filters" { 
  # shellcheck disable=SC2317
  find() {
    echo "find $*"
  }

  filters=()

  run main

  assert_output --partial "[CONFIG] Configuring macOS"
  assert_output --partial "[RUN] filter=essential"
  assert_output --partial "find ${PROJECT_ROOT}/packages/essential -type file -name config.sh -exec bash {} ;"
  assert_output --partial "[INSTRUCTION] To run additional filters, run the script again with --filter <package>. Use -h for a list of available packages to filter on."
  assert_output --partial "[INSTRUCTION] Check the output above or in ${brew_caveats_log} for any additional steps you can complete. The full log is at ${log_file}"
  assert_success
}

# bats test_tags=local,ci
@test "main should handle filters with esential" { 
  # shellcheck disable=SC2317
  find() {
    echo "find $*"
  }
  filters=('recommended' 'essential')

  run main

  assert_output --partial "[CONFIG] Configuring macOS"
  assert_output --partial "[RUN] filter=essential"
  assert_output --partial "[RUN] additional filters=(recommended)"
  assert_output --partial "[RUN] filter=recommended"
  assert_output --partial "find ${PROJECT_ROOT}/packages/essential -type file -name config.sh -exec bash {} ;"
  assert_output --partial "find ${PROJECT_ROOT}/packages/recommended -type file -name config.sh -exec bash {} ;"
  assert_output --partial "[INSTRUCTION] Check the output above or in ${brew_caveats_log} for any additional steps you can complete. The full log is at ${log_file}"
  assert_success
}

# bats test_tags=local,ci
@test "main should handle filters without esential" { 
  # shellcheck disable=SC2317
  find() {
    echo "find $*"
  }
  filters=('recommended')

  run main

  assert_output --partial "[CONFIG] Configuring macOS"
  refute_output --partial "[RUN] filter=essential"
  assert_output --partial "[RUN] additional filters=(recommended)"
  assert_output --partial "[RUN] filter=recommended"
  assert_output --partial "find ${PROJECT_ROOT}/packages/recommended -type file -name config.sh -exec bash {} ;"
  assert_output --partial "[INSTRUCTION] Check the output above or in ${brew_caveats_log} for any additional steps you can complete. The full log is at ${log_file}"
  assert_success
}

# bats test_tags=local,ci
@test "main should extract caveats to logfile" { 
  export log_file="${PROJECT_ROOT}/test/test_helper/sample_install.log"

  brew() {
    echo "brew $*"
  }

  filters=()

  run main

  assert_output --partial "[CONFIG] Configuring macOS"
  assert_output --partial "[RUN] filter=essential"
  assert_output --partial "[INSTRUCTION] To run additional filters, run the script again with --filter <package>. Use -h for a list of available packages to filter on."
  assert_output --partial "[INSTRUCTION] Check the output above or in ${brew_caveats_log} for any additional steps you can complete. The full log is at ${log_file}"
  assert_success
  
  assert grep -q "Add the following line to your ~/.bash_profile" "${brew_caveats_log}"
}