module mul_unit_prop
#(
		parameter ASSERT_INPUTS = 0,
		parameter logic REG_32       = 1'b1,                         //! If HIGH (1'b1), register the valid computation of 32-bits multiplications (1 cycle) to match the latency of 64-bit multiplications (2 cycles).
		parameter logic CONFIG32     = 1'b0,                         //! If HIGH (1'b1), the functional unit is configured for operations with 32-bits max size. If LOW (1'b0), the functional unit also handles 64-bit operations.
		localparam int  WIDTH        = (CONFIG32 == 1'b1) ? 32 : 64, //! Constant with size of operands and result.
		localparam int  MUL_OPS      = 4,                            //! Number of different operations performed by this functional unit.,
		localparam int  MUL_OPS_BITS = $clog2(MUL_OPS),              //! Bits needed for encoding operations.
		localparam int  MAX_CYCLES   = (CONFIG32 == 1'b1) ? 1 : 2    //! Max number of cycles a MUL operation takes to complete
)
(		input  logic                    clk_i,                       //! System clock signal.
		input  logic                    rstn_i,                      //! System reset signal (active low).
		
		input  logic [MAX_CYCLES-1:0]   flush_i,                     //! Synchronous reset. Can flush operations on 1st or 2nd stage.
		
		input  logic                    valid_i,                     //! Valid bit for operation received.
		input  logic [MUL_OPS_BITS-1:0] op_i,                        //! Operation encoded that must be performed (see table above).
		input  logic                    op_32bits_i,                 //! Set if operation uses 32-bit operands.
		
		input  logic [WIDTH-1:0]        data_rs1_i,                  //! Operand 1.
		input  logic [WIDTH-1:0]        data_rs2_i,                  //! Operand 2.
		
		input  logic                    valid_o,                     //! Valid bit for result. //output
		input  logic [WIDTH-1:0]        result_o                     //! Result of operation performed. //output
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
as__ValidCheck: assert property((valid_i) |-> (valid_o == mul_unit.valid_q[mul_unit.MAX_CYCLES-1]));

as__FlushCheck: assert property((flush_i[0]) |=> (mul_unit.valid_q[0] == 1'b0));

as__FlushCheck2: assert property((flush_i[1]) |=> (mul_unit.valid_q[1] == 1'b0));

as__NegCheck2: assert property((valid_i && (op_i == mul_unit.MULH)) |-> (mul_unit.neg_d == !mul_unit.same_sign));

as__NegCheck3: assert property((valid_i && (op_i == mul_unit.MULHSU)) |-> (mul_unit.neg_d == data_rs1_i[(mul_unit.WIDTH-1)]));

as__NegCheck4: assert property((valid_i && (op_i == mul_unit.MULHU)) |-> (mul_unit.neg_d == 1'b0));

as__ResultLowCheck: assert property((valid_i) |-> (mul_unit.result_low_d == mul_unit.data_rs1_q * mul_unit.data_rs2_q[(mul_unit.WIDTH/2)-1:0]));

as__Result2WidthCheck: assert property((valid_i && !op_32bits_i) |-> (mul_unit.result_2width == {{(mul_unit.WIDTH/2){1'b0}}, mul_unit.result_low_q} + {mul_unit.result_high_q, {(mul_unit.WIDTH/2){1'b0}}}));

as__Result2WidthDefCheck: assert property((valid_i && !op_32bits_i) |-> (mul_unit.result_2width_def == (mul_unit.neg_q_final ? (~mul_unit.result_2width + mul_unit.ONEDOUBLE) : mul_unit.result_2width)));

as__ValidCheck3: assert property((valid_i && op_32bits_i && REG_32 && !mul_unit.CONFIG32) |-> (valid_o == mul_unit.valid_q[1]));

as__ValidCheck4: assert property((valid_i && op_32bits_i && (!REG_32 || mul_unit.CONFIG32)) |-> (valid_o == mul_unit.valid_q[0]));

as__SignCheck: assert property((valid_i) |-> (mul_unit.same_sign == (~(data_rs2_i[(mul_unit.WIDTH-1)] ^ data_rs1_i[(mul_unit.WIDTH-1)]) && !op_32bits_i) || (~(data_rs2_i[31] ^ data_rs1_i[31]) && op_32bits_i)));

as__DataRs1Check2: assert property((valid_i && (op_i == mul_unit.MULH)) |-> (mul_unit.data_rs1_d == (data_rs1_i[(mul_unit.WIDTH-1)] ? ~data_rs1_i + mul_unit.ONE : data_rs1_i)));

as__DataRs2Check2: assert property((valid_i && (op_i == mul_unit.MULH)) |-> (mul_unit.data_rs2_d == (data_rs2_i[(mul_unit.WIDTH-1)] ? ~data_rs2_i + mul_unit.ONE : data_rs2_i)));

as__DataRs1Check3: assert property((valid_i && (op_i == mul_unit.MULHSU)) |-> (mul_unit.data_rs1_d == (data_rs1_i[(mul_unit.WIDTH-1)] ? ~data_rs1_i + mul_unit.ONE : data_rs1_i)));

as__DataRs2Check3: assert property((valid_i && (op_i == mul_unit.MULHSU)) |-> (mul_unit.data_rs2_d == data_rs2_i));

as__DataRs1Check4: assert property((valid_i && (op_i == mul_unit.MULHU)) |-> (mul_unit.data_rs1_d == data_rs1_i));

as__DataRs2Check4: assert property((valid_i && (op_i == mul_unit.MULHU)) |-> (mul_unit.data_rs2_d == data_rs2_i));

as__NegCheck5: assert property((valid_i && (op_i == mul_unit.MUL)) |-> (mul_unit.neg_d == !mul_unit.same_sign));

as__ValidCheck5: assert property((valid_i && !op_32bits_i) |-> (valid_o == mul_unit.valid_q[1]));

as__NegCheck6: assert property((valid_i && (op_i == 2'b01)) |-> (mul_unit.neg_d == !mul_unit.same_sign));

as__NegCheck10: assert property((valid_i && (op_i == 2'b00)) |-> (mul_unit.neg_d == !mul_unit.same_sign));

as__DataRs1Check7: assert property((valid_i && (op_i == 2'b01)) |-> (mul_unit.data_rs1_d == (data_rs1_i[(mul_unit.WIDTH-1)] ? ~data_rs1_i + mul_unit.ONE : data_rs1_i)));

as__DataRs2Check7: assert property((valid_i && (op_i == 2'b01)) |-> (mul_unit.data_rs2_d == (data_rs2_i[(mul_unit.WIDTH-1)] ? ~data_rs2_i + mul_unit.ONE : data_rs2_i)));

as__OpCheck: assert property((valid_i) |-> (mul_unit.op_q_final == op_i));

as__Op32bitsCheck: assert property((valid_i) |-> (mul_unit.op_32bits_q_final == op_32bits_i && (op_i == mul_unit.MUL)));

as__NegCheck: assert property((valid_i) |-> (mul_unit.neg_q_final == mul_unit.neg_d));

as__Result32Check: assert property((valid_i && op_32bits_i && (op_i == mul_unit.MUL)) |=> (result_o == (mul_unit.op_32bits_q_final && mul_unit.REG_32 && !mul_unit.CONFIG32 ? mul_unit.result_32_q : mul_unit.result)));

as__Result64Check: assert property((valid_i && !op_32bits_i) |-> (result_o == mul_unit.result_2width_def[mul_unit.WIDTH-1:0]));

as__ResultHighCheck: assert property((valid_i && (op_i != mul_unit.MUL)) |-> (result_o == mul_unit.result_2width_def[mul_unit.WIDTHDOUBLE-1:mul_unit.WIDTH]));

as__NoCollisionCheck: assert property((mul_unit.op_32bits_q[0] && mul_unit.valid_q[0]) |-> !(mul_unit.valid_o && !mul_unit.op_32bits_q[0]));

as__DataRs1Check: assert property((valid_i) |-> (mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs1_i[31] & op_32bits_i)) ? ~data_rs1_i + mul_unit.ONE : data_rs1_i));

as__DataRs2Check: assert property((valid_i) |-> (mul_unit.data_rs2_d == ((data_rs2_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs2_i[31] & op_32bits_i)) ? ~data_rs2_i + mul_unit.ONE : data_rs2_i));

as__ResultHighCheck_1: assert property((valid_i) |-> (mul_unit.result_high_d == mul_unit.data_rs1_q * mul_unit.data_rs2_q[mul_unit.WIDTH-1:(mul_unit.WIDTH/2)]));

as__Result32AuxCheck: assert property((valid_i && op_32bits_i && (op_i == mul_unit.MUL)) |-> (mul_unit.result_32_aux == (mul_unit.neg_q ? (~mul_unit.result_low_d[mul_unit.WIDTH-1:0] + mul_unit.ONE) : mul_unit.result_low_d[mul_unit.WIDTH-1:0])));

as__Result32Check2: assert property((valid_i && op_32bits_i && (op_i == mul_unit.MUL)) |=> (mul_unit.result_32_q == {{(mul_unit.WIDTH-32){mul_unit.result_32_q[31]}},mul_unit.result_32_q[31:0]}));

as__ResultCheck: assert property((valid_i && op_32bits_i && REG_32 && !mul_unit.CONFIG32) |-> (result_o == mul_unit.result_32_q));

as__ResultCheck2: assert property((valid_i && (op_i == mul_unit.MUL)) |-> (result_o == mul_unit.result_2width_def[mul_unit.WIDTH-1:0]));

as__ValidCheck2: assert property((valid_i && !op_32bits_i) |=> (valid_o == mul_unit.valid_q[1]));

as__DataRs1Check5: assert property((valid_i && (op_i == mul_unit.MUL)) |-> (mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs1_i[31] & op_32bits_i)) ? ~data_rs1_i + mul_unit.ONE : data_rs1_i));

as__DataRs2Check5: assert property((valid_i && (op_i == mul_unit.MUL)) |-> (mul_unit.data_rs2_d == ((data_rs2_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs2_i[31] & op_32bits_i)) ? ~data_rs2_i + mul_unit.ONE : data_rs2_i));

as__SignCheck2: assert property((valid_i && (op_i == 2'b10)) |-> (mul_unit.same_sign == ~(mul_unit.op_32bits_i ? (data_rs2_i[31] ^ data_rs1_i[31]) : (data_rs2_i[63] ^ data_rs1_i[63]))));

as__SignCheck3: assert property((valid_i && (op_i == 2'b11)) |-> (mul_unit.same_sign == ~(mul_unit.op_32bits_i ? (data_rs2_i[31] ^ data_rs1_i[31]) : (data_rs2_i[63] ^ data_rs1_i[63]))));

as__SignCheck4: assert property((valid_i && (op_i == 2'b00)) |-> (mul_unit.same_sign == ~(op_32bits_i ? (data_rs2_i[31] ^ data_rs1_i[31]) : (data_rs2_i[63] ^ data_rs1_i[63]))));

as__ResultCheck3: assert property((valid_i && (op_i == 2'b10)) |-> (result_o == mul_unit.result_2width_def[127:64]));

as__ResultCheck4: assert property((valid_i && (op_i == 2'b11)) |-> (result_o == mul_unit.result_2width_def[127:64]));

as__ResultCheck5: assert property((valid_i && (op_i == 2'b00)) |-> (result_o == mul_unit.result_2width_def[127:64]));

as__FlushCheck3: assert property((flush_i[0]) |=> (mul_unit.valid_q[1] == 1'b0));

as__FlushCheck4: assert property((flush_i[0]) |=> (mul_unit.valid_q[0] == 1'b0));

as__NoCollisionCheck2: assert property((mul_unit.op_32bits_q[0] && mul_unit.valid_q[0]) |=> !(mul_unit.valid_q[1] && !mul_unit.op_32bits_q_final));

as__SignCheck5: assert property((valid_i && (op_i == 2'b01)) |-> (mul_unit.same_sign == ~(mul_unit.op_32bits_i ? (data_rs2_i[31] ^ data_rs1_i[31]) : (data_rs2_i[63] ^ data_rs1_i[63]))));

as__ResultCheck6: assert property((valid_i && (op_i == 2'b01)) |-> (result_o == mul_unit.result_2width_def[127:64]));

as__DataRs1Check6: assert property((valid_i && (op_i == 2'b01)) |-> (mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs1_i[31] & op_32bits_i)) ? ~data_rs1_i + mul_unit.ONE : data_rs1_i));

as__DataRs2Check6: assert property((valid_i && (op_i == 2'b01)) |-> (mul_unit.data_rs2_d == ((data_rs2_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs2_i[31] & op_32bits_i)) ? ~data_rs2_i + mul_unit.ONE : data_rs2_i));

as__DataRs1Check8: assert property((valid_i && (op_i == 2'b10)) |-> (mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs1_i[31] & op_32bits_i)) ? ~data_rs1_i + mul_unit.ONE : data_rs1_i));

as__DataRs2Check8: assert property((valid_i && (op_i == 2'b10)) |-> (mul_unit.data_rs2_d == ((data_rs2_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs2_i[31] & op_32bits_i)) ? ~data_rs2_i + mul_unit.ONE : data_rs2_i));

as__NegCheck8: assert property((valid_i && (op_i == 2'b10)) |-> (mul_unit.neg_d == !mul_unit.same_sign));

as__DataRs1Check9: assert property((valid_i && (op_i == 2'b11)) |-> (mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs1_i[31] & op_32bits_i)) ? ~data_rs1_i + mul_unit.ONE : data_rs1_i));

as__DataRs2Check9: assert property((valid_i && (op_i == 2'b11)) |-> (mul_unit.data_rs2_d == ((data_rs2_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs2_i[31] & op_32bits_i)) ? ~data_rs2_i + mul_unit.ONE : data_rs2_i));

as__NegCheck9: assert property((valid_i && (op_i == 2'b11)) |-> (mul_unit.neg_d == !mul_unit.same_sign));

as__DataRs1Check10: assert property((valid_i && (op_i == 2'b00)) |-> (mul_unit.data_rs1_d == ((data_rs1_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs1_i[31] & op_32bits_i)) ? ~data_rs1_i + mul_unit.ONE : data_rs1_i));

as__DataRs2Check10: assert property((valid_i && (op_i == 2'b00)) |-> (mul_unit.data_rs2_d == ((data_rs2_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs2_i[31] & op_32bits_i)) ? ~data_rs2_i + mul_unit.ONE : data_rs2_i));

as__SignCheck6: assert property((valid_i && (op_i == 2'b01)) |-> (mul_unit.same_sign == ~(mul_unit.op_32bits_i ? (data_rs2_i[31] ^ data_rs1_i[31]) : (data_rs2_i[63] ^ data_rs1_i[63]))));

as__ResultCheck7: assert property((valid_i && (op_i == 2'b01)) |-> (result_o == mul_unit.result_2width_def[63:32]));

as__NegCheck7: assert property((valid_i && (op_i == 2'b01)) |-> (mul_unit.neg_d == data_rs1_i[(mul_unit.WIDTH-1)]));

as__DataRs1Check11: assert property((valid_i && (op_i == 2'b00)) |-> (mul_unit.data_rs1_d == (((data_rs1_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs1_i[31] & op_32bits_i)) ? ~data_rs1_i + mul_unit.ONE : data_rs1_i)));

as__DataRs2Check11: assert property((valid_i && (op_i == 2'b00)) |-> (mul_unit.data_rs2_d == (((data_rs2_i[(mul_unit.WIDTH-1)] & !op_32bits_i) | (data_rs2_i[31] & op_32bits_i)) ? ~data_rs2_i + mul_unit.ONE : data_rs2_i)));

endmodule
