vlib work
vlog FSM2.v 
vsim FSM2
log -r {/*}
add wave {/*}
force {clock} 0 0ns , 1 {1ns} -r 2ns

force {reset} 1
run 10ns

#3 shapes
#4 beats


force {reset} 0
force {start} 1
run 60ns

force {start} 0
run 10ns

#beat1
force {beatIncremented} 1
run 10ns

force {beatIncremented} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

#beat2
force {beatIncremented} 1
run 10ns

force {beatIncremented} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

#beat3
force {beatIncremented} 1
run 10ns

force {beatIncremented} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

#beat4
force {beatIncremented} 1
run 10ns

force {beatIncremented} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

force {shapeDone} 1
run 10ns

force {shapeDone} 0
run 10ns

force {songDone} 1
run 10ns
