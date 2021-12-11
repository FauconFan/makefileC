#!/bin/bash

ONE_C_FILE=$(find . -name "*.c" | head -n 1)
ONE_H_FILE=$(find . -name "*.h" | head -n 1)

make fclean


# Checks the message is different after two consecutive runs of make
# Checks the file hasn't been modified
make > /tmp/first_make
stat "${NAME}" > /tmp/stat_first_make
make > /tmp/nothing_to_recompile

test $(diff /tmp/first_make /tmp/nothing_to_recompile | wc -l) -gt 0
diff /tmp/stat_first_make <(stat "${NAME}")

# Checks the file has been modified after make re
make re
test $(diff /tmp/stat_first_make <(stat "${NAME}") | wc -l) -gt 0

make re

# Checks it recompiles after a C file has been modified
touch "${ONE_C_FILE}"
test $(diff <(make) /tmp/nothing_to_recompile | wc -l) -gt 0
diff <(make) /tmp/nothing_to_recompile

# Checks it recompiles after a H file has been modified
touch "${ONE_H_FILE}"
test $(diff <(make) /tmp/nothing_to_recompile | wc -l) -gt 0
diff <(make) /tmp/nothing_to_recompile

# Checks output is different when nothing needs to be recompile and when make re
make
test $(diff <(make re) /tmp/nothing_to_recompile | wc -l) -gt 0

make fclean

rm -f \
	/tmp/stat_first_make \
	/tmp/nothing_to_recompile \
	/tmp/first_make
