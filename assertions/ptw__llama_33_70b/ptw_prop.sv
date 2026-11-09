module ptw_prop

// Automatically detected package imports
import riscv_pkg::*;
import mmu_pkg::*;

#(
		parameter ASSERT_INPUTS = 0
)(
		input logic clk_i,
		input logic rstn_i,
		
		// iTLB request-response
		input tlb_ptw_comm_t itlb_ptw_comm_i, 
		input  ptw_tlb_comm_t ptw_itlb_comm_o, //output
		
		// dTLB request-response
		input tlb_ptw_comm_t dtlb_ptw_comm_i,
		input  ptw_tlb_comm_t ptw_dtlb_comm_o, //output
		
		// dmem request-response
		input dmem_ptw_comm_t dmem_ptw_comm_i,
		input  ptw_dmem_comm_t ptw_dmem_comm_o, //output
		
		// csr interface
		input csr_ptw_comm_t csr_ptw_comm_i,
		
		// pmu interface
		input  logic pmu_ptw_hit_o, //output
		input  logic pmu_ptw_miss_o //output
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
as__ptwReady: assert property(ptw.ptw_ready |-> (ptw.current_state == ptw.S_READY));

as__ptwNotReady: assert property(!ptw.ptw_ready |-> (ptw.current_state != ptw.S_READY));

as__dmemReqValid: assert property(ptw_dmem_comm_o.req.valid |-> (ptw.current_state == ptw.S_REQ));

as__fsmState: assert property((ptw.current_state == ptw.S_READY) |-> (ptw.next_state == ptw.S_REQ || ptw.next_state == ptw.S_READY));

as__fsmStateSReq: assert property((ptw.current_state == ptw.S_REQ) |-> (ptw.next_state == ptw.S_WAIT || ptw.next_state == ptw.S_REQ));

as__fsmStateSDone: assert property((ptw.current_state == ptw.S_DONE) |-> (ptw.next_state == ptw.S_READY));

as__fsmStateSError: assert property((ptw.current_state == ptw.S_ERROR) |-> (ptw.next_state == ptw.S_READY));

as__countQ: assert property((ptw.current_state == ptw.S_REQ) |=> (ptw.count_q == $past(ptw.count_d)));

as__pmuPtwhitO: assert property(pmu_ptw_hit_o |-> (ptw.current_state == ptw.S_REQ && ptw.pte_cache_hit));

as__respErr: assert property(ptw.resp_err |-> (ptw.current_state == ptw.S_ERROR));

as__respVal: assert property(ptw.resp_val |-> (ptw.current_state == ptw.S_DONE || ptw.current_state == ptw.S_ERROR));

as__respPpn: assert property(ptw.r_resp_ppn == {{(64-(SIZE_VADDR-11)){1'b0}}, ptw.pte_addr[SIZE_VADDR:12]});

as__vpnIdx: assert property(ptw.vpn_idx == ptw.vpn_req[ptw.count_q]);

as__pteAddr: assert property(ptw.pte_addr == ptw.aux_pte_addr[SIZE_VADDR:0]);

as__ptwDmemCommOReqPhys: assert property(ptw_dmem_comm_o.req.phys == 1'b1);

as__ptwDmemCommOReqCmd: assert property(ptw_dmem_comm_o.req.cmd == ptw.M_XRD);

as__ptwDmemCommOReqTyp: assert property(ptw_dmem_comm_o.req.typ == ptw.MT_D);

as__ptwDmemCommOReqAddr: assert property(ptw_dmem_comm_o.req.addr == ptw.pte_addr);

as__ptwDmemCommOReqKill: assert property(ptw_dmem_comm_o.req.kill == 1'b0);

as__ptwDmemCommOReqPhysNext: assert property(ptw_dmem_comm_o.req.phys |=> 1'b1);

as__ptwDmemCommOReqCmdNext: assert property(ptw_dmem_comm_o.req.cmd |=> ptw.M_XRD);

as__ptwDmemCommOReqTypNext: assert property(ptw_dmem_comm_o.req.typ |=> ptw.MT_D);

as__ptwDmemCommOReqKillNext: assert property(ptw_dmem_comm_o.req.kill |=> 1'b0);

as__pteCacheData: assert property(ptw.pte_cache_hit |-> (ptw.pte_cache_data == ptw.ptecache_entry[ptw.hit_idx].data));

as__pteCacheEntry: assert property(ptw.pte_cache_hit |-> (ptw.ptecache_entry[ptw.hit_idx].tags == ptw.pte_addr));

as__ptecacheEntryInvalid: assert property(!ptw.ptecache_entry[ptw.hit_idx].valid |-> (!ptw.pte_cache_hit));

as__reqValid: assert property(tlb_ptw_comm_i.req.valid |-> (ptw.next_state == ptw.S_REQ));

as__reqNotValid: assert property(!tlb_ptw_comm_i.req.valid |-> (ptw.next_state == ptw.S_READY));

as__pteCacheHit: assert property(ptw.pte_cache_hit |-> (ptw_dmem_comm_o.req.valid == 1'b0));

as__pteCacheMiss: assert property(!ptw.pte_cache_hit |-> (ptw_dmem_comm_o.req.valid == 1'b1));

as__permOk: assert property(ptw.perm_ok |-> ((ptw.prv_req[0] && (ptw.is_pte_sx || ptw.is_pte_ux)) || (!ptw.prv_req[0] && (ptw.is_pte_ux))));

as__permNotOk: assert property(!ptw.perm_ok |-> ((!ptw.prv_req[0] && !ptw.is_pte_ux) || (ptw.prv_req[0] && !(ptw.is_pte_sx || ptw.is_pte_ux))));

as__dmemReqNotValid: assert property(!ptw_dmem_comm_o.req.valid |-> (ptw.current_state != ptw.S_REQ || (ptw.current_state == ptw.S_REQ && ptw.pte_cache_hit)));

as__fsmStateSWait: assert property((ptw.current_state == ptw.S_WAIT) |-> (ptw.next_state == ptw.S_ERROR || ptw.next_state == ptw.S_DONE || ptw.next_state == ptw.S_WAIT));

as__countD: assert property((ptw.current_state == ptw.S_REQ) |=> (ptw.count_d == ptw.count[1:0]));

as__pmuPtwhitONot: assert property(!pmu_ptw_hit_o |-> (ptw.current_state != ptw.S_REQ || !ptw.pte_cache_hit || ptw.count_q == $unsigned(LEVELS-1)));

as__respPpnLvl: assert property(ptw.resp_ppn_lvl[ptw.count_q] == ptw.r_resp_ppn[PPN_SIZE-1:0]);

as__fsmNextState: assert property((ptw.current_state == ptw.S_READY) |=> (ptw.next_state == ptw.S_REQ || ptw.next_state == ptw.S_READY));

as__fsmNextStateSReq: assert property((ptw.current_state == ptw.S_REQ) |=> (ptw.next_state == ptw.S_WAIT || ptw.next_state == ptw.S_REQ || ptw.next_state == ptw.S_ERROR || ptw.next_state == ptw.S_DONE));

as__fsmNextStateSWait: assert property((ptw.current_state == ptw.S_WAIT) |=> (ptw.next_state == ptw.S_ERROR || ptw.next_state == ptw.S_DONE || ptw.next_state == ptw.S_WAIT));

as__fsmNextStateSDone: assert property((ptw.current_state == ptw.S_DONE) |=> (ptw.next_state == ptw.S_READY));

as__fsmNextStateSError: assert property((ptw.current_state == ptw.S_ERROR) |=> (ptw.current_state == ptw.S_READY));

as__pmuPtwhitONext: assert property(pmu_ptw_hit_o |=> (ptw.current_state == ptw.S_REQ && $past(ptw.pte_cache_hit) && $past(ptw.count_q) < $unsigned(LEVELS-1)));

as__pmuPtwhitONotNext: assert property(!pmu_ptw_hit_o |=> (ptw.current_state != ptw.S_REQ || !ptw.pte_cache_hit));

as__respErrNext: assert property(ptw.resp_err |=> (ptw.current_state == ptw.S_ERROR || $past(ptw.current_state) == ptw.S_ERROR));

as__respValNext: assert property(ptw.resp_val |=> (ptw.current_state == ptw.S_DONE || ptw.current_state == ptw.S_ERROR || ptw.current_state == ptw.S_READY));

as__respPpnNext: assert property(ptw.r_resp_ppn |=> {{(64-(SIZE_VADDR-11)){1'b0}}, ptw.pte_addr[SIZE_VADDR:12]});

as__respPpnLvlNext: assert property(ptw.resp_ppn_lvl[ptw.count_q] |=> ptw.r_resp_ppn[PPN_SIZE-1:0]);

as__vpnIdxNext: assert property(ptw.vpn_idx |=> ptw.vpn_req[ptw.count_q]);

as__pteAddrNext: assert property(ptw.pte_addr |=> ptw.aux_pte_addr[SIZE_VADDR:0]);

as__ptwDmemCommOReqValidNext: assert property(ptw_dmem_comm_o.req.valid |=> (ptw.current_state == ptw.S_REQ));

as__ptwDmemCommOReqNotValidNext: assert property(!ptw_dmem_comm_o.req.valid |=> (ptw.current_state != ptw.S_REQ));

as__ptwDmemCommOReqAddrNext: assert property(ptw_dmem_comm_o.req.valid |=> ptw_dmem_comm_o.req.addr == ptw.pte_addr);

as__ptecacheEntryValid: assert property(ptw.ptecache_entry[ptw.hit_idx].valid |-> (ptw.pte_cache_hit));

as__ptwReadyNext: assert property(ptw.ptw_ready |=> (ptw.next_state == ptw.S_REQ || ptw.next_state == ptw.S_READY || ptw.next_state == ptw.S_WAIT));

as__ptwNotReadyNext: assert property(!ptw.ptw_ready |=> (ptw.next_state != ptw.S_READY));

as__reqValidNext: assert property(tlb_ptw_comm_i.req.valid |=> (ptw.next_state == ptw.S_REQ));

as__reqNotValidNext: assert property(!tlb_ptw_comm_i.req.valid |=> (ptw.next_state == ptw.S_READY));

as__pteCacheHitNext: assert property(ptw.pte_cache_hit |=> (ptw_dmem_comm_o.req.valid == 1'b0));

as__pteCacheMissNext: assert property(!ptw.pte_cache_hit |=> (ptw_dmem_comm_o.req.valid == 1'b1));

as__permOkNext: assert property(ptw.perm_ok |=> ((ptw.prv_req[0] && (ptw.is_pte_sx || ptw.is_pte_ux)) || (!ptw.prv_req[0] && (ptw.is_pte_ux))));

as__permNotOkNext: assert property(!ptw.perm_ok |=> ((!ptw.prv_req[0] && !ptw.is_pte_ux) || (ptw.prv_req[0] && !(ptw.is_pte_sx || ptw.is_pte_ux))));

as__pteCacheDataNext: assert property(ptw.pte_cache_hit |=> (ptw.pte_cache_data == ptw.ptecache_entry[ptw.hit_idx].data));

as__pteCacheEntryNext: assert property(ptw.pte_cache_hit |=> (ptw.ptecache_entry[ptw.hit_idx].tags == ptw.pte_addr));

as__ptecacheEntryValidNext: assert property(ptw.ptecache_entry[ptw.hit_idx].valid |=> (ptw.pte_cache_hit));

as__ptecacheEntryInvalidNext: assert property(!ptw.ptecache_entry[ptw.hit_idx].valid |=> (!ptw.pte_cache_hit));

endmodule
