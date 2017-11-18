vlib work
vlog FSM3.v 
vsim FSM3
log -r {/*}
add wave {/*}
force {clock} 0 0ns , 1 {1ns} -r 2ns

force {reset} 1
run 5 ns

force {reset} 0
run 5 ns

force {startingAddressLoaded} 1
run 5 ns

force {startingAddressLoaded} 0
run 5 ns

force {startingAddressLoaded} 1
run 5 ns

force {startingAddressLoaded} 0
run 5 ns

force {startingAddressLoaded} 1
run 5 ns

force {startingAddressLoaded} 0
run 5 ns

force {startingAddressLoaded} 1
run 5 ns

force {startingAddressLoaded} 0
run 5 ns

force {startingAddressLoaded} 1
run 5 ns

force {startingAddressLoaded} 0
run 5 ns