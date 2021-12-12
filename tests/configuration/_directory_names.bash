#!/bin/bash

declare -A CONFIG=()

# Save output for later
CONFIG[output]="output"
CONFIG[SRC_FOLDER]="src/"
saveConfig "$(declare -p CONFIG)"
make
make clean

# Change SRC_FOLDER
mv src src-tmp

CONFIG[output]="output-tmp"
CONFIG[SRC_FOLDER]="src-tmp/"
saveConfig "$(declare -p CONFIG)"
make
make clean

diff output output-tmp

make fclean
mv src-tmp src

CONFIG[SRC_FOLDER]="src/"

# Change INC_FOLDER
mv inc inc-tmp

CONFIG[output]="output-tmp"
CONFIG[INC_FOLDER]="inc-tmp/"
saveConfig "$(declare -p CONFIG)"
make
make clean

diff output output-tmp

make fclean
mv inc-tmp inc

CONFIG[INC_FOLDER]="inc/"

# Change INC_FOLDER to src
mv inc/main.h src/main.h

CONFIG[output]="output-tmp"
CONFIG[INC_FOLDER]="src/"
saveConfig "$(declare -p CONFIG)"
make
make clean

diff output output-tmp

make fclean
mv src/main.h inc/main.h

CONFIG[INC_FOLDER]="inc/"

# Change BUILD_FOLDER
CONFIG[output]="output"
CONFIG[BUILD_FOLDER]="build/"
saveConfig "$(declare -p CONFIG)"
make
mv build build-tmp2

CONFIG[output]="output-tmp"
CONFIG[BUILD_FOLDER]="build-tmp/"
saveConfig "$(declare -p CONFIG)"
make

diff output output-tmp
diff build-tmp2 build-tmp

make fclean

CONFIG[output]="output"
CONFIG[BUILD_FOLDER]="build/"
saveConfig "$(declare -p CONFIG)"
make fclean

rm -rf build-tmp2

# Cleans
rm -f output

deleteConfig
