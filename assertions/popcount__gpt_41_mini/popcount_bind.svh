bind popcount popcount_prop
	#(
		.N_PORTS (N_PORTS),
		.REGS_WIDTH (REGS_WIDTH),
		.ASSERT_INPUTS (0)
	) u_popcount_sva(.*);