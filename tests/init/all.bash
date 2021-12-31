#!/bin/bash

set -eux

if [ ! "$(git rev-parse --show-prefix)" = "" ]; then
	echo "You have to run this test inside the root folder"
	exit 1
fi

PATH_MAKEFILE="$(pwd)/Makefile"
PATH_TEMPLATE_CONFIG_MK="$(pwd)/template.config.mk"
TMP_DIR="$(mktemp -d)"

pushd "${TMP_DIR}"

cp "${PATH_MAKEFILE}" Makefile
make init

diff config.mk "${PATH_TEMPLATE_CONFIG_MK}"

make
./output
make clean
./output
make fclean
test ! -f output
make re
./output
make fclean

make debug
./output-debug
make clean
./output-debug
make fclean
test ! -f output-debug
make redebug
./output-debug
make fclean

popd

rm -rf "${TMP_DIR}"
