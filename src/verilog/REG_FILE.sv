module REG_FILE(
    input  logic        clk,
    input  logic        w,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] write_data,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] register_file [31:0];

    always_ff @( posedge clk ) begin : register_write
        if (w) begin
            if(rd != 5'b0) begin
                register_file[rd] <= write_data;
            end
        end
    end

    always_comb begin : register_read
        read_data1 = (rs1 == 5'd0) ? 32'b0 : register_file[rs1];
        read_data2 = (rs2 == 5'd0) ? 32'b0 : register_file[rs2];
    end
endmodule