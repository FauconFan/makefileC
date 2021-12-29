#!/bin/bash

make fclean

touch -t "$(date -d "1 year ago" "+%Y%m%d%H%M.%S")" "${PATH_LOCAL_IGNORE}"
make fclean > old.txt

make self_update_ignore
make fclean > recent.txt

grep "\[ UPDATE \]" < old.txt
diff recent.txt <(grep -v "\[ UPDATE \]" < recent.txt)
diff recent.txt <(grep -v "\[ UPDATE \]" < old.txt)

rm -f \
	old.txt \
	recent.txt
