 /*
 * pi - calculer pi
 *      sur un cluster avec MPI
 * Copyright 2006 Thibault GODOUET
 */
/*
 * A compiler avec:
 * mpicc -Wall -O2 pi-parallel.c \
   -o pi-parallel
 * puis lancer avec par exemple:
 * mpirun -machinefile machines \
   -np 1 pi-parallel 100000000
 */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
/* Inclure les déclarations
 * des fonctions MPI */
#include "mpi.h"
/* Nombre de noeuds dans le cluster,
 * et rang de ce noeud */
int size, rank;
/* Pour calculer le temps de calcul: */
double start_time, end_time;
/* printf() avec le rang du noeud
 * affiché au début de la ligne */
void
xprintf(char *fmt, ...)
{
  va_list args;
  va_start(args, fmt);
  printf("noeud %d: ", rank);
  vprintf(fmt, args);
}
/* Sortir propremment du programme,
 * et afficher le temps de calcul */
void
xexit(int code)
{
  if ( rank == 0 ) {
    end_time = MPI_Wtime();
    xprintf("TEMPS DE CALCUL: "
      "%f secondes\n",
      end_time - start_time);
  }
  MPI_Finalize();
  exit(code);
}
/* Fonction à intégrer
 * pour calculer pi: */
/* NOTE: le "inline" n’est là que pour
 * (peut-être!) améliorer
 * les performances et peut être enlever
 * sans problème */
inline
double
f(double x)
{
  return (4.0 / (1.0 + x*x));
}
/* Calcul de la partie de la somme
 * approximant l’intégrale de f()
 * à faire par ce noeud */
double
sub_sum(long long int start_i,
        long long int stop_i, double h)
{
  double f_xi, f_xi1;
  long long int i = 0;
  double sum = 0;
  double x = 0;

  xprintf("Sous-somme de %Ld à %Ld\n",
	  start_i, stop_i);
  sum = 0;
  x = h*(start_i-1);
  f_xi1 = f(x);
  for ( i = start_i; i <= stop_i; i++ ) {
    f_xi = f_xi1;
    f_xi1 = f(x+h);
    sum += (f_xi+f_xi1);
    x += h;
  }
  sum *= h/2.0;
  return sum;
}
int
main(int argc, char **argv)
{
  /* nombre de trapèzes: */
  long long int num_trap = 0;
  long long int i = 0,
    start_i = 0, stop_i = 0;
  double h = 0;
  double sum = 0;
  /* buffer pour récupérer
   * les sous-sommes des différents
   * noeuds: */
  double *sum_buf = NULL;
  size = rank = -1;
  /* En cas de problème (deadlock,
   * boucle infinie, etc), arrêter le
   * programme au bout de 60 secondes: */  alarm(600);
  MPI_Init(&argc, &argv);
  MPI_Barrier(MPI_COMM_WORLD);
  start_time = MPI_Wtime();
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  if (rank == 0) {
    /* Noeud maître*/
    xprintf("Taille du cluster: %d\n",
            size);
    /* Lire le nombre de trapèzes à
     * utiliser pour le calcul de
     * l’intégrale */
    num_trap = atoll(argv[1]);
    xprintf("Nombre de trapèzes: %Ld\n",
           num_trap);
  }
  /* Envoyer/recevoir le nombre
   * de trapèzes */
  MPI_Bcast((void *) &num_trap, 1,
            MPI_LONG_LONG_INT, 0,
            MPI_COMM_WORLD);
  /* Calculer notre partie
   * de la somme: */
  h = ( 1.0 - 0.0 ) / (double)num_trap;
  start_i = 1 + num_trap * rank / size;
  stop_i = num_trap * (rank + 1) / size;
  sum = sub_sum(start_i, stop_i, h);
  /* récupérer toutes les valeurs
   * des sous-sommes */
  if ( rank == 0 )
    /* Noeud maître: c’est nous qui
     * récupérons les valeurs, nous
     * devons donc allouer de la mémoire
     * à cette fin */
    sum_buf = malloc(sizeof(double)
                     * size);
  MPI_Gather((void *)&sum, 1,
             MPI_DOUBLE, sum_buf, 1,
             MPI_DOUBLE, 0,
             MPI_COMM_WORLD);
  if ( rank == 0 ) {
    /* noeud maître: sommer
     * les sous-sommes pour obtenir
     * la valeur de pi */
    sum = 0;
    for (i=0 ; i < size ; i++ ) {
      xprintf("somme=%.12f pour le "
	      "noeud %d\n",
	      sum_buf[i], i);
      sum += sum_buf[i];
    }
    xprintf("pi=%.12f\n", sum);
  }
  xexit(0);
  /* Nous n’arrivons jamais ici,
   * mais la ligne suivante est
   * nécessaire pour éviter un warning
   */
  return 0;
}
