#!/bin/bash
# shellcheck disable=SC2153

mkdir -p /tmp/empty

_SRC_FOLDER="/tmp/empty"
_INC_FOLDER="/tmp/empty"

if [ -d "${SRC_FOLDER}" ]; then
	_SRC_FOLDER="${SRC_FOLDER}"
fi
if [ -d "${INC_FOLDER}" ]; then
	_INC_FOLDER="${INC_FOLDER}"
fi

ls -lRs "${_SRC_FOLDER}" "${_INC_FOLDER}" > /tmp/tree_hierarchy_in_src_and_inc # register project architecture for later

## Check that fclean full cleans on every command
for rule in ${ALL_RULES}
do
	make "${rule}"
	diff <(ls -lRs "${_SRC_FOLDER}" "${_INC_FOLDER}") /tmp/tree_hierarchy_in_src_and_inc
done

make fclean

rm -rf \
	/tmp/tree_hierarchy_in_src_and_inc \
	/tmp/empty
