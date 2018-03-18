vlib work
vlog -timescale 1ns/1ns spawner.v
vsim spawner

log {/*}
add wave {/*}

force {clk} 0 0, 1 1 -r 2
force {enable} 0 0, 1 20, 0 500
force {reset} 1 0, 0 40, 1 60, 0 460, 1 480
force {frequency} 10 0, 01 300, 00 400 

run 500ns