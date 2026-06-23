`timescale 1ns/1ps

module tb_alu_8bit;

    reg  [7:0] A, B;
    reg  [2:0] ALU_Sel;
    wire [7:0] ALU_Out;
    wire       Carry, Zero, Overflow;

    integer i;
    integer errors = 0;

    alu_8bit DUT (
        .A       (A),
        .B       (B),
        .ALU_Sel (ALU_Sel),
        .ALU_Out (ALU_Out),
        .Carry   (Carry),
        .Zero    (Zero),
        .Overflow(Overflow)
    );

    task run_test(input [7:0] a_in, input [7:0] b_in, input [2:0] sel,
                  input [7:0] expected, input [31:0] op_name);
        begin
            A = a_in; B = b_in; ALU_Sel = sel;
            #10;
            if (ALU_Out !== expected) begin
                errors = errors + 1;
                $display("FAIL: %s  A=%b B=%b  Out=%b (exp %b)  Carry=%b Zero=%b Ovf=%b",
                          op_name, A, B, ALU_Out, expected, Carry, Zero, Overflow);
            end else begin
                $display("PASS: %s  A=%b B=%b  Out=%b  Carry=%b Zero=%b Ovf=%b",
                          op_name, A, B, ALU_Out, Carry, Zero, Overflow);
            end
        end
    endtask

    initial begin
        $dumpfile("alu_8bit.vcd");
        $dumpvars(0, tb_alu_8bit);

        $display("================ ALU 8-bit Testbench ================");

        run_test(8'd15, 8'd10, 3'b000, 8'd25,           "ADD       ");
        run_test(8'd10, 8'd15, 3'b001, -8'd5,           "SUB(neg)  ");
        run_test(8'd200,8'd100,3'b000, (8'd200+8'd100), "ADD(ovfl) ");
        run_test(8'hF0, 8'h0F, 3'b010, 8'h00,           "AND       ");
        run_test(8'hF0, 8'h0F, 3'b011, 8'hFF,           "OR        ");
        run_test(8'hFF, 8'h0F, 3'b100, 8'hF0,           "XOR       ");
        run_test(8'h0F, 8'h00, 3'b101, 8'hF0,           "NOT       ");
        run_test(8'h81, 8'h00, 3'b110, 8'h02,           "SHL       ");
        run_test(8'h81, 8'h00, 3'b111, 8'h40,           "SHR       ");
        run_test(8'h00, 8'h00, 3'b000, 8'h00,           "ADD(zero) ");

        for (i = 0; i < 20; i = i + 1) begin
            A       = $random;
            B       = $random;
            ALU_Sel = $random % 8;
            #10;
            $display("RAND: Sel=%0d A=%b B=%b -> Out=%b Carry=%b Zero=%b Ovf=%b",
                      ALU_Sel, A, B, ALU_Out, Carry, Zero, Overflow);
        end

        $display("=======================================================");
        if (errors == 0)
            $display("ALL DIRECTED TESTS PASSED");
        else
            $display("%0d DIRECTED TEST(S) FAILED", errors);
        $display("=======================================================");

        #10 $finish;
    end

endmodule
