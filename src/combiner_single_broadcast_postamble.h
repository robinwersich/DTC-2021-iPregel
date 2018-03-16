/**
 * @file combiner_single_broadcast_postamble.h
 * @author Ludovic Capelli
 **/

#ifndef SINGLE_BROADCAST_POSTAMBLE_H_INCLUDED
#define SINGLE_BROADCAST_POSTAMBLE_H_INCLUDED

#include <omp.h>

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
}

void ip_fetch_broadcast_messages(struct ip_vertex_t* v)
{
	IP_NEIGHBOURS_COUNT_TYPE i = 0;
	while(i < v->in_neighbours_count && !ip_get_vertex_by_id(v->in_neighbours[i])->has_broadcast_message)
	{
		i++;
	}

	if(i >= v->in_neighbours_count)
	{
		v->has_message = false;
	}
	else
	{
		ip_messages_left_omp[omp_get_thread_num()]++;
		v->has_message = true;
		v->message = ip_get_vertex_by_id(v->in_neighbours[i])->broadcast_message;
		i++;
		struct ip_vertex_t* teip_vertex = NULL;
		while(i < v->in_neighbours_count)
		{
			teip_vertex = ip_get_vertex_by_id(v->in_neighbours[i]);
			if(teip_vertex->has_broadcast_message)
			{
				ip_combine(&v->message, teip_vertex->broadcast_message);
			}
			i++;
		}
	}	
}

void ip_add_edge(IP_VERTEX_ID_TYPE src, IP_VERTEX_ID_TYPE dest)
{
	struct ip_vertex_t* v;

	//////////////////////////////
	// Add the dest to the src //
	////////////////////////////
	v = ip_get_vertex_by_id(src);
	v->id = src;
	#ifndef IP_UNUSED_OUT_NEIGHBOURS
		v->out_neighbours_count++;
		#ifndef IP_UNUSED_OUT_NEIGHBOURS_VALUES
			if(v->out_neighbours_count == 1)
			{
				v->out_neighbours = ip_safe_malloc(sizeof(IP_VERTEX_ID_TYPE));
			}
			else
			{
				v->out_neighbours = ip_safe_realloc(v->out_neighbours, sizeof(IP_VERTEX_ID_TYPE) * v->out_neighbours_count);
			}
			v->out_neighbours[v->out_neighbours_count-1] = dest;
		#endif // ifndef IP_UNUSED_OUT_NEIGHBOURS_VALUES
	#endif // ifndef IP_UNUSED_OUT_NEIGHBOURS

	//////////////////////////////
	// Add the src to the dest //
	////////////////////////////
	v = ip_get_vertex_by_id(dest);
	v->id = dest;
	v->in_neighbours_count++;
	if(v->in_neighbours_count == 1)
	{
		v->in_neighbours = ip_safe_malloc(sizeof(IP_VERTEX_ID_TYPE));
	}
	else
	{
		v->in_neighbours = ip_safe_realloc(v->in_neighbours, sizeof(IP_VERTEX_ID_TYPE) * v->in_neighbours_count);
	}
	v->in_neighbours[v->in_neighbours_count-1] = src;
}

int ip_init(FILE* f, size_t number_of_vertices, size_t number_of_edges)
{
	(void)number_of_edges;
	double timer_init_start = omp_get_wtime();
	double timer_init_stop = 0;
	struct ip_vertex_t* teip_vertex = NULL;

	ip_set_vertices_count(number_of_vertices);
	ip_all_vertices = (struct ip_vertex_t*)ip_safe_malloc(sizeof(struct ip_vertex_t) * ip_get_vertices_count());

	#pragma omp parallel for default(none) private(teip_vertex)
	for(size_t i = IP_ID_OFFSET; i < IP_ID_OFFSET + ip_get_vertices_count(); i++)
	{
		teip_vertex = ip_get_vertex_by_location(i);
		teip_vertex->active = true;
		teip_vertex->has_message = false;
		teip_vertex->has_broadcast_message = false;
	}

	ip_deserialise(f);
	ip_active_vertices = number_of_vertices;

	timer_init_stop = omp_get_wtime();
	printf("Initialisation finished in %fs.\n", timer_init_stop - timer_init_start);
		
	return 0;
}

int ip_run()
{
	double timer_superstep_total = 0;
	double timer_superstep_start = 0;
	double timer_superstep_stop = 0;

	while(ip_get_meta_superstep() < ip_get_meta_superstep_count())
	{
		ip_reset_superstep();
		while(ip_active_vertices != 0 || ip_messages_left > 0)
		{
			timer_superstep_start = omp_get_wtime();
			ip_active_vertices = 0;
			#pragma omp parallel default(none) shared(ip_active_vertices, \
													  ip_messages_left, \
													  ip_messages_left_omp)
			{
				struct ip_vertex_t* teip_vertex = NULL;

				#pragma omp for reduction(+:ip_active_vertices)
				for(size_t i = IP_ID_OFFSET; i < ip_get_vertices_count() + IP_ID_OFFSET; i++)
				{
					teip_vertex = ip_get_vertex_by_location(i);	
					teip_vertex->has_broadcast_message = false;
					if(teip_vertex->active || ip_has_message(teip_vertex))
					{
						teip_vertex->active = true;
						ip_compute(teip_vertex);
						if(teip_vertex->active)
						{
							ip_active_vertices++;
						}
					}
				}

				// Count how many messages have been consumed by vertices.	
				#pragma omp for reduction(-:ip_messages_left)
				for(int i = 0; i < OMP_NUM_THREADS; i++)
				{
					ip_messages_left -= ip_messages_left_omp[i];
					ip_messages_left_omp[i] = 0;
				}

				// Get the messages broadcasted by neighbours.
				#pragma omp for
				for(size_t i = IP_ID_OFFSET; i < ip_get_vertices_count() + IP_ID_OFFSET; i++)
				{
					ip_fetch_broadcast_messages(ip_get_vertex_by_location(i));
				}
				
				// Count how many vertices have a message.
				#pragma omp for reduction(+:ip_messages_left)
				for(int i = 0; i < OMP_NUM_THREADS; i++)
				{
					ip_messages_left += ip_messages_left_omp[i];
					ip_messages_left_omp[i] = 0;
				}
			}
	
			timer_superstep_stop = omp_get_wtime();
			timer_superstep_total += timer_superstep_stop - timer_superstep_start;
			printf("Meta-superstep %zu superstep %zu finished in %fs; %zu active vertices and %zu messages left.\n", ip_get_meta_superstep(), ip_get_superstep(), timer_superstep_stop - timer_superstep_start, ip_active_vertices, ip_messages_left);
			ip_increment_superstep();
		}
		for(size_t i = IP_ID_OFFSET; i < ip_get_vertices_count() + IP_ID_OFFSET; i++)
		{
			ip_get_vertex_by_location(i)->active = true;
		}
		ip_active_vertices = ip_get_vertices_count();
		ip_increment_meta_superstep();
	}

	printf("Total time of supersteps: %fs.\n", timer_superstep_total);
	
	return 0;
}

void ip_vote_to_halt(struct ip_vertex_t* v)
{
	v->active = false;
}

#endif // SINGLE_BROADCAST_POSTAMBLE_H_INCLUDED
