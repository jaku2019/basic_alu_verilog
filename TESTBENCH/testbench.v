// Glowny modul symulacji -- musi nazywac sie testbench ze wzgledu na skrypty symulacyjne
module testbench;

    localparam DATA_WIDTH = 4;
    
    wire [DATA_WIDTH-1 : 0] s_A, s_B, s_Y;
    wire s_CLK;
    wire s_RSTn;

    wire s_alu_ready, s_valid2alu, s_ready2alu, s_alu_valid;

    // Modul nadrzedny hierarchii projektu
    TOP #(.WIDTH(DATA_WIDTH))   // Nazwa modulu -- MUSI BYC TOP ze wzgledu na skrypty symulacyjne i syntezy
        UTOP                    // Nazwa instancji -- MUSI BYC UTOP ze wzgledu na skrypty syntezy logicznej i symulacji
            (
                .o_READY(s_alu_ready),
                .i_VALID(s_valid2alu),
                .o_VALID(s_alu_valid),
                .i_READY(s_ready2alu),

                .i_A(s_A), 
                .i_B(s_B), 
                .i_CLK(s_CLK),
                .i_RSTn(s_RSTn),
                .o_Y(s_Y)
            );

    //
    // Komponenty symulacyjne
    //

    // Generator danych zgodnie z protokolem READY-VALID
    random_vector #(.WIDTH(2*DATA_WIDTH))
        U_GEN_A
            (
                .i_CLK(s_CLK), 
                .i_RSTn(s_RSTn), 
                .i_READY(s_alu_ready),
                .o_VALID(s_valid2alu),
                .o_Y({s_A, s_B})
             );
        
    // Odbiorca danych zgodnie z protokolem READY-VALID
    vector_data_accept #(.WIDTH(DATA_WIDTH))
        U_ACCEPT
            (
                .i_CLK(s_CLK), 
                .i_RSTn(s_RSTn), 
                .o_READY(s_ready2alu),
                .i_VALID(s_alu_valid),
                .i_D(s_Y)
            );
    
    // Generator globalnych sygnalow CLK i RST oraz zakonczenia symulacji
    global_signals #(.SIM_CLOCK_CYCLES(100), .CLOCK_PERIOD(10))
        U_RST_CLK
            (.o_CLK(s_CLK), .o_RSTn(s_RSTn));


endmodule


