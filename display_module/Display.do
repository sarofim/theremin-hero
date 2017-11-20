vlib work
vlog Display.v dataPath.v FSM.v FSM1.v FSM2.v FSM3.v 
vsim CombinedShit

log -r {/*}
add wave {/*}
force {clock} 0 0ns , 1 {50ps} -r 100ps

force {reset} 1
run 5 ns

force {reset} 0
force {start} 0
run 10000ns

force {start} 1
run 5ns

force {start} 0
run 10000ns


