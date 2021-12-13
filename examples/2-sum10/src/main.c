#include "sum100.h"

#define SIZEOF(tab)	sizeof(tab) / sizeof(*tab)

static int (*tabF[])(void) = {
	num000, num001, num002, num003, num004, num005, num006, num007, num008, num009,
	num010,
};

int	main(void) {
	int res = 0;

	for (size_t i = 0; i < SIZEOF(tabF); ++i) {
		res += tabF[i]();
	}

	printf("Should be 55: %d\n", res);
	return 0;
}
