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
as__ReadyStateCountZero: assert property((ptw.current_state == ptw.S_READY) |-> (ptw.count_d == 0));

as__RespValidWhenDoneOrError: assert property((ptw.ptw_tlb_comm.resp.valid) == ((ptw.current_state == ptw.S_DONE) || (ptw.current_state == ptw.S_ERROR)));

as__RespErrorWhenErrorState: assert property((ptw.ptw_tlb_comm.resp.error) == (ptw.current_state == ptw.S_ERROR));

as__RespLevelMatchesCountQ: assert property(ptw.ptw_tlb_comm.resp.level == ptw.count_q);

as__RespPtePpnMatchesRespPpn: assert property(ptw.ptw_tlb_comm.resp.pte.ppn == ptw.resp_ppn);

as__RespPteFieldsMatchRPte: assert property((ptw.ptw_tlb_comm.resp.pte.rfs == ptw.r_pte.rfs) && (ptw.ptw_tlb_comm.resp.pte.d == ptw.r_pte.d) && (ptw.ptw_tlb_comm.resp.pte.a == ptw.r_pte.a) && (ptw.ptw_tlb_comm.resp.pte.g == ptw.r_pte.g) && (ptw.ptw_tlb_comm.resp.pte.u == ptw.r_pte.u) && (ptw.ptw_tlb_comm.resp.pte.x == ptw.r_pte.x) && (ptw.ptw_tlb_comm.resp.pte.w == ptw.r_pte.w) && (ptw.ptw_tlb_comm.resp.pte.r == ptw.r_pte.r) && (ptw.ptw_tlb_comm.resp.pte.v == ptw.r_pte.v));

as__PtwReadyWhenStateReady: assert property(ptw.ptw_tlb_comm.ptw_ready == (ptw.current_state == ptw.S_READY));

as__PtwStatusMatchesCsrMstatus: assert property(ptw.ptw_tlb_comm.ptw_status == csr_ptw_comm_i.mstatus);

as__InvalidateTlbMatchesFlush: assert property(ptw.ptw_tlb_comm.invalidate_tlb == csr_ptw_comm_i.flush);

as__CountDIncrementsCorrectly: assert property((ptw.current_state == ptw.S_REQ && !ptw.pte_cache_hit) |-> (ptw.count_d == ptw.count_q));

as__PteCacheHitImpliesHitVector: assert property(ptw.pte_cache_hit == (|ptw.hit_vector));

as__FullCacheImpliesAllValidVector: assert property(ptw.full_cache == (&ptw.valid_vector));

as__PtwDmemReqAddrMatchesPteAddr: assert property(ptw_dmem_comm_o.req.addr == ptw.pte_addr);

as__PtwDmemReqCmdIsRead: assert property(ptw_dmem_comm_o.req.cmd == ptw.M_XRD);

as__PtwDmemReqTypIsData: assert property(ptw_dmem_comm_o.req.typ == ptw.MT_D);

as__PtwDmemReqPhysIsOne: assert property(ptw_dmem_comm_o.req.phys == 1'b1);

as__PtwDmemReqKillIsZero: assert property(ptw_dmem_comm_o.req.kill == 1'b0);

as__PtwDmemReqDataHasASet: assert property(ptw_dmem_comm_o.req.data[6] == 1'b1);

as__PermOkMatchesPermissionLogic: assert property(ptw.perm_ok == ((ptw.prv_req[0]) ? ((csr_ptw_comm_i.mstatus.sum) ? ((ptw.r_req.fetch) ? (ptw.is_pte_sx || ptw.is_pte_ux) : ((ptw.r_req.store) ? (ptw.is_pte_sw || ptw.is_pte_uw) : ((csr_ptw_comm_i.mstatus.mxr) ? (ptw.is_pte_sr || ptw.is_pte_ur || ptw.is_pte_ux || ptw.is_pte_sx) : (ptw.is_pte_sr || ptw.is_pte_ur)))) : ((ptw.r_req.fetch) ? ptw.is_pte_sx : ((ptw.r_req.store) ? ptw.is_pte_sw : ((csr_ptw_comm_i.mstatus.mxr) ? (ptw.is_pte_sr || ptw.is_pte_sx) : ptw.is_pte_sr)))) : ((ptw.r_req.fetch) ? ptw.is_pte_ux : ((ptw.r_req.store) ? ptw.is_pte_uw : ((csr_ptw_comm_i.mstatus.mxr) ? (ptw.is_pte_ur || ptw.is_pte_ux) : ptw.is_pte_ur)))));

as__VpnIdxMatchesVpnReqCountQ: assert property(ptw.vpn_idx == ptw.vpn_req[ptw.count_q]);

as__PteVMatchesValidPteLvlCountQ: assert property(ptw.pte.v == ptw.valid_pte_lvl[ptw.count_q]);

as__InvalidPteSetCorrectly: assert property(ptw.invalid_pte == (((dmem_ptw_comm_i.resp.data >> (PPN_SIZE+10)) != '0) || (ptw.is_pte_table && ptw.pte.v && (ptw.pte.d || ptw.pte.a || ptw.pte.u))));

as__IsPteTableMatchesDefinition: assert property(ptw.is_pte_table == (ptw.pte.v && !ptw.pte.x && !ptw.pte.w && !ptw.pte.r));

as__IsPteLeafMatchesDefinition: assert property(ptw.is_pte_leaf == (ptw.pte.v && (ptw.pte.x || ptw.pte.w || ptw.pte.r)));

as__PmuHitOnlyInReqStateWithCacheHit: assert property((pmu_ptw_hit_o == 1'b1) |-> (ptw.current_state == ptw.S_REQ && ptw.pte_cache_hit));

as__RrespPpnMatchesShiftedPteAddr: assert property(ptw.r_resp_ppn == (ptw.pte_addr >> 12));

as__RespPpnLvlLastMatchesRrespPpn: assert property(ptw.resp_ppn_lvl[LEVELS-1] == ptw.r_resp_ppn[PPN_SIZE-1:0]);

as__RespPpnMatchesRespPpnLvlCountQ: assert property(ptw.resp_ppn == ptw.resp_ppn_lvl[ptw.count_q]);

as__ReqStateDmemReqValidNoCacheHit: assert property((ptw.current_state == ptw.S_REQ && !ptw.pte_cache_hit && !dmem_ptw_comm_i.dmem_ready) |-> (ptw.ptw_dmem_comm_o.req.valid == 1'b1));

as__PmuHitOnlyInReqStateWithCacheHit_1: assert property((ptw.pmu_ptw_hit_o == 1'b1) |-> (ptw.current_state == ptw.S_REQ && ptw.pte_cache_hit));

as__DmemReqValidOnlyInReqState: assert property(ptw.ptw_dmem_comm_o.req.valid |-> (ptw.current_state == ptw.S_REQ));

as__RespValidOnlyInDoneOrError: assert property(ptw.ptw_tlb_comm.resp.valid == ((ptw.current_state == ptw.S_DONE) || (ptw.current_state == ptw.S_ERROR)));

as__RespErrorOnlyInErrorState: assert property(ptw.ptw_tlb_comm.resp.error == (ptw.current_state == ptw.S_ERROR));

as__PtwDmemReqAddrMatchesPteAddr_1: assert property(ptw.ptw_dmem_comm_o.req.addr == ptw.pte_addr);

as__PtwDmemReqCmdIsRead_1: assert property(ptw.ptw_dmem_comm_o.req.cmd == ptw.M_XRD);

as__PtwDmemReqTypIsData_1: assert property(ptw.ptw_dmem_comm_o.req.typ == ptw.MT_D);

as__PtwDmemReqPhysIsOne_1: assert property(ptw.ptw_dmem_comm_o.req.phys == 1'b1);

as__PtwDmemReqKillIsZero_1: assert property(ptw.ptw_dmem_comm_o.req.kill == 1'b0);

as__PtwDmemReqDataHasASet_1: assert property(ptw.ptw_dmem_comm_o.req.data[6] == 1'b1);

as__RPteUpdatedToPteInWaitStateOnRespValid: assert property((ptw.current_state == ptw.S_WAIT && dmem_ptw_comm_i.resp.valid) |=> (ptw.r_pte == $past(ptw.pte)));

as__ReqStateDmemReadyNextWait: assert property((ptw.current_state == ptw.S_REQ && !ptw.pte_cache_hit && dmem_ptw_comm_i.dmem_ready) |=> (ptw.next_state == ptw.S_WAIT));

as__WaitStateNackNextReq: assert property ((ptw.current_state == ptw.S_WAIT && ptw.dmem_ptw_comm_i.resp.nack) |-> (ptw.next_state == ptw.S_REQ));

as__WaitStateInvalidPteNextError: assert property((ptw.current_state == ptw.S_WAIT && dmem_ptw_comm_i.resp.valid && ptw.invalid_pte) |=> (ptw.next_state == ptw.S_ERROR));

as__WaitStatePteLeafNextDone: assert property((ptw.current_state == ptw.S_WAIT && dmem_ptw_comm_i.resp.valid && ptw.is_pte_leaf) |=> (ptw.next_state == ptw.S_DONE));

as__WaitStateRespValidElseError: assert property((ptw.current_state == ptw.S_WAIT && dmem_ptw_comm_i.resp.valid && !ptw.invalid_pte && !ptw.is_pte_table && !ptw.is_pte_leaf) |=> (ptw.next_state == ptw.S_ERROR));

as__WaitStateRespNotValidStayWait: assert property((ptw.current_state == ptw.S_WAIT && !dmem_ptw_comm_i.resp.valid) |=> (ptw.next_state == ptw.S_WAIT));

as__DoneStateNextReady: assert property((ptw.current_state == ptw.S_DONE) |-> (ptw.next_state == ptw.S_READY));

as__ErrorStateNextReady: assert property ((ptw.current_state == ptw.S_ERROR) |=> ($past(ptw.current_state) == ptw.S_ERROR && ptw.current_state == ptw.S_READY));

as__RpteUpdatedOnWaitRespValid: assert property((ptw.current_state == ptw.S_WAIT && ptw.dmem_ptw_comm_i.resp.valid) |=> (ptw.r_pte == $past(ptw.pte)));

as__CountQUpdatedNextCycle: assert property((ptw.count_q != $past(ptw.count_q)) |=> (ptw.count_q == $past(ptw.count_d)));

as__AccessHitSetWhenCacheHitAndReqState: assert property((ptw.current_state == ptw.S_REQ && ptw.pte_cache_hit) |=> (ptw.access_hit == 1'b1));

as__AccessHitClearOtherwise: assert property((!(ptw.current_state == ptw.S_REQ && ptw.pte_cache_hit)) |=> (ptw.access_hit == 1'b0));

as__CountDIncrementsInReqStateNoCacheHit: assert property((ptw.current_state == ptw.S_REQ && !ptw.pte_cache_hit) |-> (ptw.count_d == (ptw.count_q + 1'b1)));

endmodule
