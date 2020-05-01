#! /bin/bash

module purge
module load gcc/7.4.0
module load spectrum-mpi/10.3.1.2-20200121
module load cuda/10.1.243
module load netlib-lapack/3.8.0
module load openblas/0.3.9-omp
module load cmake/3.15.2

# build_chroma_laph.sh
# This script builds the chroma_laph library with options for parallel acrheticture. 

BASE_DIR=$1
CHROMA_LAPH_BUILD_DIR=${BASE_DIR}/build/chroma_laph
CHROMA_LAPH_INSTALL_DIR=${BASE_DIR}/install/chroma_laph
CHROMA_LAPH_SOURCE_DIR=${BASE_DIR}/source/chroma_laph

# Clean out any previous builds, installs, and sources
rm -rf ${CHROMA_LAPH_BUILD_DIR}
rm -rf ${CHROMA_LAPH_INSTALL_DIR}
rm -rf ${CHROMA_LAPH_SOURCE_DIR}

# Make a new build and install dir
mkdir -p ${CHROMA_LAPH_BUILD_DIR}
mkdir -p ${CHROMA_LAPH_INSTALL_DIR}

# Clone the CHROMA_LAPH repo
git clone https://cpviolator@bitbucket.org/jbulava/chroma_laph.git ${CHROMA_LAPH_SOURCE_DIR}

(cd ${CHROMA_LAPH_SOURCE_DIR}; git checkout devel/v2beta_blas_quda)

# Define paths to dependencies
# Define paths to dependencies
QMP_INSTALL_DIR=${BASE_DIR}/install/qmp
QDPXX_INSTALL_DIR=${BASE_DIR}/install/qdpxx
CHROMA_INSTALL_DIR=${BASE_DIR}/install/chroma
QUDA_INSTALL_DIR=${BASE_DIR}/build/quda

(cd ${CHROMA_LAPH_SOURCE_DIR}; aclocal; autoconf; automake --foreign --add-missing )

(cd ${CHROMA_LAPH_BUILD_DIR}; ${CHROMA_LAPH_SOURCE_DIR}/configure --prefix=${CHROMA_LAPH_INSTALL_DIR} LIBS="-llapack -lopenblas -lquda -lqmp -lcuda" CXXFLAGS="-O3 -std=c++14 -DUSE_OPENBLAS -DBUILD_QUDA -I${QUDA_INSTALL_DIR}/include" LDFLAGS="-L${QUDA_INSTALL_DIR}/lib -L${QMP_INSTALL_DIR}/lib " CFLAGS="" --with-chroma=${CHROMA_INSTALL_DIR} CC=mpicc CXX=mpicxx; make -j 10; make -j 10 install)


#(cd chroma_laph/test; `${CHROMA_INSTALL_DIR}/bin/chroma-config --cxx` `${CHROMA_INSTALL_DIR}/bin/chroma-config --cxxflags` -I${CHROMA_LAPH_SOURCE_DIR}/lib -c tests-hadrons.cpp)

#(cd chroma_laph/test; `${CHROMA_INSTALL_DIR}/bin/chroma-config --cxx` tests-hadrons.o tests-main.o -L${CHROMA_LAPH_SOURCE_DIR}/lib/ -lchromalaph -lopenblas `${CHROMA_INSTALL_DIR}/bin/chroma-config --ldflags` `${CHROMA_INSTALL_DIR}/bin/chroma-config --libs` -fopenmp -o tests)
