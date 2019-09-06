#Simple script to run different microbench tests
MODE=serial_spawn
LOG2ELEM=10
THREADS=128
ITERATIONS=1
emusim.x local_stream_kokkos_1909.mwx $MODE $LOG2ELEM $THREADS $ITERATIONS   
