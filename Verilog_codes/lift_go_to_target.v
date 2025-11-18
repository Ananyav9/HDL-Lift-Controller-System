module lift_go_to_target (
    input wire clk,           // 100 MHz clock
    input wire rst,           // synchronous reset (active high)
    input wire btn_set,       // button to confirm input
    input wire [3:0] sw,      // switches representing target floor
    output reg [14:0] leds,   // LED indicating current floor
    output reg [3:0] floor,    // current floor
    output reg  [3:0] target_floor

);
    // --- Movement timing
    parameter integer MOVE_TICKS =  50_000_000; //0.5; for simualation// 0.5s per floor CHANGE
    reg [31:0] move_counter = 0;

    //Button synchronizer
    reg b0, b1;
    always @(posedge clk) begin
        b0 <= btn_set;
        b1 <= b0;
    end
    wire set_pulse = b0 & ~b1;   // detect rising edge

   // Target floor register
    reg [3:0] target_floor = 0;

    always @(posedge clk) begin
        if (rst) begin
            target_floor <= 4'd0;
        end else if (set_pulse) begin
            target_floor <= sw;       // latch target on button press
        end
    end

    // Lift movement control
    always @(posedge clk) begin
        if (rst) begin
            floor <= 4'd0;
            move_counter <= 0;
        end else begin
            if (floor == target_floor) begin
                move_counter <= 0;  // do nothing
            end else begin
                // countdown timer to move 1 floor
                if (move_counter + 1 >= MOVE_TICKS) begin
                    move_counter <= 0;
                    // Move one floor toward target:
                    if (floor < target_floor)
                        floor <= floor + 1;
                    else if (floor > target_floor)
                        floor <= floor - 1;
                end else begin
                    move_counter <= move_counter + 1;
                end
            end
        end
    end

    // LED indicator (one-hot encoding)
    always @(posedge clk) begin
        leds <= 16'b0;
        leds[floor] <= 1'b1;
    end

endmodule
