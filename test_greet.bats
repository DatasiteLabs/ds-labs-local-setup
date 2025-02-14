#!/usr/bin/env bats

load './greet.sh'

@test "greet function with name" {
  run greet "World"
  [ "$status" -eq 0 ]
  [ "$output" = "Hello, World!" ]
}