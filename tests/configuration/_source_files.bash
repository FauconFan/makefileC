#!/bin/bash

declare -A CONFIG=()

CONFIG[SRC]="main.c"
CONFIG[output]="output"
saveConfig "$(declare -p CONFIG)"
make

mv src/main.c src/main-tmp.c

CONFIG[SRC]="main-tmp.c"
CONFIG[output]="output-tmp"
saveConfig "$(declare -p CONFIG)"
make

./output
./output-tmp
# Cannot test more than that

make fclean

mv src/main-tmp.c src/main.c

rm -f output output-tmp

deleteConfig
