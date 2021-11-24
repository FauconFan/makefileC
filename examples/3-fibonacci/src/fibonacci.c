#include "main.h"

long	fibonacci(long n) {
	long	a, b, c;

	if (n <= 1) return n;
	a = 0;
	b = 1;
	c = 0;
	while (n != 1) {
		c = b;
		b = a + b;
		a = c;
		n -= 1;
	}
	return b;
}
