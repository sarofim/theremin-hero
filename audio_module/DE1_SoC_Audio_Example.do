#set up
vlib work
vlog DE1_SoC_Audio_Example.v
vsim -novopt DE1_SoC_Audio_Example

log {/*}
add wave {/*}

#reset
force {CLOCK_50} 0 0ns , 1 {1ns} -r 2ns
force {KEY[0]} 1
run 10ns

#B4
force {SW[2]} 1
force {SW[1]} 0
force {SW[0]} 0
force {KEY[0]} 0
run 1000ns

#g4
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0
force {KEY[0]} 0
run 1000ns

#f4
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 1
force {KEY[0]} 0
run 1000ns
