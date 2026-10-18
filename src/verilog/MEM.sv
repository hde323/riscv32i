module MEM (
    input logic clk,
    input logic [31:0] addr,
    input logic w,
    input logic [5:0] mem_size,
    input logic mem_sign_ext,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);

    logic [7:0] memory [32767:0];

    initial begin
        $readmemh("const/program.hex", memory);
    end

    always_ff @( posedge clk ) begin : write 
        if (w) begin
            if(mem_size == 32) begin
                memory[addr] <= write_data[7:0];
                memory[addr + 1] <= write_data[15:8];
                memory[addr + 2] <= write_data[23:16];
                memory[addr + 3] <= write_data[31:24];
            end else if(mem_size == 16) begin 
                memory[addr] <= write_data[7:0];
                memory[addr + 1] <= write_data[15:8];
            end else if(mem_size == 8) begin
                memory[addr] <= write_data[7:0];
            end
        end
    end

    always_comb begin : read
        read_data = 32'b0;
        if (!w) begin
            if(mem_size == 32) begin
                read_data[7:0] = memory[addr];
                read_data[15:8] = memory[addr + 1];
                read_data[23:16] = memory[addr + 2];
                read_data[31:24] = memory[addr + 3];
            end else if(mem_size == 16) begin 
                read_data[7:0] = memory[addr];
                read_data[15:8] = memory[addr + 1];
                if (!mem_sign_ext) begin
                    read_data[31:16] =  16'b0;
                end else begin 
                    read_data[31:16] = {16{read_data[15]}};
                end
            end else if(mem_size == 8) begin 
                read_data[7:0] = memory[addr];
                if (!mem_sign_ext) begin
                    read_data[31:8] =  24'b0;
                end else begin 
                    read_data[31:8] = {24{read_data[7]}};
                end
            end
        end
    end
endmodule