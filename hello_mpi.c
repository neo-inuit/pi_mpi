/* hello_mpi.c ---
 * 
 * Author: Remi Michelas
 * Created: Tue Oct 29 16:29:44 CET 2013
 * Version: 0.1
 */

/* C Example */
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main (argc, argv)
     int argc;
     char *argv[];
{
	char* input = (argv[1]);
	//int output = input+1;
  	int rank, size;

  MPI_Init (&argc, &argv);	/* starts MPI */
  MPI_Comm_rank (MPI_COMM_WORLD, &rank);	/* get current process id */
  MPI_Comm_size (MPI_COMM_WORLD, &size);	/* get number of processes */
  printf( "Hello %s from process %d of %d\n",input, rank, size );
  MPI_Finalize();
  return 0;
}
