## Test README

This test directory contains files to generate test suites for different
Emu microbenchmarks. It can be customized for other Emu tests as well
using JSON configuration files.

### Included Files
* generate_tests.py - Python script that creates joblists for simulation
or Emu HW runs. Takes in the following parameters: 
    * platform - provides a user-specified definition of the platform which can be
      one of the following:  native, emusim, emusim-chick-box, emusim_profile, emusim-validation, emu-singlenode, emu-multinode. 
    * suite - one of the "test_suite" files which allows for specifying a set of tests using a certain platform
    * output_test_dir - the directory where all generated files are placed. Is passed as a parameter to the run scripts below.
* local_config.json is required to specify high-level settings for each platform. An example is included below but note that
absolute paths must be entered by the user.
* run_tests_serial.sh - Run all tests in a serial fashion (all platforms)
* launch_parallel_tests.sh - Uses GNU parallel to run multiple tests simultaneously. Can be used on native and emusim.. platforms only.
* create_emu_hw_tarball.sh - Allows a user to create a tarball for moving tests and the serial runscript to the Emu hardware test platform

## Generating Tests

We assume that all the files above are in the same directory. Note that the test directory does not have to live in the same place as the development repo since it uses absolute paths for binaries

1) The user must compile tests before running the generate script - this is because this script checks for their existence.
2) The user must specify a local_config.json file with the specific EXE location, any flags and the absolute path of binaries used. Note that additional flags can be added but require editing generate_tests.py

```
{
        "emusim" : {
            "emusim_exe" : "/tools/emu/emu-20.01/bin/emusim.x",
            "emusim_flags" : "--log2_num_nodelets=6 --model_hw",
            "binaries" : {
                   "global_stream" : "/localscratch/emu_work/build-hw/global_stream.mwx"
                }
        },

        "native" : {
            "native_flags" : "CILK_NWORKERS=28 numactl --membind=0 --cpunodebind=0",
            "binaries" : {
                   "global_stream" : "/localscratch/emu_work/build-cilk-x86/global_stream"
                   "global_stream_kokkos" : "/localscratch/emu_work/build-kokkos-x86/global_stream"
                }
        },

        "emu-multinode" : {
                "binaries" : {
                        "global_stream" : "/home/user/global_stream.mwx"
                }
        }
}
```
3) The user can then create a custom test suite to specify an experimental sweep. As an example the following test suite runs global stream with a specific input size, cilk_for spawn mode, 3 different test types, and 10 trials. Note that some options can be specified either globally in the local_config.json or on a per-test basis in the test suite JSON file. 

```
#emu-global-stream.json
[
{
    "benchmark": "global_stream",
    "log2_num_elements" : 10,
    "num_threads" : [128, 256, 512],
    "spawn_mode" : ["cilk_for"],
    "num_trials" : 10
}
]
```
4) Using generate_test.py with the JSON files above, the user can then generate their test sweeps:
```
./generate_tests.py emusim test_suites/emu-global-stream.json emusim_gstream_tests
```
If this directory exists, it can be cleaned of scripts and results and all tests can be regenerated using:
```
./generate_tests.py --clean emusim test_suites/emu-global-stream.json emusim_gstream_tests
```
For our example in Step 3, we expect to see three scripts, one for each thread size. These can be launched manually or using the serial/parallel runscripts in the main test directory.

```
[]$cd emusim_gstream_tests
[]$ls
joblist  results  scripts
[]$ls scripts
global_stream.10.128.cilk_for.1.emusim.sh  global_stream.10.256.cilk_for.1.emusim.sh  global_stream.10.512.cilk_for.1.emusim.sh
```
5) The run_tests_serial.sh and launch_parallel_tests.sh scripts can then be used to run tests serially or in parallel. Results will
show up in the results directory.

6) create_emu_hw_tarball.sh can be used to create a custom tarball with the generated tests along with the serial runscript. This can then be copied to the Chick and run in either single-node or multi-node mode.

