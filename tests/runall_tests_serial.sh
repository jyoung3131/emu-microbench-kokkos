#!/bin/bash -e
# This script runs all the generated jobs in a serial fashion
# Usage: ./runall_tests_serial.sh <generated_test_dir> 
# 6/13/20
# Eric Hein 
# Slightly updated by Jeff Young

if [ -z $1 ];
then
	printf "Pass a test directory as the first arg\n"
	printf "Example usage: ./runall_tests_serial.sh global_stream_test_dir\n"
	exit 1
fi

while IFS= read -r -u9 cmd; do
    date
    echo "Running $cmd"
    $cmd
done 9< $1 #joblist
date
echo "Done!"

