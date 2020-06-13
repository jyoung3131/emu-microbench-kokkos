## Test README

This test directory contains files to generate test suites for different
Emu microbenchmarks. It can be customized for other Emu tests as well
using JSON configuration files.

### Included Files
* generate_tests.py - Python script that creates joblists for simulation
or Emu HW runs. Takes in the following parameters: 
    * platform - provides a user-specified definition of the 
* launch_parallel_tests.sh - Uses GNU parallel to run multiple tests
simultaneously. Best used for simulation or native runs with small numbers
of threads.
