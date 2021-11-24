#include <stdio.h>
#include "main.h"

int	main(void) {
	long	n = 10;
	
	printf("fib(%ld) = %ld\n", n, fibonacci(n));
	return 0;
}
