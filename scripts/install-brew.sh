#!/usr/bin/env bash
[[ ${DEBUG:-} == true ]] && set -o xtrace

# Brew may change over time, if you run into issues visit
# https://docs.brew.sh/Installation#:~:text=Instructions%20for%20a%20supported%20install,sudo%20when%20you%20brew%20install%20
yes | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
