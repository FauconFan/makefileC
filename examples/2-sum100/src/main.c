#include "sum100.h"

#define SIZEOF(tab)	sizeof(tab) / sizeof(*tab)

static int (*tabF[])(void) = {
	num000, num001, num002, num003, num004, num005, num006, num007, num008, num009,
	num010, num011, num012, num013, num014, num015, num016, num017, num018, num019,
	num020, num021, num022, num023, num024, num025, num026, num027, num028, num029,
	num030, num031, num032, num033, num034, num035, num036, num037, num038, num039,
	num040, num041, num042, num043, num044, num045, num046, num047, num048, num049,
	num050, num051, num052, num053, num054, num055, num056, num057, num058, num059,
	num060, num061, num062, num063, num064, num065, num066, num067, num068, num069,
	num070, num071, num072, num073, num074, num075, num076, num077, num078, num079,
	num080, num081, num082, num083, num084, num085, num086, num087, num088, num089,
	num090, num091, num092, num093, num094, num095, num096, num097, num098, num099,
	num100,
};

int	main(void) {
	int res = 0;

	for (size_t i = 0; i < SIZEOF(tabF); ++i) {
		res += tabF[i]();
	}

	printf("Should be 5050: %d\n", res);
	return 0;
}
