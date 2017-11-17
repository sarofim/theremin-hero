vlib work
vlog lab7part2.v 
vsim -L altera_mf_ver -L lpm_ver part2

log -r {/*}
add wave {/*}

force {clock} 0 0ns , 1 {1ns} -r 2ns

force {resetn} 0
force {plot} 0
force {loadX} 0
run 10ns
force {resetn} 1
run 10ns

force {coordinates[0]} 1
force {coordinates[1]} 1
force {coordinates[2]} 1
force {coordinates[3]} 1
force {coordinates[4]} 1
force {coordinates[5]} 1
force {coordinates[6]} 1
force {colour[0]} 1
force {colour[1]} 1
force {colour[2]} 1
force {loadX} 1
run 10ns
force {loadX} 0

run 20ns
force {plot} 1
run 10ns
force {plot} 0
run 10ns

run 200ns
force {clear} 1
run 1000ns
force {clear} 0
run 10ns
