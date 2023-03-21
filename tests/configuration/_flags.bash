#!/bin/bash

# How to get debug symbols from objdump
# https://stackoverflow.com/questions/3284112/how-to-check-if-program-was-compiled-with-debug-symbols
# Unfortunately, it appears the objdump does not print debug symbols by default,
# We now have to use the -g option to print them.
# We then check that the output contains at least one debug symbol when relevant.

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
test "$(objdump --syms -g output | grep -v "file format" | grep -c '\.debug')" -eq 0
test "$(objdump --syms -g output-debug | grep -v "file format" | grep -c '\.debug')" -eq 0

make fclean

## Debug sumbols in release only
CONFIG[CFLAGS_COMMON]=""
CONFIG[CFLAGS_RELEASE]="-g"
CONFIG[CFLAGS_DEBUG]=""

saveConfig "$(declare -p CONFIG)"
make
make debug
test "$(objdump --syms -g output | grep -v "file format" | grep -c '\.debug')" -gt 0
test "$(objdump --syms -g output-debug | grep -v "file format" | grep -c '\.debug')" -eq 0

make fclean

## Debug sumbols in debug only
CONFIG[CFLAGS_COMMON]=""
CONFIG[CFLAGS_RELEASE]=""
CONFIG[CFLAGS_DEBUG]="-g"

saveConfig "$(declare -p CONFIG)"
make
make debug
test "$(objdump --syms -g output | grep -v "file format" | grep -c '\.debug')" -eq 0
test "$(objdump --syms -g output-debug | grep -v "file format" | grep -c '\.debug')" -gt 0

make fclean

## Debug sumbols in both binaries
CONFIG[CFLAGS_COMMON]="-g"
CONFIG[CFLAGS_RELEASE]=""
CONFIG[CFLAGS_DEBUG]=""

saveConfig "$(declare -p CONFIG)"
make
make debug
test "$(objdump --syms -g output | grep -v "file format" | grep -c '\.debug')" -gt 0
test "$(objdump --syms -g output-debug | grep -v "file format" | grep -c '\.debug')" -gt 0

make fclean

deleteConfig
