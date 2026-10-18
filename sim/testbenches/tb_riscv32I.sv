
`timescale 1ns/1ps

module tb_riscv32I;

    logic clk = 0;
    logic rst = 1;

    riscv32I dut (
        .clk(clk),
        .rst(rst)
    );

    // Generate a clock with a 10 ns period.
    always #5 clk = ~clk;

    initial begin
        // Create a waveform file.
        $dumpfile("riscv32I.vcd");
        $dumpvars(0, tb_riscv32I);

        // Keep reset active for two clock cycles.
        repeat (2) @(negedge clk);
        rst = 0;

        // Let the CPU execute the test program.
        repeat (35) @(negedge clk);

        // Inspect the data written by SW.
        $display("Memory[0x2000] = %02h",
                 dut.memory.memory[16'h2000]);
        $display("Memory[0x2001] = %02h",
                 dut.memory.memory[16'h2001]);
        $display("Memory[0x2002] = %02h",
                 dut.memory.memory[16'h2002]);
        $display("Memory[0x2003] = %02h",
                 dut.memory.memory[16'h2003]);

        $finish;
    end

    // Track the processor's progress.
    initial begin
        $monitor(
            "t=%0t state=%0d pc=%08h IR=%08h ALUOUT=%08h",
            $time, dut.state, dut.pc, dut.IR, dut.ALUOUT
        );
    end

endmodule
