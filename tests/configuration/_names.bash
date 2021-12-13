#!/bin/bash

declare -A CONFIG=()

# release check
CONFIG[output]='output'
saveConfig "$(declare -p CONFIG)"
make

CONFIG[output]='random-output'
saveConfig "$(declare -p CONFIG)"
make

test -f output
test -f random-output

diff output random-output
make fclean

CONFIG[output]='output'
saveConfig "$(declare -p CONFIG)"
make fclean

test ! -f output
test ! -f random-output

# debug check
CONFIG[output-debug]='output-debug'
saveConfig "$(declare -p CONFIG)"
make debug

CONFIG[output-debug]='random-debug'
saveConfig "$(declare -p CONFIG)"
make debug

test -f output-debug
test -f random-debug

diff output-debug random-debug
make fclean

CONFIG[output-debug]='output-debug'
saveConfig "$(declare -p CONFIG)"
make fclean

test ! -f output-debug
test ! -f random-debug

deleteConfig
