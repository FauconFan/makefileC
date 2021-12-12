#!/bin/bash

declare -A CONFIG=()

CONFIG[CC]="clang"
CONFIG[output]="output"
CONFIG[output-debug]="output-debug"

## No debug symbols
CONFIG[CFLAGS_COMMON]=""
CONFIG[CFLAGS_RELEASE]=""
CONFIG[CFLAGS_DEBUG]=""

saveConfig "$(declare -p CONFIG)"
make
make debug
test "$(objdump --syms output | grep -v "file format" | grep -c debug)" -eq 0
test "$(objdump --syms output-debug | grep -v "file format" | grep -c debug)" -eq 0

make fclean

## Debug sumbols in release only
CONFIG[CFLAGS_COMMON]=""
CONFIG[CFLAGS_RELEASE]="-g"
CONFIG[CFLAGS_DEBUG]=""

saveConfig "$(declare -p CONFIG)"
make
make debug
test "$(objdump --syms output | grep -v "file format" | grep -c debug)" -gt 0
test "$(objdump --syms output-debug | grep -v "file format" | grep -c debug)" -eq 0

make fclean

## Debug sumbols in debug only
CONFIG[CFLAGS_COMMON]=""
CONFIG[CFLAGS_RELEASE]=""
CONFIG[CFLAGS_DEBUG]="-g"

saveConfig "$(declare -p CONFIG)"
make
make debug
test "$(objdump --syms output | grep -v "file format" | grep -c debug)" -eq 0
test "$(objdump --syms output-debug | grep -v "file format" | grep -c debug)" -gt 0

make fclean

## Debug sumbols in both binaries
CONFIG[CFLAGS_COMMON]="-g"
CONFIG[CFLAGS_RELEASE]=""
CONFIG[CFLAGS_DEBUG]=""

saveConfig "$(declare -p CONFIG)"
make
make debug
test "$(objdump --syms output | grep -v "file format" | grep -c debug)" -gt 0
test "$(objdump --syms output-debug | grep -v "file format" | grep -c debug)" -gt 0

make fclean

deleteConfig
