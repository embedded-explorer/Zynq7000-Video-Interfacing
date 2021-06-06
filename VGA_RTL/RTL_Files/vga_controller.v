//////////////////////////////////////////////////////////////////////////////////
// VGA Controller Module
//////////////////////////////////////////////////////////////////////////////////
module vga_controller (
    input           clk,    // 125 MHz clock
    output          hsync,  // horizontal sync
    output          vsync,  // vertical sync
    output  reg     vga_r,  // 1-bit VGA red
    output  reg     vga_g,  // 1-bit VGA green
    output  reg     vga_b   // 1-bit VGA blue
);

//////////////////////////////////////////////////////////////////////////////////
// Clock Generator Instantiation
//////////////////////////////////////////////////////////////////////////////////
    wire    clk_pix;
    wire    clk_tmds;    
    
    clock_gen #(
        .MULT_MASTER (36        ),  // master clock multiplier (2.000-64.000)
        .DIV_MASTER  (5         ),  // master clock divider (1-106)
        .DIV_PIX     (12.5      ),  // pixel clock divider (1-128)
        .IN_PERIOD   (8         )   // period of master clock in ns
    ) clock_gen_inst (
        .clk        (clk        ),  // Input Clock 125MHz
        .clk_pix    (clk_pix    )  // pixel clock output
    );

//////////////////////////////////////////////////////////////////////////////////
// Sync Signal Generator Instantiation
//////////////////////////////////////////////////////////////////////////////////
    wire [11:0] sx, sy;
    wire de;
    
    sync_gen #(
        // horizontal timings
        .HA_END     (1365),  // end of active pixels
        .HS_STA     (1379),  // sync starts after front porch
        .HS_END     (1435),  // sync ends
        .LINE       (1499),  // last pixel on line (after back porch)
    
        // vertical timings
        .VA_END     (767),  // end of active pixels
        .VS_STA     (768),  // sync starts after front porch
        .VS_END     (771),  // sync ends
        .SCREEN     (799)   // last line on screen (after back porch)
    ) sync_gen_inst (
        .clk_pix    (clk_pix    ),     // pixel clock
        .sx         (sx         ),     // horizontal screen position
        .sy         (sy         ),     // vertical screen position
        .hsync      (hsync      ),     // horizontal sync
        .vsync      (vsync      ),     // vertical sync
        .de         (de         )      // data enable (low in blanking interval)
    );

//////////////////////////////////////////////////////////////////////////////////
// 8 Colour Strip Pattern Generator
//////////////////////////////////////////////////////////////////////////////////
    always@(posedge clk_pix)
    begin
        vga_r <= (sx >= 683);
        vga_g <= (sx >= 341 && sx <= 682) || (sx >= 1025);
        vga_b <= (sx >= 170 && sx <= 340) || (sx >= 512 && sx <= 682) || 
                 (sx >= 854 && sx <= 1024) || (sx >= 1195);
    end
    
    endmodule