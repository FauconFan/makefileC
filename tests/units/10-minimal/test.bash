#!/bin/bash

set -eux

make
./minimal
make clean
./minimal
make fclean
test ! -f minimal
make
./minimal
make re
./minimal
make fclean

make debug
./minimal-debug
make clean
./minimal-debug
make fclean
test ! -f minimal-debug
make debug
./minimal-debug
make redebug
./minimal-debug
make fclean

make
make debug
test -f minimal
test -f minimal-debug
test "$(objdump --syms minimal | grep -c debug)" -eq 0
test "$(objdump --syms minimal-debug | grep -c debug)" -gt 0

make fclean