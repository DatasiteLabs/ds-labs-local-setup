#!/usr/bin/env bats

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    install_dir="/tmp/ds-labs-local-setup-test"
}

teardown() {
    rm -rf "${install_dir}"
}

@test "run basic install" {
    run ./install.sh << EOF
${install_dir}
n
EOF
    assert_output --partial "[INFO] ds-labs-local-setup will create ${install_dir} if it does not exist and download the repo to that directory."
    assert_output --partial "[CREATE] ${install_dir}"
    assert_output --partial "[CREATE] cloning DatasiteLabs/ds-labs-local-setup to ${install_dir}/ds-labs-local-setup"
    assert_output --partial "[INSTRUCTION] Run the following commands in a new terminal to continue."
    assert_output --partial "cd ${install_dir}/ds-labs-local-setup"
    assert_output --partial "./bootstrap.sh"
    [[ -d "${install_dir}" ]] || fail "Failed to create ${install_dir}"
    [[ -d "${install_dir}/ds-labs-local-setup" ]] || fail "Failed to clone ds-labs-local-setup"
    assert_success
}

@test "handle directories already exists" {
    mkdir -p ${install_dir}/ds-labs-local-setup
    touch ${install_dir}/ds-labs-local-setup/file.txt
    run ./install.sh << EOF
${install_dir}
n
EOF
    assert_output --partial "[INFO] ds-labs-local-setup will create ${install_dir} if it does not exist and download the repo to that directory."
    assert_output --partial "[SKIP] ${install_dir} exists."
    assert_output --partial "[SKIP] ${install_dir}/ds-labs-local-setup exists."
    assert_output --partial "[INSTRUCTION] Run the following commands in a new terminal to continue."
    assert_output --partial "cd ${install_dir}/ds-labs-local-setup"
    assert_output --partial "./bootstrap.sh"
    [[ -f "${install_dir}/ds-labs-local-setup/file.txt" ]] || fail "Failed to preserve eisting files"
    assert_success
}