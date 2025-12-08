// Y = A - B czyli odejmowacz
module subtractor #(
    parameter WIDTH = 4
)
(
    input wire signed [WIDTH-1:0] i_a,
    input wire signed [WIDTH-1:0] i_b,
    output reg signed [WIDTH-1:0] o_y,
    output reg                    o_overflow,
    output reg                    o_err
)
always @(*) begin
    o_y = i_a - i_b;
    // overflow bedzie widac gdy przy przeciwnych znakach A, B Y bedzie miala znak przeciwny do A
    o_overflow = (i_a[WIDTH-1] != i_b[WIDTH-1]) && (i_a[WIDTH-1] != o_y[WIDTH-1]); 
end

endmodule

// Y = A nand B czyli nandownik :)
module nand #(
    parameter WIDTH = 4
)
    input wire signed [WIDTH-1:0] i_a,
    input wire signed [WIDTH-1:0] i_b,
    output reg signed [WIDTH-1:0] o_y,
    output reg                    o_overflow,   // nie dotyczy
    output reg                    o_err
(
    always @(*) begin
        o_y = ~(A & B);                 // NAND = ~AND
        o_overflow = 1'b0;
    end
)
endmodule

// liczba wiodacych jedynek wektora {B,A} liczac od MSB, czyli wiodacy
module starting_ones #(
    parameter WIDTH = 4
)
    input wire signed [WIDTH-1:0] i_a,
    input wire signed [WIDTH-1:0] i_b,
    output reg        [WIDTH-1:0] o_y,
    output reg                    o_overflow,       // nie dotyczy 
    output reg                    o_err
(
    reg [WIDTH+WIDTH-1:0] c,
    integer i,
    integer count,

    always @(*) begin
        // polaczenie wektorow
        c = {i_b, i_a};
        count = 0;
    // sprawdz od MSB ile jest 1, a jesli pojawi sie 0 to przerwij fora = przestan liczyc
        for (i = WIDTH+WIDTH-1; i >= 0; i = i-1)
            if c[i] == 1
                count = count + 1
            else break;


        // ustaw overflow 1, jesli wiodących jedynek będzie więcej niż maksymanla warosc o_y (na razie WIDTH)
        o_overflow = (count > (2**WIDTH-1)) ? 1'b1 : 1'b0
        o_y = count[WIDTH-1:0];
    end
)
endmodule

// onehot do u2 (a w zasadzie do nkb, bo nie moze byc ujemnych), czyli dekoder
module onehot2u2_decoder #(
    parameter LEN = 8
    // WIDTH musi wynosic tyle co log2(LEN+LEN)
    parameter WIDTH = 4,

)
(
    input wire [LEN-1:0] i_a_oh,
    input wire [LEN-1:0] i_b_oh,
    output reg [WIDTH-1:0] o_y_u2,
    output reg             o_overflow,
    output reg             o_err
)
    reg s_was1;
    integer i;
    integer posit;
    wire i_onehot;
    always @(*) begin
        // wyzeruj wartosci 
        o_y_u2 = WIDTH'd0;
        o_overflow, = 1'b0;
        o_err   = 1'b0;
        s_was1  = 1'b0;
        posit     = 0;
        // polacz B, A
        i_onehot = {i_b_oh, i_a_oh};

        for (i=0; i < (LEN+LEN); i = i+1)
            if (i_onehot[i] == 1'b1)
                if (s_was1)
                    o_err = 1'b1;           // wyswietl blad jesli to kolejna jedynka
                else
                begin
                    s_was1 = 1'b1;
                    posit = i;             // ustaw pamiec o tym, ze jedynka juz byla i przechowaj wartosc z oh
                end
        o_overflow = (posit > (2**WIDTH-1)) ? 1'b1 : 1'b0;
        o_y_u2 = posit[WIDTH-1:0];
    end
endmodule


module ALU #(
    parameter WIDTH = 4
)
(
    input wire [WIDTH-1 : 0]    i_A,
    input wire [WIDTH-1 : 0]    i_B,
    input wire                  i_sel,
    input wire                  i_CLK,
    input wire                  i_RSTn,
    input wire                  i_READY, i_VALID,
    output wire                 o_READY, o_VALID,
    output wire [WIDTH-1 : 0]   o_Y
)
    always @(*) begin
        case(i_sel)
            2'b00: subtractor #(.WIDTH(WIDTH))
            (
                .i_a(i_A)
                .i_b(i_B)
                .o_y(o_Y)
            );
            2'b01:
            2'b10:
            2'b11:
            default: 
        endcase
    end
endmodule



/*
    Modul rejestru potokowego z kontrola przeplywu
    danych synchronicznym protokolem READY-VALID

*/
module cpreg
#(
    parameter WIDTH = 4
)
(
    input wire i_CLK,
    input wire i_RSTn,
    input wire i_READY, i_VALID,
    output reg o_READY, o_VALID,
    input wire [WIDTH-1 : 0] i_D,
    output reg [WIDTH-1 : 0] o_Q   
);

    reg [WIDTH-1 : 0]   s_Q1;
    reg                 s_LATCH, s_VALID;
    wire                s_EN1, s_EN2;
    reg [1:0]           s_state;

    localparam [1:0] 
        S0 = 2'b00, 
        S1 = 2'b01,
        S2 = 2'b11;

    assign s_EN1 = s_LATCH & (~ i_CLK);     // Master LATCH enable
    assign s_EN2 = s_LATCH &    i_CLK;      // Slave LATCH enable

    always @(posedge i_CLK or negedge i_RSTn)
        if (i_RSTn == 1'b0)
            s_VALID     <= 1'b0;
        else
            s_VALID     <= i_VALID;

    // Master input latch
    always @(s_EN1)
        if (s_EN1 == 1'b1)
            s_Q1 <= i_D;

    // Slave output latch
    always @(s_EN2)
        if (s_EN2 == 1'b1)
            o_Q <= s_Q1;

    // Blok stanow i przejsc automatu
    always @(posedge i_CLK or negedge i_RSTn)
        if (i_RSTn == 1'b0)
            s_state     <= S0;
        else
            case (s_state)
                S0: if (i_VALID == 1'b1)
                        s_state     <= S1;

                S1: if (i_READY == 1'b0)
                        s_state <= S2;
                    else
                        if (i_VALID == 1'b0)
                            s_state <= S0;

                S2: if (i_READY == 1'b1)
                        if (s_VALID)
                            s_state     <= S1;
                        else
                            s_state     <= S0;

                default:
                        s_state     <= S0;
            endcase
        

    // Blok wyjsc automatu
    always @(*) 
    begin
        s_LATCH = 1'b1;
        o_READY   = 1'b1;
        o_VALID   = 1'b1;

        case (s_state)
            S0: begin
                    o_VALID     = 1'b0;
                end
            S1: begin
                    if (i_READY == 1'b0)
                        s_LATCH = 1'b0;
                end

            S2: begin
                    s_LATCH   = 1'b0;
                    o_READY     = 1'b0;
                end
        endcase
    end

endmodule