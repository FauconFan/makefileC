#!/bin/bash

# This bash script is used to priorly test the github CI pipeline
# If github workflow files are changed, you have to change this file accordingly
# TODO: somehow generate this file

set -eux

if [ ! "$(git rev-parse --show-prefix)" = "" ]; then
	echo "You have to run this test in the root folder of the git project"
	exit 1
fi

# shellcheck disable=SC2046
shellcheck -x $(find . -name "*.bash" -o -name "*.sh")
test "$(find examples -mindepth 1 -maxdepth 1 | wc -l)" -eq 8

for folder in 1-hello-world 2-sum10 3-fibonacci 4-fib-gcc 5-subdirs 6-debug 7-libmymath 8-libquotes
do
	pushd "examples/${folder}"
	../../tests/compilation/all.bash
	popd
done

pushd tests/configuration/mini-project
../all.bash
popd

pushd tests/error-handling/mini-project2
../all.bash
popd

pushd tests/readme-check-help/mini-project4
../all.bash
popd

./tests/init/all.bash
