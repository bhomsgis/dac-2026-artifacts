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
as__RemanentOutput: assert property((remanent_o == div_4bits.tmp_remanent_sub[0]) |-> (remanent_o == div_4bits.tmp_remanent_sub[0]));

as__DividendQuotientOutput: assert property((dividend_quotient_o == div_4bits.tmp_dividend_quotient[0]) |-> (dividend_quotient_o == div_4bits.tmp_dividend_quotient[0]));

as__DivisorOutput: assert property((divisor_o == divisor_i) |-> (divisor_o == divisor_i));

as__RemanentCalculation: assert property((div_4bits.tmp_remanent[1] == {remanent_i[div_4bits.WIDTH-2:0], dividend_quotient_i[(div_4bits.WIDTH-1)]}) |-> (div_4bits.tmp_remanent[1] == {remanent_i[div_4bits.WIDTH-2:0], dividend_quotient_i[(div_4bits.WIDTH-1)]}));

as__DividendQuotientCalculation: assert property((div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}) |-> (div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}));

as__RemanentSubCalculation: assert property(((div_4bits.tmp_remanent[1] >= divisor_i) && (div_4bits.tmp_remanent_sub[1] == div_4bits.tmp_remanent[1] - divisor_i)) |-> (div_4bits.tmp_remanent_sub[1] == div_4bits.tmp_remanent[1] - divisor_i));

as__QuotientBitCalculation: assert property(((div_4bits.tmp_remanent[1] >= divisor_i) && (div_4bits.quotient_bit[1] == 1'b1)) |-> (div_4bits.quotient_bit[1] == 1'b1));

as__RemanentSubCalculationElse: assert property(((div_4bits.tmp_remanent[1] < divisor_i) && (div_4bits.tmp_remanent_sub[1] == div_4bits.tmp_remanent[1])) |-> (div_4bits.tmp_remanent_sub[1] == div_4bits.tmp_remanent[1]));

as__QuotientBitCalculationElse: assert property(((div_4bits.tmp_remanent[1] < divisor_i) && (div_4bits.quotient_bit[1] == 1'b0)) |-> (div_4bits.quotient_bit[1] == 1'b0));

as__SEW8RemanentCalculation: assert property((sew_i == 2'b00) && (div_4bits.tmp_remanent[1] == {remanent_i[div_4bits.WIDTH-2:0], dividend_quotient_i[7]}) |-> (div_4bits.tmp_remanent[1] == {remanent_i[div_4bits.WIDTH-2:0], dividend_quotient_i[7]}));

as__SEW16RemanentCalculation: assert property((sew_i == 2'b01) && (div_4bits.tmp_remanent[1] == {remanent_i[div_4bits.WIDTH-2:0], dividend_quotient_i[15]}) |-> (div_4bits.tmp_remanent[1] == {remanent_i[div_4bits.WIDTH-2:0], dividend_quotient_i[15]}));

as__SEW32RemanentCalculation: assert property((sew_i == 2'b10) && (div_4bits.tmp_remanent[1] == {remanent_i[div_4bits.WIDTH-2:0], dividend_quotient_i[31]}) |-> (div_4bits.tmp_remanent[1] == {remanent_i[div_4bits.WIDTH-2:0], dividend_quotient_i[31]}));

as__SEW64RemanentCalculation: assert property((sew_i == 2'b11) && (div_4bits.tmp_remanent[1] == {remanent_i[div_4bits.WIDTH-2:0], dividend_quotient_i[63]}) |-> (div_4bits.tmp_remanent[1] == {remanent_i[div_4bits.WIDTH-2:0], dividend_quotient_i[63]}));

as__SEW8DividendQuotientCalculation: assert property((sew_i == 2'b00) && (div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}) |-> (div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}));

as__SEW16DividendQuotientCalculation: assert property((sew_i == 2'b01) && (div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}) |-> (div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}));

as__SEW32DividendQuotientCalculation: assert property((sew_i == 2'b10) && (div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}) |-> (div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}));

as__SEW64DividendQuotientCalculation: assert property((sew_i == 2'b11) && (div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}) |-> (div_4bits.tmp_dividend_quotient[1] == {dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}));

as__RemanentCalculation_q: assert property((div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[div_4bits.WIDTH-1]}) |-> (div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[div_4bits.WIDTH-1]}));

as__DividendQuotientCalculation_q: assert property((div_4bits.tmp_dividend_quotient[1] == {div_4bits.dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}) |-> (div_4bits.tmp_dividend_quotient[1] == {div_4bits.dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}));

as__RemanentSubCalculation_q: assert property(((div_4bits.tmp_remanent[1] >= div_4bits.divisor_i) && (div_4bits.tmp_remanent_sub[1] == div_4bits.tmp_remanent[1] - div_4bits.divisor_i)) |-> (div_4bits.tmp_remanent_sub[1] == div_4bits.tmp_remanent[1] - div_4bits.divisor_i));

as__QuotientBitCalculation_q: assert property(((div_4bits.tmp_remanent[1] >= div_4bits.divisor_i) && (div_4bits.quotient_bit[1] == 1'b1)) |-> (div_4bits.quotient_bit[1] == 1'b1));

as__RemanentSubCalculationElse_q: assert property(((div_4bits.tmp_remanent[1] < div_4bits.divisor_i) && (div_4bits.tmp_remanent_sub[1] == div_4bits.tmp_remanent[1])) |-> (div_4bits.tmp_remanent_sub[1] == div_4bits.tmp_remanent[1]));

as__QuotientBitCalculationElse_q: assert property(((div_4bits.tmp_remanent[1] < div_4bits.divisor_i) && (div_4bits.quotient_bit[1] == 1'b0)) |-> (div_4bits.quotient_bit[1] == 1'b0));

as__SEW8RemanentCalculation_q: assert property((div_4bits.sew_i == 2'b00) && (div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[7]}) |-> (div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[7]}));

as__SEW16RemanentCalculation_q: assert property((div_4bits.sew_i == 2'b01) && (div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[15]}) |-> (div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[15]}));

as__SEW32RemanentCalculation_q: assert property((div_4bits.sew_i == 2'b10) && (div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[31]}) |-> (div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[31]}));

as__SEW64RemanentCalculation_q: assert property((div_4bits.sew_i == 2'b11) && (div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[63]}) |-> (div_4bits.tmp_remanent[1] == {div_4bits.remanent_i[div_4bits.WIDTH-2:0], div_4bits.dividend_quotient_i[63]}));

as__SEW8DividendQuotientCalculation_q: assert property((div_4bits.sew_i == 2'b00) && (div_4bits.tmp_dividend_quotient[1] == {div_4bits.dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}) |-> (div_4bits.tmp_dividend_quotient[1] == {div_4bits.dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}));

as__SEW16DividendQuotientCalculation_q: assert property((div_4bits.sew_i == 2'b01) && (div_4bits.tmp_dividend_quotient[1] == {div_4bits.dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}) |-> (div_4bits.tmp_dividend_quotient[1] == {div_4bits.dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}));

as__SEW32DividendQuotientCalculation_q: assert property((div_4bits.sew_i == 2'b10) && (div_4bits.tmp_dividend_quotient[1] == {div_4bits.dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}) |-> (div_4bits.tmp_dividend_quotient[1] == {div_4bits.dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}));

as__SEW64DividendQuotientCalculation_q: assert property((div_4bits.sew_i == 2'b11) && (div_4bits.tmp_dividend_quotient[1] == {div_4bits.dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}) |-> (div_4bits.tmp_dividend_quotient[1] == {div_4bits.dividend_quotient_i[div_4bits.WIDTH-2:0], div_4bits.quotient_bit[1]}));

as__RemanentOutput_q2: assert property((div_4bits.remanent_o_q == div_4bits.tmp_remanent_sub[0]) |-> (div_4bits.remanent_o_q == div_4bits.tmp_remanent_sub[0]));

as__DividendQuotientOutput_q2: assert property((div_4bits.dividend_quotient_o_q == div_4bits.tmp_dividend_quotient[0]) |-> (div_4bits.dividend_quotient_o_q == div_4bits.tmp_dividend_quotient[0]));

as__DivisorOutput_q2: assert property((div_4bits.divisor_o_q == div_4bits.divisor_i) |-> (div_4bits.divisor_o_q == div_4bits.divisor_i));

as__RemanentOutput_q: assert property((div_4bits.remanent_o_q == $past(div_4bits.tmp_remanent_sub[0])) |=> (div_4bits.remanent_o_q == $past(div_4bits.tmp_remanent_sub[0])));

as__DividendQuotientOutput_q: assert property((div_4bits.dividend_quotient_o_q == $past(div_4bits.tmp_dividend_quotient[0])) |=> (div_4bits.dividend_quotient_o_q == $past(div_4bits.tmp_dividend_quotient[0])));

as__DivisorOutput_q: assert property((div_4bits.divisor_i |-> div_4bits.divisor_o == div_4bits.divisor_i));

endmodule
