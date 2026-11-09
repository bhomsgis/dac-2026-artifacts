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
as__ValidOutput2: assert property(div_unit.cycles_counter == 6'd1 |-> valid_o == div_unit.valid_q);

as__ResultOutput: assert property(div_unit.cycles_counter == 6'd1 && !div_unit.op_q |-> result_o == div_unit.quo_aux);

as__ResultOutput2: assert property(div_unit.cycles_counter == 6'd1 && div_unit.op_q |-> result_o == div_unit.rmd_aux);

as__BusyOutput: assert property(|div_unit.cycles_counter |-> busy_o == 1'b1);

as__BusyOutput2: assert property(!(|div_unit.cycles_counter) |-> busy_o == 1'b0);

as__Quo: assert property(div_unit.div_zero_q |-> div_unit.quo == {WIDTH{1'b1}});

as__Quo2: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && div_unit.same_sign_q |-> div_unit.quo == div_unit.dividend_quotient_q);

as__Quo4: assert property(!div_unit.div_zero_q && !div_unit.signed_op_q |-> div_unit.quo == div_unit.dividend_quotient_q);

as__Rmd: assert property(div_unit.div_zero_q |-> div_unit.rmd == div_unit.first_dividend_q);

as__Rmd3: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && !(div_unit.first_dividend_q[WIDTH-1] && !div_unit.op_32_q || div_unit.first_dividend_q[31] && div_unit.op_32_q) |-> div_unit.rmd == div_unit.remanent_q);

as__Rmd4: assert property(!div_unit.div_zero_q && !div_unit.signed_op_q |-> div_unit.rmd == div_unit.remanent_q);

as__CyclesCounter3: assert property(!valid_i && div_unit.cycles_counter == 6'd0 |=> div_unit.cycles_counter == 6'd0);

as__QuoAux: assert property(div_unit.CONFIG32 == 1'b1 |-> div_unit.quo_aux == div_unit.quo);

as__RmdAux: assert property(div_unit.CONFIG32 == 1'b1 |-> div_unit.rmd_aux == div_unit.rmd);

as__QuoAux2: assert property(div_unit.CONFIG32 == 1'b0 && div_unit.op_32_q |-> div_unit.quo_aux == {{32{div_unit.quo[31]}},div_unit.quo[31:0]});

as__RmdAux2: assert property(div_unit.CONFIG32 == 1'b0 && div_unit.op_32_q |-> div_unit.rmd_aux == {{32{div_unit.rmd[31]}},div_unit.rmd[31:0]});

as__QuoAux3: assert property(div_unit.CONFIG32 == 1'b0 && !div_unit.op_32_q |-> div_unit.quo_aux == div_unit.quo);

as__RmdAux3: assert property(div_unit.CONFIG32 == 1'b0 && !div_unit.op_32_q |-> div_unit.rmd_aux == div_unit.rmd);

as__Dividend: assert property(op_32bits_i |-> div_unit.dividend_d == {div_unit.dividend_aux_d[31:0], 32'b0});

as__Divisor: assert property(op_32bits_i |-> div_unit.divisor_d == {32'b0, div_unit.divisor_aux_d[31:0]});

as__Dividend2: assert property(!op_32bits_i |-> div_unit.dividend_d == div_unit.dividend_aux_d);

as__Divisor2: assert property(!op_32bits_i |-> div_unit.divisor_d == div_unit.divisor_aux_d);

as__Divisor2_1: assert property(!valid_i |=> div_unit.divisor_q == div_unit.divisor_out);

as__Rmd7: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && !(div_unit.first_dividend_q[WIDTH-1] && !div_unit.op_32_q || div_unit.first_dividend_q[31] && div_unit.op_32_q) |-> div_unit.rmd_aux == div_unit.remanent_q);

as__ValidOutput3: assert property(div_unit.cycles_counter == 6'd1 |-> div_unit.valid_o == div_unit.valid_q);

as__ResultOutput3: assert property(div_unit.cycles_counter == 6'd1 && !div_unit.op_q |-> div_unit.result_o == div_unit.quo_aux);

as__ResultOutput4: assert property(div_unit.cycles_counter == 6'd1 && div_unit.op_q |-> div_unit.result_o == div_unit.rmd_aux);

as__BusyOutput3: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput4: assert property(!(|div_unit.cycles_counter) |-> div_unit.busy_o == 1'b0);

as__BusyOutput5: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput6: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput7: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput8: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput9: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__Rmd11: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && !(div_unit.first_dividend_q[div_unit.WIDTH-1] && !div_unit.op_32_q || div_unit.first_dividend_q[31] && div_unit.op_32_q) |-> div_unit.rmd_aux == div_unit.remanent_q);

as__BusyOutput10: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__Rmd15: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && !(div_unit.first_dividend_q[div_unit.WIDTH-1] && !div_unit.op_32_q || div_unit.first_dividend_q[31] && div_unit.op_32_q) |-> div_unit.rmd == div_unit.remanent_q);

as__BusyOutput11: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput12: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput14: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput16: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput18: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput20: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput22: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput24: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput25: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput27: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput29: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput30: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput31: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput32: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput33: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput34: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput35: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput36: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput37: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput38: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput40: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput39: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput41: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput42: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput43: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput44: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput45: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput46: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput47: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput48: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput49: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput50: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput51: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput52: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput53: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput54: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput55: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput56: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput57: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput58: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput59: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput60: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput61: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput62: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput63: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput64: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput65: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput66: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput67: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput68: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput69: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput70: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput71: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput72: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput73: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput74: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput75: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput76: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput77: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput78: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput79: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__BusyOutput80: assert property(|div_unit.cycles_counter |-> div_unit.busy_o == 1'b1);

as__ValidOutput: assert property(valid_i |-> valid_o == 1'b0);

as__DivZero: assert property(valid_i && !(|data_rs2_i) |-> div_unit.div_zero_q == 1'b1);

as__SameSign: assert property(valid_i && (op_32bits_i ? (data_rs1_i[31] == data_rs2_i[31]) : (data_rs1_i[WIDTH-1] == data_rs2_i[WIDTH-1])) |-> div_unit.same_sign_d == 1'b1);

as__SignedOp: assert property(valid_i && !op_unsigned_i |-> div_unit.signed_op_q == 1'b1);

as__Op32: assert property(valid_i && op_32bits_i |-> div_unit.op_32_q == 1'b1);

as__Quo3: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && !div_unit.same_sign_q |-> div_unit.quo == ~div_unit.dividend_quotient_q + {WIDTH{1'b1}});

as__Rmd2: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && (div_unit.first_dividend_q[WIDTH-1] && !div_unit.op_32_q || div_unit.first_dividend_q[31] && div_unit.op_32_q) |-> div_unit.rmd == ~div_unit.remanent_q + {WIDTH{1'b1}});

as__CyclesCounter: assert property(valid_i |=> div_unit.cycles_counter == (op_32bits_i ? CYCLES_32[5:0] : div_unit.CYCLES_64[5:0]));

as__CyclesCounter2: assert property(!valid_i && div_unit.cycles_counter != 6'd0 |=> div_unit.cycles_counter == $past(div_unit.cycles_counter) - 6'd1);

as__DividendAux: assert property((!op_32bits_i && data_rs1_i[63] && !op_unsigned_i) || (op_32bits_i && data_rs1_i[31] && !op_unsigned_i) |-> div_unit.dividend_aux_d == ~data_rs1_i + {WIDTH{1'b1}});

as__DivisorAux: assert property((!op_32bits_i && data_rs2_i[63] && !op_unsigned_i) || (op_32bits_i && data_rs2_i[31] && !op_unsigned_i) |-> div_unit.divisor_aux_d == ~data_rs2_i + {WIDTH{1'b1}});

as__FirstDividend: assert property(valid_i |=> div_unit.first_dividend_q == data_rs1_i);

as__Op: assert property(valid_i |=> div_unit.op_q == op_i);

as__Valid: assert property(valid_i |=> div_unit.valid_q == valid_i);

as__DivZero2: assert property(valid_i |=> div_unit.div_zero_q == div_unit.div_zero_d);

as__SameSign2: assert property(valid_i |=> div_unit.same_sign_q == div_unit.same_sign_d);

as__SignedOp2: assert property(valid_i |=> div_unit.signed_op_q == !op_unsigned_i);

as__Op32_2: assert property(valid_i |=> div_unit.op_32_q == op_32bits_i);

as__Remanent: assert property(!valid_i |=> div_unit.remanent_q == div_unit.remanent_out);

as__DividendQuotient: assert property(!valid_i |=> div_unit.dividend_quotient_q == div_unit.dividend_quotient_out);

as__Rmd5: assert property(div_unit.div_zero_q |-> div_unit.rmd_aux == div_unit.first_dividend_q);

as__Quo6: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && div_unit.same_sign_q |-> div_unit.quo_aux == div_unit.dividend_quotient_q);

as__Quo7: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && !div_unit.same_sign_q |-> div_unit.quo_aux == ~div_unit.dividend_quotient_q + {WIDTH{1'b1}});

as__Quo8: assert property(!div_unit.div_zero_q && !div_unit.signed_op_q |-> div_unit.quo_aux == div_unit.dividend_quotient_q);

as__Rmd6: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && (div_unit.first_dividend_q[WIDTH-1] && !div_unit.op_32_q || div_unit.first_dividend_q[31] && div_unit.op_32_q) |-> div_unit.rmd_aux == ~div_unit.remanent_q + {WIDTH{1'b1}});

as__Rmd8: assert property(!div_unit.div_zero_q && !div_unit.signed_op_q |-> div_unit.rmd_aux == div_unit.remanent_q);

as__Quo11: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && !div_unit.same_sign_q |-> div_unit.quo_aux == ~div_unit.dividend_quotient_q + {div_unit.WIDTH{1'b1}});

as__Rmd10: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && (div_unit.first_dividend_q[div_unit.WIDTH-1] && !div_unit.op_32_q || div_unit.first_dividend_q[31] && div_unit.op_32_q) |-> div_unit.rmd_aux == ~div_unit.remanent_q + {div_unit.WIDTH{1'b1}});

as__SameSign3: assert property(valid_i && (op_32bits_i ? (data_rs1_i[31] == data_rs2_i[31]) : (data_rs1_i[WIDTH-1] == data_rs2_i[WIDTH-1])) |-> div_unit.same_sign_d == 1'b1);

as__Quo15: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && !div_unit.same_sign_q |-> div_unit.quo == ~div_unit.dividend_quotient_q + {div_unit.WIDTH{1'b1}});

as__Rmd14: assert property(!div_unit.div_zero_q && div_unit.signed_op_q && (div_unit.first_dividend_q[div_unit.WIDTH-1] && !div_unit.op_32_q || div_unit.first_dividend_q[31] && div_unit.op_32_q) |-> div_unit.rmd == ~div_unit.remanent_q + {div_unit.WIDTH{1'b1}});

as__CyclesCounter4: assert property(valid_i |=> div_unit.cycles_counter == (op_32bits_i ? div_unit.CYCLES_32[5:0] : div_unit.CYCLES_64[5:0]));

as__DividendAux2: assert property((!op_32bits_i && data_rs1_i[div_unit.WIDTH-1] && !op_unsigned_i) || (op_32bits_i && data_rs1_i[31] && !op_unsigned_i) |-> div_unit.dividend_aux_d == ~data_rs1_i + {div_unit.WIDTH{1'b1}});

as__DivisorAux2: assert property((!op_32bits_i && data_rs2_i[div_unit.WIDTH-1] && !op_unsigned_i) || (op_32bits_i && data_rs2_i[31] && !op_unsigned_i) |-> div_unit.divisor_aux_d == ~data_rs2_i + {div_unit.WIDTH{1'b1}});

endmodule
