#!/bin/bash

set -eux

if [ ! "$(git rev-parse --show-prefix)" = "tests/readme-check-help/mini-project4/" ]; then
	echo "You have to run this test inside the mini-project4 folder"
	exit 1
fi

TMPDIR="$(mktemp -d)"

make self_update_ignore

# Extract help without colors from Makefile
make help NO_COLORS=1 > "${TMPDIR}/output_help.txt"

# Determine number of lines printed
_NB_LINES="$(wc -l < "${TMPDIR}/output_help.txt")"

# Extract make help routine in README
grep "\$> make help" -A "${_NB_LINES}" \
	< ../../../README.md \
	| grep -v "\$> make help" > "${TMPDIR}/make_help_on_readme.txt"

# Check no difference
diff "${TMPDIR}/output_help.txt" "${TMPDIR}/make_help_on_readme.txt"

rm -rf "${TMPDIR}"
