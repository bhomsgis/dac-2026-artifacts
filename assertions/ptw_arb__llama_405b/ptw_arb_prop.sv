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
as__TLBResp: assert property(ptw_arb.current_state == ptw_arb.SERVING_iTLB |-> ptw_itlb_comm_o.resp == ptw_tlb_comm_i.resp);

as__TLBResp1: assert property(ptw_arb.current_state == ptw_arb.SERVING_dTLB |-> ptw_dtlb_comm_o.resp == ptw_tlb_comm_i.resp);

as__PTWStatus: assert property(ptw_itlb_comm_o.ptw_status == ptw_tlb_comm_i.ptw_status && ptw_dtlb_comm_o.ptw_status == ptw_tlb_comm_i.ptw_status);

as__InvalidateTLB: assert property(ptw_itlb_comm_o.invalidate_tlb == ptw_tlb_comm_i.invalidate_tlb && ptw_dtlb_comm_o.invalidate_tlb == ptw_tlb_comm_i.invalidate_tlb);

as__ServingiTLB1: assert property(ptw_arb.current_state == ptw_arb.SERVING_iTLB |-> ptw_arb.ptw_dtlb_comm_o.resp.valid == 1'b0);

as__ServingdTLB1: assert property(ptw_arb.current_state == ptw_arb.SERVING_dTLB |-> ptw_arb.ptw_itlb_comm_o.resp.valid == 1'b0);

as__ServingiTLB2: assert property(ptw_arb.current_state == ptw_arb.SERVING_iTLB && ptw_arb.is_req_waiting_q == 1'b1 |-> ptw_arb.tlb_ptw_comm_o == ptw_arb.itlb_req_waiting_q);

as__ServingiTLB3: assert property(ptw_arb.current_state == ptw_arb.SERVING_iTLB && ptw_arb.is_req_waiting_q == 1'b0 |-> ptw_arb.tlb_ptw_comm_o == itlb_ptw_comm_i);

as__ServingdTLB2: assert property(ptw_arb.current_state == ptw_arb.SERVING_dTLB |-> ptw_arb.tlb_ptw_comm_o == dtlb_ptw_comm_i);

as__ServingiTLBToIdle1: assert property(ptw_arb.current_state == ptw_arb.SERVING_iTLB && ptw_tlb_comm_i.resp.valid == 1'b1 |=> ptw_arb.is_req_waiting_q == 1'b0);

as__TlbRespSame: assert property(ptw_arb.current_state == ptw_arb.SERVING_iTLB |-> ptw_arb.ptw_itlb_comm_o.resp == ptw_tlb_comm_i.resp);

as__TlbRespSame1: assert property(ptw_arb.current_state == ptw_arb.SERVING_dTLB |-> ptw_arb.ptw_dtlb_comm_o.resp == ptw_tlb_comm_i.resp);

as__PTWStatusSame: assert property(ptw_arb.ptw_itlb_comm_o.ptw_status == ptw_tlb_comm_i.ptw_status && ptw_arb.ptw_dtlb_comm_o.ptw_status == ptw_tlb_comm_i.ptw_status);

as__InvalidateTLBSame: assert property(ptw_arb.ptw_itlb_comm_o.invalidate_tlb == ptw_tlb_comm_i.invalidate_tlb && ptw_arb.ptw_dtlb_comm_o.invalidate_tlb == ptw_tlb_comm_i.invalidate_tlb);

as__IdleState1: assert property(ptw_arb.current_state == ptw_arb.IDLE |-> ptw_arb.ptw_itlb_comm_o.resp.valid == 1'b0 && ptw_arb.ptw_dtlb_comm_o.resp.valid == 1'b0);

as__IdleState: assert property(ptw_arb.current_state == ptw_arb.IDLE && !itlb_ptw_comm_i.req.valid && !dtlb_ptw_comm_i.req.valid && !ptw_arb.is_req_waiting_q |-> ptw_itlb_comm_o.ptw_ready == 1'b1 && ptw_dtlb_comm_o.ptw_ready == 1'b1);

as__IdleToServingiTLB: assert property(ptw_arb.current_state == ptw_arb.IDLE && ptw_arb.is_req_waiting_q == 1'b1 |=> ptw_arb.next_state == ptw_arb.SERVING_iTLB);

as__IdleToServingdTLB: assert property(ptw_arb.current_state == ptw_arb.IDLE && dtlb_ptw_comm_i.req.valid == 1'b1 |=> ptw_arb.next_state == ptw_arb.SERVING_dTLB);

as__ServingiTLBToIdle: assert property(ptw_arb.current_state == ptw_arb.SERVING_iTLB && ptw_tlb_comm_i.resp.valid == 1'b1 && ptw_arb.is_req_waiting_q == 1'b0 && ptw_itlb_comm_o.ptw_ready == 1'b1 |=> ptw_arb.next_state == ptw_arb.IDLE);

as__ServingdTLBToIdle: assert property(ptw_arb.current_state == ptw_arb.SERVING_dTLB && ptw_tlb_comm_i.resp.valid == 1'b1 |=> ptw_arb.next_state == ptw_arb.IDLE);

as__ReqWaiting: assert property(ptw_arb.is_req_waiting_q == 1'b1 |-> ptw_arb.itlb_req_waiting_q == itlb_ptw_comm_i);

as__IdleToServingiTLB1: assert property(ptw_arb.current_state == ptw_arb.IDLE && ptw_arb.is_req_waiting_q == 1'b1 && !dtlb_ptw_comm_i.req.valid && !itlb_ptw_comm_i.req.valid |-> ptw_arb.ptw_itlb_comm_o.ptw_ready == 1'b0 && ptw_arb.ptw_dtlb_comm_o.ptw_ready == 1'b0);

as__IdleToServingdTLB1: assert property(ptw_arb.current_state == ptw_arb.IDLE && dtlb_ptw_comm_i.req.valid == 1'b1 && ptw_arb.is_req_waiting_q == 1'b0 |-> ptw_arb.tlb_ptw_comm_o == dtlb_ptw_comm_i);

as__IdleToServingiTLB2: assert property(ptw_arb.current_state == ptw_arb.IDLE && itlb_ptw_comm_i.req.valid == 1'b1 && dtlb_ptw_comm_i.req.valid == 1'b0 |-> ptw_arb.tlb_ptw_comm_o == itlb_ptw_comm_i);

as__IdleToServingdTLB2: assert property(ptw_arb.current_state == ptw_arb.IDLE && dtlb_ptw_comm_i.req.valid == 1'b1 && itlb_ptw_comm_i.req.valid == 1'b0 && ptw_arb.is_req_waiting_q == 1'b0 |-> ptw_arb.tlb_ptw_comm_o == dtlb_ptw_comm_i);

as__NoReqWaiting: assert property(ptw_arb.is_req_waiting_q == 1'b0 |-> ptw_arb.itlb_req_waiting_q == '0);

as__ReqWaiting1: assert property(ptw_arb.is_req_waiting_q == 1'b1 && dtlb_ptw_comm_i.req.valid == 1'b1 |-> ptw_arb.itlb_req_waiting_q == itlb_ptw_comm_i);

as__IdleToServingiTLB6: assert property(ptw_arb.current_state == ptw_arb.IDLE && itlb_ptw_comm_i.req.valid == 1'b1 && dtlb_ptw_comm_i.req.valid == 1'b0 |=> ptw_arb.next_state == ptw_arb.SERVING_iTLB);

as__IdleToServingdTLB6: assert property(ptw_arb.current_state == ptw_arb.IDLE && dtlb_ptw_comm_i.req.valid == 1'b1 && itlb_ptw_comm_i.req.valid == 1'b0 |=> ptw_arb.next_state == ptw_arb.SERVING_dTLB);

endmodule
