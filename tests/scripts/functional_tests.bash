#!/bin/bash

set -eux

NAME="./$(grep NAME < config.mk | grep -v NAME_DEBUG | cut -d'=' -f2 | xargs)"
NAME_DEBUG="./$(grep NAME_DEBUG < config.mk | cut -d'=' -f2 | xargs)"

ALL_RULES="all clean fclean re debug redebug"

ls -lRs > /tmp/tree_hierarchy # register project architecture for later

## Check all availables commands
for rule in ${ALL_RULES}
do
	make "${rule}"
done

## Check that fclean full cleans on every command
for rule in ${ALL_RULES}
do
	make "${rule}"
	make fclean
	diff <(ls -lRs) /tmp/tree_hierarchy
done

## Check verbosity
for rule in ${ALL_RULES}
do
	make fclean
	make "${rule}" > "/tmp/build_${rule}"
	make fclean
	make "${rule}" VERBOSE=1 > "/tmp/build_${rule}_verbose"

	diff "/tmp/build_${rule}" <(grep -v CMD < "/tmp/build_${rule}_verbose")
	test "$(wc -l < "/tmp/build_${rule}")" -lt "$(wc -l < "/tmp/build_${rule}_verbose")"

	rm -f "/tmp/build_${rule}" "/tmp/build_${rule}_verbose"
done

make fclean # resets

## Check tree and output consistency on release build
make all
eval "${NAME}" > /tmp/release_output # register release output for later
make clean
diff <(eval "${NAME}") /tmp/release_output
make fclean
make re
diff <(eval "${NAME}") /tmp/release_output
make fclean

## Check tree and output consistency on debug build
make debug
eval "${NAME_DEBUG}" > /tmp/debug_output # register debug output for later
make clean
diff <(eval "${NAME_DEBUG}") /tmp/debug_output
make fclean
make redebug
diff <(eval "${NAME_DEBUG}") /tmp/debug_output
make fclean

## Check debug informations in binaries
make all
test "$(objdump --syms "${NAME}" | grep -c debug)" -eq 0
make debug
test "$(objdump --syms "${NAME_DEBUG}" | grep -c debug)" -gt 0
make fclean

## Remove useless files
rm -f \
	/tmp/tree_hierarchy \
	/tmp/release_output \
	/tmp/debug_output