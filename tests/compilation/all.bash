#!/bin/bash
# shellcheck source=/dev/null

set -eux

SCRIPT_DIR=$(dirname "$(realpath "$0")")

ALL_RULES="all clean fclean re debug redebug"
NAME="./$(grep NAME < config.mk | grep -v NAME_DEBUG | cut -d'=' -f2 | xargs)"
NAME_DEBUG="./$(grep NAME_DEBUG < config.mk | cut -d'=' -f2 | xargs)"

export ALL_RULES
export NAME
export NAME_DEBUG

. "${SCRIPT_DIR}"/_all_targets.bash
. "${SCRIPT_DIR}"/_all_vs_debug.bash
. "${SCRIPT_DIR}"/_fclean.bash
. "${SCRIPT_DIR}"/_verbose.bash
