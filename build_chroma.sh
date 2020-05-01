#! /bin/bash -l

module purge
module load gcc/7.4.0
module load spectrum-mpi/10.3.1.2-20200121
module load cuda/10.1.243
module load netlib-lapack/3.8.0
module load openblas/0.3.9-omp
module load cmake/3.15.2

# build_chroma.sh
# This script builds the chroma library with options for parallel acrheticture. 

BASE_DIR=$1
CHROMA_BUILD_DIR=${BASE_DIR}/build/chroma
CHROMA_INSTALL_DIR=${BASE_DIR}/install/chroma
CHROMA_SOURCE_DIR=${BASE_DIR}/source/chroma

# Clean out any previous builds, installs, and sources
rm -rf ${CHROMA_BUILD_DIR}
rm -rf ${CHROMA_INSTALL_DIR}
rm -rf ${CHROMA_SOURCE_DIR}

# Make a new build and install dir
mkdir -p ${CHROMA_BUILD_DIR}
mkdir -p ${CHROMA_INSTALL_DIR}

# Clone the CHROMA repo
git clone https://github.com/JeffersonLab/chroma.git ${CHROMA_SOURCE_DIR}
(cd ${CHROMA_SOURCE_DIR}; git checkout devel)

# Fix the submodule addresses
sed -i "s/git@github.com:/https:\/\/github.com\//" ${CHROMA_SOURCE_DIR}/.git/config

# Recursive clone 
(cd ${CHROMA_SOURCE_DIR}; git submodule update --init --recursive)

# Define paths to dependencies
QMP_INSTALL_DIR=${BASE_DIR}/install/qmp
QDPXX_INSTALL_DIR=${BASE_DIR}/install/qdpxx
#QUDA_INSTALL_DIR=${BASE_DIR}/build/quda

# configure, make, install
(cd ${CHROMA_SOURCE_DIR}; aclocal; autoconf -i -f; autoreconf -i -f; automake -i -f)

(cd ${CHROMA_BUILD_DIR}; ${CHROMA_SOURCE_DIR}/configure --prefix=${CHROMA_INSTALL_DIR} --disable-cpp-wilson-dslash --with-qmp=${QMP_INSTALL_DIR} --enable-openmp --with-qdp=${QDPXX_INSTALL_DIR} --enable-layout=cb2 CXXFLAGS="-O3 -std=c++14 -finline-limit=15000 -funroll-all-loops -fopenmp -D_REENTRANT" CFLAGS="-O3 -std=c99 -funroll-all-loops -fopenmp -D_REENTRANT" LIBS="-lm" LDFLAGS="" CC=mpicc CXX=mpicxx ; make -j 6; make -j 6 install)

#(cd ${CHROMA_BUILD_DIR}; ${CHROMA_SOURCE_DIR}/configure --prefix=${CHROMA_INSTALL_DIR} --disable-cpp-wilson-dslash --with-qmp=${QMP_INSTALL_DIR} --enable-openmp --with-qdp=${QDPXX_INSTALL_DIR} --with-quda=${QUDA_INSTALL_DIR} --with-cuda=${CUDA_DIR} --enable-layout=cb2 CXXFLAGS="-O3 -std=c++14 -finline-limit=15000 -funroll-all-loops -fopenmp -D_REENTRANT" CFLAGS="-O3 -std=c99 -funroll-all-loops -fopenmp -D_REENTRANT" LIBS="-lm" LDFLAGS="" CC=mpicc CXX=mpicxx ; make -j 6; make -j 6 install)
