module div_unit_prop

#(
		parameter ASSERT_INPUTS = 0,
		parameter   CONFIG32       = 1'b0,                        //! If HIGH (1'b1), the functional unit is configured for operations with 32-bits max size. If LOW (1'b0), the functional unit also handles 64-bit operations.
		localparam  WIDTH          = (CONFIG32 == 1'b1) ? 32 : 64,//! Constant with size of operands and result.
		localparam  CYCLES_32      = 17,                          //! Constant cycles (+1) needed for 32-bit operations.
		localparam  CYCLES_64      = (CONFIG32 == 1'b1) ? 17 : 33 //! Constant cycles (+1) needed for 64-bit operations.
)
(		input  logic                clk_i,            //! System clock signal.
		input  logic                rstn_i,           //! System reset signal (active low).
		
		input  logic                flush_i,          //! Synchronous reset.
		
		input  logic                valid_i,          //! Valid bit for operation received.
		input  logic                op_i,             //! Operation encoded that must be performed (see table above).
		input  logic                op_unsigned_i,    //! Set if operation is unsigned.
		input  logic                op_32bits_i,      //! Set if operation uses 32-bit operands.
		
		input  logic [WIDTH-1:0]    data_rs1_i,       //! Operand 1.
		input  logic [WIDTH-1:0]    data_rs2_i,       //! Operand 2.
		
		input  logic                busy_o,           //! Set if the functional unit is performing an operation. //output
		
		input  logic                valid_o,          //! Valid bit for result. //output
		input  logic [WIDTH-1:0]    result_o          //! Result of operation performed. //output
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
as__BusyWhenCyclesCounterNotZero: assert property(div_unit.cycles_counter != 6'd0 |-> busy_o);

as__NotBusyWhenCyclesCounterZero: assert property(div_unit.cycles_counter == 6'd0 |-> !busy_o);

as__ValidOutWhenCyclesCounterOne: assert property(div_unit.cycles_counter == 6'd1 |-> valid_o);

as__NotValidOutWhenCyclesCounterNotOne: assert property(div_unit.cycles_counter != 6'd1 |-> !valid_o);

as__ResultOutDIVWhenOpIsZero: assert property(div_unit.cycles_counter == 6'd1 && !div_unit.op_q |-> result_o == div_unit.quo_aux);

as__ResultOutREMWhenOpIsOne: assert property(div_unit.cycles_counter == 6'd1 && div_unit.op_q |-> result_o == div_unit.rmd_aux);

as__QuoAuxWhenDivZero: assert property(div_unit.div_zero_q |-> div_unit.quo_aux == {WIDTH{1'b1}});

as__QuoAuxExtensionWhenConfig32: assert property(div_unit.CONFIG32 == 1'b1 |-> div_unit.quo_aux == div_unit.quo);

as__RmdAuxExtensionWhenConfig32: assert property(div_unit.CONFIG32 == 1'b1 |-> div_unit.rmd_aux == div_unit.rmd);

as__QuoAuxExtensionWhenNotConfig32AndOp32: assert property(div_unit.CONFIG32 == 1'b0 && div_unit.op_32_q |-> div_unit.quo_aux == {{32{div_unit.quo[31]}},div_unit.quo[31:0]});

as__RmdAuxExtensionWhenNotConfig32AndOp32: assert property(div_unit.CONFIG32 == 1'b0 && div_unit.op_32_q |-> div_unit.rmd_aux == {{32{div_unit.rmd[31]}},div_unit.rmd[31:0]});

as__QuoAuxExtensionWhenNotConfig32AndNotOp32: assert property(div_unit.CONFIG32 == 1'b0 && !div_unit.op_32_q |-> div_unit.quo_aux == div_unit.quo);

as__RmdAuxExtensionWhenNotConfig32AndNotOp32: assert property(div_unit.CONFIG32 == 1'b0 && !div_unit.op_32_q |-> div_unit.rmd_aux == div_unit.rmd);

as__DivisorQUpdate: assert property(div_unit.cycles_counter != 6'd0 |=> div_unit.divisor_q == div_unit.divisor_out);

as__BusyWhenValid: assert property(valid_i |=> busy_o == (|div_unit.cycles_counter));

as__ResultOutWhenCyclesCounterOne: assert property(div_unit.cycles_counter == 6'd1 |=> valid_o -> result_o != {WIDTH{1'b0}});

as__QuoAuxWhenSignedOp: assert property(div_unit.signed_op_q |-> div_unit.quo_aux == ((div_unit.same_sign_q) ? div_unit.dividend_quotient_q : ~div_unit.dividend_quotient_q + div_unit.ONE));

as__QuoAuxWhenNotSignedOp: assert property(!div_unit.signed_op_q && div_unit.cycles_counter == 6'd1 |-> div_unit.quo_aux == (div_unit.div_zero_q ? {WIDTH{1'b1}} : (div_unit.op_32_q ? {{32{div_unit.dividend_quotient_q[31]}},div_unit.dividend_quotient_q[31:0]} : div_unit.dividend_quotient_q)));

as__RmdAuxWhenDivZero: assert property(div_unit.div_zero_q |-> div_unit.rmd == div_unit.first_dividend_q);

as__RmdAuxWhenSignedOp: assert property(div_unit.signed_op_q |=> div_unit.rmd_aux == ((div_unit.op_32_q) ? {{32{div_unit.rmd[31]}}, div_unit.rmd[31:0]} : div_unit.rmd));

as__RmdAuxWhenNotSignedOp: assert property(!div_unit.signed_op_q |-> div_unit.rmd_aux == div_unit.remanent_q);

as__CyclesCounterUpdate: assert property(div_unit.cycles_counter != 6'd0 && !div_unit.valid_q |=> div_unit.cycles_counter == $past(div_unit.cycles_counter) - 6'd1 || (div_unit.valid_q && div_unit.cycles_counter == (div_unit.op_32_q ? CYCLES_32[5:0] : CYCLES_64[5:0])));

as__CyclesCounterNoUpdate: assert property(!div_unit.valid_i && div_unit.cycles_counter == 6'd0 |=> div_unit.cycles_counter == 6'd0);

as__ValidQUpdate: assert property(valid_i && !flush_i |=> div_unit.valid_q);

as__ValidQNoUpdate: assert property(!valid_i && !div_unit.flush_i && div_unit.cycles_counter != 6'd1 |=> div_unit.valid_q == $past(div_unit.valid_q));

as__OpQUpdate: assert property(valid_i && !flush_i |=> div_unit.op_q == $past(op_i));

as__OpQNoUpdate: assert property(!valid_i && !flush_i |=> div_unit.op_q == $past(div_unit.op_q));

as__SignedOpQUpdate: assert property(valid_i |=> div_unit.signed_op_q == !op_unsigned_i);

as__SignedOpQNoUpdate: assert property(!valid_i && !flush_i |=> div_unit.signed_op_q == $past(div_unit.signed_op_q));

as__Op32QUpdate: assert property(valid_i |=> div_unit.valid_q -> div_unit.op_32_q == $past(op_32bits_i));

as__Op32QNoUpdate: assert property(!valid_i |=> div_unit.op_32_q == $past(div_unit.op_32_q));

as__DivZeroQUpdate: assert property(valid_i |-> div_unit.div_zero_d == (~(|data_rs2_i) || (op_32bits_i && ~(|data_rs2_i[31:0]))));

as__DivZeroQNoUpdate: assert property(!valid_i && !div_unit.valid_q |=> div_unit.div_zero_q == $past(div_unit.div_zero_q));

as__SameSignQUpdate: assert property(valid_i |=> div_unit.same_sign_q == ((op_32bits_i) ? ~(data_rs2_i[31] ^ data_rs1_i[31]) : ~(data_rs2_i[63] ^ data_rs1_i[63])));

as__SameSignQNoUpdate: assert property(!valid_i && !div_unit.valid_q |=> div_unit.same_sign_q == $past(div_unit.same_sign_q));

as__RemanentQUpdate: assert property(div_unit.cycles_counter != 6'd0 |=> div_unit.remanent_q == div_unit.remanent_out);

as__RemanentQNoUpdate: assert property(div_unit.cycles_counter == 6'd0 |=> div_unit.remanent_q == $past(div_unit.remanent_q));

as__DividendQuotientQUpdate: assert property(div_unit.cycles_counter != 6'd0 |=> div_unit.dividend_quotient_q == div_unit.dividend_quotient_out);

as__DividendQuotientQNoUpdate: assert property(div_unit.cycles_counter == 6'd0 |=> div_unit.dividend_quotient_q == $past(div_unit.dividend_quotient_q));

as__DivisorQNoUpdate: assert property(div_unit.cycles_counter != 6'd0 |=> div_unit.divisor_q == div_unit.divisor_out);

as__FirstDividendQUpdate: assert property(div_unit.valid_q |-> div_unit.first_dividend_q == div_unit.first_dividend_d);

as__FirstDividendQNoUpdate: assert property(!valid_i |=> div_unit.first_dividend_q == div_unit.first_dividend_d);

endmodule
