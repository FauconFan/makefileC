
SHELL := bash
.SUFFIXES:
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

_SELF_PROJECT_NAME   := makefileC
_SELF_URL_RELEASE    := https://raw.githubusercontent.com/FauconFan/$(_SELF_PROJECT_NAME)/master/Makefile

###############################################################################
#########                                                            ##########
#########                     PRELUDE - variables                    ##########
#########                                                            ##########
###############################################################################

######### Define termcap values if possible

_RED		:= $(shell tput setaf 1 2> /dev/null || echo -n "")
_GREEN		:= $(shell tput setaf 2 2> /dev/null || echo -n "")
_YELLOW		:= $(shell tput setaf 3 2> /dev/null || echo -n "")
_BLUE		:= $(shell tput setaf 4 2> /dev/null || echo -n "")
_PURPLE		:= $(shell tput setaf 5 2> /dev/null || echo -n "")
_CYAN		:= $(shell tput setaf 6 2> /dev/null || echo -n "")
_WHITE		:= $(shell tput setaf 7 2> /dev/null || echo -n "")
_END		:= $(shell tput sgr0 2> /dev/null || echo -n "")

######### "Constants"

_empty				:=
_space				:= $(_empty) $(_empty)
_impossible_pattern	:= ¤µ§£¢42Ł£§µ£

###############################################################################
#########                                                            ##########
#########                  PRELUDE - "functions" lib                 ##########
#########                                                            ##########
###############################################################################

### Function to compute all files that respects a pattern recursively in a directory
#### $(1): The directory to "scan"
#### $(2): The pattern
####   example: $(call _rwildcard, $(SRC_FOLDER), *.c)
_rwildcard_rec		= $(foreach d, $(wildcard $(1:=/*)), \
						$(call _rwildcard_rec, $(d), $(2)) \
						$(filter $(subst *,%, $(2)), $(d)))
_rwildcard			= $(call _rwildcard_rec, $(patsubst %/,%,$(1)), $(2))

### Function to generate all variables defined in files like this Makefile or config.mk
#### Takes no arguments (is expanded when called)
####   example: $(call _file_defined_variables)
_file_defined_variables		= $(foreach V, $(sort $(.VARIABLES)), \
								$(if $(filter $(origin $(V)),file), \
									$(V), \
									) \
								)

### Functions that increments or decrements an integer by one
#### $(1): The integer
####   example: $(call _inc_int, 2)
####   example: $(call _dec_int, 2)
_inc_int			= $(shell echo $(1) + 1 | bc)
_dec_int			= $(shell echo $(1) - 1 | bc)

### Functions that (un)merge a list of words together in order to make them like one
#### $(1): The list of words to be merged
#### $(1): OR the word that needs to be unmerged
####   example: $(call _merge_words,I am a sentence that needs to be merged)
####   example: $(call _unmerge_words,I¤µ§£¢42Ł£§µ£am¤µ§£¢42Ł£§µ£a¤µ§£¢42Ł£§µ£sentence¤µ§£¢42Ł£§µ£that¤µ§£¢42Ł£§µ£needs¤µ§£¢42Ł£§µ£to¤µ§£¢42Ł£§µ£be¤µ§£¢42Ł£§µ£merged)
_merge_words		= $(subst $(_space),$(_impossible_pattern),$(strip $(1)))
_unmerge_words		= $(subst $(_impossible_pattern),$(_space),$(strip $(1)))

### _select: Function that takes a list of words and returns only words that are requested
#### $(1): The list of words
#### $(2): The indexes (starts 0) of words we want to keep
####   example: $(call _select, ONE TWO THREE FOUR, 1 3) <- will correspond to "TWO FOUR"
_select_eff			= $(foreach var,$(2), $(word $(var), $(1)))
_select				= $(call _select_eff,$(1),$(foreach i,$(2),$(call _inc_int, $(i))))

### _select_mod: Function that takes a list of words and returns only words that are in a
###              certain place in a cycle (k mod n)
#### $(1): The list of words
#### $(2): The number k -> The k-th word(s) of every group (starts from 0)
#### $(3): The number n -> The size of a group
####   example: $(call _select_mod, ZERO ONE TWO THREE FOUR FIVE, 0 1, 3) <- will correspond to "ZERO ONE THREE FOUR"
_select_mod_rec		= $(if $(strip $(1)), \
							$(call _select,$(1),$(2)) \
							$(call _select_mod_rec, \
								$(wordlist $(3),$(words $(1)),$(1)), \
								$(2), \
								$(3)) \
							, \
						)
_select_mod			= $(call _select_mod_rec, \
						$(1), \
						$(2), \
						$(call _inc_int, $(3)))

### _select_on_mod: Function that takes a list of words and returns only words that are in a
###                 certain place in a cycle (k mod n) and when a certain word in the group
###                 have a given value
#### $(1): The list of words
#### $(2): The number k -> The k-th word(s) of every group (starts from 0)
#### $(3): The number n -> The size of a group
#### $(4): The number l -> The l-th word that will be testes (starts from 0)
#### $(5): The value that word l must have in order to be selected
####   example: $(call _select_on_mod, ONE EVEN TWO ODD, 0, 2, 1, EVEN) -> will correspond to "ONE"
_select_on_mod_rec	= $(if $(strip $(1)), \
							$(if $(filter $(5),$(word $(4),$(1))), \
								$(call _select,$(1),$(2)) \
								, \
							) \
							$(call _select_on_mod_rec, \
								$(wordlist $(3),$(words $(1)),$(1)), \
								$(2), \
								$(3), \
								$(4), \
								$(5)) \
							, \
						)
_select_on_mod		= $(call _select_on_mod_rec, \
						$(1), \
						$(2), \
						$(call _inc_int, $(3)), \
						$(call _inc_int, $(4)), \
						$(5))

### _foreach2: Function that applies some kind of foreach on pair of elements in a "table"
###            _unmerge_words is called on the pattern if it's called with a field that was 
###            "merged" with _merge_words
#### $(1): The name of the first element of the pair
#### $(2): The name of the second element of the pair
#### $(3): The table
#### $(4): The pattern with which we will replace the elements of the pair, each variable must
####       be preceded with the special character @
####   example: $(call _foreach2, animal, speed, TURTLE slow RABBIT fast, printf "%s is %s\\n" "@animal" "@speed";)
####            ^ This will correspond to printing the table with printf within a target
_foreach2			= $(if $(strip $(3)), \
							$(call _unmerge_words, \
								$(subst @$(strip $(1)),$(word 1,$(3)), \
								$(subst @$(strip $(2)),$(word 2,$(3)),$(4)))) \
							$(call _foreach2, \
								$(1), \
								$(2), \
								$(wordlist 3,$(words $(3)),$(3)), \
								$(4)) \
							, \
						)

###############################################################################
#########                                                            ##########
#########                        PRELUDE - SCT                       ##########
#########                                                            ##########
###############################################################################

######### Self config tables (or SCT)

# Columns:
#   rule				description
_SCT_TARGETS := \
	all					$(call _merge_words,Builds the release binary) \
	clean				$(call _merge_words,Removes generated files except binaries) \
	fclean				$(call _merge_words,Removes all generated files) \
	re					$(call _merge_words,Alias for \"make fclean && make all\") \
	debug				$(call _merge_words,Same as \"make all\" except it uses debug flags) \
	redebug				$(call _merge_words,Alias for \"make fclean && make debug\") \
	self_update			$(call _merge_words,Self update from remote if new version is available) \
	self_update_ignore	$(call _merge_words,Ignore self reminder for a short time) \
	init				$(call _merge_words,Initialize the project (at start only)) \
	help				$(call _merge_words,Prints this message) \

_SCT_TARGETS_NAMES      := $(call _select_mod,$(_SCT_TARGETS), 0, 2)
_SCT_TARGETS_HELP       := $(call _select_mod,$(_SCT_TARGETS), 1, 2)

_SCT_SELF_UPDATE_DESCRIPTION        := $(call _unmerge_words,$(strip $(call _select_on_mod,$(_SCT_TARGETS), 1, 2, 0, self_update)))
_SCT_SELF_UPDATE_IGNORE_DESCRIPTION := $(call _unmerge_words,$(strip $(call _select_on_mod,$(_SCT_TARGETS), 1, 2, 0, self_update_ignore)))

# Columns:
#   name variable		isMandatory
_SCT_VARIABLES := \
	NAME				TRUE \
	NAME_DEBUG			TRUE \
	INC_FOLDER			TRUE \
	SRC_FOLDER			TRUE \
	BUILD_FOLDER		TRUE \
	CC					FALSE \
	CFLAGS_COMMON		FALSE \
	CFLAGS_RELEASE		FALSE \
	CFLAGS_DEBUG		FALSE \
	LDFLAGS				FALSE \
	LDLIBS				FALSE \
	SRC					TRUE \

_SCT_VARIABLES_ALL       := $(call _select_mod,$(_SCT_VARIABLES), 0, 2)
_SCT_VARIABLES_MANDATORY := $(call _select_on_mod,$(_SCT_VARIABLES), 0, 2, 1, TRUE)

###############################################################################
#########                                                            ##########
#########              PRELUDE - default content (init)              ##########
#########                                                            ##########
###############################################################################

define _DEFAULT_CONFIG_MK_CONTENT

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
CC = clang
## C Flags
CFLAGS_COMMON = -Wall -Wextra -Werror -Weverything -pedantic -std=c17
CFLAGS_RELEASE = -O2 -DNDEBUG
CFLAGS_DEBUG = -O0 -ggdb -DDEBUG
## LD Flags
LDFLAGS =
## Libs Flags
LDLIBS =

# Exhaustive list of the source files (base dir is $$(SRC_FOLDER))
# All your source code files must be in $$(SRC_FOLDER)
SRC = $\\
	main.c $\\

endef

define _DEFAULT_MAIN_C_CONTENT
#include "main.h"

int		main(int argc, char **argv, char **envp) {
	(void) argc;
	(void) argv;
	(void) envp;
	printf("Hello World\n");
	return 0;
}
endef

define _DEFAULT_MAIN_H_CONTENT
#ifndef MAIN_H
# define MAIN_H

# include <stdio.h>

#endif
endef

###############################################################################
#########                                                            ##########
#########               PRELUDE - helpers for printing               ##########
#########                                                            ##########
###############################################################################

######### Define print functions

define _print_help
	printf "Usage: make %s[target]%s\\n" "$(_CYAN)" "$(_END)"
	printf "\\n"
	printf "Here is the list of targets:\\n"
	$(call _foreach2, target, description,$(_SCT_TARGETS), \
		printf "%2s%-2smake %s%-25s%s %s\\n" \
			"" "-" \
			"$(_CYAN)" "@target" "$(_END)" \
			"@description";)
endef

define _print_name
	printf " %s[ INFO ]%s %sAssemble%s     %s\`%s\`%s  %-s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_GREEN)" "$(_END)" \
		"$(_YELLOW)" "$(_NAME_TARGET)" "$(_END)" ""
endef

define _print_nothing_to_relink
	printf " %s[ INFO ]%s Nothing to recompile\\n" \
		"$(_CYAN)" "$(_END)"
endef

define _print_cmd # 1:cmd
	printf " %s[ CMD ]%s %s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(1)"
endef

define _print_init
	printf " %s[ INFO ]%s %sInitialization%s of the project\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_GREEN)" "$(_END)"
endef

define _print_progress # 1:name of file to compile as argument
	printf " %s[%2s/%2s]%s  %sCompile%s      %-55s\\n" \
		"$(_CYAN)" "$(_NB_ACTU)" "$(_NB_TO_COMP)" "$(_END)" \
		"$(_GREEN)" "$(_END)" \
		"\`$(strip $(1))\`"
endef

define _print_can_update
	printf " %s[ UPDATE ]%s %sA new version of $(_SELF_PROJECT_NAME) is available%s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_PURPLE)" "$(_END)"
	printf " %s[ UPDATE ]%s   %sYou can either:%s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_PURPLE)" "$(_END)"
	printf " %s[ UPDATE ]%s     %s- \`make self_update\`: $(_SCT_SELF_UPDATE_DESCRIPTION)%s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_PURPLE)" "$(_END)"
	printf " %s[ UPDATE ]%s     %s- \`make self_update_ignore\`: $(_SCT_SELF_UPDATE_IGNORE_DESCRIPTION)%s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_PURPLE)" "$(_END)"
endef

define _print_self_update
	printf " %s[ INFO ]%s %sUpdate%s       $(_SELF_REALPATH) has been updated\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_PURPLE)" "$(_END)"
endef

define _print_self_update_ignore
	printf " %s[ INFO ]%s %sIgnore%s       reminder has been muted\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_PURPLE)" "$(_END)"
endef

define _print_clean_build_dir
	printf " %s[ INFO ]%s %sRemove%s       object and dependency files\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_RED)" "$(_END)"
endef

define _print_clean_bin # 1: name of the file that was removed
	printf " %s[ INFO ]%s %sRemove%s       %s\`%s\`%s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_RED)" "$(_END)" \
		"$(_YELLOW)" "$(strip $(1))" "$(_END)"
endef

define _print_end_clean
	printf " %s[ INFO ]%s %sClean%s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_RED)" "$(_END)"
endef

define _print_end_fclean
	printf " %s[ INFO ]%s %sFull clean%s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_RED)" "$(_END)"
endef

define _print_missing_config_mk
	printf " %s[ INFO ]%s \`%s\` is missing\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_CONFIG_FILE)"
endef

define _print_unauthorized_variables # 1:list of unauthorized variables
	$(foreach err,$(1), \
		printf " %s[ INFO ]%s Cannot define variable: %s\\n" \
			"$(_CYAN)" "$(_END)" \
			"$(err)";)
endef

define _print_missing_variables # 1:list of missing variables
	$(foreach err,$(1), \
		printf " %s[ INFO ]%s Variable not defined: %s\\n" \
			"$(_CYAN)" "$(_END)" \
			"$(err)";)
endef

define _print_missing_files # 1:list of files in spec but no exist, 2:list of files that exist but not in spec
	$(foreach file, $(1), \
		printf " %s[ INFO ]%s This file is in the config file (\`%s\`) but doesn't exist: %s\\n" \
			"$(_CYAN)" "$(_END)" \
			"$(_CONFIG_FILE)" \
			"$(file)";)
	$(foreach file, $(2), \
		printf " %s[ INFO ]%s This file exists but it isn't in the config file (\`%s\`): %s\\n" \
			"$(_CYAN)" "$(_END)" \
			"$(_CONFIG_FILE)" \
			"$(file)";)
endef

define _print_end_error_reporting
	printf " %s[ INFO ]%s create or change your \`%s\` file accordingly\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_CONFIG_FILE)"
	printf " %s[ INFO ]%s aborting\\n" \
		"$(_CYAN)" "$(_END)"
endef

###############################################################################
#########                                                            ##########
#########                         SELF UPDATE                        ##########
#########                                                            ##########
###############################################################################

_SELF_LOCAL_DIR         := ~/.$(_SELF_PROJECT_NAME)
_SELF_LATEST_MAKEFILE   := $(_SELF_LOCAL_DIR)/latest.mk
_SELF_IGNORE_FILE       := $(_SELF_LOCAL_DIR)/ignore
_SELF_REFRESH_CHECK     := 1 day

_SELF_NEED_DOWNLOAD     := 0
_SELF_CAN_UPDATE        := 0

_IGNORE_SELF_UPDATE     ?= 0

_SELF_REALPATH          := $(shell realpath $(lastword $(MAKEFILE_LIST)))

_SELF_CMD_IGNORE_UPDATE := touch $(_SELF_IGNORE_FILE)
_SELF_CMD_UPDATE        := cp $(_SELF_LATEST_MAKEFILE) $(_SELF_REALPATH)

######### Create local dir if not exists

ifeq ($(wildcard $(_SELF_LOCAL_DIR)),)
$(shell mkdir $(_SELF_LOCAL_DIR))
endif

ifeq ($(wildcard $(_SELF_IGNORE_FILE)),)
$(shell touch -t $(shell date -d "$(_SELF_REFRESH_CHECK) ago" "+%Y%m%d%H%M.%S") $(_SELF_IGNORE_FILE))
endif

######### Check if download the makefile from GitHub is necessary

ifeq ($(wildcard $(_SELF_LATEST_MAKEFILE)),)
_SELF_NEED_DOWNLOAD = 1
else

ifeq ($(shell test "$(shell stat --format=%Y $(_SELF_LATEST_MAKEFILE))" -gt \
	"$(shell date -d "$(_SELF_REFRESH_CHECK) ago" +%s)" || echo 1),1)
_SELF_NEED_DOWNLOAD = 1
endif

endif

######### Downloading

ifeq ($(_SELF_NEED_DOWNLOAD),1)
$(shell curl -s -o $(_SELF_LATEST_MAKEFILE) $(_SELF_URL_RELEASE))
endif

######### Checking if you can update

ifneq ($(shell diff $(_SELF_REALPATH) $(_SELF_LATEST_MAKEFILE)),)
_SELF_CAN_UPDATE = 1
endif

######### Ignore self update if specified

ifeq ($(shell test "$(shell stat --format=%Y $(_SELF_IGNORE_FILE))" -lt \
	"$(shell date -d "$(_SELF_REFRESH_CHECK) ago" +%s)" || echo 1),1)
_SELF_CAN_UPDATE = 0
endif

ifeq ($(_IGNORE_SELF_UPDATE),1)
_SELF_CAN_UPDATE = 0
endif

###############################################################################
#########                                                            ##########
#########                      LOAD `config.mk`                      ##########
#########                                                            ##########
###############################################################################

_HAS_ERROR                               := 0
_HAS_ERROR_MISSING_CONFIG_FILE           := 0
_HAS_ERROR_UNAUTHORIZED_VARIABLES        := 0
_HAS_ERROR_MISSING_VARIABLES             := 0
_HAS_ERROR_UNCONSISTENT_FILES            := 0

_CONFIG_FILE := ./config.mk

######### Include `config.mk`

ifeq ($(wildcard $(_CONFIG_FILE)),)
_HAS_ERROR = 1
_HAS_ERROR_MISSING_CONFIG_FILE = 1
else #endif will end at end of load config.mk

_MAKEFILE_DEFINED_VARIABLES := $(call _file_defined_variables) _MAKEFILE_DEFINED_VARIABLES

include $(_CONFIG_FILE)

_USER_DEFINED_VARIABLES := $(filter-out $(_MAKEFILE_DEFINED_VARIABLES), $(call _file_defined_variables))

######### Verify unauthorized variables in config.mk

_ERRORS_UNAUTHORIZED_VARIABLES := $(filter-out $(_SCT_VARIABLES_ALL), $(_USER_DEFINED_VARIABLES))

ifneq ($(_ERRORS_UNAUTHORIZED_VARIABLES),)
_HAS_ERROR = 1
_HAS_ERROR_UNAUTHORIZED_VARIABLES = 1
endif

######### Verify missing variables in config.mk

_ERRORS_MISSING_VARIABLES := $(foreach MANDATORY_VARIABLE,$(_SCT_VARIABLES_MANDATORY), \
								$(if $($(MANDATORY_VARIABLE)),,$(MANDATORY_VARIABLE)))

ifneq ($(strip $(_ERRORS_MISSING_VARIABLES)),)
_HAS_ERROR = 1
_HAS_ERROR_MISSING_VARIABLES = 1
else #endif will end at end of load config.mk

######### Define variables

_DEBUG  ?= 0
VERBOSE ?= 0

_NAME                 := $(strip $(NAME))
_NAME_DEBUG           := $(strip $(NAME_DEBUG))
_INC_FOLDER           := $(strip $(INC_FOLDER))
_SRC_FOLDER           := $(strip $(SRC_FOLDER))
_BUILD_FOLDER         := $(strip $(BUILD_FOLDER))

_NAME_TARGET          := $(if $(filter 0, $(_DEBUG)),$(_NAME),$(_NAME_DEBUG))
_TARGET               := $(if $(filter 0, $(_DEBUG)),release,debug)

_BUILD_TARGET_FOLDER  := $(subst /,,$(_BUILD_FOLDER))/$(_TARGET)/

######### Default values if not set by default

CFLAGS_COMMON  ?= -Wall -Wextra -Werror -Weverything -pedantic -std=c17
CFLAGS_RELEASE ?= -O2 -DNDEBUG
CFLAGS_DEBUG   ?= -O0 -DDEBUG -ggdb

CFLAGS_COMMON  += -MMD

_CC         := $(if $(filter-out $(origin CC),default),$(CC),clang)
_IFLAGS     := -I $(_INC_FOLDER)
_LDFLAGS    := $(if $(filter-out $(origin LDFLAGS),default),$(LDFLAGS),)
_LDLIBS     := $(if $(filter-out $(origin LDLIBS),default),$(LDLIBS),)

_CFLAGS     := $(CFLAGS_COMMON) $(if $(filter 0, $(_DEBUG)), $(CFLAGS_RELEASE), $(CFLAGS_DEBUG))

######### Generating variables for files

_SRC := $(SRC:%.c=$(_SRC_FOLDER)%.c)
_OBJ := $(SRC:%.c=$(_BUILD_TARGET_FOLDER)%.o)
_DEP := $(SRC:%.c=$(_BUILD_TARGET_FOLDER)%.d)

######### Verify missing files in config.mk

_SRC_WILDCARDED := $(call _rwildcard, $(_SRC_FOLDER), *.c)

_ERRORS_SRC_SPEC_NO_EXISTS := $(sort $(filter-out $(_SRC_WILDCARDED), $(_SRC)))
_ERRORS_SRC_EXISTS_NO_SPEC := $(sort $(filter-out $(_SRC), $(_SRC_WILDCARDED)))

ifneq ($(strip $(_ERRORS_SRC_SPEC_NO_EXISTS) $(_ERRORS_SRC_EXISTS_NO_SPEC)),)
_HAS_ERROR = 1
_HAS_ERROR_UNCONSISTENT_FILES = 1
endif

endif #endif for errors missing variables
endif #endif of include _CONFIG_FILE

###############################################################################
#########                                                            ##########
#########                       ERROR REPORTING                      ##########
#########                                                            ##########
###############################################################################

_ALLOW_INIT_WHEN_MISSING_FILE = 0

ifeq ($(_HAS_ERROR),1)
ifeq ($(_HAS_ERROR_MISSING_CONFIG_FILE),1)
ifeq ($(MAKECMDGOALS),init)
_ALLOW_INIT_WHEN_MISSING_FILE = 1
endif
endif
endif

ifeq ($(_HAS_ERROR),1)
ifeq ($(_ALLOW_INIT_WHEN_MISSING_FILE),0)

.PHONY: default
default:
ifeq ($(_HAS_ERROR_MISSING_CONFIG_FILE),1)
	@ $(call _print_missing_config_mk)
endif
ifeq ($(_HAS_ERROR_UNAUTHORIZED_VARIABLES),1)
	@ $(call _print_unauthorized_variables, $(_ERRORS_UNAUTHORIZED_VARIABLES))
endif
ifeq ($(_HAS_ERROR_MISSING_VARIABLES),1)
	@ $(call _print_missing_variables, $(_ERRORS_MISSING_VARIABLES))
endif
ifeq ($(_HAS_ERROR_UNCONSISTENT_FILES),1)
	@ $(call _print_missing_files, $(_ERRORS_SRC_SPEC_NO_EXISTS), $(_ERRORS_SRC_EXISTS_NO_SPEC))
endif
	@ $(call _print_end_error_reporting)
	@ false

ifneq ($(MAKECMDGOALS),)
$(MAKECMDGOALS): default
endif
endif

else # will end at end of Makefile (before init)

###############################################################################
#########                                                            ##########
#########                         CORE RULES                         ##########
#########                                                            ##########
###############################################################################

######### Manage verbose

ifeq ($(VERBOSE),0)

define cmd #1: command to run
	($(1))
endef

else

define cmd #1: command to run
	($(1) && $(call _print_cmd, $(strip $(1))))
endef

endif

######### Core rules

.PHONY: default
default: all

.PHONY: all
all: _show_self_update $(_NAME_TARGET)

$(_NAME_TARGET): _precomp $(_OBJ)
	@ ! test "$(_NB_TO_COMP)" -eq 0 || $(call _print_nothing_to_relink)
	@ ! test "$(_NB_TO_COMP)" -ne 0 || $(call cmd, $(_CC) $(_CFLAGS) $(_IFLAGS) $(_LDFLAGS) -o $@ $(_OBJ) $(_LDLIBS))
	@ ! test "$(_NB_TO_COMP)" -ne 0 || $(call _print_name)

ifdef _COUNT_OBJS

$(_BUILD_TARGET_FOLDER)%.o: $(_SRC_FOLDER)%.c
	@ echo "+1"

else

$(_BUILD_TARGET_FOLDER)%.o: $(_SRC_FOLDER)%.c
	@ mkdir -p $(dir $@)
	@ $(call cmd, $(_CC) $(_CFLAGS) $(_IFLAGS) -c $< -o $@)
	@ $(eval _NB_ACTU := $(shell echo $$(( $(_NB_ACTU) + 1 )) ))
	@ $(call _print_progress, $<)

endif

-include $(_DEP)

# Computes the number of files that will be recompiled and store it in _NB_TO_COMP
# The second eval manages to check somehow the final binary has been removed
#   The structure of the makefile will not be able to relink because of the _precomp target
#   So we increment the _NB_TO_COMP by one in order to force it
.PHONY: _precomp
_precomp:
	@ $(eval _NB_TO_COMP := \
		$(shell $(MAKE) _COUNT_OBJS=YES _DEBUG=$(_DEBUG) _IGNORE_SELF_UPDATE=1 $(_OBJ) | grep +1 | wc -l))
	@ $(eval _NB_TO_COMP := \
		$(shell echo $$(( $(_NB_TO_COMP) + \
			0$(shell test "$(_NB_TO_COMP)" -eq 0 -a ! -f "$(_NAME_TARGET)" && echo 1) \
		)) ) \
	  )

	@ $(eval _NB_ACTU := 0)

.PHONY: _clean_build_dir
_clean_build_dir:
	@ ! test -d "$(_BUILD_FOLDER)" || $(call _print_clean_build_dir)
	@ ! test -d "$(_BUILD_FOLDER)" || $(call cmd, rm -rf $(_BUILD_FOLDER))

.PHONY: _fclean_binaries
_fclean_binaries:
	@ ! test -f "$(_NAME)" || $(call _print_clean_bin,$(_NAME))
	@ ! test -f "$(_NAME)" || $(call cmd, rm -f $(_NAME))
	@ ! test -f "$(_NAME_DEBUG)" || $(call _print_clean_bin,$(_NAME_DEBUG))
	@ ! test -f "$(_NAME_DEBUG)" || $(call cmd, rm -f $(_NAME_DEBUG))

.PHONY: clean
clean: _show_self_update _clean_build_dir
	@ $(call _print_end_clean)

.PHONY: fclean
fclean: _show_self_update _clean_build_dir _fclean_binaries
	@ $(call _print_end_fclean)

.PHONY: re
re: fclean all

######### Manage debug

.PHONY: debug
debug: _show_self_update
	@ $(MAKE) --no-print-directory _DEBUG=1 _IGNORE_SELF_UPDATE=1 all

ifeq ($(_DEBUG),0)
$(_NAME_DEBUG): debug
endif

.PHONY: redebug
redebug: _show_self_update
	@ $(MAKE) --no-print-directory _DEBUG=1 _IGNORE_SELF_UPDATE=1 re

######### Manage help

.PHONY: help
help: _show_self_update
	@ $(call _print_help)

######### Manage self update

.PHONY: _show_self_update
_show_self_update:
ifeq ($(_SELF_CAN_UPDATE),1)
	@ $(call _print_can_update)
endif

.PHONY: self_update_ignore
self_update_ignore:
	@ $(call _print_self_update_ignore)
	@ $(_SELF_CMD_IGNORE_UPDATE)

.PHONY: self_update
self_update:
	@ $(call _print_self_update)
	@ $(_SELF_CMD_UPDATE)

endif #endif of error reporting

######### Manage init

ifeq ($(_ALLOW_INIT_WHEN_MISSING_FILE),1)

.PHONY: init
init:
	@ $(call _print_init)
	@ mkdir inc
	@ mkdir src
	@ $(file > config.mk,$(_DEFAULT_CONFIG_MK_CONTENT))
	@ $(file > main.c,$(_DEFAULT_MAIN_C_CONTENT))
	@ $(file > main.h,$(_DEFAULT_MAIN_H_CONTENT))
	@ mv main.c src/
	@ mv main.h inc/

endif

######### Manage printing variables for CI purposes (not documented in the API)

.PHONY: _printvar_%
_printvar_%:
	@ echo $($*)
