module IDECODE 
    import types::alusel_t;
    import types::_t;
(
    input logic [31:0] instruction,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic [31:0] imm,
    output logic [2:0] func3,
    output logic [6:0] func7,
    output logic regWrite,
    output logic [1:0] regWriteSrc,
    output logic memWrite,
    output logic memRead,
    output logic branch,
    output logic jump,
    output logic aluSrc,
    output logic [1:0] aluOp
);

    logic [9:0] controls;

    always_comb begin : decode
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd = 5'b0;
        imm = {32{instruction[31]}};
        func3 = 3'b0;
        func7 = 7'b0;
        controls = 10'b0;
        case (instruction[6:0])
            7'b0110011:  begin //r-type instructions
                func7 = instruction[31:25];
                rs2 = instruction[24:20];
                rs1 = instruction[19:15];
                func3 = instruction[14:12];
                rd = instruction[11:7];
                controls = 10'b1_00_0_0_0_0_0_10;
            end 
            7'b0010011:  begin //i-type instructions alu
                imm[11:0] = instruction[31:20];
                rs1 = instruction[19:15];
                func3 = instruction[14:12];
                func7 = instruction[31:25];
                rd = instruction[11:7];
                controls = 10'b1_00_0_0_0_0_1_10;
            end
            7'b0000011:  begin //load instructions
                imm[11:0] = instruction[31:20];
                rs1 = instruction[19:15];
                func3 = instruction[14:12];
                rd = instruction[11:7];
                controls = 10'b1_01_0_1_0_0_1_00;
            end 
            7'b0100011:  begin //store instructions
                imm[11:0] = {instruction[31:25],instruction[11:7]}; 
                rs2 = instruction[24:20];
                rs1 = instruction[19:15];
                func3 = instruction[14:12];
                rd = instruction[11:7];
                controls = 10'b0_xx_1_0_0_0_1_00;
            end
            7'b1100011:  begin //conditional branches
                imm[12:0] = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; 
                rs2 = instruction[24:20];
                rs1 = instruction[19:15];
                func3 = instruction[14:12];
                rd = instruction[11:7];
                controls = 10'b0_xx_0_0_1_0_1_00;
            end
            7'b0110111:  begin //u upper immediate 
                imm[11:0] = 12'b0;
                imm[31:12] = instruction[31:12];
                rd = instruction[11:7];
                controls = 10'b1_11_0_0_0_0_x_11;
            end
            7'b0010111:  begin //pc upper immediate
                imm[31:12] = instruction[31:12];
                rd = instruction[11:7];
                controls = 10'b1_11_0_0_0_0_x_00;
            end
            7'b1101111:  begin //jal
                imm[20:0] = {instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
                rd = instruction[11:7];
                controls = 10'b1_10_0_0_0_1_1_00;
            end
            7'b1100111:  begin //jalr
                imm[11:0] = instruction[31:20];
                rs1 = instruction[19:15];
                func3 = instruction[14:12];
                rd = instruction[11:7];
                controls = 10'b1_10_0_0_0_1_1_00;
            end
            7'b0001111:  begin //fence
                imm[11:0] = instruction[31:20];
                rs1 = instruction[19:15];
                func3 = instruction[14:12];
                rd = instruction[11:7];
                controls = 10'b0_xx_0_0_0_0_x_11;
            end
            7'b1110011:  begin //system
                imm[11:0] = instruction[31:20];
                rs1 = instruction[19:15];
                func3 = instruction[14:12];
                rd = instruction[11:7];
                controls = 10'b0_xx_0_0_0_0_x_11;
            end
        endcase
    end

    assign {regWrite,regWriteSrc,memWrite,memRead,branch,jump,aluSrc,aluOp} = controls;

endmodule