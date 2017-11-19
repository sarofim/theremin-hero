vlib work
vlog FSM1.v 
vsim FSM1
log -r {/*}
add wave {/*}

#song has 4 bits - run for 5
#try with timing where readyForSong appears before timing suggests you go
#try other way around - readyForSong appears after timing says to go
force {clock} 0 0ns , 1 {1ns} -r 2ns

force {reset} 1
force {readyForSong} 0
run 2ns


force {reset} 0
run 2ns

force {readyForSong} 1
run 2 ns

force {readyForSong} 0
run 20ns

force {readyForSong} 1
run 2 ns

force {readyForSong} 0
run 20ns

force {readyForSong} 1
run 2 ns

force {readyForSong} 0
run 20ns

force {readyForSong} 1
run 2 ns

force {readyForSong} 0
run 20ns

force {readyForSong} 1
run 2 ns

force {readyForSong} 0
run 20ns

force {readyForSong} 1
run 2 ns

force {readyForSong} 0
run 20ns