vlib work

vlog -timescale 1ns/1ns animation.v

vsim datapath

log {/*}
add wave {/*}

# Reset to initiate
force {clk}  0 0 ns, 1 10 ns -r 20 ns
force {resetn} 0
force {plot} 0
force {do_e} 0
force {do_d} 0
run 40 ns

# Set up y
force {clk}  0 0 ns, 1 10 ns
force {resetn} 0
force {plot} 1
force {do_e} 0
force {do_d} 0
run 20 ns

# Let the x move
# Notice that y should be random and stays the same
force {clk}  0 0 ns, 1 10 ns -r 20 ns
force {resetn} 1
force {plot} 0
force {do_e} 1 0 ns, 0 20 ns -r 40 ns
force {do_d} 0 0 ns, 1 20 ns -r 40 ns
run 4000 ns

# Try reset
force {clk}  0 0 ns, 1 10 ns
force {resetn} 0
force {plot} 0
force {do_e} 0
force {do_d} 0
run 20 ns
