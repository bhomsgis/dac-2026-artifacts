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
as__NoUpdateWhenNoHit: assert property(access_hit_i == 1'b0 |-> pseudoLRU.plru_tree_d == pseudoLRU.plru_tree_q);

as__OnlyOneEntryReplaced: assert property($countones(pseudoLRU.replace_en) <= 1);

as__ReplacementIsValidEntry: assert property(|pseudoLRU.replace_en |-> replacement_idx_o < ENTRIES);

as__ReplacementUpdated: assert property(access_hit_i == 1'b1 |=> pseudoLRU.replace_en != '0);

as__AccessArraySet: assert property(|pseudoLRU.access_array |-> $countones(pseudoLRU.access_array) == 1);

as__AccessArrayReset: assert property(!(|pseudoLRU.access_array) |-> pseudoLRU.access_array == '0);

as__ReplaceEnSet: assert property(|pseudoLRU.replace_en |-> $countones(pseudoLRU.replace_en) == 1);

as__ReplaceEnReset: assert property(!(|pseudoLRU.replace_en) |-> pseudoLRU.replace_en == '0);

as__ReplacementIdxValid: assert property(|pseudoLRU.replace_en |-> replacement_idx_o < pseudoLRU.ENTRIES);

as__ReplacementIdxOnehot: assert property(|pseudoLRU.replace_en |-> pseudoLRU.replace_en == (1 << replacement_idx_o));

as__TreeUpdatedImpliesAccessHit: assert property(pseudoLRU.plru_tree_q != $past(pseudoLRU.plru_tree_q) |-> $past(access_hit_i) == 1'b1);

as__AccessArrayResetImpliesNoAccessHit: assert property(!(|pseudoLRU.access_array) |-> access_hit_i == 1'b0);

as__ReplaceEnResetImpliesNoAccessHit: assert property(!(|pseudoLRU.replace_en) |-> $past(access_hit_i) == 1'b0);

as__TreeUpdatedImpliesReplaceEn: assert property(pseudoLRU.plru_tree_q != $past(pseudoLRU.plru_tree_q) |-> |$past(pseudoLRU.replace_en));

as__TreeUpdatedImpliesAccessArraySet: assert property(pseudoLRU.plru_tree_q != $past(pseudoLRU.plru_tree_q) |-> |$past(pseudoLRU.access_array));

as__AccessIdxValid: assert property(access_idx_i < pseudoLRU.ENTRIES);

as__AccessIdxOnehot: assert property(pseudoLRU.access_array == (1 << access_idx_i));

as__AccessArraySetImpliesReplaceEnSet: assert property(|pseudoLRU.access_array |-> |pseudoLRU.replace_en);

as__ReplaceEnSetImpliesAccessArraySet: assert property(|pseudoLRU.replace_en |-> |pseudoLRU.access_array);

as__AccessArrayResetImpliesReplaceEnReset: assert property(!(|pseudoLRU.access_array) |-> !(|pseudoLRU.replace_en));

as__ReplaceEnResetImpliesAccessArrayReset: assert property(!(|pseudoLRU.replace_en) |-> !(|pseudoLRU.access_array));

as__AccessIdxOnehotImpliesAccessArraySet: assert property(pseudoLRU.access_array == (1 << access_idx_i) |-> |pseudoLRU.access_array);

as__AccessArraySetImpliesAccessIdxOnehot: assert property(|pseudoLRU.access_array |-> pseudoLRU.access_array == (1 << access_idx_i));

as__ReplaceEnOnehotImpliesReplaceEnSet: assert property(pseudoLRU.replace_en == (1 << replacement_idx_o) |-> |pseudoLRU.replace_en);

as__ReplaceEnSetImpliesReplaceEnOnehot: assert property(|pseudoLRU.replace_en |-> pseudoLRU.replace_en == (1 << replacement_idx_o));

as__ReplaceEnValid: assert property(replacement_idx_o < pseudoLRU.ENTRIES);

as__ReplaceEnOnehot: assert property(pseudoLRU.replace_en == (1 << replacement_idx_o));

as__UpdateWhenHit: assert property(access_hit_i == 1'b1 |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_d));

as__NoReplacementWhenNoHit: assert property(access_hit_i == 1'b0 |=> replacement_idx_o == $past(replacement_idx_o));

as__TreeUpdated: assert property(access_hit_i == 1'b1 |=> pseudoLRU.plru_tree_q != $past(pseudoLRU.plru_tree_q));

as__ReplacementIdx: assert property(|pseudoLRU.replace_en |-> replacement_idx_o == cast_integer($onehot(pseudoLRU.replace_en)));

as__ReplacementUpdatedImpliesAccessHit: assert property(|pseudoLRU.replace_en |-> $past(access_hit_i) == 1'b1);

as__AccessArraySetImpliesAccessHit: assert property(access_hit_i |-> pseudoLRU.access_array[access_idx_i] == 1'b1);

as__ReplaceEnImpliesTreeUpdated: assert property (pseudoLRU.replace_en |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_d));

as__AccessArraySetImpliesTreeUpdated: assert property(|pseudoLRU.access_array |-> pseudoLRU.plru_tree_q != $past(pseudoLRU.plru_tree_q));

as__AccessIdxStableWhenNoHit: assert property(access_hit_i == 1'b0 |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_q));

as__AccessIdxUpdatedWhenHit: assert property(access_hit_i == 1'b1 |=> $past(pseudoLRU.plru_tree_d) == pseudoLRU.plru_tree_q);

as__AccessArrayStableWhenNoHit: assert property(access_hit_i == 1'b0 |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_q));

as__AccessArrayUpdatedWhenHit: assert property(access_hit_i == 1'b1 |-> pseudoLRU.access_array != $past(pseudoLRU.access_array));

as__ReplaceEnStableWhenNoHit: assert property(access_hit_i == 1'b0 |-> $countones(pseudoLRU.replace_en) == 1);

as__ReplaceEnUpdatedWhenHit: assert property(access_hit_i == 1'b1 |=> |pseudoLRU.replace_en);

as__ReplacementIdxStableWhenNoHit: assert property(access_hit_i == 1'b0 |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_q));

as__ReplacementIdxUpdatedWhenHit: assert property(access_hit_i == 1'b1 |-> replacement_idx_o != $past(replacement_idx_o));

as__TreeStableWhenNoHit: assert property(access_hit_i == 1'b0 |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_d));

as__TreeUpdatedWhenHit: assert property(access_hit_i == 1'b1 |-> pseudoLRU.plru_tree_q != $past(pseudoLRU.plru_tree_q));

endmodule
