//////////////////////////////////////////////////////////////////////////////////
// Clock Generator Module
// This module generates pixel clock and TMDS clock using MMCM
//////////////////////////////////////////////////////////////////////////////////
module clock_gen #(
    parameter   MULT_MASTER = 63.375,   // master clock multiplier (2.000-64.000)
    parameter   DIV_MASTER  = 11,       // master clock divider (1-106)
    parameter   DIV_PIX     = 10,       // pixel clock divider (1-128)
    parameter   DIV_TMDS    = 1,        // tmds clock divider (1-128)
    parameter   IN_PERIOD   = 8.0       // period of master clock in ns
)   (
    input   wire    clk,                // Input Clock 125MHz
    output          clk_pix,            // pixel clock output
    output          clk_tmds            // tmds clock output
);
    
    wire clk_fb;            // internal clock feedback
    wire clk_pix_unbuf;     // unbuffered pixel clock
    wire clk_tmds_unbuf;    // unbuffered tmds clock

    MMCME2_BASE #(
        .CLKFBOUT_MULT_F(MULT_MASTER),  // Multiply value for all CLKOUT (2.000-64.000).
        .CLKIN1_PERIOD(IN_PERIOD),      // Input clock period in ns.
        .CLKOUT0_DIVIDE_F(DIV_PIX),     // Divide amount for CLKOUT0 (1.000-128.000).
        .CLKOUT1_DIVIDE(DIV_TMDS),      // Divide amount for CLKOUT1 (1-128).
        .DIVCLK_DIVIDE(DIV_MASTER)      // Master division value (1-106)
    ) MMCME2_BASE_inst (
        .CLKIN1(clk),                   // 1-bit input: Clock
        .RST(1'b0),                     // out of reset
        .CLKOUT0(clk_pix_unbuf),        // unbuffered pixel clock output
        .CLKOUT1(clk_tmds_unbuf),       // unbuffered tmds clock output
        .CLKFBOUT(clk_fb),              // 1-bit output: Feedback clock
        .CLKFBIN(clk_fb)                // 1-bit input: Feedback clock
    );
    
    // buffer pixel clock output
    BUFG bufg_clk_pix(
        .I(clk_pix_unbuf), 
        .O(clk_pix)
    );
    
    // buffer tmds clock output
    BUFG bufg_clk_tmds(
        .I(clk_tmds_unbuf), 
        .O(clk_tmds)
    );
    
endmodule