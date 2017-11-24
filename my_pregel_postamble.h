/**
 * @file my_pregel_postamble.h
 * @author Ludovic Capelli
 **/

#ifndef MY_PREGEL_POSTAMBLE_H_INCLUDED
#define MY_PREGEL_POSTAMBLE_H_INCLUDED

#ifdef USE_COMBINER
	#ifdef SINGLE_BROADCAST
		#include "single_broadcast_postamble.h"
	#else // ifndef SINGLE_BROADCAST
		#include "combiner_postamble.h"
	#endif // if(n)def SINGLE_BROADCAST
#else // ifndef USE_COMBINER
	#error The version without combiner is not implemented.
#endif // if(n)def USE_COMBINER

void* safe_malloc(size_t size_to_malloc)
{
	void* ptr = malloc(size_to_malloc);
	if(ptr == NULL)
	{
		exit(-1);
	}
	return ptr;
}

void* safe_realloc(void* ptr, size_t size_to_realloc)
{
	ptr = realloc(ptr, size_to_realloc);
	if(ptr == NULL)
	{
		exit(-1);
	}
	return ptr;
}

#endif // MY_PREGEL_POSTAMBLE_H_INCLUDED
