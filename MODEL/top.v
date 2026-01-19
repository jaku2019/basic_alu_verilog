module TOP #(
    parameter WIDTH = 4,
    parameter LEN = 1
)
(
    input wire signed [WIDTH-1 : 0]    i_arg0,
    input wire signed [WIDTH-1 : 0]    i_arg1,
    input wire [1:0]                   i_oper,
    input wire                         i_clk,
    input wire                         i_rstn,
    output reg [3:0]                   o_flag,
    output reg signed [WIDTH-1 : 0]    o_result
);

    wire [WIDTH-1:0] sub_result, nand_result, oh_result, decoder_result;
    wire sub_overflow, sub_err;
    wire nand_overflow, nand_err;
    wire oh_overflow, oh_err;
    wire decoder_overflow, decoder_err;

    
    subtractor #(.WIDTH(WIDTH))
    u_subtractor
    (
        .i_a(i_arg0),
        .i_b(i_arg1),
        .o_y(sub_result),
        .o_overflow(sub_overflow),
        .o_err(sub_err)
    );
    nand_gate #(.WIDTH(WIDTH))
    u_nand_gate
    (
        .i_a(i_arg0),
        .i_b(i_arg1),
        .o_y(nand_result),
        .o_overflow(nand_overflow),
        .o_err(nand_err)
    );
    starting_ones #(.WIDTH(WIDTH))
    u_starting_ones
    (
        .i_a(i_arg0),
        .i_b(i_arg1),
        .o_y(oh_result),
        .o_overflow(oh_overflow),
        .o_err(oh_err)
    );
    onehot2u2_decoder #(.LEN(LEN), .WIDTH(WIDTH))
    u_decoder
    (
        .i_a_oh(i_arg0),
        .i_b_oh(i_arg1),
        .o_y_u2(decoder_result),
        .o_overflow(decoder_overflow),
        .o_err(decoder_err)
    );

    // sygnaly temp do flag
    reg temp_overflow, temp_err, temp_neg, temp_pos;
    reg signed [WIDTH-1:0] o_result_next;
    reg [2:0] o_flag_next;

    always @(*) begin
        o_result = 0;
        o_result_next = 0;
        temp_overflow = 0;
        temp_err = 0;
        temp_neg = 0;
        temp_pos = 0;
        case(i_oper)
            2'b00: begin
                o_result_next = sub_result;
                temp_overflow = sub_overflow;
                temp_err = sub_err;
            end
            2'b01: begin
                o_result_next = nand_result;
                temp_overflow = nand_overflow;
                temp_err = nand_err;                
            end
            2'b10: begin
                o_result_next = oh_result;
                temp_overflow = oh_overflow;
                temp_err = oh_err;                                
            end
            2'b11: begin
                o_result_next = decoder_result;
                temp_overflow = decoder_overflow;
                temp_err = decoder_err;                                
            end
        endcase
    temp_pos = ~o_result_next[WIDTH-1] & (o_result_next != 0);
    temp_neg = o_result_next[WIDTH-1] & (o_result_next != 0);

    // wszystkie flagi na jednym wyjsciu
    o_flag_next[0] = temp_err;
    o_flag_next[1] = temp_neg;
    o_flag_next[2] = temp_pos;
    o_flag_next[3] = temp_overflow;
    end

    always @(posedge i_clk or negedge i_rstn)
        if (i_rstn == 1) begin
            o_result <= {WIDTH{1'b0}};
            o_flag <= {4{1'b0}};
        end
        else begin
            o_result <= o_result_next;
            o_flag <= o_flag_next;
        end
endmodule