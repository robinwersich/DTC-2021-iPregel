/**
 * @file no_combiner_preamble.h
 * @author Ludovic Capelli
 **/

#ifndef NO_COMBINER_PREAMBLE_H_INCLUDED
#define NO_COMBINER_PREAMBLE_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <omp.h>

// Global variables
/// This variable contains the number of active vertices at an instant t.
unsigned int active_vertices = 0;
/// This variable contains the number of messages that have not been read yet.
unsigned int messages_left = 0;
/// This variable is used for multithreading reduction into message_left.
unsigned int messages_left_read_omp[OMP_NUM_THREADS] = {0};
/// This variable is used for multithreading reduction into message_left.
unsigned int messages_left_sent_omp[OMP_NUM_THREADS] = {0};
/// This variable contains the current superstep number. It is 0-indexed.
unsigned int superstep = 0;
/// This variable contains the total number of vertices.
unsigned int vertices_count = 0;
/// This variable contains all the vertices.
struct vertex_t* all_vertices = NULL;

// Prototypes
/**
 * @brief This function removes unread messages in vertex mailboxes.
 * @param[in] id The identifier of the vertex to process.
 * @post The mailbox of the vertex identified by id is empty.
 **/
void reset_inbox(VERTEX_ID id);

/// This macro defines the minimal attributes of a vertex.
#define VERTEX_STRUCTURE VERTEX_ID* neighbours; \
						 			unsigned int neighbours_count; \
						 			bool active; \
						 			bool voted_to_halt; \
						 			VERTEX_ID id;

/**
 * @brief This structure acts as the mailbox of a vertex.
 **/
struct messagebox_t
{
	/// This variable contains the maximum number of mails that this inbox can contain.
	size_t max_message_number;
	/// This variable contains the current number of mails in this inbox.
	size_t message_number;
	/// This variable contains the number of mails read in this inbox.
	size_t message_read;
	/// This variable contains the actual messages.
	MESSAGE_TYPE* messages;
};
/// This variable contains the inbox for each vertex.
struct messagebox_t* all_inboxes[OMP_NUM_THREADS];
/// This variable contains the inbox for the next superstep for each vertex.
struct messagebox_t* all_inboxes_next_superstep[OMP_NUM_THREADS];

#endif // NO_COMBINER_PREAMBLE_H_INCLUDED
