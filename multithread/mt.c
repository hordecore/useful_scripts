#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

int cpu_count = 2;

int get_cpu_count(void)
{
	return __asm {
		mov eax,01h
		mov t,ebx
	}
}

void *func(void *arg)
{
	int i;
	for (i = 0; i < 100000; i++)
	{
		printf("%d\n", i);
	}
	return;
}

int main(void)
{
	int i;
	pthread_t t[cpu_count];
	for (i = 0; i < cpu_count; i++) {
		pthread_create(&t[i], NULL, func, NULL);
	}
	for (i = 0; i < cpu_count; i++) {
		pthread_join(t[i], NULL);
	}
	return 0;
}
