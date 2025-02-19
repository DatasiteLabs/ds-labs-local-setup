#!/usr/bin/env bats
declare PROJECT_ROOT

setup() {
    load 'test_helper/common-setup'
    _common_setup
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/bootstrap.sh"
    
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
  run  filter_opts filters -h

  assert_output --partial "usage: [DEBUG=true] ${0} [-h|--help] [--filter package]"
  assert_success
}

# bats test_tags=local,ci
@test "filter_opts should show help with --help" { 
  run filter_opts filters --help

  assert_output --partial "usage: [DEBUG=true] ${0} [-h|--help] [--filter package]"
  assert_success
}

# bats test_tags=local,ci
@test "filter_opts should show help and error with unknown option" { 
  run filter_opts filters --yo

  assert_output --partial "usage: [DEBUG=true] ${0} [-h|--help] [--filter package]"
  assert_failure
}

# bats test_tags=local,ci
@test "filter_opts should require a filters variable" { 
  run filter_opts

  assert_output --partial "[ERROR] the first argument is required to be an array to store filters"
  assert_failure
}

# bats test_tags=local,ci
@test "filter_opts should handle no filters" { 
  filter_opts filters

  assert [ ${#filters[@]} -eq 0 ]
}

# bats test_tags=local,ci
@test "filter_opts should handle single filter" { 
  filter_opts filters --filter essential

  assert [ "${filters[*]}" = 'essential' ]
}

# bats test_tags=local,ci
@test "filter_opts should handle multiple filters" { 
  filter_opts filters --filter essential --filter recommended

  assert [ "${filters[*]}" = 'essential recommended' ]
}

# bats test_tags=local,ci
@test "filter_opts should handle invalid filters" { 
  filter_opts filters --filter essential --filter yo

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
  refute_output --partial "[RUN] filters="
  assert_output --partial "[RUN] filter=essential"
  assert_output --partial "find ${PROJECT_ROOT}/packages/essential -type file -name config.sh -exec bash {} ;"
  assert_output --partial "[INSTRUCTION] To run additional filters, run the script again with --filter <package>. Use -h for a list of available packages to filter on."
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
  assert_success
}