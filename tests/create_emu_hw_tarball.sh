#!/bin/bash -e
# This script creates a tarball to copy data to/from the Emu HW
# Usage: ./create_emu_hw_tarball.sh <generated_test_dir> 
# 6/13/20
# Jeff Young

EMU_TEST_DIR=emu_hw_test

if [ -z $1 ];
then
	printf "Pass a test directory as the first arg\n"
	printf "Example usage: ./create_emu_hw_tarball.sh global_stream_test_dir\n"
	exit 1
fi

#Create a tarball with the test scripts and mwx directories under a new top-level directory
mkdir -p ${EMU_TEST_DIR}
cp -rf $1 runall_tests_serial.sh print_results_awk.sh set_emu_hw_paths.sh ../bin/*.mwx ${EMU_TEST_DIR}/.
#Tar up the test directory
tar cvzf $1.tgz ${EMU_TEST_DIR}
#Remove the local copy of this directory
rm -rf ${EMU_TEST_DIR}
