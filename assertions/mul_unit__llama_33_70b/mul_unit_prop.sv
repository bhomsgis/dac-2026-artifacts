module mul_unit_prop
#(
		parameter ASSERT_INPUTS = 0,
		parameter logic REG_32       = 1'b1,                         //! If HIGH (1'b1), register the valid computation of 32-bits multiplications (1 cycle) to match the latency of 64-bit multiplications (2 cycles).
		parameter logic CONFIG32     = 1'b0,                         //! If HIGH (1'b1), the functional unit is configured for operations with 32-bits max size. If LOW (1'b0), the functional unit also handles 64-bit operations.
		localparam int  WIDTH        = (CONFIG32 == 1'b1) ? 32 : 64, //! Constant with size of operands and result.
		localparam int  MUL_OPS      = 4,                            //! Number of different operations performed by this functional unit.,
		localparam int  MUL_OPS_BITS = $clog2(MUL_OPS),              //! Bits needed for encoding operations.
		localparam int  MAX_CYCLES   = (CONFIG32 == 1'b1) ? 1 : 2    //! Max number of cycles a MUL operation takes to complete
)
(		input  logic                    clk_i,                       //! System clock signal.
		input  logic                    rstn_i,                      //! System reset signal (active low).
		
		input  logic [MAX_CYCLES-1:0]   flush_i,                     //! Synchronous reset. Can flush operations on 1st or 2nd stage.
		
		input  logic                    valid_i,                     //! Valid bit for operation received.
		input  logic [MUL_OPS_BITS-1:0] op_i,                        //! Operation encoded that must be performed (see table above).
		input  logic                    op_32bits_i,                 //! Set if operation uses 32-bit operands.
		
		input  logic [WIDTH-1:0]        data_rs1_i,                  //! Operand 1.
		input  logic [WIDTH-1:0]        data_rs2_i,                  //! Operand 2.
		
		input  logic                    valid_o,                     //! Valid bit for result. //output
		input  logic [WIDTH-1:0]        result_o                     //! Result of operation performed. //output
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
as__ValidOutput64: assert property(valid_i && op_i != mul_unit.MUL && !op_32bits_i |-> valid_o == mul_unit.valid_q[1]);

as__ValidOutput32: assert property(valid_i && op_i == mul_unit.MUL && !op_32bits_i |-> valid_o == mul_unit.valid_q[1]);

as__ValidOutputNext64: assert property(valid_i && op_i != mul_unit.MUL && !op_32bits_i |=> valid_o == mul_unit.valid_q[1]);

as__ValidOutputNext32: assert property(valid_i && op_i == mul_unit.MUL && !op_32bits_i |=> valid_o == mul_unit.valid_q[1]);

as__ValidOutput: assert property(valid_i && op_i == mul_unit.MUL && op_32bits_i |-> valid_o == 1'b1);

as__ResultMUL: assert property(valid_i && op_i == mul_unit.MUL && op_32bits_i |-> result_o == (mul_unit.neg_q ? (~mul_unit.result_low_d[WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_d[WIDTH-1:0]));

as__ResultMULH: assert property(valid_i && op_i == mul_unit.MULH |-> result_o == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:WIDTH]);

as__ResultMULHSU: assert property(valid_i && op_i == mul_unit.MULHSU |-> result_o == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:WIDTH]);

as__ResultMULHU: assert property(valid_i && op_i == mul_unit.MULHU |-> result_o == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:WIDTH]);

as__Result64: assert property(valid_i && op_i != mul_unit.MUL && !op_32bits_i |-> result_o == mul_unit.result_2width_def[WIDTH-1:0]);

as__Result32: assert property(valid_i && op_i == mul_unit.MUL && !op_32bits_i |-> result_o == mul_unit.result_2width_def[WIDTH-1:0]);

as__NoCollision: assert property(!(valid_i && op_i == mul_unit.MUL && op_32bits_i && mul_unit.valid_q[1] && !mul_unit.op_32bits_q_final));

as__NoInvalidResult: assert property(!(valid_o && result_o == {WIDTH{1'bx}}));

as__NoInvalidValid: assert property(!(valid_o && valid_i == 1'b0));

as__NoInvalidOp: assert property(!(valid_o && $isunknown(op_i)));

as__NoInvalidData: assert property(!(valid_o && (data_rs1_i == {WIDTH{1'bx}} || data_rs2_i == {WIDTH{1'bx}})));

as__NoInvalidResultMUL: assert property(!(valid_o && op_i == mul_unit.MUL && result_o != (mul_unit.neg_q ? (~mul_unit.result_low_d[WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_d[WIDTH-1:0])));

as__NoInvalidResultMULH: assert property(!(valid_o && op_i == mul_unit.MULH && result_o != mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:WIDTH]));

as__NoInvalidResultMULHSU: assert property(!(valid_o && op_i == mul_unit.MULHSU && result_o != mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:WIDTH]));

as__NoInvalidResultMULHU: assert property(!(valid_o && op_i == mul_unit.MULHU && result_o != mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:WIDTH]));

as__NoInvalidResult64: assert property(!(valid_o && op_i != mul_unit.MUL && !op_32bits_i && result_o != mul_unit.result_2width_def[WIDTH-1:0]));

as__NoInvalidResult32: assert property(!(valid_o && op_i == mul_unit.MUL && !op_32bits_i && result_o != mul_unit.result_2width_def[WIDTH-1:0]));

as__ValidOutputNext: assert property(valid_i && op_i == mul_unit.MUL && op_32bits_i |=> $past(valid_i) && $past(op_i) == mul_unit.MUL && $past(op_32bits_i) && mul_unit.valid_q[mul_unit.MAX_CYCLES-1] == 1'b1 |-> valid_o == 1'b1);

as__ResultNextMUL: assert property(valid_i && op_i == mul_unit.MUL && op_32bits_i |=> result_o == (mul_unit.neg_q ? (~mul_unit.result_low_d[WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_d[WIDTH-1:0]));

as__ResultNextMULH: assert property(valid_i && op_i == mul_unit.MULH |=> result_o == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:WIDTH]);

as__ResultNextMULHSU: assert property(valid_i && op_i == mul_unit.MULHSU |=> result_o == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:WIDTH]);

as__ResultNextMULHU: assert property(valid_i && op_i == mul_unit.MULHU |=> result_o == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:WIDTH]);

as__ResultNext64: assert property(valid_i && op_i != mul_unit.MUL && !op_32bits_i |=> result_o == mul_unit.result_2width_def[WIDTH-1:0]);

as__ResultNext32: assert property(valid_i && op_i == mul_unit.MUL && !op_32bits_i |=> result_o == mul_unit.result_2width_def[WIDTH-1:0]);

as__NoInvalidValidNext: assert property(valid_i |=> !(valid_o && $past(valid_i) == 1'b0));

as__NoInvalidOpNext: assert property(valid_i |=> !(valid_o && op_i == {MUL_OPS_BITS{1'bx}}));

as__NoInvalidDataNext: assert property(valid_i |=> !(valid_o && (data_rs1_i == {WIDTH{1'bx}} || data_rs2_i == {WIDTH{1'bx}})));

as__NoInvalidResultNext: assert property(valid_i |=> !(valid_o && result_o == {WIDTH{1'bx}}));

as__NoInvalidResultNextMUL: assert property(valid_i |=> !(valid_o && op_i == mul_unit.MUL && result_o != (mul_unit.neg_q ? (~mul_unit.result_low_d[WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_d[WIDTH-1:0])));

as__NoInvalidResultNext64: assert property(valid_i |=> !(valid_o && op_i != mul_unit.MUL && !op_32bits_i && result_o != mul_unit.result_2width_def[WIDTH-1:0]));

as__NoInvalidResultNext32: assert property(valid_i |=> !(valid_o && op_i == mul_unit.MUL && !op_32bits_i && result_o != mul_unit.result_2width_def[WIDTH-1:0]));

as__NoInvalidValidNext64: assert property(valid_i && op_i != mul_unit.MUL && !op_32bits_i |=> !(valid_o && $past(valid_i) == 1'b0));

as__NoInvalidOpNext64: assert property(valid_i && op_i != mul_unit.MUL && !op_32bits_i |=> !(valid_o && op_i == {MUL_OPS_BITS{1'bx}}));

as__NoInvalidDataNext64: assert property(valid_i && op_i != mul_unit.MUL && !op_32bits_i |=> !(valid_o && (data_rs1_i == {WIDTH{1'bx}} || data_rs2_i == {WIDTH{1'bx}})));

as__NoInvalidResultNext64_1: assert property(valid_i && op_i != mul_unit.MUL && !op_32bits_i |=> !(valid_o && result_o == {WIDTH{1'bx}}));

as__NoInvalidResultNextMUL64: assert property(valid_i && op_i == mul_unit.MUL && !op_32bits_i |=> !(valid_o && result_o != mul_unit.result_2width_def[WIDTH-1:0]));

as__NoInvalidValidNext32: assert property(valid_i && op_i == mul_unit.MUL && !op_32bits_i |=> !(valid_o && $past(valid_i) == 1'b0 && $past(op_i) == mul_unit.MUL && $past(op_32bits_i) == 1'b0));

as__NoInvalidOpNext32: assert property(valid_i && op_i == mul_unit.MUL && !op_32bits_i |=> !(valid_o && ($past(op_i) != mul_unit.MUL || $past(op_32bits_i))));

as__NoInvalidDataNext32: assert property(valid_i && op_i == mul_unit.MUL && !op_32bits_i |=> !(valid_o && (data_rs1_i == {WIDTH{1'bx}} || data_rs2_i == {WIDTH{1'bx}})));

as__NoInvalidResultNext32_1: assert property(valid_i && op_i == mul_unit.MUL && !op_32bits_i |=> !(valid_o && result_o == {WIDTH{1'bx}}));

endmodule
