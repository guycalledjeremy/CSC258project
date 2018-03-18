vlib work
vlog -timescale 1ns/1ns spawner.v
vsim LFSR

log {/*}
add wave {/*}

force {clk} 0 0, 1 10 -r 20
force {enable} 0 0, 1 20, 0 500
force {reset} 0 0, 1 40, 0 60, 1 460, 0 480

run 500ns