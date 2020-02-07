#!/bin/bash
# This script allows for simulating and profiling Kokkos Emu benchmarks
# Last updated: 2/6/20

#Macros for Emu-specific timing hooks
export CORE_CLK_MHZ=175
export GCS_PER_NODELET=1

#------------Command-line input----------
RUNCFG=$1
TEST=$2

#------------User-specified flags----------
#MODE can be cilk_for, serial_spawn, recursive_spawn, library, or serial
MODE=serial_spawn
LOG2ELEM=6
THREADS=64
ITERATIONS=1
bmkname=local_stream
testname=2
#Disable any validation
export NO_VALIDATE=1

#Check to make sure arguments were passed
check_param()
{
        if [ -z "$RUNCFG" ]; then
                echo "Please pass <0> for simulation or <1> for profiling"
                exit 1
        fi
        
	if [ -z "$TEST" ]; then
                echo "Please pass <0> for Emu Cilk benchmark or <1> for kokkos benchmark"
                exit 1
        fi
}

check_param

if [ "$TEST" == "0" ]; then
	exe=${bmkname}.mwx
	exetype=emucilk
else
	exe=${bmkname}_kokkos.mwx
	exetype=kokkos
fi

logname=${bmkname}_${exetype}_${testname}

#Loop over multiple scales to test
#for scale in {1..1}
#do

	#You need to pass the full path for data inputs when using distributed load and the files must
	#be at the same exact paths on each node
	flags="$MODE $LOG2ELEM $THREADS $ITERATIONS"

	#Run simulation
	if [ "$RUNCFG" == "0" ]; then
		cmd="emusim.x --model_hw -m26 --ignore_starttiming --max_sim_time 400 --initialize_memory -- ${exe} ${flags}"
		output_dir=results/simulation
		#--initialize-memory with -m30 requires about 8 GB of physical memory to be available
		#cmd="emusim.x --ignore_starttiming -- ${exe} ${flags}"
		output_file="${output_dir}/sim_emu_${logname}.log"
	else
		output_dir=results/profiling
		cmd="emusim_profile ${output_dir}/prof_${logname} --model_hw -m26 -- ${exe} ${flags}"
		#Create the new profiling directory
		mkdir -p ${output_dir}/prof_${logname}
		output_file="${output_dir}/prof_${logname}/profile_emu_${logname}.log"
	fi

	#Print the command being run
	echo "${cmd} &> ${output_file}"
	#Run the Emu tests and print all output to a file
	#${cmd} &> ${output_file}
#done
