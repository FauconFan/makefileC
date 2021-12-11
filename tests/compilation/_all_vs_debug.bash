#!/bin/bash

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

make all
test "$(objdump --syms "${NAME}" | grep -c debug)" -eq 0
make debug
test "$(objdump --syms "${NAME_DEBUG}" | grep -c debug)" -gt 0
make fclean

rm -f /tmp/release_output /tmp/debug_output