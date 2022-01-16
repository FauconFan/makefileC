#!/bin/bash

make fclean

ls -lRs > /tmp/tree_hierarchy # register project architecture for later

## Check that fclean full cleans on every command
for rule in ${ALL_RULES}
do
	make "${rule}"
	make fclean
	diff <(ls -lRs) /tmp/tree_hierarchy
done

rm -f /tmp/tree_hierarchy
