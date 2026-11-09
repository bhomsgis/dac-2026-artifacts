module skipper_counter_prop
 #(
		parameter ASSERT_INPUTS = 0,
		parameter CLOSE_LIMIT        = 3, //! The counter will be configured to reach the exact value in this parameter and then reset, output port "count_o" will be countgretly sized. Example values secuence for CLOSE_LIMIT = 2: 00,01,10,00,01,10,00... Parameter must be greater than 0.  
		parameter CYCLES_PER_CHANGE  = 1, //! Desired cycles per each increment change in the counter.
		parameter IMMEDIATE_CHANGE   = 1,
		localparam LIMIT_RSIZE  = $clog2(CLOSE_LIMIT+1)-1
)(
		input  logic                     clk_i,            //! Clock
		input  logic                     rstn_i,           //! Asynchronous reset active low.
		
		input  logic                     stall_i,          //! If set counter will pause the count until the port is low again.
		
		input  logic [CLOSE_LIMIT:0]     active_vector_i,  //! Vector of active valid states, each bit represent a state, if the bit is set the round robin sequence will be able to reach the state, if not that state/count will be skkiped.
		
		input  logic [LIMIT_RSIZE:0]     turn_count_o,     //! Current turn, of the state, i.e. the simple round robin fashon. //output
		
		input  logic                     valid_state_o,    //! If true, the input  state is valid. //output
		input  logic [LIMIT_RSIZE:0]     state_count_o     //! Current value of the counter. //output
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
as__PriorityValidImpliesActiveVectorNonZero: assert property(skipper_counter.priority_valid |-> |skipper_counter.current_active_vector);

as__OneHotImpliesSingleBitSet: assert property(skipper_counter.one_hot |-> $countones(skipper_counter.current_active_vector) == 1);

as__ValidStateMatchesPriorityValid: assert property(valid_state_o == skipper_counter.priority_valid);

as__TurnCountWithinLimit: assert property(turn_count_o <= CLOSE_LIMIT);

as__StateCountWithinLimit: assert property(state_count_o <= CLOSE_LIMIT);

as__StallHoldsTurnCount: assert property(stall_i |-> turn_count_o == $past(turn_count_o));

as__ActiveVectorChangesUpdateCurrentActiveVector: assert property((!skipper_counter.same_vector || skipper_counter.one_hot) |-> skipper_counter.current_active_vector == active_vector_i);

as__CurrentActiveVectorClearsBitAtStateCountWhenNoChange: assert property((skipper_counter.same_vector && !skipper_counter.one_hot) |-> skipper_counter.current_active_vector[skipper_counter.state_count] == 1'b0);

as__LastActiveVectorTracksActiveVector: assert property($past(active_vector_i) == skipper_counter.last_active_vector);

as__SameVectorSignalCorrect: assert property(skipper_counter.same_vector == (~|(active_vector_i ^ skipper_counter.last_active_vector)));

as__OneHotSignalCorrect: assert property(skipper_counter.one_hot == (~|(skipper_counter.current_active_vector & (skipper_counter.current_active_vector - 1))));

as__PriorityValidImpliesStateCountIsEncoded: assert property(skipper_counter.priority_valid |-> skipper_counter.state_count == priority_encoder_inst.encoded_value_o);

as__TurnCountAdvancesWhenNotStalled: assert property((!stall_i && $past(!stall_i)) |=> turn_count_o != $past(turn_count_o));

as__TurnCountHoldsWhenStalled: assert property(stall_i |=> turn_count_o == $past(turn_count_o));

as__ValidStateOutputMatchesPriorityValid: assert property(valid_state_o == skipper_counter.priority_valid);

as__StateCountMatchesPriorityEncoderOutput: assert property(state_count_o == priority_encoder_inst.encoded_value_o);

as__LastStateTracksStateCount: assert property($past(state_count_o) == skipper_counter.last_state);

as__OneHotQTracksOneHotD: assert property($past(skipper_counter.one_hot_d) == skipper_counter.one_hot_q);

as__SameCountSignalCorrect: assert property(skipper_counter.same_count == (~|(skipper_counter.turn_count ^ skipper_counter.last_count)));

as__LastCountTracksTurnCount: assert property($past(skipper_counter.turn_count) == skipper_counter.last_count);

as__CurrentActiveVectorAssignsCorrectlyImmediateChange: assert property(skipper_counter.IMMEDIATE_CHANGE && (!skipper_counter.same_count || !skipper_counter.same_vector) |-> (( !skipper_counter.same_vector || skipper_counter.one_hot_q ) ? (skipper_counter.current_active_vector == active_vector_i) : (skipper_counter.current_active_vector[skipper_counter.last_state] == 1'b0)));

as__CurrentActiveVectorAssignsCorrectlyNoImmediateChange: assert property(!skipper_counter.IMMEDIATE_CHANGE && !skipper_counter.same_count |-> (( !skipper_counter.same_vector || skipper_counter.one_hot_q ) ? (skipper_counter.current_active_vector == active_vector_i) : (skipper_counter.current_active_vector[skipper_counter.last_state] == 1'b0)));

endmodule
