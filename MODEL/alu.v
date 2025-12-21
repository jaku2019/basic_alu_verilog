module TOP #(
    parameter WIDTH = 4,
    parameter LEN = 2
)
(
    input wire [WIDTH-1 : 0]    i_arg0,
    input wire [WIDTH-1 : 0]    i_arg1,
    input wire                  i_oper,
    input wire                  i_clk,
    input wire                  i_rstn,
    output reg [3:0]            o_flag,
    output reg [WIDTH-1 : 0]    o_result
)

    wire [WIDTH-1:0] sub_result, nand_result, oh_result, decoder_result;
    wire sub_overflow, sub_err;
    wire nand_overflow, nand_err;
    wire oh_result, oh_result;
    wire decoder_overflow, decoder_err;

    
    subtractor #(.WIDTH(WIDTH))
    (
        .i_a(i_arg0)
        .i_b(i_arg1)
        .o_y(o_result)
        .o_overflow(sub_overflow)
        .o_err(sub_err)
    );
    nand #(.WIDTH(WIDTH))
    (
        .i_a(i_arg0)
        .i_b(i_arg1)
        .o_y(o_result)
        .o_overflow(nand_overflow)
        .o_err(nand_err)
    )
    starting_ones #(.WIDTH(WIDTH))
    (
        .i_a(i_arg0)
        .i_b(i_arg1)
        .o_y(o_result)
        .o_overflow(oh_result)
        .o_err(oh_result)                
    )
    onehot2u2_decoder #(.LEN(LEN), .WIDTH(WIDTH))
    (
        .i_a_oh(i_arg0)
        .i_b_oh(i_arg1)
        .o_y_u2(o_result)
        .o_overflow(decoder_overflow)
        .o_err(decoder_err)                    
    )
    default: assign o_y = 0;

    // sygnaly temp do flag
    reg temp_overflow, temp_err, temp_neg, temp_pos;

    always @(*) begin
        o_result = 0;
        temp_overflow = 0;
        temp_err = 0;
        temp_neg = 0;
        temp_pos = 0;
        case(i_oper)
            2'b00: begin
                o_result = sub_result;
                temp_overflow = sub_overflow;
                temp_err = sub_err;
            end
            2'b01: begin
                o_result = nand_result;
                temp_overflow = nand_overflow;
                temp_err = nand_err;                
            end
            2'b10: begin
                o_result = oh_result;
                temp_overflow = oh_result;
                temp_err = oh_result;                                
            end
            2'b11: begin
                o_result = decoder_result;
                temp_overflow = decoder_overflow;
                temp_err = decoder_err;                                
            end
        endcase
    temp_pos = ~o_result[WIDTH-1] & (o_result != 0);
    temp_neg = o_result[WIDTH-1] & (o_result != 0);

    // wszystkie flagi na jednym wyjsciu
    o_flag[0] = temp_err;
    o_flag[1] = temp_neg;
    o_flag[2] = temp_pos;
    o_flag[3] = temp_overflow;
    end
endmodule