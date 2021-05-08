//////////////////////////////////////////////////////////////////////////////////
// Sync Generator Module
// This module generates hsync and vsync signals
//////////////////////////////////////////////////////////////////////////////////
module sync_gen #(
    // horizontal timings
    parameter HA_END = 639,             // end of active pixels
    parameter HS_STA = HA_END + 16,     // sync starts after front porch
    parameter HS_END = HS_STA + 96,     // sync ends
    parameter LINE   = 799,             // last pixel on line (after back porch)

    // vertical timings
    parameter VA_END = 479,             // end of active pixels
    parameter VS_STA = VA_END + 10,     // sync starts after front porch
    parameter VS_END = VS_STA + 2,      // sync ends
    parameter SCREEN = 524              // last line on screen (after back porch)
)   (
    input               clk_pix,        // pixel clock
    input               reset,          // reset
    output  reg [11:0]  sx,             // horizontal screen position
    output  reg [11:0]  sy,             // vertical screen position
    output  reg         hsync,          // horizontal sync
    output  reg         vsync,          // vertical sync
    output  reg         de              // data enable (low in blanking interval)
);
 
  
    // calculate horizontal and vertical screen position
    // make sx = 0 if end of line is reached else increment sx
    // make sy = 0 if end of frame is reached else increment sy
    always@(posedge clk_pix) 
    begin
        sx <= (sx==LINE) ? 0 : sx+1;
        if (sx == LINE)
        begin
            sy <= (sy == SCREEN) ? 0 : sy + 1;
        end 
        if(reset)
        begin
            sx <= 0;
            sy <= 0;
        end
    end

    // generate hsync, vsync and de signals
    always@(posedge clk_pix) 
    begin
        hsync <= (sx > HS_STA) && (sx <= HS_END);
        vsync <= (sy > VS_STA && sy <= VS_END);
        de <= (sx <= HA_END) && (sy <= VA_END);
    end

endmodule