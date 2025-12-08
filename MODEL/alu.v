module TOP #(
    parameter WIDTH = 4,
    parameter LEN = 2
)
(
    input wire [WIDTH-1 : 0]    i_A,
    input wire [WIDTH-1 : 0]    i_B,
    input wire                  i_sel,
    input wire                  i_CLK,
    input wire                  i_RSTn,
    input wire                  i_READY, i_VALID,
    output reg                  o_READY, o_VALID,
    output reg                  o_err, o_overflow,
    output reg                  o_neg, o_pos,
    output reg [WIDTH-1 : 0]    o_Y
)
    always @(*) begin
        case(i_sel)
            2'b00: subtractor #(.WIDTH(WIDTH))
            (
                .i_a(i_A)
                .i_b(i_B)
                .o_y(o_Y)
                .o_overflow(o_overflow)
                .o_err(o_err)
            );
            2'b01: nand #(.WIDTH(WIDTH))
            (
                .i_a(i_A)
                .i_b(i_B)
                .o_y(o_Y)
                .o_overflow(o_overflow)
                .o_err(o_err)
            )
            2'b10: starting_ones #(.WIDTH(WIDTH))
            (
                .i_a(i_A)
                .i_b(i_B)
                .o_y(o_Y)
                .o_overflow(o_overflow)
                .o_err(o_err)                
            )
            2'b11: onehot2u2_decoder #(.LEN(LEN), .WIDTH(WIDTH))
            (
                .i_a_oh(i_A)
                .i_b_oh(i_B)
                .o_y_u2(o_Y)
                .o_overflow(o_overflow)
                .o_err(o_err)                    
            )
            default: assign y = 0;
        i
        endcase
    end
endmodule