#!/bin/bash -l

#summit modules
module purge
module load gcc/7.4.0
module load spectrum-mpi/10.3.1.2-20200121
module load cuda/10.1.243
module load netlib-lapack/3.8.0
module load openblas/0.3.9-omp
module load cmake/3.15.2

# This is where the stack install will take place
BASE_DIR=/gpfs/alpine/lgt100/proj-shared/c51/software/laph_nn/dean_test

mkdir -p ${BASE_DIR}/build
mkdir -p ${BASE_DIR}/install
mkdir -p ${BASE_DIR}/source

# Build QMP. This script will download, build, and install
./build_qmp.sh ${BASE_DIR} 

# Build QDPXX. This script will download, build, and install
./build_qdpxx.sh ${BASE_DIR} 

# Build QUDA. This script will download, and build
./build_quda.sh ${BASE_DIR} 

# Build CHROMA. This script will download, build, and install
./build_chroma.sh ${BASE_DIR} 

# Build CHROMA_LAPH. This script will download, build, and install
./build_chroma_laph.sh ${BASE_DIR} 
