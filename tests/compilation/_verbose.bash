#!/bin/bash

## Check verbosity
for rule in ${ALL_RULES}
do
	## Don't test verbosity on help,
	## This target doesn't use any outside command
	if [[ "${rule}" = "help" ]]; then
		continue
	fi

	## Differentiate clean and fclean because they don't output any command CMD
	## if there is nothing to remove
	if [[ "${rule}" = "clean" ]] || [[ "${rule}" = "fclean" ]]; then
		make
		make "${rule}" > "/tmp/build_${rule}"
		make
		make "${rule}" VERBOSE=1 > "/tmp/build_${rule}_verbose"
	else
		make fclean
		make "${rule}" > "/tmp/build_${rule}"
		make fclean
		make "${rule}" VERBOSE=1 > "/tmp/build_${rule}_verbose"
	fi

	diff "/tmp/build_${rule}" <(grep -v CMD < "/tmp/build_${rule}_verbose")
	test "$(wc -l < "/tmp/build_${rule}")" -lt "$(wc -l < "/tmp/build_${rule}_verbose")"

	rm -f "/tmp/build_${rule}" "/tmp/build_${rule}_verbose"
done

make fclean # resets
