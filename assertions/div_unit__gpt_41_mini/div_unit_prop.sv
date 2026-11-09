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
as__BusyClearsWhenNoCycles: assert property((div_unit.cycles_counter == 6'd0) |-> !busy_o);

as__BusySetWhenCyclesNonZero: assert property((div_unit.cycles_counter != 6'd0) |-> busy_o);

as__CyclesCountDown: assert property((div_unit.cycles_counter != 6'd0 && !valid_i && !flush_i) |=> (div_unit.cycles_counter == $past(div_unit.cycles_counter) - 6'd1));

as__ValidOSetWhenCyclesOne: assert property((div_unit.cycles_counter == 6'd1) |-> valid_o == div_unit.valid_q);

as__ResultODivWhenOpDiv: assert property((div_unit.cycles_counter == 6'd1 && !div_unit.op_q) |-> result_o == div_unit.quo_aux);

as__ResultORemWhenOpRem: assert property((div_unit.cycles_counter == 6'd1 && div_unit.op_q) |-> result_o == div_unit.rmd_aux);

as__QuoAllOnesWhenDivZero: assert property((div_unit.div_zero_q) |-> div_unit.quo == {WIDTH{1'b1}});

as__RmdEqualsFirstDividendWhenDivZero: assert property((div_unit.div_zero_q) |-> div_unit.rmd == div_unit.first_dividend_q);

as__QuoSignCorrectWhenSignedOp: assert property((!div_unit.div_zero_q && div_unit.signed_op_q && div_unit.same_sign_q) |-> div_unit.quo == div_unit.dividend_quotient_q);

as__QuoSignCorrectWhenSignedOpNeg: assert property((!div_unit.div_zero_q && div_unit.signed_op_q && !div_unit.same_sign_q) |-> div_unit.quo == (~div_unit.dividend_quotient_q + div_unit.ONE));

as__QuoUnsignedOp: assert property((!div_unit.div_zero_q && !div_unit.signed_op_q) |-> div_unit.quo == div_unit.dividend_quotient_q);

as__RmdSignCorrectWhenSignedOpNeg: assert property((!div_unit.div_zero_q && div_unit.signed_op_q && ((div_unit.first_dividend_q[(WIDTH - 1)] & (!div_unit.op_32_q)) || (div_unit.first_dividend_q[31] & div_unit.op_32_q))) |-> div_unit.rmd == ((~div_unit.remanent_q) + div_unit.ONE));

as__RmdSignCorrectWhenSignedOpPos: assert property((!div_unit.div_zero_q && div_unit.signed_op_q && !((div_unit.first_dividend_q[(WIDTH - 1)] & (!div_unit.op_32_q)) || (div_unit.first_dividend_q[31] & div_unit.op_32_q))) |-> div_unit.rmd == div_unit.remanent_q);

as__RmdUnsignedOp: assert property((!div_unit.div_zero_q && !div_unit.signed_op_q) |-> div_unit.rmd == div_unit.remanent_q);

as__DividendAuxSignedConversion: assert property((valid_i && !op_unsigned_i && ((div_unit.CONFIG32 == 1'b1 && data_rs1_i[31]) || (div_unit.CONFIG32 == 1'b0 && ((!op_32bits_i && data_rs1_i[63]) || (op_32bits_i && data_rs1_i[31]))))) |-> div_unit.dividend_aux_d == (~data_rs1_i + div_unit.ONE));

as__DividendAuxUnsignedConversion: assert property((valid_i && (op_unsigned_i || (div_unit.CONFIG32 == 1'b1 && !data_rs1_i[31]) || (div_unit.CONFIG32 == 1'b0 && ((!op_32bits_i && !data_rs1_i[63]) && (op_32bits_i && !data_rs1_i[31]))))) |-> div_unit.dividend_aux_d == data_rs1_i);

as__DivisorAuxSignedConversion: assert property((valid_i && !op_unsigned_i && ((div_unit.CONFIG32 == 1'b1 && data_rs2_i[31]) || (div_unit.CONFIG32 == 1'b0 && ((!op_32bits_i && data_rs2_i[63]) || (op_32bits_i && data_rs2_i[31]))))) |-> div_unit.divisor_aux_d == (~data_rs2_i + div_unit.ONE));

as__DivisorAuxUnsignedConversion: assert property((valid_i && (op_unsigned_i || (div_unit.CONFIG32 == 1'b1 && !data_rs2_i[31]) || (div_unit.CONFIG32 == 1'b0 && ((!op_32bits_i && !data_rs2_i[63]) && (op_32bits_i && !data_rs2_i[31]))))) |-> div_unit.divisor_aux_d == data_rs2_i);

as__DividendDAssign32: assert property((div_unit.CONFIG32 == 1'b1 && valid_i) |-> div_unit.dividend_d == div_unit.dividend_aux_d);

as__DivisorDAssign32: assert property((div_unit.CONFIG32 == 1'b1 && valid_i) |-> div_unit.divisor_d == div_unit.divisor_aux_d);

as__DividendDAssign64: assert property((div_unit.CONFIG32 == 1'b0 && valid_i && op_32bits_i) |-> div_unit.dividend_d == {div_unit.dividend_aux_d[31:0], 32'b0});

as__DividendDAssign64NoOp32: assert property((div_unit.CONFIG32 == 1'b0 && valid_i && !op_32bits_i) |-> div_unit.dividend_d == div_unit.dividend_aux_d);

as__DivisorDAssign64Op32: assert property((div_unit.CONFIG32 == 1'b0 && valid_i && op_32bits_i) |-> div_unit.divisor_d == {32'b0, div_unit.divisor_aux_d[31:0]});

as__DivisorDAssign64NoOp32: assert property((div_unit.CONFIG32 == 1'b0 && valid_i && !op_32bits_i) |-> div_unit.divisor_d == div_unit.divisor_aux_d);

as__BusyOReflectsCyclesCounter: assert property(busy_o == (div_unit.cycles_counter != 6'd0));

as__CyclesCounterNotNegative: assert property(div_unit.cycles_counter >= 6'd0);

as__CyclesCounterDecrementsWhenBusy: assert property((busy_o && !valid_i && !flush_i) |=> (div_unit.cycles_counter == $past(div_unit.cycles_counter) - 6'd1));

as__RemanentQZeroOnValidI: assert property((valid_i) |=> div_unit.remanent_q == {WIDTH{1'b0}});

as__FlushClearsValidQ: assert property((flush_i) |=> div_unit.valid_q == 1'b0);

as__FlushClearsBusy: assert property((flush_i) |=> busy_o == 1'b0);

as__FlushClearsCyclesCounter: assert property((flush_i) |=> div_unit.cycles_counter == 6'd0);

as__FlushClearsInternalRegs: assert property((flush_i) |=> (div_unit.div_zero_q == 1'b0 && div_unit.same_sign_q == 1'b0 && div_unit.op_32_q == 1'b0 && div_unit.signed_op_q == 1'b0));

as__ResultOZeroWhenNotValid: assert property((!valid_o) |-> result_o == {WIDTH{1'b0}});

as__ValidOOnlySetWhenCyclesOne: assert property((valid_o) |-> (div_unit.cycles_counter == 6'd1));

as__RegsUpdateWhenBusy: assert property((div_unit.busy_o && !valid_i && !flush_i) |=> (div_unit.remanent_q == $past(div_unit.remanent_out) && div_unit.dividend_quotient_q == $past(div_unit.dividend_quotient_out) && div_unit.divisor_q == $past(div_unit.divisor_out)));

as__CyclesCounterDecrementsWhenBusyNoValidFlush: assert property((div_unit.busy_o && !valid_i && !flush_i) |=> (div_unit.cycles_counter == $past(div_unit.cycles_counter) - 6'd1));

as__FlushClearsState: assert property((flush_i) |=> (div_unit.valid_q == 1'b0 && busy_o == 1'b0 && div_unit.cycles_counter == 6'd0 && div_unit.div_zero_q == 1'b0 && div_unit.same_sign_q == 1'b0 && div_unit.op_32_q == 1'b0 && div_unit.signed_op_q == 1'b0));

as__ValidOImpliesBusy: assert property((valid_o) |-> busy_o);

as__RemanentQUpdatesWhenBusyNoValidFlush: assert property((busy_o && !valid_i && !flush_i) |=> div_unit.remanent_q == $past(div_unit.remanent_out));

as__DividendQuotientQUpdatesWhenBusyNoValidFlush: assert property((busy_o && !valid_i && !flush_i) |=> div_unit.dividend_quotient_q == $past(div_unit.dividend_quotient_out));

as__DivisorQUpdatesWhenBusyNoValidFlush: assert property((busy_o && !valid_i && !flush_i) |=> div_unit.divisor_q == $past(div_unit.divisor_out));

as__FlushClearsValidQ_1: assert property((flush_i) |=> !div_unit.valid_q);

as__FlushClearsBusyO: assert property((flush_i) |=> !busy_o);

as__CyclesCounterDecrementsWhenBusyNoValidFlush_1: assert property((busy_o && !valid_i && !flush_i) |=> div_unit.cycles_counter == $past(div_unit.cycles_counter) - 6'd1);

as__ResultOMatchesQuoAuxWhenDiv: assert property((valid_o && !div_unit.op_q) |-> result_o == div_unit.quo_aux);

as__ResultOMatchesRmdAuxWhenRem: assert property((valid_o && div_unit.op_q) |-> result_o == div_unit.rmd_aux);

as__QuoAllOnesWhenDivZero_1: assert property((div_unit.div_zero_q) |-> (div_unit.quo == {WIDTH{1'b1}}));

as__RmdCorrectWhenSignedOpNegative: assert property((!div_unit.div_zero_q && div_unit.signed_op_q && ((div_unit.first_dividend_q[(WIDTH-1)] & !div_unit.op_32_q) || (div_unit.first_dividend_q[31] & div_unit.op_32_q))) |-> div_unit.rmd == (~div_unit.remanent_q + div_unit.ONE));

as__RemanentQUpdatesWhenBusyNoValidFlush_1: assert property((div_unit.busy_o && !valid_i && !flush_i) |=> div_unit.remanent_q == $past(div_unit.remanent_out));

as__DividendQuotientQUpdatesWhenBusyNoValidFlush_1: assert property((div_unit.busy_o && !valid_i && !flush_i) |=> div_unit.dividend_quotient_q == $past(div_unit.dividend_quotient_out));

as__DivisorQUpdatesWhenBusyNoValidFlush_1: assert property((div_unit.busy_o && !valid_i && !flush_i) |=> div_unit.divisor_q == $past(div_unit.divisor_out));

as__CyclesCounterDecrementsWhenBusyNoValidFlush_2: assert property((div_unit.busy_o && !valid_i && !flush_i) |=> div_unit.cycles_counter == $past(div_unit.cycles_counter) - 6'd1);

as__ValidOOnlyWhenCyclesCounterOne: assert property(valid_o |-> div_unit.cycles_counter == 6'd1);

as__ValidOOnlyWhenCyclesCounterOneAndValidQ: assert property((valid_o) |-> (div_unit.cycles_counter == 6'd1 && div_unit.valid_q));

as__BusyOReflectsValidAndFlush: assert property((valid_i && !flush_i) |-> busy_o && (!valid_i || flush_i) |-> !busy_o);

as__ValidOSetOnlyWhenValidQAndCyclesOne: assert property(valid_o |-> (div_unit.valid_q && div_unit.cycles_counter == 6'd1));

as__ResultOMatchesAuxOnValidO: assert property(valid_o |-> ((div_unit.op_q == 1'b0) ? (result_o == div_unit.quo_aux) : (result_o == div_unit.rmd_aux)));

as__QuoAllOnesWhenDivZeroQ: assert property(div_unit.div_zero_q |-> (&div_unit.quo));

as__RmdEqualsFirstDividendQWhenDivZeroQ: assert property(div_unit.div_zero_q |-> (div_unit.rmd == div_unit.first_dividend_q));

as__QuoSignCorrectWhenSignedOpSameSign: assert property((!div_unit.div_zero_q && div_unit.signed_op_q && div_unit.same_sign_q) |-> (div_unit.quo == div_unit.dividend_quotient_q));

as__QuoSignCorrectWhenSignedOpDiffSign: assert property((!div_unit.div_zero_q && div_unit.signed_op_q && !div_unit.same_sign_q) |-> (div_unit.quo == (~div_unit.dividend_quotient_q + div_unit.ONE)));

as__QuoEqualsDividendQuotientQWhenUnsignedOp: assert property((!div_unit.div_zero_q && !div_unit.signed_op_q) |-> (div_unit.quo == div_unit.dividend_quotient_q));

as__RmdSignCorrectWhenSignedOpNegDividend: assert property((!div_unit.div_zero_q && div_unit.signed_op_q && ((div_unit.first_dividend_q[(WIDTH-1)] & !div_unit.op_32_q) || (div_unit.first_dividend_q[31] & div_unit.op_32_q))) |-> (div_unit.rmd == (~div_unit.remanent_q + div_unit.ONE)));

as__RmdSignCorrectWhenSignedOpPosDividend: assert property((!div_unit.div_zero_q && div_unit.signed_op_q && !((div_unit.first_dividend_q[(WIDTH-1)] & !div_unit.op_32_q) || (div_unit.first_dividend_q[31] & div_unit.op_32_q))) |-> (div_unit.rmd == div_unit.remanent_q));

as__RmdEqualsRemanentQWhenUnsignedOp: assert property((!div_unit.div_zero_q && !div_unit.signed_op_q) |-> (div_unit.rmd == div_unit.remanent_q));

as__FlushClearsState_1: assert property((flush_i) |=> (!div_unit.valid_q && !busy_o && div_unit.cycles_counter == 6'd0 && !div_unit.div_zero_q && !div_unit.same_sign_q && !div_unit.op_32_q && !div_unit.signed_op_q));

as__ResultOZeroWhenNotValidO: assert property((!valid_o) |-> (result_o == {WIDTH{1'b0}}));

as__ResultOMatchesQuoAuxWhenDivValidO: assert property((valid_o && !div_unit.op_q) |-> (result_o == div_unit.quo_aux));

as__ResultOMatchesRmdAuxWhenRemValidO: assert property((valid_o && div_unit.op_q) |-> (result_o == div_unit.rmd_aux));

as__RemanentQZeroOnValidI_1: assert property((valid_i) |=> (div_unit.remanent_q == {WIDTH{1'b0}}));

as__RemanentQUpdatesWhenBusyNoValidFlush_2: assert property((busy_o && !valid_i && !flush_i) |=> (div_unit.remanent_q == $past(div_unit.remanent_out)));

as__DividendQuotientQUpdatesWhenBusyNoValidFlush_2: assert property((busy_o && !valid_i && !flush_i) |=> (div_unit.dividend_quotient_q == $past(div_unit.dividend_quotient_out)));

as__DivisorQUpdatesWhenBusyNoValidFlush_2: assert property((busy_o && !valid_i && !flush_i) |=> (div_unit.divisor_q == $past(div_unit.divisor_out)));

as__CyclesCounterClearedOnFlush: assert property((flush_i) |=> (div_unit.cycles_counter == 6'd0));

as__InternalRegsClearedOnFlush: assert property((flush_i) |=> (!div_unit.div_zero_q && !div_unit.same_sign_q && !div_unit.op_32_q && !div_unit.signed_op_q));

as__QuoAllOnesWhenDivZero_2: assert property((div_unit.div_zero_q) |-> &div_unit.quo);

as__ValidQSetAndCleared: assert property((valid_i) |=> div_unit.valid_q && (flush_i) |=> !div_unit.valid_q);

as__ControlRegsSetAndCleared: assert property((valid_i) |=> (div_unit.op_q == op_i && div_unit.op_32_q == op_32bits_i && div_unit.signed_op_q == !op_unsigned_i && div_unit.div_zero_q == div_unit.div_zero_d && div_unit.same_sign_q == div_unit.same_sign_d) && (flush_i) |=> (!div_unit.op_q && !div_unit.op_32_q && !div_unit.signed_op_q && !div_unit.div_zero_q && !div_unit.same_sign_q));

as__DataRegsSetAndUpdate: assert property((valid_i) |=> (div_unit.remanent_q == {WIDTH{1'b0}} && div_unit.dividend_quotient_q == div_unit.dividend_d && div_unit.divisor_q == div_unit.divisor_d) && (busy_o && !valid_i && !flush_i) |=> (div_unit.remanent_q == $past(div_unit.remanent_out) && div_unit.dividend_quotient_q == $past(div_unit.dividend_quotient_out) && div_unit.divisor_q == $past(div_unit.divisor_out)));

as__FirstDividendQLatchedAndCleared: assert property((valid_i) |=> (div_unit.first_dividend_q == data_rs1_i) && (flush_i) |=> (div_unit.first_dividend_q == {WIDTH{1'b0}}));

as__ValidInputSetsBusy: assert property((valid_i) |-> busy_o);

as__CyclesLoadOnValid: assert property((valid_i) |=> ((div_unit.cycles_counter == ((op_32bits_i) ? CYCLES_32[5:0] : div_unit.CYCLES_64[5:0]))));

as__ValidQSetOnValidI: assert property((valid_i) |=> div_unit.valid_q);

as__OpQSetOnValidI: assert property((valid_i) |=> div_unit.op_q == op_i);

as__Op32QSetOnValidI: assert property((valid_i) |=> div_unit.op_32_q == op_32bits_i);

as__SignedOpQSetOnValidI: assert property((valid_i) |=> div_unit.signed_op_q == !op_unsigned_i);

as__DivZeroQSetOnValidI: assert property((valid_i) |=> div_unit.div_zero_q == div_unit.div_zero_d);

as__SameSignQSetOnValidI: assert property((valid_i) |=> div_unit.same_sign_q == div_unit.same_sign_d);

as__DividendQuotientQSetOnValidI: assert property((valid_i) |=> div_unit.dividend_quotient_q == div_unit.dividend_d);

as__DivisorQSetOnValidI: assert property (valid_i && !div_unit.flush_i |=> div_unit.divisor_q == $past(div_unit.divisor_d));

as__FirstDividendQSetOnValidI: assert property((valid_i) |=> div_unit.first_dividend_q == data_rs1_i);

as__CyclesCounterLoadCorrect: assert property((valid_i) |=> div_unit.cycles_counter == ((op_32bits_i) ? div_unit.CYCLES_32[5:0] : div_unit.CYCLES_64[5:0]));

as__CyclesLoadOnValid_1: assert property((valid_i) |=> ((div_unit.cycles_counter == ((op_32bits_i) ? div_unit.CYCLES_32[5:0] : div_unit.CYCLES_64[5:0]))));

as__DivZeroDReflectsDivisorZero: assert property((valid_i) |-> div_unit.div_zero_d == (~(|data_rs2_i) || (div_unit.op_32_d && ~(|data_rs2_i[31:0]))));

as__SameSignDReflectsOperandSigns: assert property((valid_i && !div_unit.op_32_d) |-> div_unit.same_sign_d == ~(data_rs2_i[63] ^ data_rs1_i[63]));

as__SameSignDReflectsOperandSigns32: assert property((valid_i && div_unit.op_32_d) |-> div_unit.same_sign_d == ~(data_rs2_i[31] ^ data_rs1_i[31]));

as__RegsResetOnValidI: assert property((valid_i) |=> (div_unit.remanent_q == {WIDTH{1'b0}} && div_unit.dividend_quotient_q == div_unit.dividend_d && div_unit.divisor_q == div_unit.divisor_d));

as__NoValidOutputWhileBusy: assert property ((div_unit.busy_o && (div_unit.cycles_counter != 6'd1)) |-> !div_unit.valid_o);

as__FlushClearsValidO: assert property (flush_i |=> !valid_o);

as__CyclesLoadOnValid_2: assert property((valid_i) |=> (div_unit.cycles_counter == ((op_32bits_i) ? div_unit.CYCLES_32[5:0] : div_unit.CYCLES_64[5:0])));

as__BusyClearedOnFlush: assert property (flush_i |=> !div_unit.busy_o);

as__DivZeroDReflectsDivisorZeroOnValidI: assert property (valid_i |-> div_unit.div_zero_d == (~(|data_rs2_i) || (op_32bits_i && ~(|data_rs2_i[31:0]))));

as__RegsSetOnValidI: assert property((valid_i) |=> (div_unit.valid_q && div_unit.op_q == op_i && div_unit.op_32_q == op_32bits_i && div_unit.signed_op_q == !op_unsigned_i && div_unit.div_zero_q == div_unit.div_zero_d && div_unit.same_sign_q == div_unit.same_sign_d && div_unit.dividend_quotient_q == div_unit.dividend_d && div_unit.divisor_q == div_unit.divisor_d && div_unit.remanent_q == {WIDTH{1'b0}} && div_unit.first_dividend_q == data_rs1_i));

as__SameSignDReflectsOperandSignsOnValidI: assert property (valid_i |-> (div_unit.same_sign_d == ((op_32bits_i) ? ~(data_rs2_i[31] ^ data_rs1_i[31]) : ~(data_rs2_i[63] ^ data_rs1_i[63]))));

as__SameSignDReflectsOperandSigns32OnValidI: assert property((valid_i) |-> (div_unit.same_sign_d == ((div_unit.op_32bits_i) ? ~(data_rs2_i[31] ^ data_rs1_i[31]) : ~(data_rs2_i[63] ^ data_rs1_i[63]))));

as__DividendQuotientQSetOnValidI_1: assert property((valid_i) |=> (div_unit.dividend_quotient_q == div_unit.dividend_d));

as__DivisorQSetOnValidI_1: assert property((valid_i) |=> (div_unit.divisor_q == div_unit.divisor_d));

as__FirstDividendQSetOnValidI_1: assert property((valid_i) |=> (div_unit.first_dividend_q == data_rs1_i));

as__OpQSetOnValidI_1: assert property((valid_i) |=> (div_unit.op_q == op_i));

as__Op32QSetOnValidI_1: assert property ((valid_i && !flush_i) |=> (div_unit.op_32_q == $past(op_32bits_i)));

as__SignedOpQSetOnValidI_1: assert property((valid_i) |=> (div_unit.signed_op_q == !op_unsigned_i));

as__DivZeroQSetOnValidI_1: assert property((valid_i) |=> (div_unit.div_zero_q == div_unit.div_zero_d));

as__SameSignQSetOnValidI_1: assert property((valid_i) |=> (div_unit.same_sign_q == div_unit.same_sign_d));

as__ParamsLatchedOnValidI: assert property((valid_i) |=> (div_unit.op_q == op_i && div_unit.op_32_q == op_32bits_i && div_unit.signed_op_q == !op_unsigned_i));

as__DividendAuxDMatchesSignConversion: assert property (valid_i |-> (div_unit.dividend_aux_d == ((((!div_unit.op_32bits_i && div_unit.CONFIG32 == 1'b0 && data_rs1_i[div_unit.WIDTH-1] && !op_unsigned_i) || (div_unit.op_32bits_i && data_rs1_i[31] && !op_unsigned_i)) ? (~data_rs1_i + div_unit.ONE) : data_rs1_i))));

as__DivisorAuxDMatchesSignConversion: assert property (valid_i |-> (div_unit.divisor_aux_d == (((!op_unsigned_i && ((op_32bits_i ? data_rs2_i[31] : data_rs2_i[div_unit.WIDTH-1]))) ? (~data_rs2_i + div_unit.ONE) : data_rs2_i))));

as__DividendDAssignCorrect: assert property (valid_i |-> (div_unit.dividend_d == ((div_unit.CONFIG32 == 1'b1) ? div_unit.dividend_aux_d : (div_unit.op_32bits_i ? {div_unit.dividend_aux_d[31:0], 32'b0} : div_unit.dividend_aux_d))));

as__DivisorDAssignCorrect: assert property((valid_i) |-> (div_unit.divisor_d == ((div_unit.CONFIG32 == 1'b1) ? div_unit.divisor_aux_d : (div_unit.op_32_d ? {32'b0, div_unit.divisor_aux_d[31:0]} : div_unit.divisor_aux_d))));

endmodule
