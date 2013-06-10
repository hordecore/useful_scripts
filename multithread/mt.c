#include <stdio.h>
#include <sys/sysinfo.h>
#include <pthread.h>

int get_cpu_count(void)
{
	return get_nprocs();
}

void *func(void *arg)
{
	int i;
	for (i = 0; i < 100000; i++)
		printf("%d\n", i);
	return;
}

int main(void)
{
	int i;
	unsigned int cpu_count = get_cpu_count();
	pthread_t t[cpu_count];

	/* and no, you should not use one for-loop */
	for (i = 0; i < cpu_count; i++) 
		pthread_create(&t[i], NULL, func, NULL);
	for (i = 0; i < cpu_count; i++) 
		pthread_join(t[i], NULL);
	return 0;
}
