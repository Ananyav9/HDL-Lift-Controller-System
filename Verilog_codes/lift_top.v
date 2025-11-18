module top_lift_with_doors (
    input  wire clk,
    input  wire rst,
    input  wire btn_set,
    input  wire [3:0] sw,
    output wire [14:0] leds,
    output wire [6:0] seg,
    output wire [3:0] an
);

    // Instantiate Lift Controller
    wire [3:0] floor;
    wire [3:0] target_floor;

    lift_go_to_target lift_inst (
        .clk(clk),
        .rst(rst),
        .btn_set(btn_set),
        .sw(sw),
        .leds(leds),
        .floor(floor),
        .target_floor(target_floor)
    );
    // MUSIC logic
    // ON unless at floor 0 or 14
    wire music_en = (floor != 4'd0 && floor != 4'd14);

    // DOOR CONTROLLER
    // odd floor  -> open for 4 × floor units
    // even floor -> open for 7 × floor units

    // Each time unit = 1 seconds (100 million cycles)

    reg door_open = 0;
    reg [33:0] door_timer = 0;
    reg [33:0] door_limit = 0;

    localparam TIME_UNIT = 100_000_000; //1; for simulations

    reg [3:0] prev_floor = 0;
    reg arrived = 0;

    always @(posedge clk) begin
        if (rst) begin
            door_open  <= 0;
            door_timer <= 0;
            door_limit <= 0;
            arrived    <= 0;
        end else begin
            // Detect arrival
            if (prev_floor != floor && floor == target_floor) begin
                arrived    <= 1;
                door_timer <= 0;

                if (floor == 0) begin
                    // 1 second at floor 0
                    door_limit <= TIME_UNIT;
                end else if (floor[0] == 1'b1) begin
                    // odd floors
                    door_limit <= (4 * floor) * TIME_UNIT;
                end else begin
                    // even floors
                    door_limit <= (7 * floor) * TIME_UNIT;
                end

                door_open <= 1;
            end

            prev_floor <= floor;

            // If moving → door closes
            if (floor != target_floor) begin
                arrived    <= 0;
                door_open  <= 0;
                door_limit <= 0;
                door_timer <= 0;
            end
            
            // Door timer logic
            if (arrived && door_open) begin
                if (door_timer < door_limit)
                    door_timer <= door_timer + 1;
                else
                    door_open <= 0;   // close after timeout
            end
        end
    end
    
    // 7-SEGMENT DISPLAY (Music + Door open or close)
    sevenseg_display sseg (
        .clk(clk),
        .music_en(music_en),
        .door_open(door_open),
        .seg(seg),
        .an(an)
    );

endmodule
