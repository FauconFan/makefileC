
SELF_URL_GIT = https://github.com/fauconfan/makefileC
SELF_URL_MAKEFILE = https://raw.githubusercontent.com/FauconFan/makefileC/master/Makefile
SELF_URL_MAKEFILE_CONFIG_TEMPLATE = https://raw.githubusercontent.com/FauconFan/makefileC/master/template.config.mk

###############################################################################
#########                                                            ##########
#########                           PRELUDE                          ##########
#########                                                            ##########
###############################################################################

######### Define termcap values if possible

_RED=$(shell tput setaf 1 2> /dev/null || echo -n "")
_GREEN=$(shell tput setaf 2 2> /dev/null || echo -n "")
_YELLOW=$(shell tput setaf 3 2> /dev/null || echo -n "")
_BLUE=$(shell tput setaf 4 2> /dev/null || echo -n "")
_PURPLE=$(shell tput setaf 5 2> /dev/null || echo -n "")
_CYAN=$(shell tput setaf 6 2> /dev/null || echo -n "")
_WHITE=$(shell tput setaf 7 2> /dev/null || echo -n "")
_END=$(shell tput sgr0 2> /dev/null || echo -n "")

######### Define print functions

define print_name
	printf " %s[ INFO ]%s %sAssemble%s     %s\`%s\`%s  %-s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_GREEN)" "$(_END)" \
		"$(_YELLOW)" "$(_NAME_TARGET)" "$(_END)" ""
endef

define print_nothing_to_relink
	printf " %s[ INFO ]%s Nothing to recompile\\n" \
		"$(_CYAN)" "$(_END)"
endef

define print_cmd # 1:cmd
	printf " %s[ CMD ]%s %s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(1)"
endef

define print_progress # 1:name of file to compile as argument
	printf " %s[%2s/%2s]%s  %sCompile%s      %-55s\\n" \
		"$(_CYAN)" "$(_NB_ACTU)" "$(_NB_TO_COMP)" "$(_END)" \
		"$(_GREEN)" "$(_END)" \
		"\`$(strip $(1))\`"
endef

define print_clean
	printf " %s[ INFO ]%s %sRemove%s       object and dependency files\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_RED)" "$(_END)"
endef

define print_fclean
	printf " %s[ INFO ]%s %sRemove%s       %s\`%s\`%s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_RED)" "$(_END)" \
		"$(_YELLOW)" "$(_NAME)" "$(_END)"
	printf " %s[ INFO ]%s %sRemove%s       %s\`%s\`%s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_RED)" "$(_END)" \
		"$(_YELLOW)" "$(_NAME_DEBUG)" "$(_END)"
endef

define print_missing_config_mk
	printf " %s[ INFO ]%s \`%s\` is missing\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_CONFIG_FILE)"
endef

define print_missing_values # 1:list of missing variables
	$(foreach err,$(1),printf " %s[ INFO ]%s Variable not defined: %s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(err)";)
endef

define print_missing_files # 1:list of files in spec but no exist, 2:list of files that exist but not in spec
	$(foreach file, $(1), printf " %s[ INFO ]%s This file is in the config file (\`%s\`) but doesn't exist: %s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_CONFIG_FILE)" \
		"$(file)";)
	$(foreach file, $(2), printf " %s[ INFO ]%s This file exists but it isn't in the config file (\`%s\`): %s\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_CONFIG_FILE)" \
		"$(file)";)
endef

define print_end_error_reporting
	printf " %s[ INFO ]%s create or change your \`%s\` file accordingly\\n" \
		"$(_CYAN)" "$(_END)" \
		"$(_CONFIG_FILE)"
	printf " %s[ INFO ]%s aborting\\n" \
		"$(_CYAN)" "$(_END)"
endef

###############################################################################
#########                                                            ##########
#########                      LOAD `config.mk`                      ##########
#########                                                            ##########
###############################################################################

_HAS_ERROR                      := 0
_HAS_ERROR_MISSING_CONFIG_FILE  := 0
_HAS_ERROR_MISSING_VARIABLES    := 0
_HAS_ERROR_UNCONSISTENT_FILES   := 0

_CONFIG_FILE := ./config.mk

######### Include `config.mk`

ifeq ($(wildcard $(_CONFIG_FILE)),)
_HAS_ERROR = 1
_HAS_ERROR_MISSING_CONFIG_FILE = 1
else #endif will end at end of load config.mk

include $(_CONFIG_FILE)

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

DEBUG   ?= 0
VERBOSE ?= 0

_NAME                 := $(strip $(NAME))
_NAME_DEBUG           := $(strip $(NAME_DEBUG))
_INC_FOLDER           := $(strip $(INC_FOLDER))
_SRC_FOLDER           := $(strip $(SRC_FOLDER))
_BUILD_FOLDER         := $(strip $(BUILD_FOLDER))

_NAME_TARGET          := $(if $(filter 0, $(DEBUG)),$(_NAME),$(_NAME_DEBUG))
_TARGET               := $(if $(filter 0, $(DEBUG)),release,debug)

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

_CFLAGS     := $(CFLAGS_COMMON) $(if $(filter 0, $(DEBUG)), $(CFLAGS_RELEASE), $(CFLAGS_DEBUG))

######### Generating variables for files

_SRC := $(SRC:%.c=$(_SRC_FOLDER)%.c)
_OBJ := $(SRC:%.c=$(_BUILD_TARGET_FOLDER)%.o)
_DEP := $(SRC:%.c=$(_BUILD_TARGET_FOLDER)%.d)

######### Verify missing files in config.mk

rwildcard = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

_SRC_WILDCARDED := $(call rwildcard, $(patsubst %/,%,$(_SRC_FOLDER)), *.c)

_SRC_SPEC_NO_EXISTS := $(sort $(filter-out $(_SRC_WILDCARDED), $(_SRC)))
_SRC_EXISTS_NO_SPEC := $(sort $(filter-out $(_SRC), $(_SRC_WILDCARDED)))

ifneq ($(strip $(_SRC_SPEC_NO_EXISTS) $(_SRC_EXISTS_NO_SPEC)),)
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
	@ $(call print_missing_config_mk)
endif
ifeq ($(_HAS_ERROR_MISSING_VARIABLES),1)
	@ $(call print_missing_values, $(_ERRORS_MISSING_VARIABLES))
endif
ifeq ($(_HAS_ERROR_UNCONSISTENT_FILES),1)
	@ $(call print_missing_files, $(_SRC_SPEC_NO_EXISTS), $(_SRC_EXISTS_NO_SPEC))
endif
	@ $(call print_end_error_reporting)
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
	$(1)
endef

else

define cmd #1: command to run
	($(1) && $(call print_cmd, $(strip $(1))))
endef

endif

######### Core rules

.PHONY: all
all: $(_NAME_TARGET)

$(_NAME_TARGET): INIT $(_OBJ)
	@ test $(_NB_TO_COMP) -ne 0 || $(call print_nothing_to_relink)
	@ test $(_NB_TO_COMP) -eq 0 || $(call cmd, $(_CC) $(_CFLAGS) $(_IFLAGS) $(_LDFLAGS) -o $@ $(_OBJ) $(_LDLIBS))
	@ test $(_NB_TO_COMP) -eq 0 || $(call print_name)

ifdef COUNT_OBJS

$(_BUILD_TARGET_FOLDER)%.o: $(_SRC_FOLDER)%.c
	@ echo "+1"

else

$(_BUILD_TARGET_FOLDER)%.o: $(_SRC_FOLDER)%.c
	@ mkdir -p $(dir $@)
	@ $(call cmd, $(_CC) $(_CFLAGS) $(_IFLAGS) -c $< -o $@)
	@ $(eval _NB_ACTU := $(shell echo $$(( $(_NB_ACTU) + 1 )) ))
	@ $(call print_progress, $<)

endif

-include $(_DEP)

.PHONY: INIT
INIT:
	@ $(eval _NB_TO_COMP := $(shell env COUNT_OBJS=YES $(MAKE) $(_OBJ) DEBUG=$(DEBUG) | grep +1 | wc -l))
	@ $(eval _NB_ACTU := 0)

.PHONY: clean
clean:
	@ $(call cmd, rm -rf $(_BUILD_FOLDER))
	@ $(call print_clean)

.PHONY: fclean
fclean: clean
	@ $(call cmd, rm -f $(_NAME))
	@ $(call cmd, rm -f $(_NAME_DEBUG))
	@ $(call print_fclean)

.PHONY: re
re: fclean all

######### Manage debug

.PHONY: debug
debug:
	@ $(MAKE) --no-print-directory DEBUG=1 all

ifeq ($(DEBUG),0)
$(_NAME_DEBUG): debug
endif

.PHONY: redebug
redebug:
	@ $(MAKE) --no-print-directory DEBUG=1 re

endif #endif of error reporting
