#!/bin/bash

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
