#! /bin/bash

module purge
module load gcc/7.4.0
module load spectrum-mpi/10.3.1.2-20200121
module load cuda/10.1.243
module load netlib-lapack/3.8.0
module load openblas/0.3.9-omp
module load cmake/3.15.2

# build_qdpxx.sh
# This script builds the qdpxx library with options for parallel acrheticture. 

BASE_DIR=$1
QDPXX_BUILD_DIR=${BASE_DIR}/build/qdpxx
QDPXX_INSTALL_DIR=${BASE_DIR}/install/qdpxx
QDPXX_SOURCE_DIR=${BASE_DIR}/source/qdpxx

# Clean out any previous builds, installs, and sources
rm -rf ${QDPXX_BUILD_DIR}
rm -rf ${QDPXX_INSTALL_DIR}
rm -rf ${QDPXX_SOURCE_DIR}

# Make a new build and install dir
mkdir -p ${QDPXX_BUILD_DIR}
mkdir -p ${QDPXX_INSTALL_DIR}

# Clone the QDPXX repo
git clone https://github.com/usqcd-software/qdpxx.git ${QDPXX_SOURCE_DIR}

# Recursive clone 
(cd ${QDPXX_SOURCE_DIR}; git submodule update --init --recursive)

# Define paths to dependencies
QMP_INSTALL_DIR=${BASE_DIR}/install/qmp

# configure, make, install
(cd ${QDPXX_SOURCE_DIR}; aclocal; autoconf -i -f; autoreconf -i -f; automake -i -f)

(cd ${QDPXX_BUILD_DIR}; ${QDPXX_SOURCE_DIR}/configure --prefix=${QDPXX_INSTALL_DIR} --enable-openmp --enable-precision=double --enable-temp-precision=D --enable-layout=cb2 --enable-filedb --enable-parallel-arch=parscalar --with-qmp=${QMP_INSTALL_DIR} --enable-Nd=4 CXXFLAGS="-O3 -std=c++14  -finline-limit=15000 -funroll-all-loops -fopenmp -D_REENTRANT" CXX=mpicxx; make -j 10; make install -j 10)
