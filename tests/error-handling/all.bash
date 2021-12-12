#!/bin/bash

set -eux

if [ ! "$(git rev-parse --show-prefix)" = "tests/error-handling/mini-project2/" ]; then
	echo "You have to run this test inside the mini-project folder"
	exit 1
fi

make && exit 1
cp ../11-too-few-variables.config.mk config.mk
make && exit 1
cp ../12-too-much-variables.config.mk config.mk
make && exit 1
cp ../13-specified-files-missing.mk config.mk
make && exit 1
cp ../14-presence-unspecified-files.mk config.mk
make && exit 1

rm -f config.mk