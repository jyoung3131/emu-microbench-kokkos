#!/bin/bash
# This script runs all the generated jobs in a parallel fashion with gnu parallel
# Usage: ./launch_tests_parallel.sh <generated_test_dir> 
# 6/13/20
# Eric Hein 
# Slightly updated by Jeff Young

if [ -z $1 ];
then
	printf "Pass a test directory as the first arg\n"
	printf "Example usage: ./launch_tests_parallel.sh global_stream_test_dir\n"
	exit 1
fi


parallel --workdir . -a $1/joblist --joblog $1/joblog --progress
