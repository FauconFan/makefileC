#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include "quotes.h"

#define LENGTH_ARRAY(arr) (sizeof(arr) / sizeof(*arr))

// Source of quotes:
//   https://hellobio.com/blog/25-of-the-best-motivational-quotes-from-scientists.html

static const char	*ALL_QUOTES[] = {
	("“Everything is theoretically impossible, until it is done.” - Robert A. Heinlein."),
	("“The reward of the young scientist is the emotional thrill of being the first person in the history of the world to see something or to understand something. Nothing can compare with that experience.” - Cecilia Payne-Gaposchkin"),
	("“What you learn from a life in science is the vastness of our ignorance.” - David Eagleman"),
	("“If I have seen further it is by standing on the shoulders of Giants.“ - Issac Newton"),
	("“If a cluttered desk is a sign of a cluttered mind, of what, then, is an empty desk a sign?” - Albert Einstein"),
	("“Our virtues and our failures are inseparable, like force and matter. When they separate, man is no more.” - Nikola Tesla"),
	("“Impossible only means that you haven’t found the solution yet.” - Anonymous"),
	("“In science the credit goes to the man who convinces the world, not to the man to whom the idea first occurs.” - Sir William Osler"),
	("“Every brilliant experiment, like every great work of art, starts with an act of imagination.” - Jonah Lehrer"),
	("“The good thing about science is that it's true whether or not you believe in it.” - Neil deGrasse Tyson"),
	("“Science is not only a disciple of reason but also one of romance and passion.” - Stephen Hawking"),
	("“Science and everyday life cannot and should not be separated.” - Rosalind Franklin"),
	("“All outstanding work, in art as well as in science, results from immense zeal applied to a great idea.” - Santiago Ramón y Cajal"),
	("“If you know you are on the right track, if you have this inner knowledge, then nobody can turn you off... no matter what they say.” - Barbara McClintock"),
	("“Above all, don't fear difficult moments. The best comes from them.” - Rita Levi-Montalcini"),
	("“Research is to see what everybody else has seen, and to think what nobody else has thought.” - Albert Szent-Györgyi"),
	("“If you want to have good ideas, you must have many ideas.” - Linus Pauling"),
	("“We are just an advanced breed of monkeys on a minor planet of a very average star. But we can understand the Universe. That makes us something very special.” - Stephen Hawking"),
	("“Nothing in life is to be feared, it is only to be understood. Now is the time to understand more, so that we may fear less.” - Marie Curie"),
	("“Science means constantly walking a tightrope between blind faith and curiosity; between expertise and creativity; between bias and openness; between experience and epiphany; between ambition and passion; and between arrogance and conviction - in short, between and old today and a new tomorrow.” - Henrich Rohrer"),
	("“Science knows no country, because knowledge belongs to humanity, and is the torch which illuminates the world.” - Louis Pasteur"),
	("“When kids look up to great scientists the way they do musicians, actors [and sports figures], civilization will jump to the next level.” - Brian Greene"),
	("“The important thing is to never stop questioning [or learning].” - Albert Einstein"),
	("“We cannot solve problems with the same thinking we used to create them.” - Albert Einstein"),
	("“I am among those who think that science has great beauty.” - Marie Curie")
};

static bool QUOTES_INITIALIZED = false;

const char	*quote(void) {
	if (QUOTES_INITIALIZED == false) {
		QUOTES_INITIALIZED = true;
		srand((unsigned int)time(NULL));
	}
	return ALL_QUOTES[((unsigned int)rand()) % LENGTH_ARRAY(ALL_QUOTES)];
}
