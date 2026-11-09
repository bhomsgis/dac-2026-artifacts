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
as__iTLBResp: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) && (ptw_tlb_comm_i.resp.valid) |-> (ptw_itlb_comm_o.resp == ptw_tlb_comm_i.resp));

as__dTLBResp: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) && (ptw_tlb_comm_i.resp.valid) |-> (ptw_dtlb_comm_o.resp == ptw_tlb_comm_i.resp));

as__ReqWaiting1: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (dtlb_ptw_comm_i.req.valid) && (itlb_ptw_comm_i.req.valid) |=> (ptw_arb.is_req_waiting_q == 1'b1));

as__ReqWaiting2: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) && (ptw_tlb_comm_i.resp.valid) |=> (ptw_arb.is_req_waiting_q == 1'b0));

as__iTLBRespValid: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_itlb_comm_o.resp.valid == ptw_tlb_comm_i.resp.valid));

as__dTLBRespValid: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_dtlb_comm_o.resp.valid == ptw_tlb_comm_i.resp.valid));

as__iTLBError: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_itlb_comm_o.resp.error == ptw_tlb_comm_i.resp.error));

as__dTLBError: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_dtlb_comm_o.resp.error == ptw_tlb_comm_i.resp.error));

as__iTLBPTE: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_itlb_comm_o.resp.pte == ptw_tlb_comm_i.resp.pte));

as__dTLBPTE: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_dtlb_comm_o.resp.pte == ptw_tlb_comm_i.resp.pte));

as__iTLBLevel: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_itlb_comm_o.resp.level == ptw_tlb_comm_i.resp.level));

as__dTLBLevel: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_dtlb_comm_o.resp.level == ptw_tlb_comm_i.resp.level));

as__iTLBStatus: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_itlb_comm_o.ptw_status == ptw_tlb_comm_i.ptw_status));

as__dTLBStatus: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_dtlb_comm_o.ptw_status == ptw_tlb_comm_i.ptw_status));

as__iTLBInvalidate: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_itlb_comm_o.invalidate_tlb == ptw_tlb_comm_i.invalidate_tlb));

as__dTLBInvalidate: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_dtlb_comm_o.invalidate_tlb == ptw_tlb_comm_i.invalidate_tlb));

as__iTLBReady1: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_itlb_comm_o.ptw_ready == 1'b0));

as__dTLBReady1: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_dtlb_comm_o.ptw_ready == 1'b0));

as__TLBComm1: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (tlb_ptw_comm_o == dtlb_ptw_comm_i));

as__TLBComm3: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_arb.tlb_ptw_comm_o == dtlb_ptw_comm_i));

as__dTLBReqValid: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_arb.tlb_ptw_comm_o.req.valid == dtlb_ptw_comm_i.req.valid));

as__dTLBReqASID: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) |-> (ptw_arb.tlb_ptw_comm_o.req.asid == dtlb_ptw_comm_i.req.asid));

as__ReqWaiting5: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (dtlb_ptw_comm_i.req.valid) && (itlb_ptw_comm_i.req.valid) && (!ptw_arb.is_req_waiting_q) |=> (ptw_arb.is_req_waiting_q == 1'b1));

as__ReqWaiting8: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (dtlb_ptw_comm_i.req.valid) && (itlb_ptw_comm_i.req.valid) && (ptw_arb.is_req_waiting_q) |=> (ptw_arb.is_req_waiting_q == 1'b1));

as__ReqWaiting: assert property(ptw_arb.is_req_waiting_q |-> (ptw_arb.current_state == ptw_arb.IDLE || ptw_arb.current_state == ptw_arb.SERVING_iTLB || (ptw_arb.current_state == ptw_arb.SERVING_dTLB && ptw_arb.itlb_req_waiting_q.req.valid)));

as__iTLBReady: assert property((ptw_arb.current_state == ptw_arb.IDLE && !(ptw_arb.is_req_waiting_q)) |-> (ptw_itlb_comm_o.ptw_ready == 1'b1));

as__dTLBReady: assert property((ptw_arb.current_state == ptw_arb.IDLE && !(ptw_arb.is_req_waiting_q)) |-> (ptw_dtlb_comm_o.ptw_ready == 1'b1));

as__StateTransition: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (dtlb_ptw_comm_i.req.valid) && (itlb_ptw_comm_i.req.valid) |=> (ptw_arb.next_state == ptw_arb.SERVING_dTLB));

as__StateTransition1: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (dtlb_ptw_comm_i.req.valid) && (!itlb_ptw_comm_i.req.valid) |=> (ptw_arb.next_state == ptw_arb.SERVING_dTLB));

as__StateTransition2: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (!dtlb_ptw_comm_i.req.valid) && (itlb_ptw_comm_i.req.valid) |=> (ptw_arb.next_state == ptw_arb.SERVING_iTLB));

as__StateTransition3: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) && (ptw_tlb_comm_i.resp.valid) |=> (ptw_arb.next_state == ptw_arb.IDLE) && ($past(ptw_arb.is_req_waiting_q) == 1'b1) |=> (ptw_arb.is_req_waiting_q == 1'b0));

as__StateTransition4: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) && (ptw_tlb_comm_i.resp.valid) |=> (ptw_arb.next_state == ptw_arb.IDLE));

as__TLBComm: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (tlb_ptw_comm_o == (ptw_arb.is_req_waiting_q) ? ptw_arb.itlb_req_waiting_q : itlb_ptw_comm_i));

as__ReqWaiting3: assert property(ptw_arb.is_req_waiting_q |-> (ptw_arb.current_state != ptw_arb.IDLE || ptw_arb.current_state == ptw_arb.SERVING_iTLB || ptw_arb.current_state == ptw_arb.SERVING_dTLB || (ptw_arb.current_state == ptw_arb.IDLE && ptw_arb.itlb_req_waiting_q.req.valid)));

as__StateTransition5: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (!dtlb_ptw_comm_i.req.valid) && (!itlb_ptw_comm_i.req.valid) |=> (ptw_arb.next_state == ptw_arb.IDLE));

as__StateTransition8: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (dtlb_ptw_comm_i.req.valid) && (itlb_ptw_comm_i.req.valid) && (ptw_arb.is_req_waiting_q) |=> (ptw_arb.next_state == ptw_arb.SERVING_iTLB));

as__TLBComm2: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_arb.tlb_ptw_comm_o == (ptw_arb.is_req_waiting_q) ? ptw_arb.itlb_req_waiting_q : itlb_ptw_comm_i));

as__iTLBReqValid: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_arb.tlb_ptw_comm_o.req.valid == (ptw_arb.is_req_waiting_q) ? ptw_arb.itlb_req_waiting_q.req.valid : itlb_ptw_comm_i.req.valid));

as__iTLBReqASID: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) |-> (ptw_arb.tlb_ptw_comm_o.req.asid == (ptw_arb.is_req_waiting_q) ? ptw_arb.itlb_req_waiting_q.req.asid : itlb_ptw_comm_i.req.asid));

as__ReqWaiting4: assert property((ptw_arb.is_req_waiting_q) |-> (ptw_arb.current_state == ptw_arb.SERVING_iTLB || ptw_arb.current_state == ptw_arb.IDLE || ptw_arb.current_state == ptw_arb.SERVING_dTLB));

as__StateTransition6: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (dtlb_ptw_comm_i.req.valid) && (!itlb_ptw_comm_i.req.valid) && (!ptw_arb.is_req_waiting_q) |=> (ptw_arb.next_state == ptw_arb.SERVING_dTLB));

as__StateTransition7: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (!dtlb_ptw_comm_i.req.valid) && (itlb_ptw_comm_i.req.valid) && (!ptw_arb.is_req_waiting_q) |=> (ptw_arb.next_state == ptw_arb.SERVING_iTLB));

as__StateTransition9: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (dtlb_ptw_comm_i.req.valid) && (itlb_ptw_comm_i.req.valid) && (!ptw_arb.is_req_waiting_q) |=> (ptw_arb.next_state == ptw_arb.SERVING_dTLB));

as__StateTransition10: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) && (!ptw_tlb_comm_i.resp.valid) |=> (ptw_arb.next_state == ptw_arb.SERVING_iTLB));

as__StateTransition11: assert property((ptw_arb.current_state == ptw_arb.SERVING_dTLB) && (!ptw_tlb_comm_i.resp.valid) |=> (ptw_arb.next_state == ptw_arb.SERVING_dTLB) || (ptw_arb.next_state == ptw_arb.IDLE));

as__ReqWaiting6: assert property((ptw_arb.current_state == ptw_arb.SERVING_iTLB) && (ptw_tlb_comm_i.resp.valid) |=> (ptw_arb.is_req_waiting_q == $past(ptw_arb.is_req_waiting_d)));

as__ReqWaiting7: assert property((ptw_arb.is_req_waiting_q) |-> (ptw_arb.current_state != ptw_arb.SERVING_dTLB));

as__StateTransition14: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (!dtlb_ptw_comm_i.req.valid) && (itlb_ptw_comm_i.req.valid) && (ptw_arb.is_req_waiting_q) |=> (ptw_arb.next_state == ptw_arb.SERVING_iTLB));

as__StateTransition15: assert property((ptw_arb.current_state == ptw_arb.IDLE) && (dtlb_ptw_comm_i.req.valid) && (!itlb_ptw_comm_i.req.valid) && (ptw_arb.is_req_waiting_q) |=> (ptw_arb.next_state == ptw_arb.SERVING_dTLB));

endmodule
