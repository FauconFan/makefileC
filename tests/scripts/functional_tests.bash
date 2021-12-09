#!/bin/bash

set -eux

NAME="./$(grep NAME < config.mk | grep -v NAME_DEBUG | cut -d'=' -f2 | xargs)"
NAME_DEBUG="./$(grep NAME_DEBUG < config.mk | cut -d'=' -f2 | xargs)"

ls -lRs > /tmp/tree_hierarchy					# register project architecture for later

## Check all availables commands
make all
make clean
make fclean
make re
make debug
make redebug

## Check tree and output consistency on release build
make all
eval "${NAME}" > /tmp/release_output			# register release output for later
make clean
diff <(eval "${NAME}") /tmp/release_output		# check diff between old output and binary after cleaned
make fclean
diff <(ls -lRs) /tmp/tree_hierarchy				# check diff between old project architecture and the actual project architecture
make re
diff <(eval "${NAME}") /tmp/release_output		# check diff between old output and binary after re
make fclean
diff <(ls -lRs) /tmp/tree_hierarchy				# check diff between old project architecture and the actual project architecture

## Check tree and output consistency on debug build
make debug
eval "${NAME_DEBUG}" > /tmp/debug_output		# register debug output for later
make clean
diff <(eval "${NAME_DEBUG}") /tmp/debug_output	# check diff between old debug output and binary after cleaned
make fclean
diff <(ls -lRs) /tmp/tree_hierarchy				# check diff between old project architecture and the actual project architecture
make redebug
diff <(eval "${NAME_DEBUG}") /tmp/debug_output	# check diff between old debug output and binary after re
make fclean
diff <(ls -lRs) /tmp/tree_hierarchy				# check diff between old project architecture and the actual project architecture

## Check debug informations in binaries
make all
test "$(objdump --syms "${NAME}" | grep -c debug)" -eq 0		# check if there are no debug informations in release binary
make debug
test "$(objdump --syms "${NAME_DEBUG}" | grep -c debug)" -gt 0	# check if there are debug informations in debug binary
make fclean
diff <(ls -lRs) /tmp/tree_hierarchy								# check diff between old project architecture and the actual project architecture

## Remove useless files
rm -f \
	/tmp/tree_hierarchy \
	/tmp/release_output \
	/tmp/debug_output