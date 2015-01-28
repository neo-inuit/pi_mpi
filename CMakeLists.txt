# pi_mpi build root

#coz of tompouce
cmake_minimum_required(VERSION 2.6.0)

set(BUILD_LANGUAGE "C" CACHE STRING "choose appropriate compiler (C, CXX, Fortran)")

project(pi_mpi)

# put the target in home folder
SET(RUNTIME_OUTPUT_DIRECTORY "${CMAKE_HOME_DIRECTORY}")

set(MPIEXEC "" CACHE STRING "where is located mpiexec app")

#coz nef devel use also mpich mpi library so the path for openmpi is in /opt and cmake don t search there
if(UNIX)
	execute_process(COMMAND hostname OUTPUT_VARIABLE hostnameOutput)
	message("hostname = ${hostnameOutput}")
	if(NOT MPIEXEC AND ${hostnameOutput} MATCHES "nef-devel")
		set(MPIEXEC "/opt/openmpi-gcc/1.6.3/bin/mpiexec")

	endif()
endif()
find_package(MPI REQUIRED) 

set(MPI_VERBOSE ON CACHE BOOL "To know (print) available MPI cmake variables")
if(MPI_VERBOSE)
    message("\nMPI_C_FOUND      = ${MPI_C_FOUND}")
    message("MPI_C_COMPILER     = ${MPI_C_COMPILER}")
    message("MPI_C_COMPILE_FLAGS= ${MPI_C_COMPILE_FLAGS}")
    message("MPI_C_LINK_FLAGS   = ${MPI_C_LINK_FLAGS}")
    message("MPI_C_INCLUDE_PATH = ${MPI_C_INCLUDE_PATH}")
    message("MPI_C_LIBRARIES    = ${MPI_C_LIBRARIES}")

    message("\nMPI_CXX_FOUND        = ${MPI_CXX_FOUND}")
    message("MPI_CXX_COMPILER       = ${MPI_CXX_COMPILER}")
    message("MPI_CXX_COMPILE_FLAGS  = ${MPI_CXX_COMPILE_FLAGS}")
    message("MPI_CXX_LINK_FLAGS     = ${MPI_CXX_LINK_FLAGS}")
    message("MPI_CXX_INCLUDE_PATH   = ${MPI_CXX_INCLUDE_PATH}")
    message("MPI_CXX_LIBRARIES      = ${MPI_CXX_LIBRARIES}")

    message("\nMPIEXEC              = ${MPIEXEC}")
    message("MPIEXEC_NUMPROC_FLAG   = ${MPIEXEC_NUMPROC_FLAG}")
    message("MPIEXEC_PREFLAGS       = ${MPIEXEC_PREFLAGS}")
    message("MPIEXEC_POSTFLAGS      = ${MPIEXEC_POSTFLAGS}")
    
    message("\nFor backward compatibilities:")
    message("MPI_FOUND          = ${MPI_FOUND}")
    message("MPI_COMPILER       = ${MPI_COMPILER}")
    message("MPI_LIBRARY        = ${MPI_LIBRARY}")
    message("MPI_COMPILE_FLAGS  = ${MPI_COMPILE_FLAGS}")
    message("MPI_INCLUDE_PATH   = ${MPI_INCLUDE_PATH}")
    message("MPI_EXTRA_LIBRARY  = ${MPI_EXTRA_LIBRARY}")
    message("MPI_LINK_FLAGS     = ${MPI_LINK_FLAGS}")
    message("MPI_LIBRARIES      = ${MPI_LIBRARIES}")
    
    message("\nAdvices to use MPI:")
    message("${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} PROCS ${MPIEXEC_PREFLAGS}
EXECUTABLE ${MPIEXEC_POSTFLAGS} ARGS")
    message("where PROCS is the number of processors on which to execute the
program, EXECUTABLE is the MPI program, and ARGS are the arguments to pass to
the MPI program.")
endif()

if(NOT MPI_${BUILD_LANGUAGE}_INCLUDE_PATH AND MPI_INCLUDE_PATH)
    include_directories(${MPI_INCLUDE_PATH})
else()
    include_directories(${MPI_${BUILD_LANGUAGE}_INCLUDE_PATH})
endif()

set(${PROJECT_NAME}_SOURCES
  pi_mpi.c
)
set_source_files_properties(${${PROJECT_NAME}_SOURCES} PROPERTIES LANGUAGE
${BUILD_LANGUAGE})

add_executable(${PROJECT_NAME} ${${PROJECT_NAME}_SOURCES})

if(NOT MPI_${BUILD_LANGUAGE}_LIBRARIES AND MPI_LIBRARIES)
    target_link_libraries(${PROJECT_NAME} ${MPI_LIBRARIES})
else()
    target_link_libraries(${PROJECT_NAME} ${MPI_${BUILD_LANGUAGE}_LIBRARIES})
endif()

if(NOT MPI_${BUILD_LANGUAGE}_COMPILE_FLAGS AND MPI_COMPILE_FLAGS)
    set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS
"${MPI_COMPILE_FLAGS}")
else()
    set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS
"${MPI_${BUILD_LANGUAGE}_COMPILE_FLAGS}")
endif()

if(NOT MPI_${BUILD_LANGUAGE}_LINK_FLAGS AND MPI_LINK_FLAGS)
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS
"${MPI_LINK_FLAGS}")
else()
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS
"${MPI_${BUILD_LANGUAGE}_LINK_FLAGS}")
endif()

# pi_mpi build root previous version

#cmake_minimum_required(VERSION 2.8.9)

#set(CMAKE_C_COMPILER "mpicc.openmpi")
#set(CMAKE_LINKER "mpicc.openmpi")
#set(LIBS "-L/usr/lib -lmpi")
#set(INCLUDEPATH ". /usr/include/")

#project(pi_mpi)

#include_directories( ${INCLUDEPATH} )

#set(${PROJECT_NAME}_SOURCES
#  pi_mpi.c)

#add_executable(${PROJECT_NAME}
#  ${${PROJECT_NAME}_SOURCES})
#target_link_libraries(pi_mpi ${LIBS})
