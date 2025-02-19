#!/usr/bin/env bats
declare PROJECT_ROOT

setup() {
    load 'test_helper/common-setup'
    _common_setup
    # shellcheck disable=SC1091
    source "${PROJECT_ROOT}/packages/recommended/config.sh"
}

teardown() {
    _common_teardown
}

# bats test_tags=local,ci
@test "1password_config should give the user instructions and wait to continue" { 
  run 1password_config << EOF

EOF

  assert_output --partial "[INSTRUCTION] Visit https://developer.1password.com/docs/cli/get-started/#step-2-turn-on-the-1password-desktop-app-integration to finish configuring the 1Password CLI."
  assert_output --partial "[INSTRUCTION] Visit https://1password.com/downloads/browser-extension in your browser of choice to install the 1Password browser extention."

  assert_success
}