
# Name of the binary
NAME = output
NAME_DEBUG = output-debug

# Folder constants
## folder that contains the headers files [.h]
INC_FOLDER = inc/
## folder that contains the source files [.c]
SRC_FOLDER = src/
## folder that contains the object and dependency files [.[od]]
BUILD_FOLDER = build/

# Makefile built-ins variables
## CC compiler
CC = gcc
## C Flags
CFLAGS_COMMON = -Wall -Wextra -Werror -pedantic -std=c11
CFLAGS_RELEASE = -O2 -DNDEBUG
CFLAGS_DEBUG = -O0 -ggdb -DDEBUG
## LD Flags
LDFLAGS =
## Libs Flags
LDLIBS =

# Exhaustive list of the source files (base dir is $(SRC_FOLDER))
# All your source code files must be in $(SRC_FOLDER)
SRC = \
	main.c \
	fibonacci.c \
