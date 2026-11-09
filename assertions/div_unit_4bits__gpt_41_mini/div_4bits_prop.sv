module div_4bits_prop

#(
		parameter ASSERT_INPUTS = 0,
		parameter   CONFIG32    = 1'b0,         //! If HIGH (1'b1), the functional unit is configured for operations with 32-bits max size. If LOW (1'b0), the functional unit also handles 64-bit operations.,
		parameter   SIMD_ENABLE = 1'b0,         //! If HIGH (1'b1), the functional unit is configured to work with dynamic widths (SEW). Setting this parameter overwrites CONFIG32
		localparam  WIDTH = ((CONFIG32 == 1'b1) && (SIMD_ENABLE == 1'b0)) ? 32 : 64 //! Constant with size of operands and result.
)
(		/* verilator lint_off UNUSEDSIGNAL */
		input  logic [WIDTH-1:0]      remanent_i,           //! Contains the remanent of the previous division without last bit
		/* verilator lint_on UNUSEDSIGNAL */
		input  logic [WIDTH-1:0]      dividend_quotient_i,  //! Contains at same time the dividend and the quotient of previous division
		input  logic [WIDTH-1:0]      divisor_i,            //! Contains the divisor
		/* verilator lint_off UNUSEDSIGNAL */
		input  logic [1:0]                  sew_i,                //! Dynamic element widh for SIMD
		/* verilator lint_on UNUSEDSIGNAL */
		
		input  logic [WIDTH-1:0]      remanent_o,           //! Contains the remanent of the actual 8 bit division //output
		input  logic [WIDTH-1:0]      dividend_quotient_o,  //! Contains at same time dividend and quotient of actual 8 bit division //output
		input  logic [WIDTH-1:0]      divisor_o //output
	);

//==============================================================================
// Local Parameters
//==============================================================================

genvar j;

// Re-defined wires 

// Symbolics and Handshake signals

//==============================================================================
// Modeling
//==============================================================================


//====DESIGNER-ADDED-SVA====//
as__QuotientBitCorrecteotid: assert property((div_4bits.tmp_remanent[0] >= divisor_i) |-> div_4bits.quotient_bit[0] == 1'b1 && (div_4bits.tmp_remanent[0] < divisor_i) |-> div_4bits.quotient_bit[0] == 1'b0 && (div_4bits.tmp_remanent[1] >= divisor_i) |-> div_4bits.quotient_bit[1] == 1'b1 && (div_4bits.tmp_remanent[1] < divisor_i) |-> div_4bits.quotient_bit[1] == 1'b0);

as__TmpRemanentSubCorrecteotid: assert property((div_4bits.tmp_remanent[0] >= divisor_i) |-> div_4bits.tmp_remanent_sub[0] == div_4bits.tmp_remanent[0] - divisor_i && (div_4bits.tmp_remanent[0] < divisor_i) |-> div_4bits.tmp_remanent_sub[0] == div_4bits.tmp_remanent[0] && (div_4bits.tmp_remanent[1] >= divisor_i) |-> div_4bits.tmp_remanent_sub[1] == div_4bits.tmp_remanent[1] - divisor_i && (div_4bits.tmp_remanent[1] < divisor_i) |-> div_4bits.tmp_remanent_sub[1] == div_4bits.tmp_remanent[1]);

as__RemanentOutputCorrecteotid: assert property(remanent_o == div_4bits.tmp_remanent_sub[0]);

as__DividendQuotientOutputCorrecteotid: assert property(dividend_quotient_o == div_4bits.tmp_dividend_quotient[0]);

as__DivisorOutputCorrecteotid: assert property(divisor_o == divisor_i);

as__TmpDividendQuotientShiftCorrecteotid: assert property(div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]});

as__TmpDividendQuotient0ShiftCorrecteotid: assert property(div_4bits.tmp_dividend_quotient[0] == {div_4bits.tmp_dividend_quotient[1][div_4bits.WIDTH-2:0], div_4bits.quotient_bit[0]});

as__TmpRemanent0ShiftCorrecteotid: assert property(div_4bits.tmp_remanent[0] == {div_4bits.tmp_remanent_sub[1][div_4bits.WIDTH-2:0], div_4bits.tmp_dividend_quotient[1][div_4bits.WIDTH-1]});

as__TmpRemanent1ShiftCorrecteotid: assert property(div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[div_4bits.WIDTH-1]});

as__TmpRemanentShiftCorrecteotid: assert property((1'b1) |-> ((div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], (div_4bits.SIMD_ENABLE ? (div_4bits.dividend_quotient_i[(div_4bits.sew_i == 2'b00 ? 7 : (div_4bits.sew_i == 2'b01 ? 15 : (div_4bits.sew_i == 2'b10 ? 31 : 63)))] ) : div_4bits.dividend_quotient_i[div_4bits.WIDTH-1])})));

endmodule
