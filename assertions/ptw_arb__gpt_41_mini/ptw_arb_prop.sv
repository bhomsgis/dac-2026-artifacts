module ptw_arb_prop

// Automatically detected package imports
import mmu_pkg::*;

#(
		parameter ASSERT_INPUTS = 0
)(
		input logic clk_i,
		input logic rstn_i,
		
		// iTLB & dTLB interfaces
		input tlb_ptw_comm_t itlb_ptw_comm_i, 
		input tlb_ptw_comm_t dtlb_ptw_comm_i,
		input  ptw_tlb_comm_t ptw_itlb_comm_o,  //output
		input  ptw_tlb_comm_t ptw_dtlb_comm_o, //output
		
		// PTW interface
		input ptw_tlb_comm_t ptw_tlb_comm_i,
		input  tlb_ptw_comm_t tlb_ptw_comm_o //output
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
as__IdleReadyBothValid: assert property((ptw_arb.current_state == ptw_arb.IDLE && dtlb_ptw_comm_i.req.valid && itlb_ptw_comm_i.req.valid) |-> (ptw_arb.is_req_waiting_d == 1'b1 && ptw_arb.itlb_req_waiting_d == itlb_ptw_comm_i && tlb_ptw_comm_o == dtlb_ptw_comm_i && ptw_arb.next_state == ptw_arb.SERVING_dTLB));

as__IdleReadyDTLBOnly: assert property((ptw_arb.current_state == ptw_arb.IDLE && dtlb_ptw_comm_i.req.valid && !itlb_ptw_comm_i.req.valid && !ptw_arb.is_req_waiting_q) |-> (tlb_ptw_comm_o == dtlb_ptw_comm_i && ptw_arb.next_state == ptw_arb.SERVING_dTLB));

as__IdleReadyITLBOnly: assert property((ptw_arb.current_state == ptw_arb.IDLE && itlb_ptw_comm_i.req.valid && !dtlb_ptw_comm_i.req.valid && !ptw_arb.is_req_waiting_q) |-> (tlb_ptw_comm_o == itlb_ptw_comm_i && ptw_arb.next_state == ptw_arb.SERVING_iTLB));

as__IdleReadyNone: assert property((ptw_arb.current_state == ptw_arb.IDLE && !dtlb_ptw_comm_i.req.valid && !itlb_ptw_comm_i.req.valid && !ptw_arb.is_req_waiting_q) |-> (tlb_ptw_comm_o == '0 && ptw_arb.next_state == ptw_arb.IDLE));

as__ServingITLBResponseInvalid: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB && !ptw_tlb_comm_i.resp.valid) |-> (ptw_arb.next_state == ptw_arb.SERVING_iTLB));

as__ServingITLBRespOutput: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_itlb_comm_o.resp == ptw_tlb_comm_i.resp && ptw_dtlb_comm_o.resp == '0));

as__ServingITLBReqOutput: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (tlb_ptw_comm_o == ((ptw_arb.is_req_waiting_q) ? ptw_arb.itlb_req_waiting_q : itlb_ptw_comm_i)));

as__ServingDTLBResponseValid: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB && ptw_tlb_comm_i.resp.valid) |-> (ptw_arb.next_state == ptw_arb.IDLE));

as__ServingDTLBResponseInvalid: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB && !ptw_tlb_comm_i.resp.valid) |-> (ptw_arb.next_state == ptw_arb.SERVING_dTLB));

as__ServingDTLBRespOutput: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_itlb_comm_o.resp == '0 && ptw_dtlb_comm_o.resp == ptw_tlb_comm_i.resp));

as__ServingDTLBReqOutput: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (tlb_ptw_comm_o == dtlb_ptw_comm_i));

as__PTWStatusForwarding: assert property((1) |-> (ptw_itlb_comm_o.ptw_status == ptw_tlb_comm_i.ptw_status && ptw_dtlb_comm_o.ptw_status == ptw_tlb_comm_i.ptw_status));

as__InvalidateTLBForwarding: assert property((1) |-> (ptw_itlb_comm_o.invalidate_tlb == ptw_tlb_comm_i.invalidate_tlb && ptw_dtlb_comm_o.invalidate_tlb == ptw_tlb_comm_i.invalidate_tlb));

as__NotIdlePTWReadyNone: assert property((ptw_arb.current_state != ptw_arb.IDLE) |-> (ptw_itlb_comm_o.ptw_ready == 1'b0 && ptw_dtlb_comm_o.ptw_ready == 1'b0));

as__BothReqValidSetsWaiting: assert property((ptw_arb.current_state == ptw_arb.IDLE && dtlb_ptw_comm_i.req.valid && itlb_ptw_comm_i.req.valid) |-> (ptw_arb.is_req_waiting_d == 1'b1 && ptw_arb.itlb_req_waiting_d == itlb_ptw_comm_i));

as__PTWReadyOnlyInIdle: assert property((ptw_itlb_comm_o.ptw_ready == 1'b1 && ptw_dtlb_comm_o.ptw_ready == 1'b1) |-> (ptw_arb.current_state == ptw_arb.IDLE));

as__TLBPTWCommOZeroWhenIdleNoReq: assert property((ptw_arb.current_state == ptw_arb.IDLE && !dtlb_ptw_comm_i.req.valid && !itlb_ptw_comm_i.req.valid && !ptw_arb.is_req_waiting_q) |-> (tlb_ptw_comm_o == '0));

as__BothReqValidDTLBServedITLBWaiting: assert property((ptw_arb.current_state == ptw_arb.IDLE && dtlb_ptw_comm_i.req.valid && itlb_ptw_comm_i.req.valid) |-> (ptw_arb.itlb_req_waiting_d == itlb_ptw_comm_i && tlb_ptw_comm_o == dtlb_ptw_comm_i && ptw_arb.next_state == ptw_arb.SERVING_dTLB));

as__ServingITLBRespInvalidKeepsWaiting: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB && !ptw_tlb_comm_i.resp.valid) |-> (ptw_arb.is_req_waiting_d == ptw_arb.is_req_waiting_q));

as__ITLBRespZeroWhenServingDTLB: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_itlb_comm_o.resp == '0));

as__DTLBRespZeroWhenServingITLB: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_dtlb_comm_o.resp == '0));

as__TLBPTWCommOIsWaitingReqWhenServingITLB: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB && ptw_arb.is_req_waiting_q) |-> (tlb_ptw_comm_o == ptw_arb.itlb_req_waiting_q));

as__TLBPTWCommOIsITLBReqWhenServingITLBNoWaiting: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB && !ptw_arb.is_req_waiting_q) |-> (tlb_ptw_comm_o == itlb_ptw_comm_i));

as__PTWStatusForwardingAlways: assert property((1) |-> (ptw_itlb_comm_o.ptw_status == ptw_tlb_comm_i.ptw_status));

as__PTWStatusForwardingDTLBAlways: assert property((1) |-> (ptw_dtlb_comm_o.ptw_status == ptw_tlb_comm_i.ptw_status));

as__InvalidateTLBForwardingITLBAlways: assert property((1) |-> (ptw_itlb_comm_o.invalidate_tlb == ptw_tlb_comm_i.invalidate_tlb));

as__InvalidateTLBForwardingDTLBAlways: assert property((1) |-> (ptw_dtlb_comm_o.invalidate_tlb == ptw_tlb_comm_i.invalidate_tlb));

as__ServingDTLBRespOutputCorrect: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_dtlb_comm_o.resp == ptw_tlb_comm_i.resp && ptw_itlb_comm_o.resp == '0));

as__IdleReadyWaiting: assert property((ptw_arb.current_state == ptw_arb.IDLE && ptw_arb.is_req_waiting_q) |-> (ptw_itlb_comm_o.ptw_ready == 1'b0 && ptw_dtlb_comm_o.ptw_ready == 1'b0 && ptw_arb.next_state == ptw_arb.SERVING_iTLB));

as__ServingITLBResponseValid: assert property ((ptw_arb.current_state == ptw_arb.SERVING_iTLB && ptw_arb.ptw_tlb_comm_i.resp.valid) |-> (ptw_arb.next_state == ptw_arb.IDLE && ptw_arb.is_req_waiting_d == 1'b0));

as__IdleReadyPTWReadyBoth: assert property((ptw_arb.current_state == ptw_arb.IDLE && !ptw_arb.is_req_waiting_q && !ptw_arb.dtlb_ptw_comm_i.req.valid && !ptw_arb.itlb_ptw_comm_i.req.valid) |-> (&{ptw_arb.ptw_itlb_comm_o.ptw_ready, ptw_arb.ptw_dtlb_comm_o.ptw_ready}));

as__IsReqWaitingClearedOnlyOnITLBRespValid: assert property((ptw_arb.is_req_waiting_q == 1'b1 && ptw_arb.current_state == ptw_arb.SERVING_iTLB) |=> ($past(ptw_tlb_comm_i.resp.valid) |-> (ptw_arb.is_req_waiting_q == 1'b0)));

as__ReqWaitingLeadsToServingITLB: assert property((ptw_arb.is_req_waiting_q) |-> (ptw_arb.next_state == ptw_arb.SERVING_iTLB));

as__ServingITLBRespValidClearsWaiting: assert property ((ptw_arb.current_state == ptw_arb.SERVING_iTLB && ptw_tlb_comm_i.resp.valid) |=> (ptw_arb.is_req_waiting_q == 1'b0));

as__IsReqWaitingSetOnlyWhenBothReqValid: assert property((ptw_arb.current_state == ptw_arb.IDLE) |-> ((dtlb_ptw_comm_i.req.valid && itlb_ptw_comm_i.req.valid) == ptw_arb.is_req_waiting_d));

as__IsReqWaitingClearedOnlyOnValidITLBResp: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB && ptw_arb.is_req_waiting_q) |=> ((ptw_tlb_comm_i.resp.valid) |-> (ptw_arb.is_req_waiting_d == 1'b0)));

as__ServingITLBRespInvalidKeepsWaitingNext: assert property ((ptw_arb.current_state == ptw_arb.SERVING_iTLB && !ptw_arb.ptw_tlb_comm_i.resp.valid) |=> (ptw_arb.is_req_waiting_q == $past(ptw_arb.is_req_waiting_d)));

endmodule
