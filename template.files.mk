
# Name of the binary
NAME = output

# Folder constants
## folder that contains the headers files [.h]
INC_FOLDER = inc/
## folder that contains the source files [.c]
SRC_FOLDER = src/
## folder that contains the object and dependency files [.[od]]
BUILD_FOLDER = build/

# Makefile built-ins variables
## CC compiler
CC = clang
## C Flags
CFLAGS = -Wall -Wextra -Werror -Weverything -pedantic -O2 -std=c17
## LD Flags
LDFLAGS =
## Libs Flags
LDLIBS =

# Exhaustive list of the source files (base dir is $(SRC_FOLDER))
# All your source code files must be in $(SRC_FOLDER)
SRC = \
	main.c \
