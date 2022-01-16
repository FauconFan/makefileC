
GOAL = EXECUTABLE

NAME = help
NAME_DEBUG = output-debug

SRC_FOLDER = src/
INC_FOLDER = inc/
BUILD_FOLDER = build/

CC = clang
CFLAGS_COMMON = -Wall -Wextra -Werror -Weverything -pedantic -std=c17
CFLAGS_RELEASE = -O2 -DNDEBUG
CFLAGS_DEBUG = -O0 -ggdb -DDEBUG
LDFLAGS =
LDLIBS =

SRC = \
	main.c \
	print_mini_project.c \
