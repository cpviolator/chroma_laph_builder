#!/bin/bash -l

module purge
module load gcc/7.4.0
module load spectrum-mpi/10.3.1.2-20200121
module load cuda/10.1.243
module load netlib-lapack/3.8.0
module load openblas/0.3.9-omp
module load cmake/3.15.2

# build_qmp.sh
# This script builds the qmp library with options for parallel acrheticture. 

BASE_DIR=$1
QMP_BUILD_DIR=${BASE_DIR}/build/qmp
QMP_INSTALL_DIR=${BASE_DIR}/install/qmp
QMP_SOURCE_DIR=${BASE_DIR}/source/qmp

# Clean out any previous builds, installs, and sources
rm -rf ${QMP_BUILD_DIR}
rm -rf ${QMP_INSTALL_DIR}
rm -rf ${QMP_SOURCE_DIR}

# Make a new build and install dir
mkdir -p ${QMP_BUILD_DIR}
mkdir -p ${QMP_INSTALL_DIR}

# Clone the QMP repo
git clone https://github.com/usqcd-software/qmp.git ${QMP_SOURCE_DIR}

# configure, make, install
(cd ${QMP_SOURCE_DIR}; aclocal; autoreconf -i -f -v)

(cd ${QMP_BUILD_DIR}; ${QMP_SOURCE_DIR}/configure --with-qmp-comms-type=MPI CFLAGS="-O2 -std=c99 -funroll-all-loops -fopenmp -D_REENTRANT" CC=mpicc --prefix=${QMP_INSTALL_DIR}; make -j 8; make -j 8 install)
