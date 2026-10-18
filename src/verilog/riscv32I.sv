module riscv32I
(
  input wire clk,
  input wire rst
);
  import types::*;
  fsmState_t state;
  fsmState_t nextState;

  logic branch_taken;
  logic [31:0] ALUOUT;
  logic [31:0] A;
  logic [31:0] B;
  logic [31:0] IR;
  logic [31:0] MD;
  logic [31:0] instr_pc;

  logic [31:0] alu_input_a;
  logic [31:0] alu_input_b;
  logic [31:0] alu_output;
  alusel_t alu_sel;

  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [4:0] rd;
  logic reg_write_flag;
  logic [31:0] rs1_data;
  logic [31:0] rs2_data;
  logic [31:0] reg_write_data;

  logic [31:0] addr;
  logic mem_write_flag;
  logic [5:0] mem_size;
  logic mem_sign_ext;
  logic [31:0] mem_write_data;
  logic [31:0] mem_read_data;

  logic [31:0] imm;
  logic [2:0] func3;
  logic [6:0] func7;

  logic regWrite;
  logic [1:0] regWriteSrc;
  logic memWrite;
  logic memRead;
  logic branch;
  logic jump;
  logic aluSrc;
  logic [1:0] aluOp;

  logic [31:0] pc;
  logic [31:0] memory_base = 32'h00002000;

  ALU alu(
    .a(alu_input_a),
    .b(alu_input_b),
    .alu_sel(alu_sel),
    .alu_out(alu_output)
  );

  REG_FILE regester(
    .clk(clk),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .w(reg_write_flag),
    .write_data(reg_write_data),
    .read_data1(rs1_data),
    .read_data2(rs2_data)
  );

  MEM memory(
    .clk(clk),
    .addr(addr),
    .w(mem_write_flag),
    .mem_size(mem_size),
    .mem_sign_ext(mem_sign_ext),
    .write_data(mem_write_data),
    .read_data(mem_read_data)
  );

  IDECODE decode(
    .instruction(IR),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .imm(imm),
    .func3(func3),
    .func7(func7),
    .regWrite(regWrite),
    .regWriteSrc(regWriteSrc),
    .memWrite(memWrite),
    .memRead(memRead),
    .branch(branch),
    .jump(jump),
    .aluSrc(aluSrc),
    .aluOp(aluOp)
  );

  always_ff @(posedge clk) begin
    if (rst) begin
      state <= FETCH;
      pc <= 32'b0;
      instr_pc <= 32'b0;
    end else begin
      state <= nextState;

      case (state)
        FETCH: begin
          IR <= mem_read_data;
          instr_pc <= pc;
        end

        DECODE: begin
          A <= rs1_data;
          B <= rs2_data;
        end

        EXECUTE: begin
          ALUOUT <= alu_output;

          if (branch) begin
            if (branch_taken)
              pc <= alu_output;
            else
              pc <= instr_pc + 32'd4;
          end else if (jump) begin
            if (IR[6:0] == 7'b1100111)
              pc <= {alu_output[31:1], 1'b0};
            else
              pc <= alu_output;
          end
        end

        MEMORY: begin
          MD <= mem_read_data;
          if (memWrite)
            pc <= instr_pc + 32'd4;
        end

        WRITEBACK: begin
          pc <= instr_pc + 32'd4;
        end
      endcase
    end
  end

  always_comb begin
    nextState      = state;
    branch_taken   = 1'b0;
    alu_input_a    = 32'b0;
    alu_input_b    = 32'b0;
    alu_sel        = ADD_OP;

    addr           = 32'b0;
    mem_size       = 6'd32;
    mem_sign_ext   = 1'b0;
    mem_write_flag = 1'b0;
    mem_write_data = 32'b0;

    reg_write_flag = 1'b0;
    reg_write_data = 32'b0;

    case (state)
      FETCH: begin
        addr = pc;
        mem_size = 6'd32;
        nextState = DECODE;
      end

      DECODE: begin
        nextState = EXECUTE;
      end

      EXECUTE: begin
        if (branch || (jump && IR[6:0] == 7'b1101111) ||
            IR[6:0] == 7'b0010111)
          alu_input_a = instr_pc;
        else if (IR[6:0] == 7'b0110111)
          alu_input_a = 32'b0;
        else
          alu_input_a = A;

        alu_input_b = (branch || jump || aluSrc ||
                       IR[6:0] == 7'b0010111 ||
                       IR[6:0] == 7'b0110111) ? imm : B;

        if (branch || jump || IR[6:0] == 7'b0010111 ||
            IR[6:0] == 7'b0110111) begin
          alu_sel = ADD_OP;
        end else begin
          case (aluOp)
            2'b00: alu_sel = ADD_OP;
            2'b01: alu_sel = SUB_OP;
            2'b10: begin
              case (func3)
                3'b000: alu_sel = func7[5] ? SUB_OP : ADD_OP;
                3'b001: alu_sel = SLL_OP;
                3'b010: alu_sel = SLT_OP;
                3'b011: alu_sel = SLTU_OP;
                3'b100: alu_sel = XOR_OP;
                3'b101: alu_sel = func7[5] ? SRA_OP : SRL_OP;
                3'b110: alu_sel = OR_OP;
                3'b111: alu_sel = AND_OP;
                default: alu_sel = ADD_OP;
              endcase
            end
            default: alu_sel = ADD_OP;
          endcase
        end

        if (branch) begin
          case (func3)
            3'b000: branch_taken = (A == B);
            3'b001: branch_taken = (A != B);
            3'b100: branch_taken = ($signed(A) < $signed(B));
            3'b101: branch_taken = ($signed(A) >= $signed(B));
            3'b110: branch_taken = (A < B);
            3'b111: branch_taken = (A >= B);
            default: branch_taken = 1'b0;
          endcase

          nextState = FETCH;
        end else if (jump) begin
          nextState = WRITEBACK;
        end else if (memRead || memWrite) begin
          nextState = MEMORY;
        end else begin
          nextState = WRITEBACK;
        end
      end

      MEMORY: begin
        addr = ALUOUT + memory_base;
        mem_write_flag = memWrite;
        mem_write_data = B;

        if (memRead || memWrite) begin
          case (func3)
            3'b000: begin
              mem_size = 6'd8;
              mem_sign_ext = 1'b1;
            end
            3'b001: begin
              mem_size = 6'd16;
              mem_sign_ext = 1'b1;
            end
            3'b010: begin
              mem_size = 6'd32;
              mem_sign_ext = 1'b0;
            end
            3'b100: begin
              mem_size = 6'd8;
              mem_sign_ext = 1'b0;
            end
            3'b101: begin
              mem_size = 6'd16;
              mem_sign_ext = 1'b0;
            end
            default: begin
              mem_size = 6'd32;
              mem_sign_ext = 1'b0;
            end
          endcase
        end

        if (memWrite)
          nextState = FETCH;
        else if (memRead)
          nextState = WRITEBACK;
        else
          nextState = FETCH;
      end

      WRITEBACK: begin
        if (regWrite) begin
          reg_write_flag = 1'b1;

          case (regWriteSrc)
            2'b00: reg_write_data = ALUOUT;
            2'b01: reg_write_data = MD;
            2'b10: reg_write_data = instr_pc + 32'd4;
            2'b11: reg_write_data = imm;
            default: reg_write_data = 32'b0;
          endcase
        end

        nextState = FETCH;
      end

      default: begin
        nextState = FETCH;
      end
    endcase
  end

endmodule
