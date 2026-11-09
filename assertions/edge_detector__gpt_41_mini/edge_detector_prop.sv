module edge_detector_prop
 #( 
		parameter ASSERT_INPUTS = 0,
		parameter logic RST_INIT_VALUE = 1'b0
)(
		input  logic        clk_i,          //! System clock signal.
		input  logic        rstn_i,         //! System reset signal (active low).
		input  logic [0:0]  d_i,            //! Input signal
		input  logic [0:0]  rising_edge_o,  //! Rising edge detected //output
		input  logic [0:0]  falling_edge_o  //! Falling edge detected //output
	);

//==============================================================================
// Local Parameters
//==============================================================================

genvar j;
default clocking cb @(posedge clk_i);
endclocking
default disable iff (!rstn_i);

// Re-defined wires 

// Symbolics and Handshake signals

//==============================================================================
// Modeling
//==============================================================================


//====DESIGNER-ADDED-SVA====//
as__RisingEdgeDetecteotid: assert property (@(posedge clk_i) ( (edge_detector.q == 1'b0) && (d_i == 1'b1) ) |-> rising_edge_o == 1'b1);

as__NoFalseRisingEdgeDetecteotid: assert property (@(posedge clk_i) !( (edge_detector.q == 1'b0) && (d_i == 1'b1) ) |-> rising_edge_o == 1'b0);

as__FallingEdgeDetecteotid: assert property (@(posedge clk_i) ( (edge_detector.q == 1'b1) && (d_i == 1'b0) ) |-> falling_edge_o == 1'b1);

as__NoFalseFallingEdgeDetecteotid: assert property (@(posedge clk_i) !( (edge_detector.q == 1'b1) && (d_i == 1'b0) ) |-> falling_edge_o == 1'b0);

as__QUpdateeotid: assert property (@(posedge clk_i) 1'b1 |=> edge_detector.q == $past(d_i));

as__RisingEdgeAssertedOnlyWhenQ0D1: assert property (@(posedge clk_i) (rising_edge_o == 1'b1) |-> (edge_detector.q == 1'b0) && (d_i == 1'b1));

as__FallingEdgeAssertedOnlyWhenQ1D0: assert property (@(posedge clk_i) (falling_edge_o == 1'b1) |-> (edge_detector.q == 1'b1) && (d_i == 1'b0));

as__NoSimultaneousRisingAndFallingEdge: assert property (@(posedge clk_i) !(rising_edge_o == 1'b1 && falling_edge_o == 1'b1));

as__RisingEdgeZeroWhenNoRisingEdge: assert property (@(posedge clk_i) (rising_edge_o == 1'b0) |-> !((edge_detector.q == 1'b0) && (d_i == 1'b1)));

as__FallingEdgeZeroWhenNoFallingEdge: assert property (@(posedge clk_i) (falling_edge_o == 1'b0) |-> !((edge_detector.q == 1'b1) && (d_i == 1'b0)));

as__RisingEdgeCondition: assert property (@(posedge clk_i) ((edge_detector.q == 1'b0) && (d_i == 1'b1)) |-> (rising_edge_o == 1'b1));

as__FallingEdgeCondition: assert property (@(posedge clk_i) ((edge_detector.q == 1'b1) && (d_i == 1'b0)) |-> (falling_edge_o == 1'b1));

as__NoRisingEdgeWhenConditionNotMet: assert property (@(posedge clk_i) !( ((edge_detector.q == 1'b0) && (d_i == 1'b1)) ) |-> (rising_edge_o == 1'b0));

as__NoFallingEdgeWhenConditionNotMet: assert property (@(posedge clk_i) !( ((edge_detector.q == 1'b1) && (d_i == 1'b0)) ) |-> (falling_edge_o == 1'b0));

as__QRegisterUpdate: assert property (@(posedge clk_i) 1'b1 |=> (edge_detector.q == $past(d_i)));

as__RisingEdgeAssertedOnlyIfQ0D1: assert property (@(posedge clk_i) (rising_edge_o == 1'b1) |-> ((edge_detector.q == 1'b0) && (d_i == 1'b1)));

as__FallingEdgeAssertedOnlyIfQ1D0: assert property (@(posedge clk_i) (falling_edge_o == 1'b1) |-> ((edge_detector.q == 1'b1) && (d_i == 1'b0)));

as__RisingEdgeOnlyWhenDI1: assert property (@(posedge clk_i) (rising_edge_o == 1'b1) |-> (d_i == 1'b1));

as__FallingEdgeOnlyWhenDI0: assert property (@(posedge clk_i) (falling_edge_o == 1'b1) |-> (d_i == 1'b0));

endmodule
