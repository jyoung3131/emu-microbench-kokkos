#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <cilk/cilk.h>
#include <assert.h>
#include <string.h>

#include <emu_c_utils/emu_c_utils.h>

// Include Kokkos core headers
#include <Kokkos_Core.hpp>

#include "recursive_spawn.h"
#include "common.h"

namespace Kokkos {
namespace Experimental {
   extern void * ers;
   //EmuHostSpace, EmuReplicatedSpace, EmuLocalSpace, EmuStridedSpace
   extern EmuLocalSpace es;
   extern void initialize_memory_space();
}}

typedef Kokkos::View< long*, Kokkos::Experimental::EmuLocalSpace > ViewVectorType;

typedef struct local_stream_data {
    ViewVectorType a;
    ViewVectorType b;
    ViewVectorType c;
    long n;
    long num_threads;
   local_stream_data(long N): a("a",(size_t)N), b("b",(size_t)N), c("c",(size_t)N) {}
} local_stream_data;

void
local_stream_init(local_stream_data * data, long n)
{
    data->n = n;
}

//Kokkos::finalize handles deintialization
//void local_stream_deinit(local_stream_data * data)

void
local_stream_add_serial(local_stream_data * data)
{
    Kokkos::parallel_for(data->n, KOKKOS_LAMBDA (const long i) {
        data->c(i) = data->a(i) + data->b(i);
    } );
}

void
local_stream_add_cilk_for(local_stream_data * data)
{
    //#pragma cilk grainsize = data->n / data->num_threads
    Kokkos::parallel_for(data->n, KOKKOS_LAMBDA (const long i) {
        data->c(i) = data->a(i) + data->b(i);
    } );
}


static void
recursive_spawn_add_worker(long begin, long end, local_stream_data *data)
{
    Kokkos::parallel_for(data->n, KOKKOS_LAMBDA (const long i) {
        data->c(i) = data->a(i) + data->b(i);
    } );
}

static void
recursive_spawn_add(long begin, long end, long grain, local_stream_data *data)
{
    RECURSIVE_CILK_SPAWN(begin, end, grain, recursive_spawn_add, data);
}

void
local_stream_add_recursive_spawn(local_stream_data * data)
{
    recursive_spawn_add(0, data->n, data->n / data->num_threads, data);
}

void
local_stream_add_serial_spawn(local_stream_data * data)
{
    long grain = data->n / data->num_threads;
    for (long i = 0; i < data->n; i += grain) {
        long begin = i;
        long end = begin + grain <= data->n ? begin + grain : data->n;
        cilk_spawn recursive_spawn_add_worker(begin, end, data);
    }
    cilk_sync;
}
/*
void
local_stream_add_library_worker(long begin, long end, va_list args)
{
    long *a = va_arg(args, long*);
    long *b = va_arg(args, long*);
    long *c = va_arg(args, long*);
    for (long i = begin; i < end; ++i) {
        c[i] = a[i] + b[i];
    }
}

void local_stream_add_library(local_stream_data * data)
{
    emu_local_for(0, data->n, data->n / data->num_threads,
        local_stream_add_library_worker, data->a, data->b, data->c
    );
}
*/

void local_stream_run(
    local_stream_data * data,
    const char * name,
    void (*benchmark)(local_stream_data *),
    long num_trials)
{
    for (long trial = 0; trial < num_trials; ++trial) {
        hooks_set_attr_i64("trial", trial);
        hooks_region_begin(name);
        benchmark(data);
        double time_ms = hooks_region_end();
        double bytes_per_second = time_ms == 0 ? 0 :
            (data->n * sizeof(long) * 3) / (time_ms/1000);
        LOG("%3.2f MB/s\n", bytes_per_second / (1000000));
    }
}

/*
static void
local_stream_validate_worker(long begin, long end, va_list args)
{
    long * c = va_arg(args, long*);
    for (long i = begin; i < end; ++i) {
        if (c[i] != 3) {
            LOG("VALIDATION ERROR: c[%li] == %li (supposed to be 3)\n", i, c[i]);
            exit(1);
        }
    }
}

void
local_stream_validate(local_stream_data * data)
{
    emu_local_for(0, data->n, LOCAL_GRAIN(data->n),
        local_stream_validate_worker, data->c
    );
}
*/

int main(int argc, char** argv)
{
    struct {
        const char* mode;
        long log2_num_elements;
        long num_threads;
        long num_trials;
    } args;

    if (argc != 5) {
        LOG("Usage: %s mode log2_num_elements num_threads num_trials\n", argv[0]);
        LOG("mode=<cilk_for serial_spawn recursive_spawn library serial \n"); 
	exit(1);
    } else { 
	args.mode = argv[1];
        args.log2_num_elements = atol(argv[2]);
        args.num_threads = atol(argv[3]);
        args.num_trials = atol(argv[4]);

        if (args.log2_num_elements <= 0) { LOG("log2_num_elements must be > 0"); exit(1); }
        if (args.num_threads <= 0) { LOG("num_threads must be > 0"); exit(1); }
        if (args.num_trials <= 0) { LOG("num_trials must be > 0"); exit(1); }
    }

  Kokkos::initialize( argc, argv );
  {

    LOG("Starting Kokkos memory space initialization\n"); fflush(stdout);
    Kokkos::Experimental::initialize_memory_space();

    long N = 1L << args.log2_num_elements;
    
    LOG("N is %li\n",N); fflush(stdout);

	
    LOG("Initializing arrays with %li elements each (%li MiB)\n",
        N, (N * sizeof(long)) / (1024*1024)); fflush(stdout);
    
    local_stream_data data(N);
    data.num_threads = args.num_threads;
    //local_stream_init(&data, N);
    data.n=N;
    LOG("Doing vector addition using %s\n", args.mode); fflush(stdout);

    #define RUN_BENCHMARK(X) local_stream_run(&data, args.mode, X, args.num_trials)

    if (!strcmp(args.mode, "cilk_for")) {
        RUN_BENCHMARK(local_stream_add_cilk_for);
    } 
    else if (!strcmp(args.mode, "serial_spawn")) {
        RUN_BENCHMARK(local_stream_add_serial_spawn);
    }else if (!strcmp(args.mode, "recursive_spawn")) {
        RUN_BENCHMARK(local_stream_add_recursive_spawn);
    }/* else if (!strcmp(args.mode, "library")) {
        RUN_BENCHMARK(local_stream_add_library);
    } */else if (!strcmp(args.mode, "serial")) {
        RUN_BENCHMARK(local_stream_add_serial);
    } else {
        LOG("Mode %s not implemented!", args.mode);
    }


#ifndef NO_VALIDATE
    LOG("Validating results...");
    //local_stream_validate(&data);
    LOG("OK\n");
#endif
    //local_stream_deinit(&data);
    

    }
    Kokkos::finalize();
    
    return 0;
}