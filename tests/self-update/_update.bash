#!/bin/bash

if [ -z "$(diff Makefile "${PATH_LOCAL_LATEST}")" ]; then
	echo "Can't pursue test because difference with master are the same"
	exit 0
fi

EXIT_STATUS=0

# Remove symbolic link
cp Makefile Makefile.backup
rm Makefile
cp Makefile.backup Makefile

touch -t "$(date -d "1 year ago" "+%Y%m%d%H%M.%S")" "${PATH_LOCAL_IGNORE}"
make self_update

if [ -z "$(diff Makefile ../../../Makefile)" ]; then
	EXIT_STATUS=1
fi

# Restore Symbolic link
rm Makefile
ln -s ../../../Makefile Makefile

rm -f \
	Makefile.backup

if [ ! "$EXIT_STATUS" = "0" ]; then
	exit 1
fi
