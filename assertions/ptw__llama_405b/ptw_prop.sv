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
as__ptwReady: assert property(ptw.ptw_ready == (ptw.current_state == ptw.S_READY));

as__ptwCacheHit: assert property(ptw.pte_cache_hit == |ptw.hit_vector);

as__ptwCacheMiss: assert property(!ptw.pte_cache_hit == !(|ptw.hit_vector));

as__ptwCacheFull: assert property(ptw.full_cache == &ptw.valid_vector);

as__ptwCacheEmpty: assert property(!ptw.full_cache == !(&ptw.valid_vector));

as__ptwCountQ: assert property(ptw.count_q == $past(ptw.count_d));

as__ptwPteCacheHitData: assert property(ptw.pte_cache_hit |-> ptw.pte_cache_data == ptw.ptecache_entry[ptw.hit_idx].data);

as__ptwPteCacheHitIdx: assert property(ptw.pte_cache_hit |-> ptw.hit_idx == ptw.trunc_ptw_cache_size(ptw.hit_idx));

as__ptwPteCacheMissIdx: assert property(!ptw.pte_cache_hit |-> ptw.priorityEncoder_idx == ptw.trunc_ptw_cache_size(ptw.priorityEncoder_idx));

as__ptwPteCacheAccessIdx: assert property(ptw.access_hit |-> ptw.hit_idx == ptw.trunc_ptw_cache_size(ptw.hit_idx));

as__ptwPteCacheFullEviction: assert property(ptw.full_cache |-> ptw.plru_eviction_idx == ptw.trunc_ptw_cache_size(ptw.plru_eviction_idx));

as__ptwPtwError: assert property(ptw.resp_err == (ptw.current_state == ptw.S_ERROR));

as__ptwPtwStatus: assert property(ptw.ptw_tlb_comm.ptw_status == ptw.csr_ptw_comm_i.mstatus);

as__ptwPtwInvalidateTlb: assert property(ptw.ptw_tlb_comm.invalidate_tlb == ptw.csr_ptw_comm_i.flush);

as__ptwPtwReqData: assert property(ptw.ptw_dmem_comm_o.req.data == { {(64-$bits(ptw.pte_wdata)){1'b0}}, ptw.pte_wdata.ppn, ptw.pte_wdata.rfs, ptw.pte_wdata.d, ptw.pte_wdata.a, ptw.pte_wdata.g, ptw.pte_wdata.u, ptw.pte_wdata.x, ptw.pte_wdata.w, ptw.pte_wdata.r, ptw.pte_wdata.v });

as__ptwPtwReqAddr: assert property(ptw.ptw_dmem_comm_o.req.addr == ptw.pte_addr);

as__ptwPtwReqCmd: assert property(ptw.ptw_dmem_comm_o.req.cmd == ptw.M_XRD);

as__ptwPtwReqTyp: assert property(ptw.ptw_dmem_comm_o.req.typ == ptw.MT_D);

as__ptwPtwReqPhys: assert property(ptw.ptw_dmem_comm_o.req.phys == 1'b1);

as__ptwPtwReqKill: assert property(ptw.ptw_dmem_comm_o.req.kill == 1'b0);

as__ptwPtwRespValid: assert property(ptw.ptw_tlb_comm.resp.valid == ptw.resp_val);

as__ptwPtwRespError: assert property(ptw.ptw_tlb_comm.resp.error == ptw.resp_err);

as__ptwPtwRespLevel: assert property(ptw.ptw_tlb_comm.resp.level == ptw.count_q);

as__ptwPtwRespPtePpn: assert property(ptw.ptw_tlb_comm.resp.pte.ppn == ptw.resp_ppn);

as__ptwPtwRespPteRfs: assert property(ptw.ptw_tlb_comm.resp.pte.rfs == ptw.r_pte.rfs);

as__ptwPtwRespPteD: assert property(ptw.ptw_tlb_comm.resp.pte.d == ptw.r_pte.d);

as__ptwPtwRespPteA: assert property(ptw.ptw_tlb_comm.resp.pte.a == ptw.r_pte.a);

as__ptwPtwRespPteG: assert property(ptw.ptw_tlb_comm.resp.pte.g == ptw.r_pte.g);

as__ptwPtwRespPteU: assert property(ptw.ptw_tlb_comm.resp.pte.u == ptw.r_pte.u);

as__ptwPtwRespPteX: assert property(ptw.ptw_tlb_comm.resp.pte.x == ptw.r_pte.x);

as__ptwPtwRespPteW: assert property(ptw.ptw_tlb_comm.resp.pte.w == ptw.r_pte.w);

as__ptwPtwRespPteR: assert property(ptw.ptw_tlb_comm.resp.pte.r == ptw.r_pte.r);

as__ptwPtwRespPteV: assert property(ptw.ptw_tlb_comm.resp.pte.v == ptw.r_pte.v);

as__ptwCurrentState: assert property(ptw.current_state == $past(ptw.next_state));

as__ptwPteCacheAccessHit: assert property(ptw.access_hit == ptw.pte_cache_hit);

as__ptwPteCacheReplace: assert property(ptw.full_cache && ptw.access_hit |=> ptw.ptecache_entry[ptw.plru_eviction_idx].valid);

as__ptwPteCacheReplaceData: assert property(ptw.full_cache && ptw.access_hit |=> ptw.ptecache_entry[ptw.plru_eviction_idx].data == ptw.pte.ppn);

as__ptwPteCacheReplaceTags: assert property(ptw.full_cache && ptw.access_hit |=> ptw.ptecache_entry[ptw.plru_eviction_idx].tags == ptw.pte_addr);

as__ptwPteCacheFlush: assert property(ptw.csr_ptw_comm_i.flush |=> !ptw.ptecache_entry[ptw.hit_idx].valid);

as__ptwPteCacheFlushAll: assert property(ptw.csr_ptw_comm_i.flush |=> !(&ptw.valid_vector));

as__ptwPtwDone: assert property(ptw.resp_val |-> (ptw.current_state == ptw.S_DONE || ptw.current_state == ptw.S_ERROR));

as__ptwPtwReqValid: assert property(ptw.current_state == ptw.S_REQ && !(ptw.pte_cache_hit && (ptw.count_q < $unsigned(LEVELS-1))) |-> ptw.ptw_dmem_comm_o.req.valid);

endmodule
