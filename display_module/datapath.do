vlib work
vlog dataPath.v
vsim -novopt dataPath 

log -r {/*}
add wave {/*}
force {clock} 0 0ns , 1 {1ns} -r 2ns
#reset
force {reset} 1
run 5ns

force {reset} 0
run 5ns 
#test cases
force {shiftSong} 1
force {loadStartAddress} 1

force {boxCounter[1]} 0
force {boxCounter[0]} 0
run 10ns
#shiftOff
force {shiftSong} 0
force {loadStartAddress} 0
run 5ns
#cas2
force {shiftSong} 1
force {loadStartAddress} 1

force {boxCounter[1]} 0
force {boxCounter[0]} 1
run 10ns
#shiftOff
force {shiftSong} 0
force {loadStartAddress} 0
run 5ns
#case3
force {shiftSong} 1
force {loadStartAddress} 1

force {boxCounter[1]} 1
force {boxCounter[0]} 0
run 10ns
#shiftOff
force {shiftSong} 0
force {loadStartAddress} 0
run 5ns