vlib work

vlog -timescale 1ns/1ns animation.v

vsim control

log {/*}
add wave {/*}

# Reset to initiate
force {clock}  0 0 ns, 1 10 ns
force {reset_n} 0
force {d} 0
run 20 ns

# State 1: S_CYCLE_WAIT
# Expected output:
# do_e: 0
# do_d: 0
# next_state should be S_CYCLE_E
force {clock}  0 0 ns, 1 10 ns
force {reset_n} 1
force {d} 1
run 20 ns

# State 2: S_CYCLE_E
# Expected output:
# do_e: 1
# do_d: 0
# next_state should be S_CYCLE_D
force {clock}  0 0 ns, 1 10 ns
force {reset_n} 1
force {d} 0
run 20 ns

# State 3: S_CYCLE_D
# Expected output:
# do_e: 0
# do_d: 1
# next_state should be S_CYCLE_WAIT
force {clock}  0 0 ns, 1 10 ns
force {reset_n} 1
force {d} 0
run 20 ns

# Test 1: if S_CYCLE_WAIT works (test for two cycles)
# Expected output:
# do_e: 0
# do_d: 0
# next_state should be S_CYCLE_WAIT
force {clock}  0 0 ns, 1 10 ns -r 20 ns
force {reset_n} 1
force {d} 0
run 40 ns

# Test 1: if do works after waiting
# Expected output:
# do_e: 0
# do_d: 0
# next_state should be S_CYCLE_E
force {clock}  0 0 ns, 1 10 ns
force {reset_n} 1
force {d} 1
run 20 ns

# Test 1: if do works after waiting
# Expected output:
# do_e: 1
# do_d: 0
# next_state should be S_CYCLE_D
force {clock}  0 0 ns, 1 10 ns
force {reset_n} 1
force {d} 0
run 20 ns

# Test 1: if do works after waiting
# Expected output:
# do_e: 0
# do_d: 1
# next_state should be S_CYCLE_WAIT
force {clock}  0 0 ns, 1 10 ns
force {reset_n} 1
force {d} 0
run 20 ns
