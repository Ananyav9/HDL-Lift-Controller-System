module sevenseg_display (
    input  wire clk,          // 100 MHz
    input  wire music_en,     // 1 = music on
    input  wire door_open,    // 1 = door open
    output reg  [6:0] seg,
    output reg  [3:0] an
);

    // segment patterns (active low)
    localparam BLANK = 7'b1111111;
    localparam NSEG  = 7'b0101011; // "n" for music
    localparam OSEG  = 7'b1000000; // "O" for opened door
    localparam CSEG  = 7'b1000110; // "C" for closed door

    // multiplexing refresh counter
    reg [15:0] refresh = 0;
    always @(posedge clk) refresh <= refresh + 1;

    wire [1:0] digit = refresh[15:14];

    always @(*) begin
        // disable all digits (active low)
        an = 4'b1111;
        seg = BLANK;

        case (digit)
            2'd0: begin
                // Digit 0 → music indicator
                an = 4'b1110;
                seg = music_en ? NSEG : BLANK;
            end

            2'd1: begin
                // Digit 1 → door indicator
                an = 4'b1101;
                seg = door_open ? OSEG : CSEG;
            end

            default: begin
                an = 4'b1111; 
                seg = BLANK;
            end
        endcase
    end

endmodule
