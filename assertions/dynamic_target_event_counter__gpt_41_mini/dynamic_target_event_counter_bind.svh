bind dynamic_target_event_counter dynamic_target_event_counter_prop
	#(
		.COUNT_BSIZE (COUNT_BSIZE),
		.PPARLL_EVNTS (PPARLL_EVNTS),
		.BASE_INCREMENT (BASE_INCREMENT),
		.ASSERT_INPUTS (0)
	) u_dynamic_target_event_counter_sva(.*);