
include files.mk

_RED=$(shell tput setaf 1 2> /dev/null || echo -n "")
_GREEN=$(shell tput setaf 2 2> /dev/null || echo -n "")
_YELLOW=$(shell tput setaf 3 2> /dev/null || echo -n "")
_BLUE=$(shell tput setaf 4 2> /dev/null || echo -n "")
_PURPLE=$(shell tput setaf 5 2> /dev/null || echo -n "")
_CYAN=$(shell tput setaf 6 2> /dev/null || echo -n "")
_WHITE=$(shell tput setaf 7 2> /dev/null || echo -n "")
_END=$(shell tput sgr0 2> /dev/null || echo -n "")

define print_name
	printf " %s[ INFO ]%s %sAssemble%s     %s\`%s\`%s  %-70s\\n" "$(_CYAN)" "$(_END)" "$(_GREEN)" "$(_END)" "$(_YELLOW)" "$(NAME)" "$(_END)" ""
endef

define print_progress # name of file to compile as argument
	printf " %s[%2s/%2s]%s  %sCompile%s      %-55s\\n" "$(_CYAN)" "$(NB_ACTU)" "$(NB_TO_COMP)" "$(_END)" "$(_GREEN)" "$(_END)" "\`$(strip $(1))\`"
endef

define print_clean
	printf " %s[ INFO ]%s %sRemove%s       object and dependency files\\n" "$(_CYAN)" "$(_END)" "$(_RED)" "$(_END)"
endef

define print_fclean
	printf " %s[ INFO ]%s %sRemove%s       %s\`%s\`%s\\n" "$(_CYAN)" "$(_END)" "$(_RED)" "$(_END)" "$(_YELLOW)" "$(NAME)" "$(_END)"
endef

CC = clang
CFLAGS ?= -Wall -Wextra -Werror -Weverything -pedantic -MMD
IFLAGS ?= -I $(INC_FOLDER)

_SRC=$(SRC:%.c=$(SRC_FOLDER)%.c)
_OBJ=$(SRC:%.c=$(BUILD_FOLDER)%.o)
_DEP=$(SRC:%.c=$(BUILD_FOLDER)%.d)

.PHONY: all
all: $(NAME)

$(NAME): INIT $(_OBJ) FORCE
	@ $(CC) $(CFLAGS) -o $@ $(_OBJ)
	@ $(call print_name, $(NAME))

ifdef COUNT_OBJS

$(BUILD_FOLDER)%.o: $(SRC_FOLDER)%.c
	@ echo "+1"

else

$(BUILD_FOLDER)%.o: $(SRC_FOLDER)%.c
	@ mkdir -p $(dir $@)
	@ $(eval NB_ACTU := $(shell echo $$(( $(NB_ACTU) + 1 )) ))
	@ $(CC) $(CFLAGS) $(IFLAGS) -c $< -o $@
	@ $(call print_progress, $<)

endif

-include $(DEP)

.PHONY: INIT
INIT: FORCE
	@ $(eval NB_TO_COMP := $(shell env COUNT_OBJS=YES make $(_OBJ) | grep +1 | wc -l))
	@ $(eval NB_ACTU := 0)

.PHONY: clean
clean:
	@ rm -rf $(BUILD_FOLDER)
	@ $(call print_clean)

.PHONY: fclean
fclean: clean
	@ rm -rf $(NAME)
	@ $(call print_fclean)

.PHONY: re
re: fclean all

.PHONY: FORCE
FORCE:
