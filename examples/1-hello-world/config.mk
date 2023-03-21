
GOAL = EXECUTABLE

NAME = hello-world
NAME_DEBUG = hello-world-debug

INC_FOLDER = inc/
SRC_FOLDER = src/
BUILD_FOLDER = build/

CFLAGS_COMMON = -Wall -Wextra -Werror -Weverything -pedantic -std=c17
CFLAGS_RELEASE = -O2 -DNDEBUG
CFLAGS_DEBUG = -O0 -ggdb -DDEBUG
LDFLAGS =
LDLIBS =

SRC = \
	main.c \
	print_hello.c \
