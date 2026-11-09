module alu_prop
#(
		parameter ASSERT_INPUTS = 0,
		parameter   CONFIG32  = 1'b0, //! If HIGH (1'b1), the functional unit is configured for operations with 32-bits max size. If LOW (1'b0), the functional unit also handles 64-bit operations.
		localparam  WIDTH     = (CONFIG32 == 1'b1) ? 32 : 64,   //! Constant with size of operands and result.
		localparam  DATA_WIDTH      = 4,                        //! Different types of size of `op_size_i` (BYTE, HALF_WORD, WORD, DOUBLE_WORD).
		localparam  DATA_WIDTH_BITS = $clog2(DATA_WIDTH),       //! Bits needed for encoding `op_size_i`.
		localparam  ALU_OPS      = 9,                           //! Number of different operations performed by this functional unit.
		localparam  ALU_OPS_BITS = $clog2(ALU_OPS)              //! Bits needed for encoding operations.
)
(		input  logic                        valid_i,      //! Valid bit for operation received.
		input  logic [ALU_OPS_BITS-1:0]     op_i,         //! Operation encoded that must be performed (see table above).
		input  logic                        op_unsigned_i,//! Set if operation is unsigned.
		input  logic [DATA_WIDTH_BITS-1:0]  op_size_i,    //! Used for encoding the size. (00=BYTE, 01=HALF_WORD, 10=WORD, 11=DOUBLE_WORD) 
		
		input  logic [WIDTH-1:0]            data_rs1_i,   //! Operand 1.
		input  logic [WIDTH-1:0]            data_rs2_i,   //! Operand 2.
		
		input  logic                        valid_o,      //! Valid bit for result. //output
		input  logic [WIDTH-1:0]            result_o      //! Result of operation performed. //output
	);

//==============================================================================
// Local Parameters
//==============================================================================

genvar j;
//default clocking cb @(posedge clk);
//endclocking
//default disable iff (!rst_n);

// Re-defined wires 

// Symbolics and Handshake signals

//==============================================================================
// Modeling
//==============================================================================


//====DESIGNER-ADDED-SVA====//
as__ValidOutputMatchesValidInput: assert property(valid_i |-> valid_o);

as__AddOperationResult: assert property((valid_i && op_i == alu.ADD && alu.CONFIG32 == 1'b1) |-> result_o == data_rs1_i + data_rs2_i);

as__SubOperationResult: assert property((valid_i && op_i == alu.SUB && alu.CONFIG32 == 1'b1) |-> result_o == data_rs1_i - data_rs2_i);

as__XorOperationResult: assert property((valid_i && op_i == alu.XOR) |-> result_o == data_rs1_i ^ data_rs2_i);

as__OrOperationResult: assert property((valid_i && op_i == alu.OR) |-> result_o == data_rs1_i | data_rs2_i);

as__SraOperationSignedShift: assert property((valid_i && op_i == alu.SRA && alu.CONFIG32 == 1'b1) |-> result_o == {$signed(data_rs1_i) >>> data_rs2_i[5:0]});

as__SrlOperationLogicalShiftRight: assert property((valid_i && op_i == alu.SRL && alu.CONFIG32 == 1'b1) |-> result_o == data_rs1_i >> data_rs2_i[5:0]);

as__SllOperationLogicalShiftLeft: assert property((valid_i && op_i == alu.SLL && alu.CONFIG32 == 1'b1) |-> result_o == data_rs1_i << data_rs2_i[5:0]);

as__SltOperationUnsigned: assert property((valid_i && op_i == alu.SLT && op_unsigned_i && alu.CONFIG32 == 1'b1) |-> result_o == {{(WIDTH-1){1'b0}}, data_rs1_i < data_rs2_i});

as__SltOperationSigned: assert property((valid_i && op_i == alu.SLT && !op_unsigned_i && alu.CONFIG32 == 1'b1) |-> result_o == {{(WIDTH-1){1'b0}}, $signed(data_rs1_i) < $signed(data_rs2_i)});

as__DefaultOperationResultZero: assert property((valid_i && (op_i >= ALU_OPS)) |-> result_o == {WIDTH{1'b0}});

as__AddOperationWordSizeSignExtend: assert property((valid_i && op_i == alu.ADD && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> (result_o[31:0] == data_rs1_i[31:0] + data_rs2_i[31:0]) && (&{result_o[63:32]} == result_o[31]));

as__AddOperationNonWordSize: assert property((valid_i && op_i == alu.ADD && alu.CONFIG32 == 1'b0 && op_size_i != alu.WORD) |-> result_o == data_rs1_i + data_rs2_i);

as__SubOperationWordSizeSignExtend: assert property((valid_i && op_i == alu.SUB && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> (result_o[31:0] == data_rs1_i[31:0] - data_rs2_i[31:0]) && (&{result_o[63:32]} == result_o[31]));

as__SubOperationNonWordSize: assert property((valid_i && op_i == alu.SUB && alu.CONFIG32 == 1'b0 && op_size_i != alu.WORD) |-> result_o == data_rs1_i - data_rs2_i);

as__SraOperationNonWordSize: assert property((valid_i && op_i == alu.SRA && alu.CONFIG32 == 1'b0 && op_size_i != alu.WORD) |-> result_o == {$signed(data_rs1_i) >>> data_rs2_i[5:0]});

as__SrlOperationWordSizeSignExtend: assert property((valid_i && op_i == alu.SRL && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> (result_o[31:0] == data_rs1_i[31:0] >> data_rs2_i[4:0]) && (&{result_o[63:32]} == result_o[31]));

as__SrlOperationNonWordSize: assert property((valid_i && op_i == alu.SRL && alu.CONFIG32 == 1'b0 && op_size_i != alu.WORD) |-> result_o == data_rs1_i >> data_rs2_i[5:0]);

as__SllOperationWordSizeSignExtend: assert property((valid_i && op_i == alu.SLL && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> (result_o[31:0] == data_rs1_i[31:0] << data_rs2_i[4:0]) && (&{result_o[63:32]} == result_o[31]));

as__SllOperationNonWordSize: assert property((valid_i && op_i == alu.SLL && alu.CONFIG32 == 1'b0 && op_size_i != alu.WORD) |-> result_o == data_rs1_i << data_rs2_i[5:0]);

as__XorOperationNonConfig32: assert property((valid_i && op_i == alu.XOR && alu.CONFIG32 == 1'b0) |-> result_o == data_rs1_i ^ data_rs2_i);

as__OrOperationNonConfig32: assert property((valid_i && op_i == alu.OR && alu.CONFIG32 == 1'b0) |-> result_o == data_rs1_i | data_rs2_i);

as__SltOperationUnsignedNonConfig32: assert property((valid_i && op_i == alu.SLT && op_unsigned_i && alu.CONFIG32 == 1'b0) |-> result_o == {{(WIDTH-1){1'b0}}, data_rs1_i < data_rs2_i});

as__SltOperationSignedNonConfig32: assert property((valid_i && op_i == alu.SLT && !op_unsigned_i && alu.CONFIG32 == 1'b0) |-> result_o == {{(WIDTH-1){1'b0}}, $signed(data_rs1_i) < $signed(data_rs2_i)});

as__DefaultOperationResultZeroNonConfig32: assert property((valid_i && (op_i >= ALU_OPS) && alu.CONFIG32 == 1'b0) |-> result_o == {WIDTH{1'b0}});

as__ValidOutputEqualsValidInput: assert property(valid_o == valid_i);

as__ValidOutputOnlyWhenValidInput: assert property(!valid_i |-> !valid_o);

as__SltOperationUnsignedEqualOperands: assert property((valid_i && op_i == alu.SLT && op_unsigned_i && data_rs1_i == data_rs2_i) |-> result_o == { {(WIDTH-1){1'b0}}, 1'b0 });

as__SltOperationSignedEqualOperands: assert property((valid_i && op_i == alu.SLT && !op_unsigned_i && data_rs1_i == data_rs2_i) |-> result_o == { {(WIDTH-1){1'b0}}, 1'b0 });

as__ResultWidthMatchesWidth: assert property((valid_i && (op_i == alu.ADD || op_i == alu.SUB)) |-> $bits(result_o) == WIDTH);

as__LogicalOperationsResultWidth: assert property((valid_i && (op_i == alu.XOR || op_i == alu.OR || op_i == alu.AND)) |-> $bits(result_o) == WIDTH);

as__ShiftAmountRange: assert property((valid_i && (op_i == alu.SRA || op_i == alu.SRL || op_i == alu.SLL)) |-> (alu.CONFIG32 == 1'b1 ? (data_rs2_i[5:0] < WIDTH) : ((op_size_i == alu.WORD ? data_rs2_i[4:0] < 32 : data_rs2_i[5:0] < WIDTH))));

as__SltResultIsBoolean: assert property((valid_i && op_i == alu.SLT) |-> (result_o[WIDTH-1:1] == { (WIDTH-1){1'b0} }) && (result_o[0] == 1'b0 || result_o[0] == 1'b1));

as__WordSizeSignExtensionUpperBits: assert property((valid_i && (op_i == alu.ADD || op_i == alu.SUB) && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> (&{result_o[63:32]} == result_o[31]));

as__SraWordSizeSignExtensionUpperBits: assert property((valid_i && op_i == alu.SRA && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> (&{result_o[63:32]} == result_o[31]));

as__SrlWordSizeSignExtensionUpperBits: assert property((valid_i && op_i == alu.SRL && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> (&{result_o[63:32]} == result_o[31]));

as__SllWordSizeSignExtensionUpperBits: assert property((valid_i && op_i == alu.SLL && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> (&{result_o[63:32]} == result_o[31]));

as__AddWordSizeLowerBits: assert property((valid_i && op_i == alu.ADD && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> result_o[31:0] == data_rs1_i[31:0] + data_rs2_i[31:0]);

as__SubWordSizeLowerBits: assert property((valid_i && op_i == alu.SUB && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> result_o[31:0] == data_rs1_i[31:0] - data_rs2_i[31:0]);

as__SraWordSizeLowerBits: assert property((valid_i && op_i == alu.SRA && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> result_o[31:0] == $signed(data_rs1_i[31:0]) >>> data_rs2_i[4:0]);

as__SrlWordSizeLowerBits: assert property((valid_i && op_i == alu.SRL && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> result_o[31:0] == data_rs1_i[31:0] >> data_rs2_i[4:0]);

as__SllWordSizeLowerBits: assert property((valid_i && op_i == alu.SLL && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> result_o[31:0] == data_rs1_i[31:0] << data_rs2_i[4:0]);

as__SltResultCorrectness: assert property((valid_i && op_i == alu.SLT) |-> (result_o[0] == (op_unsigned_i ? (data_rs1_i < data_rs2_i) : ($signed(data_rs1_i) < $signed(data_rs2_i)))));

as__AndOperationResult: assert property((valid_i && op_i == alu.AND) |-> result_o == data_rs1_i & data_rs2_i);

as__SraOperationWordSizeSignExtend: assert property((valid_i && op_i == alu.SRA && alu.CONFIG32 == 1'b0 && op_size_i == alu.WORD) |-> (result_o[31:0] == $signed(data_rs1_i[31:0]) >>> data_rs2_i[4:0]) && (&{result_o[63:32]} == result_o[31]));

as__AndOperationNonConfig32: assert property((valid_i && op_i == alu.AND && alu.CONFIG32 == 1'b0) |-> result_o == data_rs1_i & data_rs2_i);

endmodule
