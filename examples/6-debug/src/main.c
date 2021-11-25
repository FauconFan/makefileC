#include "stdio.h"

#ifdef DEBUG
# define TARGET "DEBUG"
#elif defined(NDEBUG)
# define TARGET "RELEASE"
#endif

int main(void) {
	printf("Run on " TARGET "\n");
	return 0;
}
