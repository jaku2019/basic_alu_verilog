// Glowny modul symulacji -- musi nazywac sie testbench ze wzgledu na skrypty symulacyjne
module testbench;

    localparam DATA_WIDTH = 4;

    reg signed [DATA_WIDTH-1:0] s_A, s_B;
    wire signed [DATA_WIDTH-1:0] s_Y;
    reg [1:0] s_sel;
    reg s_CLK;
    reg s_RSTn;
    
    wire [3:0] s_flag;  
    
    // pozycje sygnalu _flag
/*
    localparam FLAG_ERR      = 0;
    localparam FLAG_NEG      = 1;
    localparam FLAG_POS      = 2;
    localparam FLAG_OVERFLOW = 3; 
*/
    // Modul nadrzedny hierarchii projektu
    TOP #(.WIDTH(DATA_WIDTH), .LEN(DATA_WIDTH)) // Nazwa modulu -- MUSI BYC TOP ze wzgledu na skrypty symulacyjne i syntezy
        UTOP                    // Nazwa instancji -- MUSI BYC UTOP ze wzgledu na skrypty syntezy logicznej i symulacji
            (
                .i_arg0(s_A),
                .i_arg1(s_B),
                .i_oper(s_sel),
                .i_clk(s_CLK),
                .i_rstn(s_RSTn),
                .o_result(s_Y),
                .o_flag(s_flag)
            );

    //
    // Komponenty symulacyjne
    //

    initial begin
        s_CLK = 0;
        forever #100 s_CLK = ~s_CLK; // zmiana stanu co 5 jednostek czasu
    end
    
    initial begin
        s_A = 0;
        s_B = 0;
        s_sel = 0;
        s_RSTn = 0;
        @(negedge s_CLK); #1; 
        s_RSTn = 1;
        @(negedge s_CLK);
        //@(negedge s_CLK);

        // 00 Odejmowanie 4-7=-3
        s_A = 4'd4;
        s_B = 4'd7;
        s_sel = 2'b00;  // substractor
        @(negedge s_CLK);

        // 01 NAND ~(1111&0001)=1110
        s_A = 4'b1111;
        s_B = 4'b0001;
        s_sel = 2'b01;  // NAND
        @(negedge s_CLK);

        // 10 Starting ones  {B, A} = (11111100) = 6
        s_A = 4'b1100;
        s_B = 4'b1111;
        s_sel = 2'b10;  // starting ones
        @(negedge s_CLK);

        // 11 OH decoder {B,A} = 0100, 0000 = 6
        s_A = 4'b0000;
        s_B = 4'b0100;
        s_sel = 2'b11;  // OH
        @(negedge s_CLK);

        // test flagi overflow
        s_A = 4'b0111;    // +7
        s_B = 4'b1000;    // -8  
        s_sel = 2'b00;    // subtractor
        @(negedge s_CLK);

        //teset flagi error
        s_A = 4'b0101;    // wiele jedynek - zly OH
        s_B = 4'b0000;    
        s_sel = 2'b11;    //OH
        @(negedge s_CLK);
        

        // Czekaj kilka cykli i zakoncz symulacje
        repeat (5) @(negedge s_CLK);
        $finish;
    end
    

    /* Generator globalnych sygnalow CLK i RST oraz zakonczenia symulacji
    global_signals #(.SIM_CLOCK_CYCLES(100), .CLOCK_PERIOD(10))
        U_RST_CLK
            (.o_CLK(s_CLK), .o_RSTn(s_RSTn));
*/

endmodule


