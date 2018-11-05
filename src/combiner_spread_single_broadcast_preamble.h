/**
 * @file combiner_spread_single_broadcast_preamble.h
 * @author Ludovic Capelli
 **/

#ifndef COMBINER_SPREAD_SINGLE_BROADCAST_H_INCLUDED
#define COMBINER_SPREAD_SINGLE_BROADCAST_H_INCLUDED

#ifndef IP_NEEDS_OUT_NEIGHBOUR_IDS
	#define IP_NEEDS_OUT_NEIGHBOUR_IDS
#endif // ifndef IP_NEEDS_OUT_NEIGHBOUR_IDS

#ifndef IP_NEEDS_OUT_NEIGHBOUR_COUNT
	#define IP_NEEDS_OUT_NEIGHBOUR_COUNT
#endif // ifndef IP_NEEDS_OUT_NEIGHBOUR_COUNT

#ifndef IP_NEEDS_IN_NEIGHBOUR_IDS
	#define IP_NEEDS_IN_NEIGHBOUR_IDS
#endif // ifndef IP_NEEDS_IN_NEIGHBOUR_IDS

#ifndef IP_NEEDS_IN_NEIGHBOUR_COUNT
	#define IP_NEEDS_IN_NEIGHBOUR_COUNT
#endif // ifndef IP_NEEDS_IN_NEIGHBOUR_COUNT

// Global variables
/// This variable contains the number of messages that have not been read yet.
size_t ip_messages_left = 0;
/// This variable is used for multithreading reduction into message_left.
size_t* ip_messages_left_omp = NULL;
/**
 * @brief This structure holds the vertices that have a neighbour at least who
 * broadcasted.
 **/
struct ip_targets_t
{
	/// This contains the current number of targets.
	size_t size;
	/// This contains the buffer memory size. It is used for reallocation purpose.
	size_t max_size;
	/// This contains the actual target ids.
	IP_VERTEX_ID_TYPE* data;
};
/// This variable contains the targets.
struct ip_targets_t ip_all_targets;
/// This structure defines the structure of a vertex.
struct ip_vertex_t
{
	#ifdef IP_NEEDS_OUT_NEIGHBOUR_IDS
		/// Contains the identifiers of the out-neighbours
		IP_VERTEX_ID_TYPE* out_neighbours;
	#endif // IP_NEEDS_OUT_NEIGHBOUR_IDS
	#ifdef IP_NEEDS_IN_NEIGHBOUR_IDS
		/// Contains the identifiers of the in-neighbours
		IP_VERTEX_ID_TYPE* in_neighbours;
	#endif // ifdef IP_NEEDS_IN_NEIGHBOUR_IDS
	#ifdef IP_NEEDS_OUT_NEIGHBOUR_COUNT
		/// Contains the number of out-neighbours
		IP_NEIGHBOUR_COUNT_TYPE out_neighbour_count;
	#endif // ifdef IP_NEEDS_OUT_NEIGHBOUR_COUNT
	#ifdef IP_NEEDS_IN_NEIGHBOUR_COUNT
		/// Contains the number of in-neighbours
		IP_NEIGHBOUR_COUNT_TYPE in_neighbour_count;
	#endif // IP_UNUSED_IN_NEIGHBOURS
	#ifdef IP_NEEDS_OUT_NEIGHBOUR_WEIGHTS
		/// Contains the weights of out-edges
		IP_EDGE_WEIGHT_TYPE* out_neighbour_weights;
	#endif // ifdef IP_NEEDS_OUT_NEIGHBOUR_WEIGHTS
	#ifdef IP_NEEDS_IN_NEIGHBOUR_WEIGHTS
		/// Contains the weights of the in-neighbours
		IP_EDGE_WEIGHT_TYPE* in_neighbour_weights;
	#endif // IP_WEIGHTED_EDGES
	/// Indicates whether this vertex has one of its in-neighbours at least who broadcasts. That tells whether that vertex will have to fetch messages from its in-neighbours or not.
	bool broadcast_target;
	/// Indicates whether the vertex has a message to broadcast
	bool has_broadcast_message;
	/// Indicates whether the vertex received messages from last superstep
	bool has_message;
	/// The vertex identifier
	IP_VERTEX_ID_TYPE id;
	/// The message to broadcast
	IP_MESSAGE_TYPE broadcast_message;
	/// The combined message made from messages received from last superstep
	IP_MESSAGE_TYPE message;
	/// The user-defined value
	IP_VALUE_TYPE value;
};

// Prototypes
/**
 * @brief This functions add the identifier \p id to the targets.
 * @param[in] id The identifier of the new target.
 * @post \p id is added to the targets.
 **/
void ip_add_target(IP_VERTEX_ID_TYPE id);
/**
 * @brief This functions gathers and combines all the messages destined to the
 * vertex \p v.
 * @param[inout] v The vertex to update.
 * @pre \p v points to an allocated memory area containing a vertex.
 * @post All the messages destined to vertex \p v are stored in v.
 **/
void ip_fetch_broadcast_messages(struct ip_vertex_t* v);

#endif // COMBINER_SPREAD_SINGLE_BROADCAST_PREAMBLE_H_INCLUDED
