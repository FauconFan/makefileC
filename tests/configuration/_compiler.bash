#!/bin/bash

declare -A CONFIG=()

CONFIG[CFLAGS_COMMON]=""
CONFIG[CFLAGS_RELEASE]=""
CONFIG[CFLAGS_DEBUG]=""

# Check change of compiler
CONFIG[CC]="clang"
CONFIG[output]="clang-output"
saveConfig "$(declare -p CONFIG)"
make re

CONFIG[CC]="gcc"
CONFIG[output]="gcc-output"
saveConfig "$(declare -p CONFIG)"
make re

! diff clang-output gcc-output

rm -f clang-output gcc-output

deleteConfig
