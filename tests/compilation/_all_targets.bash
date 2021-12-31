#!/bin/bash

## Check that declared targets in the testsuite is the same than in the makefile
#### Don't want ALL_RULES to be automatically captured by the makefile
diff \
	<(make _printvar__SCT_TARGETS_NAMES | tr ' ' '\n' | sort) \
	<(echo "${ALL_RULES}" "${EXCEPTED_RULES}" | tr ' ' '\n' | sort)

## Check all availables commands
for rule in ${ALL_RULES}
do
	make "${rule}"
done