module alu_8bit (
    input  wire [7:0] A,        // Operand A
    input  wire [7:0] B,        // Operand B
    input  wire [2:0] ALU_Sel,  // Operation selector
    output reg  [7:0] ALU_Out,  // Result
    output wire        Carry,    // Carry / Borrow out
    output wire        Zero,     // Zero flag
    output wire        Overflow  // Overflow flag (signed arithmetic)
);

    // Internal 9-bit signal to catch carry-out from add/sub
    reg [8:0] result_ext;

    // Opcode definitions
    localparam ADD    = 3'b000;
    localparam SUB    = 3'b001;
    localparam AND_OP = 3'b010;
    localparam OR_OP  = 3'b011;
    localparam XOR_OP = 3'b100;
    localparam NOT_OP = 3'b101;
    localparam SHL    = 3'b110;   // Logical shift left by 1
    localparam SHR    = 3'b111;   // Logical shift right by 1

    always @(*) begin
        result_ext = 9'b0;
        case (ALU_Sel)
            ADD:    begin
                        result_ext = {1'b0, A} + {1'b0, B};
                        ALU_Out    = result_ext[7:0];
                    end
            SUB:    begin
                        result_ext = {1'b0, A} - {1'b0, B};
                        ALU_Out    = result_ext[7:0];
                    end
            AND_OP: begin
                        ALU_Out    = A & B;
                        result_ext = {1'b0, ALU_Out};
                    end
            OR_OP:  begin
                        ALU_Out    = A | B;
                        result_ext = {1'b0, ALU_Out};
                    end
            XOR_OP: begin
                        ALU_Out    = A ^ B;
                        result_ext = {1'b0, ALU_Out};
                    end
            NOT_OP: begin
                        ALU_Out    = ~A;
                        result_ext = {1'b0, ALU_Out};
                    end
            SHL:    begin
                        ALU_Out    = A << 1;
                        result_ext = {A[7], ALU_Out}; // bit shifted out -> carry
                    end
            SHR:    begin
                        ALU_Out    = A >> 1;
                        result_ext = {A[0], ALU_Out}; // bit shifted out -> carry
                    end
            default: begin
                        ALU_Out    = 8'b0;
                        result_ext = 9'b0;
                    end
        endcase
    end

    // Carry/borrow flag: only meaningful for ADD/SUB/Shift, harmless otherwise
    assign Carry = result_ext[8];

    // Zero flag: result is all zeros
    assign Zero = (ALU_Out == 8'b0);

    // Overflow flag for signed ADD/SUB
    assign Overflow = (ALU_Sel == ADD) ?
                        ((A[7] == B[7]) && (ALU_Out[7] != A[7])) :
                       (ALU_Sel == SUB) ?
                        ((A[7] != B[7]) && (ALU_Out[7] != A[7])) :
                        1'b0;

endmodule
