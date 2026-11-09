bind div_4bits div_4bits_prop
	#(
		.CONFIG32 (1'b0),
		.SIMD_ENABLE (SIMD_ENABLE),
		.ASSERT_INPUTS (0)
	) u_div_4bits_sva(.*);