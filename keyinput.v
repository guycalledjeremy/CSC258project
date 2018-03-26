module keyinput(
    // clock, resetn,
    CLOCK_50, KEY,
    PS2_CLK, PS2_DAT,
    // restart, moveup, movedown
    LEDR
    );

    // input clock, resetn;
    input CLOCK_50;
	 input [3:0] KEY;
    input PS2_CLK;
    input PS2_DAT;
    // output restart;
    // output moveup;
    // output movedown;
    output [9:0] LEDR;

    // Delete these lines after test
    wire clock = CLOCK_50;
    wire resetn = KEY[0];
    // end delete 

    // Don't forget to take in PS2_CLK and PS2_DAT as inputs to your top level module.
    // RELEVANT FOR PS2 KB
    wire [ 7 : 0 ] scan_code ;
    wire read , scan_ready ;
    reg [ 7 : 0 ] scan_history [ 1 : 2 ];

    always @(posedge scan_ready )
    begin
    scan_history [ 2 ] <= scan_history [ 1 ];
    scan_history [ 1 ] <= scan_code ;
    end
    // END OF PS2 KB SETUP

    // Keyboard Section
    keyboard kb (
    . keyboard_clk ( PS2_CLK ),
    . keyboard_data ( PS2_DAT ),
    . clock50 ( clock ),
    . reset ( ~resetn ),
    . read ( read ),
    . scan_ready ( scan_ready ),
    . scan_code ( scan_code ));
    oneshot pulse (
    . pulse_out ( read ),
    . trigger_in ( scan_ready ),
    . clk ( clock ));

    wire p1_restart = (( scan_history [ 1 ] == 8'h2d) && (scan_history[2][7:4] != 4'hF )); // Key for R
    wire p1_up = (( scan_history [ 1 ] == 8'h1d) && (scan_history[2][7:4] != 4'hF )); // Key for W
    wire p1_down = (( scan_history [ 1 ] == 8'h1b) && (scan_history[2][7:4] != 4'hF )); // Key for S

    // restart should be a signal sent to the control unit to go back to the initial state.
    // assign restart = p1_restart;
    assign LEDR[0] = p1_restart;
    // if pressed together, the default is going down.
    // assign moveup = p1_up;
    assign LEDR[1] = p1_up;
    // assign movedown = p1_down;
    assign LEDR[2] = p1_down;

endmodule
