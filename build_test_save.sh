#!/usr/bin/env bash

DIR=/usr/workspace/howarth1/LASSEN/QUDA_MB_KERNELS

CHROMA_DIR=${DIR}/chroma_install
LAPH_DIR=${DIR}/chroma_laph_install
OPENBLAS=/usr/workspace/howarth1/LASSEN/OpenBLAS

`${CHROMA_DIR}/bin/chroma-config --cxx` `${CHROMA_DIR}/bin/chroma-config --cxxflags` -c tests-main.cpp
echo "Built main"

`${CHROMA_DIR}/bin/chroma-config --cxx` `${CHROMA_DIR}/bin/chroma-config --cxxflags` -I${LAPH_DIR}/include/ -c tests-hadrons.cpp
echo "Built hadrons"

`${CHROMA_DIR}/bin/chroma-config --cxx` tests-hadrons.o tests-main.o -L${LAPH_DIR}/lib -lchromalaph -L${OPENBLAS} -lopenblas `${CHROMA_DIR}/bin/chroma-config --ldflags` `${CHROMA_DIR}/bin/chroma-config --libs` -fopenmp -o tests
echo "Built executable"
