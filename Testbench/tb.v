`timescale 1ns/1ps

module tb_lift_fast;

    reg clk = 0;
    reg rst = 1;
    reg btn_set = 0;
    reg [3:0] sw = 0;

    wire [14:0] leds;
    wire [6:0] seg;
    wire [3:0] an;

    // DUT
    top_lift_with_doors dut (
        .clk(clk),
        .rst(rst),
        .btn_set(btn_set),
        .sw(sw),
        .leds(leds),
        .seg(seg),
        .an(an)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        // --------------------
        // RESET
        // --------------------
        rst = 1;
        #20;
        rst = 0;

        // --------------------
        // TEST 1: go to floor 5
        // --------------------
        sw = 4'd5;
        #10;
        btn_set = 1;
        #10;
        btn_set = 0;

        // Wait enough simulated time (scaled for fast sim)
        #5000;

        // --------------------
        // TEST 2: go to floor 0
        // --------------------
        sw = 4'd0;
        #10;
        btn_set = 1;
        #10;
        btn_set = 0;

        #3000;

        // --------------------
        // TEST 3: go to floor 10
        // --------------------
        sw = 4'd10;
        #10;
        btn_set = 1;
        #10;
        btn_set = 0;

        #8000;

        $finish;
    end

endmodule
