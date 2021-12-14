
SHELL := /bin/sh
.SUFFIXES:

###############################################################################
#########                                                            ##########
#########                           PRELUDE                          ##########
#########                                                            ##########
###############################################################################

######### Define termcap values if possible

_RED    := $(shell tput setaf 1 2> /dev/null || echo -n "")
_GREEN  := $(shell tput setaf 2 2> /dev/null || echo -n "")
_YELLOW := $(shell tput setaf 3 2> /dev/null || echo -n "")
_BLUE   := $(shell tput setaf 4 2> /dev/null || echo -n "")
_PURPLE := $(shell tput setaf 5 2> /dev/null || echo -n "")
_CYAN   := $(shell tput setaf 6 2> /dev/null || echo -n "")
_WHITE  := $(shell tput setaf 7 2> /dev/null || echo -n "")
_END    := $(shell tput sgr0 2> /dev/null || echo -n "")

######### Define print functions

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

define _print_progress # 1:name of file to compile as argument
	printf " %s[%2s/%2s]%s  %sCompile%s      %-55s\\n" \
		"$(_CYAN)" "$(_NB_ACTU)" "$(_NB_TO_COMP)" "$(_END)" \
		"$(_GREEN)" "$(_END)" \
		"\`$(strip $(1))\`"
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
	$(foreach err,$(1),printf " %s[ INFO ]%s Cannot define variable: %s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(err)";)
endef

define _print_missing_variables # 1:list of missing variables
	$(foreach err,$(1),printf " %s[ INFO ]%s Variable not defined: %s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(err)";)
endef

define _print_missing_files # 1:list of files in spec but no exist, 2:list of files that exist but not in spec
	$(foreach file, $(1), printf " %s[ INFO ]%s This file is in the config file (\`%s\`) but doesn't exist: %s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_CONFIG_FILE)" \
		"$(file)";)
	$(foreach file, $(2), printf " %s[ INFO ]%s This file exists but it isn't in the config file (\`%s\`): %s\\n" \
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

######### Define makefile functions

rwildcard              = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
file_defined_variables = $(foreach V, $(sort $(.VARIABLES)), $(if $(filter $(origin $(V)),file),$(V),))

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

_MAKEFILE_DEFINED_VARIABLES := $(call file_defined_variables) _MAKEFILE_DEFINED_VARIABLES

include $(_CONFIG_FILE)

_USER_DEFINED_VARIABLES := $(filter-out $(_MAKEFILE_DEFINED_VARIABLES), $(call file_defined_variables))

######### Verify unauthorized variables in config.mk

_AUTHORIZED_VARIABLES_CONFIG :=
_AUTHORIZED_VARIABLES_CONFIG += NAME
_AUTHORIZED_VARIABLES_CONFIG += NAME_DEBUG
_AUTHORIZED_VARIABLES_CONFIG += INC_FOLDER
_AUTHORIZED_VARIABLES_CONFIG += SRC_FOLDER
_AUTHORIZED_VARIABLES_CONFIG += BUILD_FOLDER
_AUTHORIZED_VARIABLES_CONFIG += CC
_AUTHORIZED_VARIABLES_CONFIG += CFLAGS_COMMON
_AUTHORIZED_VARIABLES_CONFIG += CFLAGS_RELEASE
_AUTHORIZED_VARIABLES_CONFIG += CFLAGS_DEBUG
_AUTHORIZED_VARIABLES_CONFIG += LDFLAGS
_AUTHORIZED_VARIABLES_CONFIG += LDLIBS
_AUTHORIZED_VARIABLES_CONFIG += SRC

_ERRORS_UNAUTHORIZED_VARIABLES := $(filter-out $(_AUTHORIZED_VARIABLES_CONFIG), $(_USER_DEFINED_VARIABLES))

ifneq ($(_ERRORS_UNAUTHORIZED_VARIABLES),)
_HAS_ERROR = 1
_HAS_ERROR_UNAUTHORIZED_VARIABLES = 1
endif

######### Verify missing variables in config.mk

_ERRORS_MISSING_VARIABLES :=

_ERRORS_MISSING_VARIABLES += $(if $(value NAME),,NAME)
_ERRORS_MISSING_VARIABLES += $(if $(value NAME_DEBUG),,NAME_DEBUG)
_ERRORS_MISSING_VARIABLES += $(if $(value INC_FOLDER),,INC_FOLDER)
_ERRORS_MISSING_VARIABLES += $(if $(value SRC_FOLDER),,SRC_FOLDER)
_ERRORS_MISSING_VARIABLES += $(if $(value BUILD_FOLDER),,BUILD_FOLDER)
_ERRORS_MISSING_VARIABLES += $(if $(value SRC),,SRC)

ifneq ($(strip $(_ERRORS_MISSING_VARIABLES)),)
_HAS_ERROR = 1
_HAS_ERROR_MISSING_VARIABLES = 1
else #endif will end at end of load config.mk

######### Define variables

_DEBUG   ?= 0
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

_SRC_WILDCARDED := $(call rwildcard, $(patsubst %/,%,$(_SRC_FOLDER)), *.c)

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

ifeq ($(_HAS_ERROR),1)

.DEFAULT_GOAL: report_error
.DEFAULT: report_error

.PHONY: report_error
report_error:
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

$(MAKECMDGOALS): report_error

else # will end at end of Makefile

###############################################################################
#########                                                            ##########
#########                            RULES                           ##########
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

.PHONY: all
all: $(_NAME_TARGET)

$(_NAME_TARGET): INIT $(_OBJ)
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
#   The structure of the makefile will not be able to relink because of the INIT target
#   So we increment the _NB_TO_COMP by one in order to force it
.PHONY: INIT
INIT:
	@ $(eval _NB_TO_COMP := \
		$(shell $(MAKE) _COUNT_OBJS=YES _DEBUG=$(_DEBUG) $(_OBJ) | grep +1 | wc -l))
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

.PHONY: clean
clean: _clean_build_dir
	@ $(call _print_end_clean)

.PHONY: fclean
fclean: _clean_build_dir
	@ ! test -f "$(_NAME)" || $(call _print_clean_bin,$(_NAME))
	@ ! test -f "$(_NAME)" || $(call cmd, rm -f $(_NAME))
	@ ! test -f "$(_NAME_DEBUG)" || $(call _print_clean_bin,$(_NAME_DEBUG))
	@ ! test -f "$(_NAME_DEBUG)" || $(call cmd, rm -f $(_NAME_DEBUG))
	@ $(call _print_end_fclean)

.PHONY: re
re: fclean all

######### Manage debug

.PHONY: debug
debug:
	@ $(MAKE) --no-print-directory _DEBUG=1 all

ifeq ($(_DEBUG),0)
$(_NAME_DEBUG): debug
endif

.PHONY: redebug
redebug:
	@ $(MAKE) --no-print-directory _DEBUG=1 re

endif #endif of error reporting
