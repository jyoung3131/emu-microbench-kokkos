#Makefile to link Emu code and Kokkos together for a simple example. Based on Kokkos tutorial Makefiles

#Make sure that the Emu tools and libraries are in your path
#export PATH=${PATH}:/usr/local/emu/bin
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/emu/lib

#Specify your Emu toolchain base path here for includes and linking
ifeq ($(EMU_1902_TOOLS),1)
	EMU_PATH = /usr/local/emu
else
	EMU_PATH = /tools/emu/emu-19.09-preview
endif
KOKKOS_PATH = ${HOME}/git_repos/sandia_kokkos/kokkos-emu-backend-mdspan2/kokkos
#KOKKOS_PATH = ${HOME}/Kokkos/kokkos

KOKKOS_DEVICES = "CilkPlus"
KOKKOS_ARCH = "Emu"

#### TODO: Add checks to compile with different backends #####
ifeq (,$(findstring Emu,$(KOKKOS_DEVICES)))
  KOKKOS_ENABLE_EMU=1
endif

#ifeq ($(KOKKOS_ENABLE_EMU), 1)
  CXX = emu-cc
#else
#  CXX = g++
#endif

CXXFLAGS = -Wall -Werror -fcilkplus -Wno-unused -Wno-uninitialized -Wno-cilk-loop-control-var-modification -O3 -DNDEBUG 
LINK ?= $(CXX)
LDFLAGS ?= 

KOKKOS_FLAGS = -lemu_c_utils

#ifeq ($(KOKKOS_ENABLE_EMU), 1)
#   KOKKOS_FLAGS += -lemu_c_utils
#else
#override KOKKOS_FLAGS += -lpthread
#endif

DEPFLAGS = -M
#Switch between older and newer Kokkos libraries to test improvements
#Make sure to also switch between toolchain versions when testing

ifeq ($(EMU_1902_TOOLS),1)
	LIBKOKKOS=libkokkos.1902.a
else
	LIBKOKKOS=libkokkos.1909.a
endif

#include $(KOKKOS_PATH)/Makefile.kokkos

KOKKOS_ETI_PATH ?= ${KOKKOS_PATH}/core/src/eti

KOKKOS_CXXFLAGS = -I./ -I$(KOKKOS_PATH)/core/src -I$(KOKKOS_PATH)/containers/src -I$(KOKKOS_PATH)/algorithms/src -I$(KOKKOS_ETI_PATH)
KOKKOS_CXXFLAGS += -I${KOKKOS_PATH}/tpls/mdspan/include
KOKKOS_LIBS := -L. -l:${LIBKOKKOS} ${KOKKOS_LIBS}
KOKKOS_LINK_DEPENDS=${LIBKOKKOS}

EMU_CXXFLAGS = -I ${EMU_PATH}/include
EMU_LIBS = -L${EMU_PATH}lib -l:libemu_c_utils.a

#Add includes for files here
#ifeq ($(KOKKOS_ENABLE_EMU), 1)
#KOKKOS_CXXFLAGS += -I${KOKKOS_PATH}/core/unit_test/emu-test
#endif

HELLOEXE=emu_hello_world.mwx
HELLOOBJ=emu_hello_world.o

LSTREAMEXE=local_stream_kokkos.mwx
LSTREAMOBJ=local_stream_kokkos.o

default: all

all: $(LSTREAMEXE) $(HELLOEXE)

emu_hello_world.o: emu_hello_world.cpp
	$(CXX) $(KOKKOS_CPPFLAGS) $(KOKKOS_CXXFLAGS) $(EMU_CXXFLAGS) $(CXXFLAGS) -c $<

$(HELLOEXE): $(HELLOOBJ)
	$(LINK) $(HELLOOBJ) $(KOKKOS_LDFLAGS) $(EMU_LIBS) $(KOKKOS_LIBS) -o $(HELLOEXE)

local_stream_kokkos.o: local_stream_kokkos.cpp
	$(CXX) $(KOKKOS_CPPFLAGS) $(KOKKOS_CXXFLAGS) $(EMU_CXXFLAGS) $(CXXFLAGS) -c $<

$(LSTREAMEXE): $(LSTREAMOBJ)
	$(LINK) $(LSTREAMOBJ) $(KOKKOS_LDFLAGS) $(KOKKOS_LIBS) $(EMU_LIBS) -o $(LSTREAMEXE)

clean:	
	rm -f *.vsf *.cdc *.o *.mwx
