
include files.mk

#########
# Check consistency of files.mk
#########

ifndef NAME
$(error NAME must be defined: NAME is the name of the final binary)
endif

ifndef INC_FOLDER
$(error INC_FOLDER must be defined: INC_FOLDER define the base root for header files)
endif

ifndef SRC_FOLDER
$(error SRC_FOLDER must be defined: SRC_FOLDER define the base root for source files)
endif

ifndef BUILD_FOLDER
$(error BUILD_FOLDER must be defined: BUILD_FOLDER define the base root for generated files)
endif

ifndef SRC
$(error SRC must be defined: SRC is the exhaustive list of all source files)
endif

#########
# Define termcap values if possible
#########

_RED=$(shell tput setaf 1 2> /dev/null || echo -n "")
_GREEN=$(shell tput setaf 2 2> /dev/null || echo -n "")
_YELLOW=$(shell tput setaf 3 2> /dev/null || echo -n "")
_BLUE=$(shell tput setaf 4 2> /dev/null || echo -n "")
_PURPLE=$(shell tput setaf 5 2> /dev/null || echo -n "")
_CYAN=$(shell tput setaf 6 2> /dev/null || echo -n "")
_WHITE=$(shell tput setaf 7 2> /dev/null || echo -n "")
_END=$(shell tput sgr0 2> /dev/null || echo -n "")

#########
# Define print functions
#########

define print_name
	printf " %s[ INFO ]%s %sAssemble%s     %s\`%s\`%s  %-s\\n" "$(_CYAN)" "$(_END)" "$(_GREEN)" "$(_END)" "$(_YELLOW)" "$(_NAME)" "$(_END)" ""
endef

define print_nothing_to_do
	printf " %s[ INFO ]%s Nothing to do\\n" "$(_CYAN)" "$(_END)"
endef

define print_progress # name of file to compile as argument
	printf " %s[%2s/%2s]%s  %sCompile%s      %-55s\\n" "$(_CYAN)" "$(_NB_ACTU)" "$(_NB_TO_COMP)" "$(_END)" "$(_GREEN)" "$(_END)" "\`$(strip $(1))\`"
endef

define print_clean
	printf " %s[ INFO ]%s %sRemove%s       object and dependency files\\n" "$(_CYAN)" "$(_END)" "$(_RED)" "$(_END)"
endef

define print_fclean
	printf " %s[ INFO ]%s %sRemove%s       %s\`%s\`%s\\n" "$(_CYAN)" "$(_END)" "$(_RED)" "$(_END)" "$(_YELLOW)" "$(_NAME)" "$(_END)"
endef

_NAME = $(strip $(NAME))
_INC_FOLDER = $(strip $(INC_FOLDER))
_SRC_FOLDER = $(strip $(SRC_FOLDER))
_BUILD_FOLDER = $(strip $(BUILD_FOLDER))

_CC = clang
_CFLAGS = -Wall -Wextra -Werror -Weverything -pedantic -MMD $(CFLAGS)
_IFLAGS = -I $(_INC_FOLDER)
_LDFLAGS = $(LDFLAGS)
_LIBS = $(LIBS)

_SRC = $(SRC:%.c=$(_SRC_FOLDER)%.c)
_OBJ = $(SRC:%.c=$(_BUILD_FOLDER)%.o)
_DEP = $(SRC:%.c=$(_BUILD_FOLDER)%.d)

#########
# Standard rules
#########

.PHONY: all
all: $(_NAME)

$(_NAME): INIT $(_OBJ)
	@ test $(_NB_TO_COMP) -ne 0 || $(call print_nothing_to_do)
	@ test $(_NB_TO_COMP) -eq 0 || $(_CC) $(_CFLAGS) $(_IFLAGS) $(_LDFLAGS) -o $@ $(_OBJ) $(_LIBS)
	@ test $(_NB_TO_COMP) -eq 0 || $(call print_name)

ifdef COUNT_OBJS

$(_BUILD_FOLDER)%.o: $(_SRC_FOLDER)%.c
	@ echo "+1"

else

$(_BUILD_FOLDER)%.o: $(_SRC_FOLDER)%.c
	@ mkdir -p $(dir $@)
	@ $(_CC) $(_CFLAGS) $(_IFLAGS) -c $< -o $@
	@ $(eval _NB_ACTU := $(shell echo $$(( $(_NB_ACTU) + 1 )) ))
	@ $(call print_progress, $<)

endif

-include $(DEP)

.PHONY: INIT
INIT:
	@ $(eval _NB_TO_COMP := $(shell env COUNT_OBJS=YES make $(_OBJ) | grep +1 | wc -l))
	@ $(eval _NB_ACTU := 0)

.PHONY: clean
clean:
	@ rm -rf $(_BUILD_FOLDER)
	@ $(call print_clean)

.PHONY: fclean
fclean: clean
	@ rm -rf $(_NAME)
	@ $(call print_fclean)

.PHONY: re
re: fclean all
