#find_path(KOKKOS_PREFIX
#    NAMES include/papi.h
#    /opt/papi
#)

#You can explicitly set the path here or in the "configure" script
#set(KOKKOS_PREFIX ${KOKKOS_PATH})

find_library(KOKKOS_LIBRARIES
    # Pick the static library first for easier run-time linking.
    NAMES libkokkos.2001.a
    HINTS .
    
)

find_path(KOKKOS_INCLUDE_DIRS
    NAMES Kokkos_Core.hpp KokkosCore_config.h
    PATHS ${KOKKOS_PREFIX}/include ${KOKKOS_PREFIX}/core/src ${KOKKOS_PREFIX}/core/unit_test ${KOKKOS_PREFIX}/containers/src ${KOKKOS_PREFIX}/algorithms/src ${KOKKOS_PREFIX}/core/src/eti ${KOKKOS_PREFIX}/tpls/mdspan/include
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(KOKKOS
    DEFAULT_MSG
    KOKKOS_LIBRARIES
    KOKKOS_INCLUDE_DIRS
)

mark_as_advanced(
    KOKKOS_PREFIX_DIRS
    KOKKOS_LIBRARIES
    KOKKOS_INCLUDE_DIRS
)

