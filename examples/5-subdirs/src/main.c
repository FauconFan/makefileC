#include "main.h"

int	main(void) {
	int a = 0;

	a += get1();
	a += get2();
	a += get3();
	a += get4();
	a += get5();
	printf("a = %d\n", a);
	return 0;
}
