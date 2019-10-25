#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <cilk.h>

// Include Kokkos core headers
#include <Kokkos_Core.hpp>

// These are Emu-specific.
#include <memoryweb.h>
#include <timing.h>

static const char str[] = "Hello, world!";

long * ptr;
char * str_out;

int main( int argc, char* argv[] )
{
   Kokkos::initialize( argc, argv );
   {
     // long is the reliable word length, 64-bits.
     const long n = strlen (str) + 1;

     ptr = mw_malloc1dlong (n); // striped across the nodelets
     str_out = (char*)(malloc (n * sizeof (char))); // entirely on the first nodelet

     starttiming(); // For the simulator.  Start gathering stats here.

     for (long k = 0; k < n; ++k)
          ptr[k] = (long)str[k]; // Remote writes

     for (long k = 0; k < n; ++k)
          str_out[k] = (char)ptr[k]; // Migration and remote write...

     printf("%s\n", str_out);  // Migration back

     stoptiming(); // For the simulator.  Start gathering stats here.
    
  }
  Kokkos::finalize();

  return 0;
}
