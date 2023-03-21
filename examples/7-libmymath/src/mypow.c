#include "mymath.h"

uint64_t		mypow(uint64_t x, uint64_t n) {
	uint64_t	tmp;

	if (n == 0) return 1;
	else if (n == 1) return x;

	tmp = mypow(x, n / 2);

	if (n % 2 == 0) return tmp * tmp;
	return x * tmp * tmp;
}
