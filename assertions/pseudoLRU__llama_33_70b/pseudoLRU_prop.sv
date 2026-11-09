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
as__AccessHit: assert property(access_hit_i |-> pseudoLRU.access_array[access_idx_i] == 1'b1);

as__AccessArray: assert property(access_hit_i |-> &pseudoLRU.access_array[access_idx_i]);

as__ReplacementIdx: assert property(pseudoLRU.replace_en[access_idx_i] == 1'b1 |-> replacement_idx_o == access_idx_i);

as__NoHit: assert property(!access_hit_i |-> pseudoLRU.plru_tree_q == pseudoLRU.plru_tree_d);

as__ReplaceEnUnique: assert property($countones(pseudoLRU.replace_en) == 1);

as__ReplacementIdxValid: assert property(replacement_idx_o >= 0 && replacement_idx_o < pseudoLRU.ENTRIES);

as__PLRUTreeUpdateNoHit: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_q));

as__ReplacementIdxValidHit: assert property(access_hit_i |-> replacement_idx_o >= 0 && replacement_idx_o < pseudoLRU.ENTRIES);

as__PLRUTreeDecodeUniqueHit: assert property(access_hit_i |-> $countones(pseudoLRU.access_array) == 1);

as__PLRUTreeEncodeUniqueHit: assert property(access_hit_i |-> $countones(pseudoLRU.replace_en) == 1);

as__PLRUTreeUpdateHitNoHit: assert property(access_hit_i |=> pseudoLRU.plru_tree_q != $past(pseudoLRU.plru_tree_q) && !access_hit_i |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_q));

as__PLRUTreeDecodeValid: assert property(pseudoLRU.access_array >= '0 && pseudoLRU.access_array <= '1);

as__PLRUTreeEncodeValid: assert property(pseudoLRU.replace_en >= '0 && pseudoLRU.replace_en <= '1);

as__PLRUTreeUpdateValid: assert property(pseudoLRU.plru_tree_q >= '0 && pseudoLRU.plru_tree_q <= '1);

as__PLRUTreeUpdateValidNoHit: assert property(!access_hit_i |-> pseudoLRU.plru_tree_q >= '0 && pseudoLRU.plru_tree_q <= '1);

as__PLRUTreeUpdateValidHit: assert property(access_hit_i |-> pseudoLRU.plru_tree_q >= '0 && pseudoLRU.plru_tree_q <= '1);

as__ReplacementIdxValidNoHit: assert property(!access_hit_i |-> replacement_idx_o >= 0 && replacement_idx_o < pseudoLRU.ENTRIES);

as__PLRUTreeDecodeNoHit_1: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_2: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_3: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_4: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_5: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_6: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_7: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeUpdateHit_1: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[0] == $past(pseudoLRU.plru_tree_d[0]));

as__PLRUTreeUpdateHit_2: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[1] == $past(pseudoLRU.plru_tree_d[1]));

as__PLRUTreeUpdateHit_3: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[2] == $past(pseudoLRU.plru_tree_d[2]));

as__PLRUTreeUpdateNoHit_1: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[0] == $past(pseudoLRU.plru_tree_d[0]));

as__PLRUTreeUpdateNoHit_2: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[1] == $past(pseudoLRU.plru_tree_d[1]));

as__PLRUTreeUpdateNoHit_3: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[2] == $past(pseudoLRU.plru_tree_d[2]));

as__PLRUTreeDecodeNoHit_1_1: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_2: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_3: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_4: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_5: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_6: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_7: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeUpdateHit_4: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[3] == $past(pseudoLRU.plru_tree_d[3]));

as__PLRUTreeUpdateHit_5: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[4] == $past(pseudoLRU.plru_tree_d[4]));

as__PLRUTreeUpdateHit_6: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[5] == $past(pseudoLRU.plru_tree_d[5]));

as__PLRUTreeUpdateHit_7: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[6] == $past(pseudoLRU.plru_tree_d[6]));

as__PLRUTreeUpdateNoHit_4: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[3] == $past(pseudoLRU.plru_tree_d[3]));

as__PLRUTreeUpdateNoHit_5: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[4] == $past(pseudoLRU.plru_tree_d[4]));

as__PLRUTreeUpdateNoHit_6: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[5] == $past(pseudoLRU.plru_tree_d[5]));

as__PLRUTreeUpdateNoHit_7: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[6] == $past(pseudoLRU.plru_tree_d[6]));

as__PLRUTreeDecodeNoHit_8: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_9: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_10: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_11: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_12: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_13: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_14: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeUpdateHit_8: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[7] == $past(pseudoLRU.plru_tree_d[7]));

as__PLRUTreeUpdateNoHit_8: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[7] == $past(pseudoLRU.plru_tree_d[7]));

as__PLRUTreeDecodeNoHit_1_8: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_9: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_10: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_11: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_12: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_13: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_1_14: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeUpdateHit_9: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[8] == $past(pseudoLRU.plru_tree_d[8]));

as__PLRUTreeUpdateNoHit_9: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[8] == $past(pseudoLRU.plru_tree_d[8]));

as__PLRUTreeDecodeNoHit_15: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_16: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeUpdateHit_10: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[9] == $past(pseudoLRU.plru_tree_d[9]));

as__PLRUTreeUpdateNoHit_10: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[9] == $past(pseudoLRU.plru_tree_d[9]));

as__PLRUTreeDecodeNoHit_17: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_18: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeUpdateHit_11: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[10] == $past(pseudoLRU.plru_tree_d[10]));

as__PLRUTreeUpdateNoHit_11: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[10] == $past(pseudoLRU.plru_tree_d[10]));

as__PLRUTreeDecodeNoHit_19: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_20: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeUpdateHit_12: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[11] == $past(pseudoLRU.plru_tree_d[11]));

as__PLRUTreeUpdateNoHit_12: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[11] == $past(pseudoLRU.plru_tree_d[11]));

as__PLRUTreeDecodeNoHit_21: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_22: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeUpdateHit_13: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[12] == $past(pseudoLRU.plru_tree_d[12]));

as__PLRUTreeUpdateNoHit_13: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[12] == $past(pseudoLRU.plru_tree_d[12]));

as__PLRUTreeDecodeNoHit_23: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_24: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeUpdateHit_14: assert property(access_hit_i |=> pseudoLRU.plru_tree_q[13] == $past(pseudoLRU.plru_tree_d[13]));

as__PLRUTreeUpdateNoHit_14: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q[13] == $past(pseudoLRU.plru_tree_d[13]));

as__PLRUTreeDecodeNoHit_25: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeDecodeNoHit_26: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeUpdate: assert property(access_hit_i |=> pseudoLRU.plru_tree_q != pseudoLRU.plru_tree_d);

as__PLRUTreeDecode: assert property(pseudoLRU.plru_tree_q[0] == 1'b1 |-> pseudoLRU.replace_en[0] == 1'b1);

as__PLRUTreeEncode: assert property(pseudoLRU.replace_en[0] == 1'b1 |-> pseudoLRU.plru_tree_q[0] == 1'b1);

as__PLRUTreeStable: assert property(!access_hit_i |-> pseudoLRU.plru_tree_q == pseudoLRU.plru_tree_d);

as__ReplaceEnStable: assert property(!access_hit_i |-> pseudoLRU.replace_en == $past(pseudoLRU.replace_en) || !&pseudoLRU.access_array);

as__ReplacementIdxStable: assert property(!access_hit_i |-> replacement_idx_o == $past(replacement_idx_o) || !&pseudoLRU.plru_tree_q);

as__PLRUTreeUpdateHit: assert property(access_hit_i |=> pseudoLRU.plru_tree_q != $past(pseudoLRU.plru_tree_q));

as__PLRUTreeEncodeHit: assert property(access_hit_i |-> pseudoLRU.replace_en[access_idx_i] == 1'b1);

as__PLRUTreeDecodeNoHit: assert property(!access_hit_i |-> !(&pseudoLRU.access_array[access_idx_i]));

as__PLRUTreeEncodeNoHit: assert property(!access_hit_i |-> pseudoLRU.replace_en[access_idx_i] == 1'b0);

as__PLRUTreeDecodeStable: assert property(!access_hit_i |-> pseudoLRU.plru_tree_d == pseudoLRU.plru_tree_q);

as__PLRUTreeDecodeUniqueNoHit: assert property(!access_hit_i |-> !(&pseudoLRU.access_array));

as__PLRUTreeEncodeUniqueNoHit: assert property(!access_hit_i |-> $countones(pseudoLRU.replace_en) == 0);

as__PLRUTreeUpdateNoHitStable: assert property(!access_hit_i |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_d));

as__ReplaceEnUpdateHit: assert property(access_hit_i |=> pseudoLRU.replace_en != $past(pseudoLRU.replace_en) || &($past(pseudoLRU.plru_tree_d) == pseudoLRU.plru_tree_q));

as__ReplacementIdxUpdateHit: assert property(access_hit_i |=> replacement_idx_o != $past(replacement_idx_o));

as__PLRUTreeDecodeUpdateHit: assert property(access_hit_i |-> pseudoLRU.access_array != $past(pseudoLRU.access_array));

as__PLRUTreeEncodeUpdateHit: assert property(access_hit_i |-> pseudoLRU.replace_en != $past(pseudoLRU.replace_en));

as__PLRUTreeUpdateStable: assert property(pseudoLRU.plru_tree_q == pseudoLRU.plru_tree_d |=> pseudoLRU.plru_tree_q == $past(pseudoLRU.plru_tree_d));

as__PLRUTreeUpdate_1: assert property(pseudoLRU.plru_tree_d != pseudoLRU.plru_tree_q |=> pseudoLRU.plru_tree_q != $past(pseudoLRU.plru_tree_q));

as__PLRUTreeEncodeNoHit_1: assert property(!access_hit_i |-> &{pseudoLRU.replace_en} == 1'b0);

endmodule
