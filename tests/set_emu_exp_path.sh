#!/bin/bash
# This script sets variables used by the test suite to run executables and pass in input files
# Source this file like `. set_emu_exp_paths.sh`

#This is the base directory where the test scripts are generated and where they point to
export EXP_BASE=/data/kokkos_emu_jyoung/emu-microbench-kokkos/tests
#Directory where the MWX files are located
export EMU_MWX_BIN=/data/kokkos_emu_jyoung/emu-microbench-kokkos/bin
#Location of dataset files
export EMU_DATASETS=/home/jyoung9/paperwasp/data_sets 

printf "New paths are: \nEXP_BASE: %s\nEMU_MWX_BIN: %s\nEMU_DATASETS: %s\n" "$EXP_BASE" "$EMU_MWX_BIN" "$EMU_DATASETS"
