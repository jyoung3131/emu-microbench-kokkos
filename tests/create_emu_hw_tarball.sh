#!/bin/bash -e
# This script creates a tarball to copy data to/from the Emu HW
# Usage: ./create_emu_hw_tarball.sh <generated_test_dir> 
# 6/13/20
# Jeff Young

if [ -z $1 ];
then
	printf "Pass a test directory as the first arg\n"
	printf "Example usage: ./create_emu_hw_tarball.sh global_stream_test_dir\n"
	exit 1
fi

#Create a tarball with the test scripts and mwx directories
tar cvzf $1.tgz generate_tests.py *.sh *.json test_suites/ ../build-kokkos-hw/*.mwx
