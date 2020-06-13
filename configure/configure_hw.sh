# Configure file for compiling with standard Emu tools (excluding Kokkos)
# Execute from the main directory using ./configure/configure_<my_platform>

BACKEND=hw
COMPILER=

BUILD_DIR=build-${BACKEND}

mkdir -p ${BUILD_DIR} && cd ${BUILD_DIR}
rm -rf CMake* 

FLAGS=""

#Make sure to use tabs rather than spaces for newline entries
cmake 	-D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_TOOLCHAIN_FILE=../cmake/emu-toolchain.cmake \
	..	
