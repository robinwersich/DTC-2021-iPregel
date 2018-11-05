/**
 * @file combiner_spread_single_broadcast_postamble.h
 * @author Ludovic Capelli
 **/

#ifndef COMBINER_SPREAD_SINGLE_BROADCAST_POSTAMBLE_H_INCLUDED
#define COMBINER_SPREAD_SINGLE_BROADCAST_POSTAMBLE_H_INCLUDED

#include <omp.h>
#include <string.h>

void ip_add_target(IP_VERTEX_ID_TYPE id)
{
	if(ip_all_targets.size == ip_all_targets.max_size)
	{
		ip_all_targets.max_size++;
		ip_all_targets.data = ip_safe_realloc(ip_all_targets.data, sizeof(IP_VERTEX_ID_TYPE) * ip_all_targets.max_size);
	}

	ip_all_targets.data[ip_all_targets.size] = id;
	ip_all_targets.size++;
}

bool ip_has_message(struct ip_vertex_t* v)
{
	return v->has_message;
}

bool ip_get_next_message(struct ip_vertex_t* v, IP_MESSAGE_TYPE* message_value)
{
	if(v->has_message)
	{
		*message_value = v->message;
		v->has_message = false;
		ip_messages_left_omp[omp_get_thread_num()]++;
		return true;
	}
	return false;
}

void ip_send_message(IP_VERTEX_ID_TYPE id, IP_MESSAGE_TYPE message)
{
	(void)(id);
	(void)(message);
	printf("The function send_message should not be used in the SINGLE_BROADCAST \
version; only broadcast() should be called, and once per superstep maximum.\n");
	exit(-1);
}

void ip_broadcast(struct ip_vertex_t* v, IP_MESSAGE_TYPE message)
{
	v->has_broadcast_message = true;
	v->broadcast_message = message;
	for(IP_NEIGHBOUR_COUNT_TYPE i = 0; i < v->out_neighbour_count; i++)
	{
		/* Should use "#pragma omp atomic write" to protect the data race, but
		 * since all threads would race to put the same value in the variable,
		 * it has been purposely left unprotected.
		 */
		ip_get_vertex_by_id(v->out_neighbours[i])->broadcast_target = true;
	}
}

void ip_fetch_broadcast_messages(struct ip_vertex_t* v)
{
	IP_NEIGHBOUR_COUNT_TYPE i = 0;
	while(i < v->in_neighbour_count && !ip_get_vertex_by_id(v->in_neighbours[i])->has_broadcast_message)
	{
		i++;
	}

	if(i >= v->in_neighbour_count)
	{
		v->has_message = false;
	}
	else
	{
		ip_messages_left_omp[omp_get_thread_num()]++;
		v->has_message = true;
		v->message = ip_get_vertex_by_id(v->in_neighbours[i])->broadcast_message;
		i++;
		IP_VERTEX_ID_TYPE spread_neighbour_id;
		struct ip_vertex_t* temp_vertex = NULL;
		while(i < v->in_neighbour_count)
		{
			spread_neighbour_id = v->in_neighbours[i];
			temp_vertex = ip_get_vertex_by_id(spread_neighbour_id);
			if(temp_vertex->has_broadcast_message)
			{
				ip_combine(&v->message, temp_vertex->broadcast_message);
			}
			i++;
		}
	}	
}

void ip_init_vertex_range(IP_VERTEX_ID_TYPE first, IP_VERTEX_ID_TYPE last)
{
	for(IP_VERTEX_ID_TYPE i = first; i <= last; i++)
	{
		ip_all_vertices[i].id = i - IP_ID_OFFSET;
		ip_all_vertices[i].broadcast_target = false;
		ip_all_vertices[i].has_message = false;
		ip_all_vertices[i].has_broadcast_message = false;
		ip_all_vertices[i].out_neighbour_count = 0;
		ip_all_vertices[i].out_neighbours = NULL;
		ip_all_vertices[i].in_neighbour_count = 0;
		ip_all_vertices[i].in_neighbours = NULL;
		#ifdef IP_WEIGHTED_EDGES
			ip_all_vertices[i].out_edge_weights = NULL;
			ip_all_vertices[i].in_edge_weights = NULL;
		#endif
		ip_all_targets.data[i] = ip_all_vertices[i].id;
	}
}

void ip_init_specific()
{
	// Initialise OpenMP variables
	#pragma omp parallel
	{
		#pragma omp master
		{
			ip_messages_left_omp = (size_t*)ip_safe_malloc(sizeof(size_t) * omp_get_num_threads());
			for(int i = 0; i < omp_get_num_threads(); i++)
			{
				ip_messages_left_omp[i] = 0;
			}
		}
	}

	ip_all_targets.max_size = ip_get_vertices_count();
	ip_all_targets.size = ip_get_vertices_count();
	ip_all_targets.data = ip_safe_malloc(sizeof(IP_VERTEX_ID_TYPE) * ip_all_targets.max_size);
}

int ip_run()
{
	double timer_superstep_total = 0;
	double timer_superstep_start = 0;
	double timer_superstep_stop = 0;

	while(ip_get_meta_superstep() < ip_get_meta_superstep_count())
	{
		ip_reset_superstep();
		while(ip_is_first_superstep() || ip_all_targets.size > 0)
		{
			timer_superstep_start = omp_get_wtime();
			#pragma omp parallel default(none) shared(ip_messages_left, \
													  ip_messages_left_omp, \
													  ip_all_targets)
			{
				struct ip_vertex_t* temp_vertex = NULL;

				#pragma omp for
				for(size_t i = 0; i < ip_all_targets.size; i++)
				{
					temp_vertex = ip_get_vertex_by_id(ip_all_targets.data[i]);
					ip_compute(temp_vertex);
				}
			
				// Count how many messages have been consumed by vertices.	
				#pragma omp for reduction(-:ip_messages_left) 
				for(int i = 0; i < omp_get_num_threads(); i++)
				{
					ip_messages_left -= ip_messages_left_omp[i];
					ip_messages_left_omp[i] = 0;
				}
			
				#pragma omp single
				{
					ip_all_targets.size = 0;
					for(size_t i = 0; i < ip_get_vertices_count(); i++)
					{
						temp_vertex = ip_get_vertex_by_location(i);
						if(temp_vertex->broadcast_target)
						{
							ip_add_target(i);
						}
					}
				}
		
				// Get the messages broadcasted by neighbours, but only for those
				// who have neighbours who broadcasted.
				#pragma omp for
				for(size_t i = 0; i < ip_all_targets.size; i++)
				{
					temp_vertex = ip_get_vertex_by_id(ip_all_targets.data[i]);
					if(temp_vertex->broadcast_target)
					{
						ip_fetch_broadcast_messages(temp_vertex);
						temp_vertex->broadcast_target = false;
					}
				}
	
				#pragma omp for
				for(size_t i = 0; i < ip_get_vertices_count(); i++)
				{
					ip_get_vertex_by_location(i)->has_broadcast_message = false;
				}
				
				// Count how many vertices have a message.
				#pragma omp for reduction(+:ip_messages_left)
				for(int i = 0; i < omp_get_num_threads(); i++)
				{
					ip_messages_left += ip_messages_left_omp[i];
					ip_messages_left_omp[i] = 0;
				}
			} // End of OpenMP parallel region
	
			timer_superstep_stop = omp_get_wtime();
			timer_superstep_total += timer_superstep_stop - timer_superstep_start;
			printf("Meta-superstep %zu superstep %zu finished in %fs; %zu active vertices and %zu messages left.\n", ip_get_meta_superstep(), ip_get_superstep(), timer_superstep_stop - timer_superstep_start, ip_all_targets.size, ip_messages_left);
			ip_increment_superstep();
		}
		ip_increment_meta_superstep();
	}

	printf("Total time of supersteps: %fs.\n", timer_superstep_total);
	
	return 0;
}

void ip_vote_to_halt(struct ip_vertex_t* v)
{
	(void)(v);
}

#endif // COMBINER_SPREAD_SINGLE_BROADCAST_POSTAMBLE_H_INCLUDED
