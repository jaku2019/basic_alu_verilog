module TOP 
#(
    parameter WIDTH  = 4
)
(

    input wire [WIDTH-1 : 0]    i_A,
    input wire [WIDTH-1 : 0]    i_B,
    input wire                  i_CLK,
    input wire                  i_RSTn,
    input wire                  i_READY, i_VALID,
    output wire                 o_READY, o_VALID,
    output wire [WIDTH-1 : 0]   o_Y

);
    wire [WIDTH-1 : 0] s_y;


    assign s_y = i_A + i_B;


    cpreg #(.WIDTH(WIDTH))
        u_preg
            (
                .i_READY(i_READY),
                .i_VALID(i_VALID),
                .o_READY(o_READY),
                .o_VALID(o_VALID),

                .i_RSTn(i_RSTn),
                .i_CLK(i_CLK), 
                .i_D(s_y), 
                .o_Q(o_Y)
            );

endmodule