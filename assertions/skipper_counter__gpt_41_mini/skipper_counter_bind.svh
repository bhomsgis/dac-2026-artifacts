bind skipper_counter skipper_counter_prop
	#(
		.CLOSE_LIMIT (CLOSE_LIMIT),
		.CYCLES_PER_CHANGE (CYCLES_PER_CHANGE),
		.IMMEDIATE_CHANGE (IMMEDIATE_CHANGE),
		.ASSERT_INPUTS (0)
	) u_skipper_counter_sva(.*);