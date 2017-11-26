vlib work
vlog memory.v bunImgMem.v
vsim -L altera_mf_ver -L lpm_ver memory

log -r {/*}
add wave {/*}

#run 1
force {clock} 1
force {address[11]} 0
force {address[10]} 0
force {address[9]} 0
force {address[8]} 0
force {address[7]} 0
force {address[6]} 0
force {address[5]} 0
force {address[4]} 0
force {address[3]} 0
force {address[2]} 0
force {address[1]} 0
force {address[0]} 0
run 10ns

#stop clock
force {clock} 0
run 10ns

#clock on
force {clock} 1
force {address[11]} 0
force {address[10]} 0
force {address[9]} 0
force {address[8]} 0
force {address[7]} 0
force {address[6]} 0
force {address[5]} 1
force {address[4]} 1
force {address[3]} 1
force {address[2]} 1
force {address[1]} 0
force {address[0]} 0
run 10ns

#stop clock
force {clock} 0
run 10ns

#clock on
force {clock} 1
force {address[11]} 0
force {address[10]} 0
force {address[9]} 0
force {address[8]} 0
force {address[7]} 0
force {address[6]} 0
force {address[5]} 0
force {address[4]} 0
force {address[3]} 1
force {address[2]} 0
force {address[1]} 1
force {address[0]} 1
run 10ns

#stop clock
force {clock} 0
run 10ns
