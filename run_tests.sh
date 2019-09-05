#Simple script to run different microbench tests
MODE=serial_spawn
LOG2ELEM=100
THREADS=64
ITERATIONS=1
emusim.x local_stream_kokkos.mwx $MODE $LOG2ELEM $THREADS $ITERATIONS   
