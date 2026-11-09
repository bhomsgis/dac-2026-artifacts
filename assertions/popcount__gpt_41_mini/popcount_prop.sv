module popcount_prop
 #(
		parameter ASSERT_INPUTS = 0,
		parameter logic                         ADDR_SUBS       = 1'b1,                        //! HIGH(1'b1): Addition Tree Reduction, LOW(1'b0): Subtraction Tree Reduction.
		parameter                               N_PORTS         = 8,                           //! Initial number of operands to be reduced.
		parameter                               REGS_WIDTH      = 8,                           //! Number of bits for each comparison port register.
		parameter  bit [$clog2(popcount.N_PORTS)-1:0]    REG_PATTERN     = {1'b0,1'b0,1'b0},
		localparam type INS_REGS_TYPE   = logic[REGS_WIDTH-1:0],
		localparam      OUTPUT_SIZE     = ((2**$clog2(popcount.N_PORTS))==popcount.N_PORTS) ? $clog2(popcount.N_PORTS)-1 : $clog2(popcount.N_PORTS)-2
)(
		/* verilator lint_off UNUSED */
		input logic                                 clk_i,           //! System Clock.
		input logic                                 rstn_i,          //! Asynchronous reset active low.
		/* verilator lint_on UNUSED */
		
		input  INS_REGS_TYPE [popcount.N_PORTS-1:0]          operands_regs_i, //! Array of input operands.
		input  logic [REGS_WIDTH + OUTPUT_SIZE:0]   result_value_o   //! result is size + 1 bit. result size increments proportional to each layer of the tree. //output
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
as__PopcountAddNoReg: assert property((ADDR_SUBS && popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0) |-> result_value_o == $countones(operands_regs_i));

as__PopcountSubNoReg: assert property((!ADDR_SUBS && popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0) |-> result_value_o == $countones(operands_regs_i[0 +: popcount.N_PORTS/2]) - $countones(operands_regs_i[popcount.N_PORTS/2 +: popcount.N_PORTS/2]));

as__PopcountRegOutput: assert property((popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 1) |=> result_value_o == $past(popcount.result_value_d));

as__PopcountAddLayer: assert property((ADDR_SUBS) |-> popcount.result_value_d == popcount.lsport + popcount.msport);

as__PopcountSubLayer: assert property((!ADDR_SUBS) |-> popcount.result_value_d == popcount.lsport - popcount.msport);

as__PopcountZeroOperands: assert property((!(|operands_regs_i)) |-> result_value_o == 0);

as__PopcountAllOnesAdd: assert property((ADDR_SUBS && (&operands_regs_i)) |-> result_value_o == popcount.N_PORTS);

as__PopcountAllOnesSub: assert property((!ADDR_SUBS && (&operands_regs_i)) |-> result_value_o == 0);

as__PopcountRegOutputMatch: assert property((popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1]) |=> result_value_o == popcount.result_value_q);

as__PopcountNoRegOutputMatch: assert property((!popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1]) |-> result_value_o == popcount.result_value_d);

as__PopcountLsportCount: assert property(popcount.lsport == $countones(operands_regs_i[0 +: popcount.N_PORTS/2]));

as__PopcountMsportCount: assert property(popcount.msport == $countones(operands_regs_i[popcount.N_PORTS/2 +: popcount.N_PORTS/2]));

as__PopcountLsportZero: assert property((!(|operands_regs_i[0 +: popcount.N_PORTS/2])) |-> popcount.lsport == 0);

as__PopcountMsportZero: assert property((!(|operands_regs_i[popcount.N_PORTS/2 +: popcount.N_PORTS/2])) |-> popcount.msport == 0);

as__PopcountEqualHalvesSub: assert property((!ADDR_SUBS && (operands_regs_i[0 +: popcount.N_PORTS/2] == operands_regs_i[popcount.N_PORTS/2 +: popcount.N_PORTS/2])) |-> result_value_o == 0);

as__PopcountSumHalvesAdd: assert property((ADDR_SUBS) |-> popcount.lsport + popcount.msport == $countones(operands_regs_i));

as__PopcountSubNoRegResult: assert property((!ADDR_SUBS && popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0) |-> result_value_o == popcount.lsport - popcount.msport);

as__PopcountAddNonNegative: assert property((ADDR_SUBS) |-> result_value_o >= 0);

as__PopcountAddMaxValue: assert property((ADDR_SUBS) |-> result_value_o <= popcount.N_PORTS);

as__PopcountSubMinValue: assert property((!ADDR_SUBS) |-> result_value_o >= -popcount.N_PORTS);

as__PopcountAddRegPatternZero: assert property((ADDR_SUBS && (popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0)) |-> result_value_o == popcount.lsport + popcount.msport);

as__PopcountSubRegPatternZero: assert property((!ADDR_SUBS && (popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0)) |-> result_value_o == popcount.lsport - popcount.msport);

as__PopcountZeroOperandsLsportMsport: assert property((!(|operands_regs_i)) |-> (popcount.lsport == 0 && popcount.msport == 0));

as__PopcountZeroOperandsLsportMsportZero: assert property((!(|operands_regs_i)) |-> (popcount.lsport == 0 && popcount.msport == 0));

as__PopcountZeroOperandsLsportMsportZeroCheck: assert property((!(|operands_regs_i)) |-> (popcount.lsport == 0 && popcount.msport == 0));

as__PopcountZeroOperandsResultZero: assert property((!(|operands_regs_i)) |-> result_value_o == 0);

as__PopcountAllOnesLsportMsportSumCheck: assert property((ADDR_SUBS && (&operands_regs_i)) |-> (popcount.lsport + popcount.msport == popcount.N_PORTS));

as__PopcountAllOnesSubEqualHalvesCheck: assert property((!ADDR_SUBS && (&operands_regs_i)) |-> (popcount.lsport == popcount.msport));

as__PopcountZeroOperandsNoRegCheck: assert property((!(|operands_regs_i) && (popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0)) |-> result_value_o == 0);

as__PopcountLsportMsportCountConsistencyCheck: assert property(popcount.lsport == $countones(operands_regs_i[0 +: popcount.N_PORTS/2]) && popcount.msport == $countones(operands_regs_i[popcount.N_PORTS/2 +: popcount.N_PORTS/2]));

as__PopcountAddResultRangeCheck: assert property((ADDR_SUBS) |-> (result_value_o >= 0 && result_value_o <= popcount.N_PORTS));

as__PopcountSubResultRangeCheck: assert property((!ADDR_SUBS) |-> (result_value_o >= -popcount.N_PORTS && result_value_o <= popcount.N_PORTS));

as__PopcountAddResultNextCycleCheck: assert property((ADDR_SUBS) |=> (result_value_o == $past(popcount.lsport) + $past(popcount.msport)));

as__PopcountSubResultNextCycleCheck: assert property((!ADDR_SUBS) |=> (result_value_o == $past(popcount.lsport) - $past(popcount.msport)));

as__PopcountLsportMsportRangeCheck: assert property((popcount.lsport >= 0 && popcount.lsport <= popcount.N_PORTS/2) && (popcount.msport >= 0 && popcount.msport <= popcount.N_PORTS/2));

as__PopcountZeroOperandsLsportMsportZeroCheck2: assert property((!(|operands_regs_i)) |-> (popcount.lsport == 0 && popcount.msport == 0));

as__PopcountAddResultNextCycleCheck2: assert property((ADDR_SUBS) |=> result_value_o == $past(popcount.lsport) + $past(popcount.msport));

as__PopcountSubResultNextCycleCheck2: assert property((!ADDR_SUBS) |=> result_value_o == $past(popcount.lsport) - $past(popcount.msport));

as__PopcountZeroOperandsLsportMsportZeroCheck3: assert property((!(|operands_regs_i)) |-> (popcount.lsport == 0 && popcount.msport == 0));

as__PopcountAddRegOutputSum: assert property((ADDR_SUBS && popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 1) |=> result_value_o == $past(popcount.lsport) + $past(popcount.msport));

as__PopcountSubRegOutputDiff: assert property((!ADDR_SUBS && popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 1) |=> result_value_o == $past(popcount.lsport) - $past(popcount.msport));

as__PopcountAddResultValueD: assert property((ADDR_SUBS && popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 1) |-> popcount.result_value_d == popcount.lsport + popcount.msport);

as__PopcountSubResultValueD: assert property((!ADDR_SUBS && popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 1) |-> popcount.result_value_d == popcount.lsport - popcount.msport);

as__PopcountLsportAllOnes: assert property((&operands_regs_i[0 +: popcount.N_PORTS/2]) |-> popcount.lsport == popcount.N_PORTS/2);

as__PopcountMsportAllOnes: assert property((&operands_regs_i[popcount.N_PORTS/2 +: popcount.N_PORTS/2]) |-> popcount.msport == popcount.N_PORTS/2);

as__PopcountRegOutputMatchQ: assert property((popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 1) |=> result_value_o == popcount.result_value_q);

as__PopcountNoRegOutputMatchD: assert property((popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0) |-> result_value_o == popcount.result_value_d);

as__PopcountLsportAllOnesOperands: assert property((&operands_regs_i[0 +: popcount.N_PORTS/2]) |-> popcount.lsport == popcount.N_PORTS/2);

as__PopcountMsportAllOnesOperands: assert property((&operands_regs_i[popcount.N_PORTS/2 +: popcount.N_PORTS/2]) |-> popcount.msport == popcount.N_PORTS/2);

as__PopcountZeroOperandsResultZeroCheck: assert property((!(|operands_regs_i)) |-> result_value_o == 0);

as__PopcountAddNoRegRegPatternZero: assert property((ADDR_SUBS && popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0) |-> result_value_o == popcount.lsport + popcount.msport);

as__PopcountAddNoRegOutputSumNextCycle: assert property((ADDR_SUBS && popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0) |=> result_value_o == $past(popcount.lsport) + $past(popcount.msport));

as__PopcountSubNoRegOutputDiffNextCycle: assert property((!ADDR_SUBS && popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0) |=> result_value_o == $past(popcount.lsport) - $past(popcount.msport));

as__PopcountZeroOperandsLsportMsportZeroCheck4: assert property((!(|operands_regs_i)) |-> (popcount.lsport == 0 && popcount.msport == 0));

as__PopcountAddNoRegResultValueD: assert property((ADDR_SUBS && (popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0)) |-> popcount.result_value_d == popcount.lsport + popcount.msport);

as__PopcountSubNoRegResultValueD: assert property((!ADDR_SUBS && (popcount.REG_PATTERN[$clog2(popcount.N_PORTS)-1] == 0)) |-> popcount.result_value_d == popcount.lsport - popcount.msport);

as__PopcountZeroOperandsResultCheck: assert property((!(|operands_regs_i)) |-> result_value_o == 0);

as__PopcountLsportAllOnesCheck: assert property((&operands_regs_i[0 +: popcount.N_PORTS/2]) |-> popcount.lsport == popcount.N_PORTS/2);

as__PopcountMsportAllOnesCheck: assert property((&operands_regs_i[popcount.N_PORTS/2 +: popcount.N_PORTS/2]) |-> popcount.msport == popcount.N_PORTS/2);

endmodule
