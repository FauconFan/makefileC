#!/bin/bash

declare -A CONFIG=()

# release check
CONFIG[output]='output'
saveConfig "$(declare -p CONFIG)"
make re

CONFIG[output]='random-output'
saveConfig "$(declare -p CONFIG)"
make re

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
make redebug

CONFIG[output-debug]='random-debug'
saveConfig "$(declare -p CONFIG)"
make redebug

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
