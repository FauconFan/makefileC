#!/bin/bash
# shellcheck source=/dev/null

set -eux

PATH_LOCAL="${HOME}/.makefileC"
PATH_LOCAL_LATEST="${PATH_LOCAL}/latest.mk"
PATH_LOCAL_IGNORE="${PATH_LOCAL}/ignore"

if [ ! "$(git rev-parse --show-prefix)" = "tests/self-update/mini-project3/" ]; then
	echo "You have to run this test inside the mini-project3 folder"
	exit 1
fi

if [ -z "$(diff Makefile "${PATH_LOCAL_LATEST}")" ]; then
	echo "Can't pursue test because difference with master are the same"
	exit 0
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")

make fclean

if [ ! -f "${PATH_LOCAL_LATEST}" ]; then
	echo "The latest makefile has not been setup correctly"
	exit 1
fi

export PATH_LOCAL_LATEST
export PATH_LOCAL_IGNORE

. "${SCRIPT_DIR}"/_message.bash
. "${SCRIPT_DIR}"/_ignore.bash
. "${SCRIPT_DIR}"/_update.bash
