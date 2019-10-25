#Simple script to run different microbench tests
MODE=serial_spawn
LOG2ELEM=4
THREADS=64
ITERATIONS=1
emusim.x --ignore_starttiming --max_sim_time 400 local_stream_kokkos.mwx $MODE $LOG2ELEM $THREADS $ITERATIONS   
#emusim.x --untimed_short_trace --gcs_per_nodelet 4 --initialize_mem -m30 --max_sim_time 400 local_stream_kokkos.mwx $MODE $LOG2ELEM $THREADS $ITERATIONS   
#emusim.x --max_sim_time 400 local_stream_kokkos.mwx $MODE $LOG2ELEM $THREADS $ITERATIONS   
