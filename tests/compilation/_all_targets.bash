#!/bin/bash

## Check all availables commands
for rule in ${ALL_RULES}
do
	make "${rule}"
done