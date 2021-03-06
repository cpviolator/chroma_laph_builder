#!/bin/bash

# CMake file for constructing QUDA builds of fixed type. Use this
# file to configure QUDA the you require it using the BASH variables,
# then save the file with a unique name. Some common choices are given,
# the rest are defaulted to QUDA's default values

module purge
module load gcc/7.4.0
module load spectrum-mpi/10.3.1.2-20200121
module load cuda/10.1.243
module load netlib-lapack/3.8.0
module load openblas/0.3.9-omp
module load cmake/3.15.2

BASE_DIR=$1
QUDA_BUILD_DIR=${BASE_DIR}/build/quda
QUDA_INSTALL_DIR=${BASE_DIR}/install/quda
QUDA_SOURCE_DIR=${BASE_DIR}/source/quda

# Clean out any previous builds, installs, and sources
rm -rf ${QUDA_BUILD_DIR}
rm -rf ${QUDA_INSTALL_DIR}
rm -rf ${QUDA_SOURCE_DIR}

# Make a new build and install dir
mkdir -p ${QUDA_BUILD_DIR}
mkdir -p ${QUDA_INSTALL_DIR}

# Clone the QUDA repo
git clone https://github.com/lattice/quda.git ${QUDA_SOURCE_DIR}

(cd ${QUDA_SOURCE_DIR}; git checkout experimental/external_progs)

# Define paths to dependencies
QMP_INSTALL_DIR=${BASE_DIR}/install/qmp
QDPXX_INSTALL_DIR=${BASE_DIR}/install/qdpxx

#Compiler
CMAKE_CUDA_HOST_COMPILER=/sw/summit/gcc/7.4.0/bin/g++
CMAKE_CXX_COMPILER=/sw/summit/gcc/7.4.0/bin/g++
CMAKE_C_COMPILER=/sw/summit/gcc/7.4.0/bin/gcc

#Fermions
QUDA_DIRAC_WILSON=ON
QUDA_DIRAC_CLOVER=ON
QUDA_DIRAC_CLOVER_HASENBUSCH=OFF
QUDA_DIRAC_TWISTED_MASS=OFF
QUDA_DIRAC_TWISTED_CLOVER=OFF
QUDA_DIRAC_NDEG_TWISTED_MASS=OFF
QUDA_DIRAC_STAGGERED=OFF
QUDA_DIRAC_DOMAIN_WALL=OFF

#Extras
QUDA_FAST_COMPILE_DSLASH=ON
QUDA_FAST_COMPILE_REDUCE=ON
QUDA_FLOAT8=ON
QUDA_TEX=OFF
QUDA_MULTIGRID=ON
QUDA_BUILD_SHAREDLIB=OFF
QUDA_GPU_ARCH="sm_70"

#Precisons enabled.
# Expressed in base 10 as a number from 1-15,
# interpreted as base 2: (double,single,half,quarter)
# eg, 14 -> (1,1,1,0)
#      4 -> (0,1,0,0)
QUDA_PRECISION=14

#IO and MPI
QUDA_QIO=ON
QUDA_QMP=ON
QUDA_DOWNLOAD_USQCD=OFF

QUDA_QIOHOME=${QDPXX_INSTALL_DIR}
QUDA_LIMEHOME=${QDPXX_INSTALL_DIR}
QUDA_QMPHOME=${QMP_INSTALL_DIR}

CMFLAGS="-DCMAKE_CUDA_HOST_COMPILER=${CMAKE_CUDA_HOST_COMPILER} \
	 -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} \
	 -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} \
         -DCMAKE_INSTALL_PREFIX:PATH=${QUDA_INSTALL_DIR} \
	 -DQUDA_DIRAC_WILSON=${QUDA_DIRAC_WILSON} \
	 -DQUDA_DIRAC_CLOVER=${QUDA_DIRAC_CLOVER} \
	 -DQUDA_DIRAC_TWISTED_MASS=${QUDA_DIRAC_TWISTED_MASS} \
	 -DQUDA_DIRAC_NDEG_TWISTED_MASS=${QUDA_DIRAC_NDEG_TWISTED_MASS} \
	 -DQUDA_DIRAC_TWISTED_CLOVER=${QUDA_DIRAC_TWISTED_CLOVER} \
	 -DQUDA_DIRAC_CLOVER_HASENBUSCH=${QUDA_DIRAC_CLOVER_HASENBUSCH} \
	 -DQUDA_DIRAC_STAGGERED=${QUDA_DIRAC_STAGGERED} \
	 -DQUDA_DIRAC_DOMAIN_WALL=${QUDA_DIRAC_DOMAIN_WALL} \
	 -DQUDA_FAST_COMPILE_DSLASH=${QUDA_FAST_COMPILE_DSLASH} \
	 -DQUDA_FAST_COMPILE_REDUCE=${QUDA_FAST_COMPILE_REDUCE} \
	 -DQUDA_BUILD_SHAREDLIB=${QUDA_BUILD_SHAREDLIB} \
	 -DQUDA_FLOAT8=${QUDA_FLOAT8} \
	 -DQUDA_TEX=${QUDA_TEX} \
	 -DQUDA_GPU_ARCH=${QUDA_GPU_ARCH} \
	 -DQUDA_PRECISION=${QUDA_PRECISION} \
	 -DQUDA_DOWNLOAD_USQCD=${QUDA_DOWNLOAD_USQCD} \
	 -DQUDA_QIOHOME=${QUDA_QIOHOME} \
	 -DQUDA_QMPHOME=${QUDA_QMPHOME}	\
	 -DQUDA_LIMEHOME=${QUDA_LIMEHOME} \
	 -DQUDA_QMP=${QUDA_QMP}	\
	 -DQUDA_QIO=${QUDA_QIO} \
	 -DQUDA_MULTIGRID=${QUDA_MULTIGRID} "

(cd ${QUDA_BUILD_DIR}; cmake ${QUDA_SOURCE_DIR} ${CMFLAGS})

(cd ${QUDA_BUILD_DIR}; cmake .)

(cd ${QUDA_BUILD_DIR}; make -j 128)
