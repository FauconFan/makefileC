#!/bin/bash

set -eux

if [ ! "$(git rev-parse --show-prefix)" = "tests/readme-check-help/mini-project4/" ]; then
	echo "You have to run this test inside the mini-project4 folder"
	exit 1
fi

TMPDIR="$(mktemp -d)"

make help > "${TMPDIR}/output_help.txt"
_NB_LINES="$(wc -l < "${TMPDIR}/output_help.txt")"

grep "\$> make help" -A "${_NB_LINES}" \
	< ../../../README.md \
	| grep -v "\$> make help"> "${TMPDIR}/make_help_on_readme.txt"

diff "${TMPDIR}/output_help.txt" "${TMPDIR}/make_help_on_readme.txt"

rm -rf "${TMPDIR}"
