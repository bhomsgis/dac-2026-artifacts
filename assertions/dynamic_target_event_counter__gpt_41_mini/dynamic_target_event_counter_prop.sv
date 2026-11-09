module dynamic_target_event_counter_prop
 #(
		parameter ASSERT_INPUTS = 0,
		parameter                           COUNT_BSIZE     = 8,            //! Count Bit Size: Size of the Counter in Bits.
		parameter                           PPARLL_EVNTS    = 5,            //! Possible Parallel Events: Number of events that can happen in parallel, this will determine the size of event_triggers_i.
		parameter                           BASE_INCREMENT  = 1,            //! Base value for each increment, if more that one event happens in parallel the increment is proportional to the number of events, so that increment = (Number of parallel events)*(Base increment).
		parameter logic                     INCR_DECR_COUNT = 1'b1,         //! If HIGH(1'b1):, configures the counter to increment with each event trigger, if LOW(1'b0):, counter decrements each event trigger.
		parameter logic                     EXT_COUNT_RESET = 1'b0,         //! If HIGH(1'b1):, configures the counter to synchronously update with `reset_count_i` event trigger, if LOW(1'b0):, counter gets set to `RST_COUNTER_VAL` each event trigger.
		parameter logic [COUNT_BSIZE-1:0]   RST_COUNTER_VAL = 0,            //! Value of the counter at reset, this value will set in the counter with a `reset_count_i` or a `rstn_i` signal.
		parameter logic                   OPEN_CLLOSE_LIMIT = 1'b1,         //! If HIGH(1'b1) (Open Limit) the target_reached_o port will be set when the counter is strictly greater(>) than the target. If LOW(1'b0) the target_reached_o will be set when the counter is equal or greater(>=) than the target.
		parameter int                   CURRENT_COUNT_PCONF = 1             //! Current count port configuration, If equal to 1'b1 then the `current_count_o` port reports the current value of the counter, if 1'b0 then the current_count_o port reports the last loaded target value, else the port will be always cero
)(
		input  logic                     clk_i,                 //! System Clock.
		input  logic                     rstn_i,                //! Asynchronous reset active low.
		
		input  logic [PPARLL_EVNTS-1:0]  event_triggers_i,      //! Group of bits that trigger and increment to the counter, each bit can generate what is consider an event (bit set during 1 cycle), and the increments is given by BASE_INCREMENT times number of parallel events.
		
		input  logic [0:0]               reset_count_i,         //! Synchronous reset of the counter with the `RST_COUNTER_VAL` parameter/`rst_cntr_val_i` input and reload the target value with the value of target_value_i.
		input  logic [COUNT_BSIZE-1:0]   rst_cntr_val_i,        //! Counter will preset this value when reset_count_i is set.
		input  logic [COUNT_BSIZE-1:0]   target_value_i,        //! Target to load when reset.
		
		input  logic [0:0]               target_reached_o,      //! Set when target value is reached by the counter  //output
		input  logic [COUNT_BSIZE-1:0]   current_count_o        //! Current count value. //output
	);

//==============================================================================
// Local Parameters
//==============================================================================

genvar j;
default clocking cb @(posedge clk_i);
endclocking
default disable iff (!rst_cntr_val_i);

// Re-defined wires 

// Symbolics and Handshake signals

//==============================================================================
// Modeling
//==============================================================================


//====DESIGNER-ADDED-SVA====//
as__SingleEventIncrement: assert property((|event_triggers_i && $countones(event_triggers_i) == 1 && INCR_DECR_COUNT == 1'b1) |-> dynamic_target_event_counter.counter_d == dynamic_target_event_counter.counter_q + BASE_INCREMENT);

as__SingleEventDecrement: assert property((|event_triggers_i && $countones(event_triggers_i) == 1 && INCR_DECR_COUNT == 1'b0) |-> dynamic_target_event_counter.counter_d == dynamic_target_event_counter.counter_q - BASE_INCREMENT);

as__CounterHoldNoEventNoReset: assert property((!|event_triggers_i && !reset_count_i) |-> dynamic_target_event_counter.counter_d == dynamic_target_event_counter.counter_q);

as__CounterResetExtCountZero: assert property((reset_count_i && EXT_COUNT_RESET == 1'b0) |=> dynamic_target_event_counter.counter_q == RST_COUNTER_VAL);

as__CounterResetExtCountOne: assert property((reset_count_i && EXT_COUNT_RESET == 1'b1) |=> dynamic_target_event_counter.counter_q == rst_cntr_val_i);

as__TargetRegUpdateOnResetCount: assert property(reset_count_i |=> dynamic_target_event_counter.target_reg_q == target_value_i);

as__TargetRegHoldNoResetCount: assert property((!reset_count_i) |=> dynamic_target_event_counter.target_reg_q == dynamic_target_event_counter.target_reg_q);

as__TargetReachedOpenLimit: assert property(OPEN_CLLOSE_LIMIT == 1'b1 |-> target_reached_o == (dynamic_target_event_counter.counter_q > dynamic_target_event_counter.target_reg_q));

as__TargetReachedClosedLimit: assert property(OPEN_CLLOSE_LIMIT == 1'b0 |-> target_reached_o == (dynamic_target_event_counter.counter_q >= dynamic_target_event_counter.target_reg_q));

as__CurrentCountOutputConfigOne: assert property(dynamic_target_event_counter.CURRENT_COUNT_PCONF == 1 |-> current_count_o == dynamic_target_event_counter.counter_q);

as__CurrentCountOutputConfigZero: assert property(dynamic_target_event_counter.CURRENT_COUNT_PCONF == 0 |-> current_count_o == dynamic_target_event_counter.target_reg_q);

as__CurrentCountOutputConfigOther: assert property((dynamic_target_event_counter.CURRENT_COUNT_PCONF != 1 && dynamic_target_event_counter.CURRENT_COUNT_PCONF != 0) |-> current_count_o == '0);

as__CounterIncrementMultipleEvents: assert property((|event_triggers_i && INCR_DECR_COUNT == 1'b1 && PPARLL_EVNTS > 1) |-> dynamic_target_event_counter.counter_d == dynamic_target_event_counter.counter_q + COUNT_BSIZE'(dynamic_target_event_counter.increment_table[$countones(event_triggers_i)]));

as__CounterDecrementMultipleEvents: assert property((|event_triggers_i && INCR_DECR_COUNT == 1'b0 && PPARLL_EVNTS > 1) |-> dynamic_target_event_counter.counter_d == dynamic_target_event_counter.counter_q - COUNT_BSIZE'(dynamic_target_event_counter.increment_table[$countones(event_triggers_i)]));

endmodule
