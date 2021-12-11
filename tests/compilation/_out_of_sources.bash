#!/bin/bash

ls -lRs "${SRC_FOLDER}" "${INC_FOLDER}" > /tmp/tree_hierarchy_in_src_and_inc # register project architecture for later

## Check that fclean full cleans on every command
for rule in ${ALL_RULES}
do
	make "${rule}"
	diff <(ls -lRs "${SRC_FOLDER}" "${INC_FOLDER}") /tmp/tree_hierarchy_in_src_and_inc
done

make fclean

rm -f /tmp/tree_hierarchy_in_src_and_inc
