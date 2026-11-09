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
as__DataRs1DCorrectForMul: assert property((op_i == 0) |-> mul_unit.data_rs1_d == (((data_rs1_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs1_i[31] & op_32bits_i)) ? (~data_rs1_i + mul_unit.ONE) : data_rs1_i));

as__DataRs2DCorrectForMul: assert property((op_i == 0) |-> mul_unit.data_rs2_d == (((data_rs2_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs2_i[31] & op_32bits_i)) ? (~data_rs2_i + mul_unit.ONE) : data_rs2_i));

as__DataRs1DCorrectForMulH: assert property((op_i == 1) |-> mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)]) ? (~data_rs1_i + mul_unit.ONE) : data_rs1_i));

as__DataRs2DCorrectForMulH: assert property((op_i == 1) |-> mul_unit.data_rs2_d == ((data_rs2_i[(mul_unit.WIDTH-1)]) ? (~data_rs2_i + mul_unit.ONE) : data_rs2_i));

as__DataRs1DCorrectForMulHSU: assert property((op_i == 2) |-> mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)]) ? (~data_rs1_i + mul_unit.ONE) : data_rs1_i));

as__DataRs2DCorrectForMulHSU: assert property((op_i == 2) |-> mul_unit.data_rs2_d == data_rs2_i);

as__DataRs1DCorrectForMulHU: assert property((op_i == 3) |-> mul_unit.data_rs1_d == data_rs1_i);

as__DataRs2DCorrectForMulHU: assert property((op_i == 3) |-> mul_unit.data_rs2_d == data_rs2_i);

as__NegDCorrectForMulHSU: assert property((op_i == 2) |-> mul_unit.neg_d == data_rs1_i[(mul_unit.WIDTH-1)]);

as__NegDZeroForMulHU: assert property((op_i == 3) |-> mul_unit.neg_d == 1'b0);

as__ResultLowDIsPartialProductLow: assert property(mul_unit.result_low_d == mul_unit.data_rs1_q * mul_unit.data_rs2_q[(mul_unit.WIDTH/2)-1:0]);

as__ResultHighDIsPartialProductHigh: assert property(mul_unit.result_high_d == mul_unit.data_rs1_q * mul_unit.data_rs2_q[mul_unit.WIDTH-1:(mul_unit.WIDTH/2)]);

as__OpQFinalUpdatedOnValidQ0: assert property((mul_unit.valid_q[0] && !flush_i[1]) |=> mul_unit.op_q_final == $past(mul_unit.op_q));

as__Op32BitsQFinalUpdatedOnValidQ0: assert property((mul_unit.valid_q[0] && !flush_i[1]) |=> mul_unit.op_32bits_q_final == $past(mul_unit.op_32bits_q));

as__NegQFinalUpdatedOnValidQ0: assert property((mul_unit.valid_q[0] && !flush_i[1]) |=> mul_unit.neg_q_final == $past(mul_unit.neg_q));

as__Result32QUpdatedOnValidQ0: assert property((mul_unit.valid_q[0] && !flush_i[1]) |=> mul_unit.result_32_q == $past(mul_unit.result_32));

as__ResultLowQUpdatedOnValidQ0: assert property((mul_unit.valid_q[0] && !flush_i[1]) |=> mul_unit.result_low_q == $past(mul_unit.result_low_d));

as__ResultHighQUpdatedOnValidQ0: assert property((mul_unit.valid_q[0] && !flush_i[1]) |=> mul_unit.result_high_q == $past(mul_unit.result_high_d));

as__Result2WidthSumCorrect: assert property(mul_unit.result_2width == {{(mul_unit.WIDTH/2){1'b0}}, mul_unit.result_low_q} + {mul_unit.result_high_q, {(mul_unit.WIDTH/2){1'b0}}});

as__Result2WidthDefCorrect: assert property(mul_unit.result_2width_def == (mul_unit.neg_q_final ? (~mul_unit.result_2width + mul_unit.ONEDOUBLE) : mul_unit.result_2width));

as__ResultSelectedCorrectly: assert property((mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32) |-> mul_unit.result == mul_unit.result_32_q);

as__ResultSelectedCorrectlyMulLow: assert property((mul_unit.op_q_final == 0 && !(mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32)) |-> mul_unit.result == mul_unit.result_2width_def[mul_unit.WIDTH-1:0]);

as__ResultSelectedCorrectlyMulHigh: assert property((mul_unit.op_q_final != 0 && !(mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32)) |-> mul_unit.result == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:mul_unit.WIDTH]);

as__ValidOAndResultOMatchRegister32bitGen: assert property(mul_unit.REG_32 |-> (valid_o == mul_unit.valid_q[1] && result_o == mul_unit.result));

as__ValidOAndResultOMatchOutput32bitGen: assert property(mul_unit.CONFIG32 |-> (valid_o == mul_unit.valid_q[0] && result_o == mul_unit.result));

as__ValidOAndResultOMatchNoRegister32bitGen: assert property((!mul_unit.REG_32 && !mul_unit.CONFIG32) |-> ((mul_unit.op_32bits_q[0] && mul_unit.valid_q[0]) ? (valid_o == mul_unit.valid_q[0] && result_o == mul_unit.result_32) : (valid_o == (mul_unit.valid_q[1] && !mul_unit.op_32bits_q_final) && result_o == mul_unit.result)));

as__ResultSelectionCorrect: assert property(((mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32) || (mul_unit.op_q_final == 0 && !(mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32)) || (mul_unit.op_q_final != 0 && !(mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32))) |-> ((mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32) ? (mul_unit.result == mul_unit.result_32_q) : (mul_unit.op_q_final == 0 ? (mul_unit.result == mul_unit.result_2width_def[mul_unit.WIDTH-1:0]) : (mul_unit.result == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:mul_unit.WIDTH]))));

as__ValidOResultOMatchConfig: assert property((mul_unit.REG_32 || mul_unit.CONFIG32 || (!mul_unit.REG_32 && !mul_unit.CONFIG32)) |-> ((mul_unit.REG_32) ? (valid_o == mul_unit.valid_q[1] && result_o == mul_unit.result) : ((mul_unit.CONFIG32) ? (valid_o == mul_unit.valid_q[0] && result_o == mul_unit.result) : ((mul_unit.op_32bits_q[0] && mul_unit.valid_q[0]) ? (valid_o == mul_unit.valid_q[0] && result_o == mul_unit.result_32) : (valid_o == (mul_unit.valid_q[1] && !mul_unit.op_32bits_q_final) && result_o == mul_unit.result)))));

as__DataRs1Rs2DCorrectForMul: assert property((op_i == 0) |-> mul_unit.data_rs1_d == (((data_rs1_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs1_i[31] & op_32bits_i)) ? (~data_rs1_i + mul_unit.ONE) : data_rs1_i) && mul_unit.data_rs2_d == (((data_rs2_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs2_i[31] & op_32bits_i)) ? (~data_rs2_i + mul_unit.ONE) : data_rs2_i));

as__DataRs1Rs2DCorrectForMulH: assert property((op_i == 1) |-> mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)]) ? (~data_rs1_i + mul_unit.ONE) : data_rs1_i) && mul_unit.data_rs2_d == ((data_rs2_i[(mul_unit.WIDTH-1)]) ? (~data_rs2_i + mul_unit.ONE) : data_rs2_i));

as__DataRs1Rs2DCorrectForMulHSU: assert property((op_i == 2) |-> mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)]) ? (~data_rs1_i + mul_unit.ONE) : data_rs1_i) && mul_unit.data_rs2_d == data_rs2_i);

as__DataRs1Rs2DCorrectForMulHU: assert property((op_i == 3) |-> mul_unit.data_rs1_d == data_rs1_i && mul_unit.data_rs2_d == data_rs2_i);

as__NegDCorrectForMul: assert property((op_i == 0) |-> mul_unit.neg_d == !mul_unit.same_sign);

as__NegDCorrectForMulH: assert property((op_i == 1) |-> mul_unit.neg_d == !mul_unit.same_sign);

as__Result2WidthDefNegationCorrect: assert property(mul_unit.valid_q[1] |=> mul_unit.result_2width_def == (mul_unit.neg_q_final ? (~mul_unit.result_2width + mul_unit.ONEDOUBLE) : mul_unit.result_2width));

as__Result2WidthSumCorrectOnValidQ1: assert property(mul_unit.valid_q[1] |=> mul_unit.result_2width == {{(mul_unit.WIDTH/2){1'b0}}, mul_unit.result_low_q} + {mul_unit.result_high_q, {(mul_unit.WIDTH/2){1'b0}}});

as__SecondStageRegistersUpdateOnValidQ0NoFlush: assert property((mul_unit.valid_q[0] && !mul_unit.flush_i[1]) |=> (mul_unit.op_q_final == $past(mul_unit.op_q) && mul_unit.op_32bits_q_final == $past(mul_unit.op_32bits_q) && mul_unit.neg_q_final == $past(mul_unit.neg_q) && mul_unit.result_32_q == $past(mul_unit.result_32) && mul_unit.result_low_q == $past(mul_unit.result_low_d) && mul_unit.result_high_q == $past(mul_unit.result_high_d)));

as__ResultSelectionCorrectOnValidQ1: assert property(mul_unit.valid_q[1] |=> ((mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32) ? (mul_unit.result == mul_unit.result_32_q) : (mul_unit.op_q_final == 0 ? (mul_unit.result == mul_unit.result_2width_def[mul_unit.WIDTH-1:0]) : (mul_unit.result == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:mul_unit.WIDTH]))));

as__ValidOSetCorrectly: assert property(mul_unit.valid_o |-> ((mul_unit.REG_32) ? mul_unit.valid_q[1] : ((mul_unit.CONFIG32) ? mul_unit.valid_q[0] : ((mul_unit.op_32bits_q[0]) ? mul_unit.valid_q[0] : (mul_unit.valid_q[1] && !mul_unit.op_32bits_q_final)))));

as__Result2WidthDefNegationCorrectOnValidQ1: assert property(mul_unit.valid_q[1] |=> (mul_unit.result_2width_def == (mul_unit.neg_q_final ? (~mul_unit.result_2width + mul_unit.ONEDOUBLE) : mul_unit.result_2width)));

as__Result2WidthSumCorrectOnValidQ1_1: assert property(mul_unit.valid_q[1] |=> (mul_unit.result_2width == {{(mul_unit.WIDTH/2){1'b0}}, mul_unit.result_low_q} + {mul_unit.result_high_q, {(mul_unit.WIDTH/2){1'b0}}}));

as__DataRs1Rs2DCorrectForMul_1: assert property((op_i == 0) |-> (mul_unit.data_rs1_d == (((data_rs1_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs1_i[31] & op_32bits_i)) ? (~data_rs1_i + mul_unit.ONE) : data_rs1_i) && mul_unit.data_rs2_d == (((data_rs2_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs2_i[31] & op_32bits_i)) ? (~data_rs2_i + mul_unit.ONE) : data_rs2_i)));

as__DataRs1Rs2DCorrectForMulH_1: assert property((op_i == 1) |-> (mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)]) ? (~data_rs1_i + mul_unit.ONE) : data_rs1_i) && mul_unit.data_rs2_d == ((data_rs2_i[(mul_unit.WIDTH-1)]) ? (~data_rs2_i + mul_unit.ONE) : data_rs2_i)));

as__DataRs1Rs2DCorrectForMulHSU_1: assert property((op_i == 2) |-> (mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)]) ? (~data_rs1_i + mul_unit.ONE) : data_rs1_i) && mul_unit.data_rs2_d == data_rs2_i));

as__DataRs1Rs2DCorrectForMulHU_1: assert property((op_i == 3) |-> (mul_unit.data_rs1_d == data_rs1_i && mul_unit.data_rs2_d == data_rs2_i));

as__NegQZeroForMulHU: assert property((mul_unit.op_q == 3) |-> mul_unit.neg_q == 1'b0);

as__OpQFinalUpdatedOnValidQ0_1: assert property((mul_unit.valid_q[0] && !mul_unit.flush_i[1]) |=> mul_unit.op_q_final == $past(mul_unit.op_q));

as__Op32BitsQFinalUpdatedOnValidQ0_1: assert property((mul_unit.valid_q[0] && !mul_unit.flush_i[1]) |=> mul_unit.op_32bits_q_final == $past(mul_unit.op_32bits_q));

as__NegQFinalUpdatedOnValidQ0_1: assert property((mul_unit.valid_q[0] && !mul_unit.flush_i[1]) |=> mul_unit.neg_q_final == $past(mul_unit.neg_q));

as__Result32QUpdatedOnValidQ0_1: assert property((mul_unit.valid_q[0] && !mul_unit.flush_i[1]) |=> mul_unit.result_32_q == $past(mul_unit.result_32));

as__ResultLowQUpdatedOnValidQ0_1: assert property((mul_unit.valid_q[0] && !mul_unit.flush_i[1]) |=> mul_unit.result_low_q == $past(mul_unit.result_low_d));

as__ResultHighQUpdatedOnValidQ0_1: assert property((mul_unit.valid_q[0] && !mul_unit.flush_i[1]) |=> mul_unit.result_high_q == $past(mul_unit.result_high_d));

as__ResultMatchesResult32QOnValidQ1For32BitReg: assert property((mul_unit.valid_q[1] && mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32) |-> mul_unit.result == mul_unit.result_32_q);

as__ResultMatchesLowPartOnValidQ1ForMul: assert property((mul_unit.valid_q[1] && mul_unit.op_q_final == 0 && !(mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32)) |-> mul_unit.result == mul_unit.result_2width_def[mul_unit.WIDTH-1:0]);

as__ResultMatchesHighPartOnValidQ1ForNonMul: assert property((mul_unit.valid_q[1] && mul_unit.op_q_final != 0 && !(mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32)) |-> mul_unit.result == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:mul_unit.WIDTH]);

as__ValidOMatchesValidQ1WhenReg32: assert property(mul_unit.REG_32 |-> valid_o == mul_unit.valid_q[1]);

as__ResultOMatchesResultWhenReg32: assert property(mul_unit.REG_32 |-> result_o == mul_unit.result);

as__ValidOMatchesValidQ0WhenConfig32: assert property(mul_unit.CONFIG32 |-> valid_o == mul_unit.valid_q[0]);

as__ResultOMatchesResultWhenConfig32: assert property(mul_unit.CONFIG32 |-> result_o == mul_unit.result);

as__ValidOSetCorrectlyGeneral: assert property(valid_o |-> ((mul_unit.REG_32) ? mul_unit.valid_q[1] : ((mul_unit.CONFIG32) ? mul_unit.valid_q[0] : ((mul_unit.op_32bits_q[0]) ? mul_unit.valid_q[0] : (mul_unit.valid_q[1] && !mul_unit.op_32bits_q_final)))));

as__ResultOMatchesResultGeneral: assert property((mul_unit.REG_32 || mul_unit.CONFIG32) |-> result_o == mul_unit.result);

as__ResultOMatchesResult32WhenNoReg32NoConfig32: assert property((!mul_unit.REG_32 && !mul_unit.CONFIG32 && mul_unit.op_32bits_q[0] && mul_unit.valid_q[0]) |-> result_o == mul_unit.result_32);

as__ResultOMatchesResultWhenNoReg32NoConfig32ValidQ1: assert property((!mul_unit.REG_32 && !mul_unit.CONFIG32 && mul_unit.valid_q[1] && !mul_unit.op_32bits_q_final) |-> result_o == mul_unit.result);

as__ValidOutputMatchesInputValid: assert property((mul_unit.valid_i && !mul_unit.flush_i[0]) |=> mul_unit.valid_q[0]);

as__Op32BitsSetOnlyForMul: assert property((op_i == 0) |-> op_32bits_i);

as__NegDMatchesSignXor: assert property((op_i == 0 || op_i == 1 || op_i == 2) |-> mul_unit.neg_d == !mul_unit.same_sign);

as__ValidQ0ClearedOnFlushOrInvalid: assert property((mul_unit.flush_i[0] || !valid_i) |=> !mul_unit.valid_q[0]);

as__ValidQ0SetOnValid: assert property((valid_i && !flush_i[0]) |=> mul_unit.valid_q[0]);

as__OpQUpdatedOnValid: assert property((mul_unit.valid_i && !mul_unit.flush_i[0]) |=> (mul_unit.op_q == $past(mul_unit.op_i) && mul_unit.valid_q[0]));

as__Op32BitsQUpdatedOnValid: assert property((valid_i && !flush_i[0]) |=> mul_unit.op_32bits_q == $past(mul_unit.op_32bits_i && (mul_unit.op_i == 0)));

as__NegQUpdatedOnValid: assert property((valid_i && !flush_i[0]) |=> (mul_unit.neg_q == $past(mul_unit.neg_d)));

as__DataRs1QUpdatedOnValid: assert property((valid_i && !flush_i[0]) |=> mul_unit.data_rs1_q == $past(mul_unit.data_rs1_d));

as__DataRs2QUpdatedOnValid: assert property((valid_i && !flush_i[0]) |=> mul_unit.data_rs2_q == $past(mul_unit.data_rs2_d));

as__Result32AuxCorrect: assert property(mul_unit.neg_q ? (mul_unit.result_32_aux == (~mul_unit.result_low_d[mul_unit.WIDTH-1:0] + mul_unit.ONE)) : (mul_unit.result_32_aux == mul_unit.result_low_d[mul_unit.WIDTH-1:0]));

as__Result32SignExtendedCorrect: assert property(mul_unit.result_32 == {{(mul_unit.WIDTH-32){mul_unit.result_32_aux[31]}},mul_unit.result_32_aux[31:0]});

as__ValidQ1ClearedOnFlushOrInvalidQ0: assert property((mul_unit.flush_i[1] || !mul_unit.valid_q[0]) |=> !mul_unit.valid_q[1]);

as__ValidQ1SetOnValidQ0: assert property((mul_unit.valid_q[0] && !mul_unit.flush_i[0] && !mul_unit.flush_i[1]) |=> ((mul_unit.op_32bits_q && mul_unit.REG_32) ? mul_unit.valid_q[1] : 1'b1));

as__RegistersUpdateOnValidAndNoFlush0: assert property((valid_i && !flush_i[0]) |=> (mul_unit.op_q == $past(op_i) && mul_unit.op_32bits_q == ($past(op_32bits_i) && ($past(op_i) == 0)) && mul_unit.neg_q == $past(mul_unit.neg_d) && mul_unit.data_rs1_q == $past(mul_unit.data_rs1_d) && mul_unit.data_rs2_q == $past(mul_unit.data_rs2_d)));

as__ValidQ1SetOnlyIfValidQ0AndNoFlush: assert property((mul_unit.valid_q[1]) |-> (mul_unit.valid_q[0] && !flush_i[1]));

as__Result32AuxCorrectForMulH: assert property ((mul_unit.op_q_final == 1 && mul_unit.op_32bits_q_final) |=> mul_unit.result_32_aux == (mul_unit.neg_q_final ? (~$past(mul_unit.result_low_q[mul_unit.WIDTH-1:0]) + mul_unit.ONE) : $past(mul_unit.result_low_q[mul_unit.WIDTH-1:0])));

as__Result32AuxCorrectForMulHSU: assert property((mul_unit.op_q_final == 2) |=> mul_unit.result_32_aux == (mul_unit.neg_q_final ? (~mul_unit.result_low_q[mul_unit.WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_q[mul_unit.WIDTH-1:0]));

as__Result32AuxCorrectForMulHU: assert property((mul_unit.op_q_final == 3 && mul_unit.op_32bits_q_final) |=> (mul_unit.result_32_q == $past(mul_unit.result_low_q[mul_unit.WIDTH-1:0])));

as__Result32SignExtendedCorrectForHighOps: assert property ((mul_unit.op_q_final inside {1,2,3}) && mul_unit.op_32bits_q_final |=> mul_unit.result_32_q == {{(mul_unit.WIDTH-32){$past(mul_unit.result_32_aux[31])}}, $past(mul_unit.result_32_aux[31:0])});

as__Result32AuxCorrectForMul: assert property((mul_unit.op_q == 0) |=> mul_unit.result_32_aux == (mul_unit.neg_q ? (~mul_unit.result_low_q[mul_unit.WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_q[mul_unit.WIDTH-1:0]));

as__Result32SignExtendedCorrectForMul: assert property((mul_unit.op_q == 0) |=> mul_unit.result_32 == {{(mul_unit.WIDTH-32){mul_unit.result_32_aux[31]}},mul_unit.result_32_aux[31:0]});

as__Result32AuxNegationCorrectForHighOps: assert property(((mul_unit.op_q_final == 1) || (mul_unit.op_q_final == 2) || (mul_unit.op_q_final == 3)) |=> (mul_unit.result_32_aux == (mul_unit.neg_q_final ? (~mul_unit.result_low_q[mul_unit.WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_q[mul_unit.WIDTH-1:0])));

as__Result32AuxNegationCorrectForMul: assert property((mul_unit.op_q == 0) |=> (mul_unit.result_32_aux == (mul_unit.neg_q ? (~mul_unit.result_low_q[mul_unit.WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_q[mul_unit.WIDTH-1:0])));

as__Result32SignExtensionCorrect: assert property(((mul_unit.op_q_final == 0) || (mul_unit.op_q_final == 1) || (mul_unit.op_q_final == 2) || (mul_unit.op_q_final == 3)) |=> (mul_unit.result_32 == {{(mul_unit.WIDTH-32){mul_unit.result_32_aux[31]}},mul_unit.result_32_aux[31:0]}));

as__NegQCorrectForMulHSU: assert property((mul_unit.op_q == 2) |-> mul_unit.neg_q == mul_unit.data_rs1_i[(mul_unit.WIDTH-1)]);

as__ValidQ0ClearedOnFlushOrInvalid_1: assert property((mul_unit.flush_i[0] || !valid_i) |=> !mul_unit.valid_q[0]);

as__ValidQ0SetOnValid_1: assert property((valid_i && !mul_unit.flush_i[0]) |=> mul_unit.valid_q[0]);

as__OpQUpdatedOnValid_1: assert property((valid_i && !mul_unit.flush_i[0]) |=> mul_unit.op_q == $past(op_i));

as__Op32BitsQUpdatedOnValid_1: assert property((valid_i && !mul_unit.flush_i[0]) |=> mul_unit.op_32bits_q == $past(op_32bits_i && (op_i == 0)));

as__NegQUpdatedOnValid_1: assert property((valid_i && !mul_unit.flush_i[0]) |=> mul_unit.neg_q == $past(mul_unit.neg_d && valid_i && !mul_unit.flush_i[0]));

as__DataRs1QUpdatedOnValid_1: assert property((valid_i && !mul_unit.flush_i[0]) |=> mul_unit.data_rs1_q == $past(mul_unit.data_rs1_d));

as__DataRs2QUpdatedOnValid_1: assert property((valid_i && !mul_unit.flush_i[0]) |=> mul_unit.data_rs2_q == $past(mul_unit.data_rs2_d));

as__ValidQ1ClearedOnFlushOrInvalidQ0_1: assert property((1'b1) |=> (($past(mul_unit.flush_i[1]) || !$past(mul_unit.valid_q[0])) -> !mul_unit.valid_q[1]));

as__ValidQ1SetOnValidQ0_1: assert property((mul_unit.valid_q[0] && !mul_unit.flush_i[0] && !mul_unit.flush_i[1]) |=> mul_unit.valid_q[1]);

as__ValidQ1SetOnlyIfValidQ0AndNoFlush_1: assert property((mul_unit.valid_q[1]) |-> (mul_unit.valid_q[0] && !mul_unit.flush_i[1]));

as__RegistersUpdateOnValidAndNoFlush0_1: assert property((valid_i && !mul_unit.flush_i[0]) |=> (mul_unit.op_q == $past(op_i) && mul_unit.op_32bits_q == ($past(op_32bits_i) && ($past(op_i) == 0)) && mul_unit.neg_q == $past(mul_unit.neg_d) && mul_unit.data_rs1_q == $past(mul_unit.data_rs1_d) && mul_unit.data_rs2_q == $past(mul_unit.data_rs2_d)));

as__OpQResetOnFlushOrInvalidInput: assert property((mul_unit.flush_i[0] || !valid_i) |=> (mul_unit.valid_q[0] == 1'b0 && mul_unit.op_q == {mul_unit.MUL_OPS_BITS{1'b0}}));

as__Op32BitsQResetOnFlushOrInvalidInput: assert property((mul_unit.flush_i[0] || !valid_i) |=> mul_unit.op_32bits_q == 1'b0);

as__NegQResetOnFlushOrInvalidInput: assert property((mul_unit.flush_i[0] || !valid_i) |=> (mul_unit.neg_q == 1'b0));

as__Result32AuxNegationCorrectOnValidQ1: assert property(((mul_unit.op_q_final == 0) || (mul_unit.op_q_final == 1) || (mul_unit.op_q_final == 2) || (mul_unit.op_q_final == 3)) && mul_unit.valid_q[1] |=> (mul_unit.result_32_aux == (mul_unit.neg_q_final ? (~mul_unit.result_low_q[mul_unit.WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_q[mul_unit.WIDTH-1:0])));

as__Result32SignExtendedCorrectOnValidQ1: assert property(mul_unit.valid_q[1] |=> mul_unit.result_32 == {{{(mul_unit.WIDTH-32){mul_unit.result_32_aux[31]}},mul_unit.result_32_aux[31:0]}});

as__Result32AuxCorrectForMulH_1: assert property((op_i == 1) |-> mul_unit.result_32_aux == (mul_unit.neg_d ? (~mul_unit.result_low_d[mul_unit.WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_d[mul_unit.WIDTH-1:0]));

as__Result32AuxCorrectForMulHSU_1: assert property((op_i == 2) |-> mul_unit.result_32_aux == (mul_unit.neg_d ? (~mul_unit.result_low_d[mul_unit.WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_d[mul_unit.WIDTH-1:0]));

as__Result32AuxCorrectForMulHU_1: assert property((op_i == 3) |-> mul_unit.result_32_aux == mul_unit.result_low_d[mul_unit.WIDTH-1:0]);

as__NegQCorrectForMulAndMulH: assert property(((mul_unit.op_q == 0) || (mul_unit.op_q == 1)) |-> mul_unit.neg_q == mul_unit.neg_d);

as__Result32AuxCorrectForMulAndMulH: assert property(((mul_unit.op_q == 0) || (mul_unit.op_q == 1)) |-> mul_unit.result_32_aux == (mul_unit.neg_q ? (~mul_unit.result_low_d[mul_unit.WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_d[mul_unit.WIDTH-1:0]));

as__Result32AuxCorrectForMulHSUQ: assert property ((mul_unit.op_q == 2 && mul_unit.op_32bits_q) |=> mul_unit.result_32_aux == ($past(mul_unit.neg_q) ? (~$past(mul_unit.result_low_d[mul_unit.WIDTH-1:0]) + mul_unit.ONE) : $past(mul_unit.result_low_d[mul_unit.WIDTH-1:0])));

as__Result32AuxCorrectForMulHUQ: assert property((mul_unit.op_q == 3) |-> mul_unit.result_32_aux == mul_unit.result_low_d[mul_unit.WIDTH-1:0]);

as__Result32SignExtendedCorrectForAllOpsQ: assert property(((mul_unit.op_q == 0) || (mul_unit.op_q == 1) || (mul_unit.op_q == 2) || (mul_unit.op_q == 3)) |-> mul_unit.result_32 == {{(mul_unit.WIDTH-32){mul_unit.result_32_aux[31]}},mul_unit.result_32_aux[31:0]});

as__Result32AuxNegationCorrectOnValidQ1AllOps: assert property(((mul_unit.op_q_final == 0) || (mul_unit.op_q_final == 1) || (mul_unit.op_q_final == 2) || (mul_unit.op_q_final == 3)) && mul_unit.valid_q[1] |=> mul_unit.result_32_aux == (mul_unit.neg_q_final ? (~mul_unit.result_low_q[mul_unit.WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_q[mul_unit.WIDTH-1:0]));

as__Result32SignExtendedCorrectOnValidQ1AllOps: assert property(mul_unit.valid_q[1] |=> mul_unit.result_32 == {{(mul_unit.WIDTH-32){mul_unit.result_32_aux[31]}},mul_unit.result_32_aux[31:0]});

endmodule
