#Makefile to link Emu code and Kokkos together for a simple example. Based on Kokkos tutorial Makefiles

#Make sure that the Emu tools and libraries are in your path
#export PATH=${PATH}:/usr/local/emu/bin
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/emu/lib

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

#include $(KOKKOS_PATH)/Makefile.kokkos

KOKKOS_ETI_PATH ?= ${KOKKOS_PATH}/core/src/eti

KOKKOS_CXXFLAGS = -I./ -I$(KOKKOS_PATH)/core/src -I$(KOKKOS_PATH)/containers/src -I$(KOKKOS_PATH)/algorithms/src -I$(KOKKOS_ETI_PATH)
KOKKOS_CXXFLAGS += -I${KOKKOS_PATH}/tpls/mdspan/include
KOKKOS_LIBS := -L. -l:libkokkos.a ${KOKKOS_LIBS}
KOKKOS_LINK_DEPENDS=libkokkos.a

EMU_CXXFLAGS = -I /usr/local/emu/include
EMU_LIBS = -L/usr/local/emu/lib -lemu_c_utils

#Add includes for files here
#ifeq ($(KOKKOS_ENABLE_EMU), 1)
#KOKKOS_CXXFLAGS += -I${KOKKOS_PATH}/core/unit_test/emu-test
#endif

LSTREAMEXE=local_stream_kokkos.mwx
LSTREAMOBJ=local_stream_kokkos.o

default: all

all: $(LSTREAMEXE)

local_stream_kokkos.o: local_stream_kokkos.cpp
	$(CXX) $(EMU_CXXFLAGS) $(KOKKOS_CPPFLAGS) $(KOKKOS_CXXFLAGS) $(CXXFLAGS) -c $<

$(LSTREAMEXE): $(LSTREAMOBJ)
	$(LINK) $(LSTREAMOBJ) $(KOKKOS_LDFLAGS) $(EMU_LIBS) $(KOKKOS_LIBS) -o $(LSTREAMEXE)

clean:	
	rm -f *.o *.mwx
