#!/usr/bin/env bats
declare PROJECT_ROOT

setup() {
    load 'test_helper/common-setup'
    _common_setup
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/packages/essential/config.sh"
}

teardown() {
    _common_teardown
}

# bats test_tags=ci
@test "update_shells should add brew managed shells for brew" { 
  BREW_PREFIX=$(brew --prefix)

  run update_shells

  check_bash=$(! grep -F --quiet "${BREW_PREFIX}/bin/bash" /etc/shells)
  check_zsh=$(! grep -F --quiet "${BREW_PREFIX}/bin/zsh" /etc/shells)
  assert_equal "${check_bash}" 0
  assert_equal "${check_zsh}" 0
  assert_success
}

# bats test_tags=local,ci
@test "update_shells should skip brew managed shells if already added" { 
  grep() {
    echo "grep $*"
    return 0
  }

  BREW_PREFIX=$(brew --prefix)

  run update_shells

  refute_output --partial "[CONFIG] Adding bash to shells"
  refute_output --partial "[CONFIG] Adding zsh to shells and setting as default shell."
  assert_success
}