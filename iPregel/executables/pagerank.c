/**
 * @file pagerank.c
 * @copyright Copyright (C) 2019 Ludovic Capelli
 * @par License
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 * @author Ludovic Capelli
 **/
#include <stdlib.h>
#include <inttypes.h>

/*
 * Line commented so that the vertex ID can be set to 4B or 8B ints at compile
 * time and therefore generate two versions of this binary so that switching
 * between the two no longer requires a recompilation.
 * typedef uint64_t IP_VERTEX_ID_TYPE;
 */
typedef IP_VERTEX_ID_TYPE IP_NEIGHBOUR_COUNT_TYPE;
typedef double IP_MESSAGE_TYPE;
typedef IP_MESSAGE_TYPE IP_VALUE_TYPE;
#define IP_NEEDS_OUT_NEIGHBOUR_COUNT
#include "iPregel.h"

double ratio;
double initial_value;
unsigned int ROUND;

void ip_compute(struct ip_vertex_t* v)
{
	if(ip_is_first_superstep())
	{
		v->value = initial_value;
	}
	else
	{
		IP_MESSAGE_TYPE sum = 0.0;
		IP_MESSAGE_TYPE value_temp;
		while(ip_get_next_message(v, &value_temp))
		{
			sum += value_temp;
		}

		value_temp = ratio + 0.85 * sum;
		v->value = value_temp;
	}

	if(ip_get_superstep() < ROUND)
	{
		if(v->out_neighbour_count > 0)
		{
			ip_broadcast(v, v->value / v->out_neighbour_count);
		}
	}
	else
	{
		ip_vote_to_halt(v);
	}
}

void ip_combine(IP_MESSAGE_TYPE* a, IP_MESSAGE_TYPE b)
{
	*a += b;
}

void ip_serialise_vertex(FILE* f, struct ip_vertex_t* v)
{
	fprintf(f, "%lu\t%0.20f\n", v->id, v->value);
}

int main(int argc, char* argv[])
{
	if(argc != 7) 
	{
		printf("Incorrect number of parameters, expecting: %s <inputFile> <outputFile> <number_of_threads> <schedule> <chunk_size> <number_of_iterations>.\n", argv[0]);
		return -1;
	}

	printf("ApplicationConfiguration:maxSuperstepCount=%u\n", atoi(argv[6]));

	////////////////////
	// INITILISATION //
	//////////////////
	bool directed = true;
	bool weighted = false;
	ROUND = atoi(argv[6]);
	ip_init(argv[1], atoi(argv[3]), argv[4], atoi(argv[5]), directed, weighted);

	//////////
	// RUN //
	////////
	ratio = 0.15 / ip_get_vertices_count();
	initial_value = 1.0 / ip_get_vertices_count();
	ip_run();

	//////////////
	// DUMPING //
	////////////
	FILE* f_out = fopen(argv[2], "wa");
	if(!f_out)
	{
		perror("File opening failed.");
		return -1;
	}
	ip_dump(f_out);

	return EXIT_SUCCESS;
}

