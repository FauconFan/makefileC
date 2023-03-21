#include "mymath.h"

uint64_t		fact(uint64_t n) {
	if (n <= 1) return n;
	return n * fact(n - 1);
}
