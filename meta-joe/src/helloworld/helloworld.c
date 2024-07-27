#include <stdio.h>
#include <jmath.h>

int main(void)
{
	printf("Hello cruel world!\n");

	jmath_info();

	printf("do sum 23 + 27 = %d\n", jmath_add(23, 27));

	return 0;
}
