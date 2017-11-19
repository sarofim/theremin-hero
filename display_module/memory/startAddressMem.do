vlib work
vlog startAddressMem.v 
vsim -novopt -L altera_mf_ver -L lpm_ver startAddressMem

log -r {/*}
add wave {/*}

force {clock} 0 0ns , 1 {1ns} -r 2ns
force {wren} 0
run 10ns

#read address 0
force {address[4]} 0
force {address[3]} 0
force {address[2]} 0
force {address[1]} 0
force {address[0]} 0
run 10ns

#read address 0
force {address[4]} 0
force {address[3]} 0
force {address[2]} 0
force {address[1]} 0
force {address[0]} 1
run 10ns

#read address 0
force {address[4]} 0
force {address[3]} 0
force {address[2]} 0
force {address[1]} 1
force {address[0]} 0
run 10ns


