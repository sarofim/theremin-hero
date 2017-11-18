vlib work
vlog FSM.v FSM1.v FSM2.v FSM3.v 
vsim FSM

log -r {/*}
add wave {/*}
force {clock} 0 0ns , 1 {1ns} -r 2ns

force {reset} 1
run 5 ns

force {reset} 0
force {start} 1
run 30 ns


force {start} 0
run 1000ns