#!/bin/bash

if [ ! "${GOAL_MODE}" = "EXECUTABLE" ]; then
	return 0
fi

TMP_DIR="$(mktemp -d)"

make fclean

make all
eval "${NAME}"
cp "${NAME}" "${TMP_DIR}/backup"
make fclean

make
eval "${NAME}"
diff "${NAME}" "${TMP_DIR}/backup"
make fclean

rm -rf "${TMP_DIR}"
