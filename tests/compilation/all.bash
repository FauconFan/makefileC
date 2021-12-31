#!/bin/bash
# shellcheck source=/dev/null

set -eux

SCRIPT_DIR=$(dirname "$(realpath "$0")")

ALL_RULES="all clean fclean re debug redebug help"
EXCEPTED_RULES="init self_update self_update_ignore"
NAME="./$(grep NAME < config.mk | grep -v NAME_DEBUG | cut -d'=' -f2 | xargs)"
NAME_DEBUG="./$(grep NAME_DEBUG < config.mk | cut -d'=' -f2 | xargs)"
SRC_FOLDER="$(grep "SRC_FOLDER *=" config.mk | cut -d'=' -f2 | xargs)"
INC_FOLDER="$(grep "INC_FOLDER *=" config.mk | cut -d'=' -f2 | xargs)"

export ALL_RULES
export EXCEPTED_RULES
export NAME
export NAME_DEBUG
export SRC_FOLDER
export INC_FOLDER

. "${SCRIPT_DIR}"/_all_targets.bash
. "${SCRIPT_DIR}"/_all_vs_debug.bash
. "${SCRIPT_DIR}"/_fclean.bash
. "${SCRIPT_DIR}"/_verbose.bash
. "${SCRIPT_DIR}"/_recompile.bash
. "${SCRIPT_DIR}"/_multithread.bash
. "${SCRIPT_DIR}"/_progress_status.bash
. "${SCRIPT_DIR}"/_out_of_sources.bash
. "${SCRIPT_DIR}"/_tput_TERM.bash

make fclean
