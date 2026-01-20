// Y = A - B czyli odejmowacz
module subtractor #(
    parameter WIDTH = 4
)
(
    input wire signed [WIDTH-1:0] i_a,
    input wire signed [WIDTH-1:0] i_b,
    output reg signed [WIDTH-1:0] o_y,
    output reg                    o_overflow,
    output reg                    o_err             // nie dotyczy
);
    always @(*) begin
        o_y = 0;
        o_y = i_a - i_b;
        // overflow bedzie widac gdy przy przeciwnych znakach A, B Y bedzie miala znak przeciwny do A
        o_overflow = (i_a[WIDTH-1] != i_b[WIDTH-1]) && (i_a[WIDTH-1] != o_y[WIDTH-1]);
        o_err = 1'b0;
    end
endmodule

// Y = A nand B czyli nandownik :)
module nand_gate #(
    parameter WIDTH = 4
)
(
    input wire signed [WIDTH-1:0] i_a,
    input wire signed [WIDTH-1:0] i_b,
    output reg signed [WIDTH-1:0] o_y,
    output reg                    o_overflow,   // nie dotyczy
    output reg                    o_err         // nie dotyczy
);
    always @(*) begin
        o_y = 0;
        o_y = ~(i_a & i_b);                 // NAND = ~AND
        o_overflow = 1'b0;
        o_err = 1'b0;
    end
endmodule

// liczba wiodacych jedynek wektora {B,A} liczac od MSB, czyli wiodacy
module starting_ones #(
    parameter WIDTH = 4
)
(
    input wire        [WIDTH-1:0] i_a,
    input wire        [WIDTH-1:0] i_b,
    output reg signed [WIDTH-1:0] o_y,
    output reg                    o_overflow, 
    output reg                    o_err             // nie dotyczy
);
    reg [WIDTH+WIDTH-1:0] c;
    integer i;
    integer count;
    integer break;

    always @(*) begin
        o_y = 0;
        // polaczenie wektorow
        c = {i_b, i_a};
        count = 0;
        break = 0;
        $display(c);
    // sprawdz od MSB ile jest 1, a jesli pojawi sie 0 to przerwij fora = przestan liczyc
        for (i = WIDTH+WIDTH-1; i >= 0; i = i-1) begin
            if ((break == 0) && (c[i] == 1)) begin
                count = count + 1;
            end
            else begin
                break = 1;
            end
        end

        // ustaw overflow 1, jesli wiodących jedynek będzie więcej niż maksymanla warosc o_y (na razie WIDTH)
        o_overflow = (count > (2**WIDTH-1)) ? 1'b1 : 1'b0;
        o_err = 1'b0;
        o_y = count;
    end
endmodule

// onehot do u2 (a w zasadzie do nkb, bo nie moze byc ujemnych), czyli dekoder
module onehot2u2_decoder #(
    parameter LEN = 8,
    // WIDTH musi wynosic tyle co log2(LEN+LEN)
    parameter WIDTH = 4
)
(
    input wire [LEN-1:0] i_a_oh,
    input wire [LEN-1:0] i_b_oh,
    output reg signed [WIDTH-1:0] o_y_u2,
    output reg             o_overflow,
    output reg             o_err
);
    reg s_was1;
    integer i;
    integer posit;
    reg [LEN+LEN-1:0] i_onehot;
    always @(*) begin
        // wyzeruj wartosci 
        o_y_u2 = 0;
        o_overflow = 1'b0;
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