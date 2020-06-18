#!/bin/bash
# This script uses simple awk commands to parse out host seconds

#Point the awk scripts at a specific results directory

Ex:
```
$ ./print_combined_gem_stats_awk.sh simdbench/exp1/
Host time: 40.03 s
Sim time: 0.007471 s
Sim instructions: 29137852
```


RESULTDIR=$1

awk -F ' ' '$1 == "host_seconds" {sum += $2} END {print "Host time: " sum " s"}' ${RESULTDIR}/*.log*
