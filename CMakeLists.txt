# hello_mpi build root

cmake_minimum_required(VERSION 2.8.9)

set(CMAKE_C_COMPILER "mpicc.openmpi")
set(CMAKE_LINKER "mpicc.openmpi")
#set(LIBS "-L/usr/lib -lmpi")
#set(INCLUDEPATH ". /usr/include/")

project(hello_mpi)

#include_directories( ${INCLUDEPATH} )

set(${PROJECT_NAME}_SOURCES
  hello_mpi.c)

add_executable(${PROJECT_NAME}
  ${${PROJECT_NAME}_SOURCES})
#target_link_libraries(hello_mpi ${LIBS})
