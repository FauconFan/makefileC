#!/bin/bash
# shellcheck source=/dev/null

set -eux

if [ ! "$(git rev-parse --show-prefix)" = "tests/configuration/mini-project/" ]; then
	echo "You have to run this test inside the mini-project folder"
	exit 1
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")

saveConfig() {
	declare -A CONFIG="${1#*=}"

	cat > config.mk << EOF

NAME = ${CONFIG[output]:-output}
NAME_DEBUG = ${CONFIG[output-debug]:-output-debug}

SRC_FOLDER = ${CONFIG[SRC_FOLDER]:- src/}
INC_FOLDER = ${CONFIG[INC_FOLDER]:- inc/}
BUILD_FOLDER = ${CONFIG[BUILD_FOLDER]:- build/}

CC = ${CONFIG[CC]:-clang}
CFLAGS_COMMON = ${CONFIG[CFLAGS_COMMON]- -Wall -Wextra -Werror -Weverything -pedantic -std=c17}
CFLAGS_RELEASE = ${CONFIG[CFLAGS_RELEASE]- -O2 -DNDEBUG}
CFLAGS_DEBUG = ${CONFIG[CFLAGS_DEBUG]- -O0 -ggdb -DDEBUG}
LDFLAGS = ${CONFIG[LDFLAGS]-}
LDLIBS = ${CONFIG[LDLIBS]-}

SRC = ${CONFIG[SRC]- main.c}

EOF
}

deleteConfig() {
	rm -f config.mk
}

. "${SCRIPT_DIR}/_names.bash"
. "${SCRIPT_DIR}/_compiler.bash"
. "${SCRIPT_DIR}/_flags.bash"
. "${SCRIPT_DIR}/_directory_names.bash"
. "${SCRIPT_DIR}/_source_files.bash"
