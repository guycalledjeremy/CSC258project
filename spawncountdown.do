vlib work
vlog -timescale 1ns/1ns spawner.v
vsim spawncountdown

log {/*}
add wave {/*}

force {clk} 0 0, 1 5 -r 10
force {enable} 0 0, 1 20, 0 500
force {reset} 0 0, 1 40, 0 60, 1 460, 0 480
force {spawn} 0 0
force {secs} 011 0, 010 250

run 500ns