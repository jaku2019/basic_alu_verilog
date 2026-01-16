// Glowny modul symulacji -- musi nazywac sie testbench ze wzgledu na skrypty symulacyjne
module testbench;

    localparam DATA_WIDTH = 4;

    reg signed [DATA_WIDTH-1:0] s_A, s_B;
    wire signed [DATA_WIDTH-1:0] s_Y;
    reg [1:0] s_sel;
    wire s_CLK;
    wire s_RSTn;
    
    wire [3:0] s_flag;  
    
    // pozycje sygnalu _flag
    localparam FLAG_ERR      = 0;
    localparam FLAG_NEG      = 1;
    localparam FLAG_POS      = 2;
    localparam FLAG_OVERFLOW = 3; 

    // Modul nadrzedny hierarchii projektu
    TOP #(.WIDTH(DATA_WIDTH), .LEN(DATA_WIDTH))   // Nazwa modulu -- MUSI BYC TOP ze wzgledu na skrypty symulacyjne i syntezy
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
    integer i;
    initial begin
        s_A = 0;
        s_B = 0;
        s_sel = 0;

        //reset
        @(posedge s_RSTn);;
        @(posedge s_CLK);

        // test wszystkich kombinacji
        for (i = 0; i < 50; i = i+1) begin
            @(posedge s_CLK);
            s_A = $random;
            s_B = $random;
            s_sel = $random;
        end
        
        // test na konkretnych wartosciach
        @(posedge s_CLK);
        s_A = 4'b0101;
        s_B = 4'b0011;
        s_sel = 2'b00;  // substractor

        @(posedge s_CLK);
        s_A = 4'b1111;
        s_B = 4'b0000;
        s_sel = 2'b01;  // nand

        @(posedge s_CLK);
        s_A = 4'b1100;
        s_B = 4'b0011;
        s_sel = 2'b10;  // starting_ones

        @(posedge s_CLK);
        s_A = 4'b0010;
        s_B = 4'b1000;
        s_sel = 2'b11;  // onehot2u2_decoder
    end
    
    // Generator globalnych sygnalow CLK i RST oraz zakonczenia symulacji
    global_signals #(.SIM_CLOCK_CYCLES(100), .CLOCK_PERIOD(10))
        U_RST_CLK
            (.o_CLK(s_CLK), .o_RSTn(s_RSTn));


endmodule


