### hello_mpi.pro ---
## 
## Author: Remi Michelas
## Created: Tue Oct 29 16:29:44 CET 2013
## Version: 
######################################################################
## 
### Change Log:
## 
######################################################################

TEMPLATE = app
TARGET = hello_mpi
DEPENDPATH += .
#INCLUDEPATH += . /usr/include/ # add include path here to find the header
#LIBS += -L/usr/lib -lmpi     # add library and path here in the link stage
QMAKE_CC = mpicc.openmpi               # replace gcc with mpicc
QMAKE_LINK = mpicc.openmpi             # change the linker, if not set it is g++


## ###################################################################
## Configuration
## ###################################################################

macx:CONFIG -= app_bundle

## ###################################################################
## Input
## ###################################################################

SOURCES += hello_mpi.c
