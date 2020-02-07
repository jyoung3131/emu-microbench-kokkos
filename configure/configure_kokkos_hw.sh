# Configure file for compiling with Kokkos Emu Cilk branch and Emu
# Execute from the main directory using ./configure/configure_<my_platform>

BACKEND=kokkos
COMPILER=hw

BUILD_DIR=build-${BACKEND}-${COMPILER}

mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR}
rm -rf CMake* 

#Explicitly set KOKKOS_PATH - can also set it with an environment variable
#KOKKOS_PATH=

#Specify the compilers to use
CC=emu-cc
CXX=emu-cc

FLAGS=""

#Make sure to use tabs rather than spaces for newline entries
cmake -D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_C_FLAGS_RELEASE="${CMAKE_C_FLAGS} ${FLAGS}" \
	-D CMAKE_TOOLCHAIN_FILE=../cmake/emu-toolchain.cmake \
	-D CMAKE_C_COMPILER=${CC} \
	-D CMAKE_CXX_COMPILER=${CXX} \
    	-D USE_KOKKOS=1 \
    	-D KOKKOS_PREFIX=${KOKKOS_PATH} \
	..    
