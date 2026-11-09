module pseudoLRU_prop
 #(
		parameter ASSERT_INPUTS = 0,
		parameter int unsigned ENTRIES = 8
)(
		input logic clk_i,
		input logic rstn_i,
		
		input logic access_hit_i, // only update the PLRU when there is a hit in the storage mechanism
		input logic [$clog2(ENTRIES)-1:0] access_idx_i,
		input  logic [$clog2(ENTRIES)-1:0] replacement_idx_o //output
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
as__NoAccessNoUpdateeotid: assert property(!access_hit_i |-> pseudoLRU.plru_tree_d == pseudoLRU.plru_tree_q);

as__ReplacementIndexValideotid: assert property(|pseudoLRU.replace_en |-> replacement_idx_o inside {[0:pseudoLRU.ENTRIES-1]});

as__ReplacementIndexMatchesReplaceEneotid: assert property(pseudoLRU.replace_en[replacement_idx_o]);

as__OnlyOneReplaceEneotid: assert property($countones(pseudoLRU.replace_en) == 1);

as__ReplacementIdxReflectsReplaceEnNextCycleeotid: assert property(1 |=> pseudoLRU.replace_en[replacement_idx_o]);

as__ReplacementIdxOneHotMatcheotid: assert property(|pseudoLRU.replace_en && pseudoLRU.replace_en[replacement_idx_o]);

as__PlruTreeQUpdateeotid: assert property(1 |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_d));

as__ReplacementIdxOneHotNextCycleeotid: assert property(1 |=> (pseudoLRU.replace_en[replacement_idx_o] && $countones(pseudoLRU.replace_en) == 1));

as__ReplaceEnOneHotNextCycle: assert property(1 |=> $countones(pseudoLRU.replace_en) == 1);

as__AccessUpdateeotid: assert property(access_hit_i && pseudoLRU.access_array == (1 << access_idx_i) |-> pseudoLRU.plru_tree_d != pseudoLRU.plru_tree_q);

as__ReplacementIdxInRangeeotid: assert property (|pseudoLRU.replace_en |=> replacement_idx_o inside {[0:pseudoLRU.ENTRIES-1]});

as__ReplacementIdxInRangeNextCycleeotid: assert property (|pseudoLRU.replace_en |-> replacement_idx_o inside {[0:pseudoLRU.ENTRIES-1]});

as__ReplacementIdxValidNextCycleeotid: assert property (|pseudoLRU.replace_en |=> (replacement_idx_o inside {[0:pseudoLRU.ENTRIES-1]}) && (|pseudoLRU.replace_en));

as__ReplacementIdxValidWhenReplaceEn: assert property (|pseudoLRU.replace_en |=> (replacement_idx_o inside {[0:pseudoLRU.ENTRIES-1]} && $past(pseudoLRU.replace_en[replacement_idx_o])));

as__ReplacementIdxStableNextCycle: assert property (|pseudoLRU.replace_en |-> pseudoLRU.replacement_idx_o inside {[0:pseudoLRU.ENTRIES-1]});

as__ReplacementIdxInRangeWhenReplaceEn: assert property (|pseudoLRU.replace_en |=> pseudoLRU.replacement_idx_o inside {[0:pseudoLRU.ENTRIES-1]});

as__ReplacementIdxValidNextCycle: assert property (|pseudoLRU.replace_en |=> (replacement_idx_o inside {[0:pseudoLRU.ENTRIES-1]}) && pseudoLRU.replace_en[replacement_idx_o]);

endmodule
