#find_path(KOKKOS_PREFIX
#    NAMES include/papi.h
#    /opt/papi
#)

set(KOKKOS_PREFIX ${KOKKOS_PATH})

find_library(KOKKOS_LIBRARIES
    # Pick the static library first for easier run-time linking.
    NAMES libkokkos.a
    HINTS ${KOKKOS_PREFIX}/core/unit_test
    
)

find_path(PAPI_INCLUDE_DIRS
    NAMES Kokkos_Core.h
    HINTS ${KOKKOS_PREFIX}/include
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

