vlib work
vlog lab7part2.v 
vsim -L altera_mf_ver -L lpm_ver part2

log -r {/*}
add wave {/*}

#song has 4 bits - run for 5
#try with timing where readyForSong appears before timing suggests you go
#try other way around - readyForSong appears after timing says to go
force {clock} 0 0ns , 1 {1ns} -r 2ns
force {reset} 1
force {readyForSong} 0
run 10ns


force {reset} 0
run 10ns

force {readyForSong} 1
2 ns

force {readyForSong} 0
10 ns

force {readyForSong} 1
2 ns

force {readyForSong} 0
10 ns

force {readyForSong} 1
2 ns

force {readyForSong} 0
10 ns

force {readyForSong} 1
2 ns

force {readyForSong} 0
10 ns

force {readyForSong} 1
2 ns

force {readyForSong} 0
10 ns