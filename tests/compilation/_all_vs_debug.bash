#!/bin/bash

if [ ! "${GOAL_MODE}" = "EXECUTABLE" ]; then
	return 0
fi

make all
eval "${NAME}" > /tmp/release_output # register release output for later
make clean
diff <(eval "${NAME}") /tmp/release_output
make fclean
make re
diff <(eval "${NAME}") /tmp/release_output
make fclean

make debug
eval "${NAME_DEBUG}" > /tmp/debug_output # register debug output for later
make clean
diff <(eval "${NAME_DEBUG}") /tmp/debug_output
make fclean
make redebug
diff <(eval "${NAME_DEBUG}") /tmp/debug_output
make fclean

# How to get debug symbols from objdump
# https://stackoverflow.com/questions/3284112/how-to-check-if-program-was-compiled-with-debug-symbols
# Unfortunately, it appears the objdump does not print debug symbols by default,
# We now have to use the -g option to print them.
# We then check that the output contains at least one debug symbol when relevant.

make all
test "$(objdump --syms -g "${NAME}" | grep -v "file format" | grep -c '\.debug')" -eq 0
make debug
test "$(objdump --syms -g "${NAME_DEBUG}" | grep -v "file format" | grep -c '\.debug')" -gt 0
make fclean

rm -f /tmp/release_output /tmp/debug_output