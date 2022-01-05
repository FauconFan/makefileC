#!/bin/bash

set -eux

if [ ! "$(git rev-parse --show-prefix)" = "tests/error-handling/mini-project2/" ]; then
	echo "You have to run this test inside the mini-project2 folder"
	exit 1
fi

ALL_RULES="all clean fclean re debug redebug help self_update self_update_ignore"
EXCEPTED_RULES="init"

## Check that declared targets in the testsuite is the same than in the makefile
#### Don't want ALL_RULES to be automatically captured by the makefile
cp correct_config.mk config.mk
diff \
	<(make _printvar__SCT_TARGETS_NAMES | tr ' ' '\n' | sort) \
	<(echo "${ALL_RULES}" "${EXCEPTED_RULES}" | tr ' ' '\n' | sort)
rm -f config.mk

testAllTargetsSameOutput() { #1: path to the current wrong config.mk file
	TMP_DIR="$(mktemp -d)"

	if [ ! "${1}" = "" ]; then
		cp "${1}" config.mk
	fi

	tar -cf "${TMP_DIR}/dump_witness.tar" ./
	make > "${TMP_DIR}"/std.txt 2>&1 && exit 1

	tar -cf "${TMP_DIR}/dump.tar" ./
	diff "${TMP_DIR}/dump_witness.tar" "${TMP_DIR}/dump.tar"
	rm -f "${TMP_DIR}/dump.tar"

	for rule in ${ALL_RULES}
	do
		diff "${TMP_DIR}"/std.txt <(make "${rule}" 2>&1)
		tar -cf "${TMP_DIR}/dump.tar" ./
		diff "${TMP_DIR}/dump_witness.tar" "${TMP_DIR}/dump.tar"
		rm -f "${TMP_DIR}/dump.tar"
	done

	if [ ! "${1}" = "" ]; then
		rm -f config.mk
	fi

	rm -rf "${TMP_DIR}"
}

testAllTargetsSameOutput ""
testAllTargetsSameOutput ../11-too-few-variables.config.mk
testAllTargetsSameOutput ../12-too-much-variables.config.mk
testAllTargetsSameOutput ../13-specified-files-missing.mk
testAllTargetsSameOutput ../14-name-is-keyword.mk
testAllTargetsSameOutput ../15-name-debug-is-keyword.mk
testAllTargetsSameOutput ../16-name-equals-name-debug.mk
testAllTargetsSameOutput ../17-srcdir-same-as-builddir.mk
testAllTargetsSameOutput ../18-incdir-same-as-builddir.mk
testAllTargetsSameOutput ../19-presence-unspecified-files.mk

rm -f config.mk