module ALU
(
    input wire [31:0] a,
    input wire [31:0] b,
    input alusel_t alu_sel,
    output logic [31:0] alu_out
);
   import types::*;

    always_comb begin
        case (alu_sel)
            AND_OP: alu_out = a & b;
            OR_OP : alu_out = a | b;
            XOR_OP: alu_out = a ^ b;
            ADD_OP: alu_out = a + b;
            SUB_OP: alu_out = a - b;
            SLL_OP: alu_out = a << b[4:0];
            SRL_OP: alu_out = a >> b[4:0];
            SRA_OP: alu_out = $signed(a) <<< b[4:0];
            SLT_OP: alu_out = $signed(a) < $signed(b) ? 32'b1 : 32'b0;
            SLTU_OP: alu_out = a < b ? 32'b1 : 32'b0;
            default: alu_out =  32'b0;
        endcase
    end

endmodule