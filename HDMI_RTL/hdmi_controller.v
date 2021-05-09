//////////////////////////////////////////////////////////////////////////////////
// HDMI Displat Driver Module
//////////////////////////////////////////////////////////////////////////////////
module hdmi_controller(
	input          clk,              // 125MHz
	output [2:0]   TMDSp, 
	output [2:0]   TMDSn,
	output         TMDSp_clock, 
	output         TMDSn_clock
);

//////////////////////////////////////////////////////////////////////////////////
// Clock Generator Instantiation
//////////////////////////////////////////////////////////////////////////////////
    wire    clk_pix;
    wire    clk_tmds;    
    
    clock_gen #(
        .MULT_MASTER (63.375    ),  // master clock multiplier (2.000-64.000)
        .DIV_MASTER  (11        ),  // master clock divider (1-106)
        .DIV_PIX     (10        ),  // pixel clock divider (1-128)
        .DIV_TMDS    (1         ),  // tmds clock divider (1-128)
        .IN_PERIOD   (8         )   // period of master clock in ns
    ) clock_gen_inst (
        .clk        (clk        ),  // Input Clock 125MHz
        .clk_pix    (clk_pix    ),  // pixel clock output
        .clk_tmds   (clk_tmds   )   // tmds clock output
    );

//////////////////////////////////////////////////////////////////////////////////
// Sync Signal Generator Instantiation
//////////////////////////////////////////////////////////////////////////////////
    wire [11:0] sx, sy;
    wire hsync, vsync, de;
    
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

/////////////////////////////////////////////////////////////////////////////////
// 8 Colour Strip Pattern Generator Logic
////////////////////////////////////////////////////////////////////////////////
    reg [7:0] red, green, blue;
    always@(posedge clk_pix)
    begin
        red <= (sx >= 683) ? 8'hFF : 8'h00;
        green <= ((sx >= 341 && sx <= 682) || (sx >= 1025)) ? 8'hFF : 8'h00;
        blue <= ((sx >= 170 && sx <= 340) || (sx >= 512 && sx <= 682) || 
                 (sx >= 854 && sx <= 1024) || (sx >= 1195)) ? 8'hFF : 8'h00;
    end

/////////////////////////////////////////////////////////////////////////////////
// TMDS Encoder Instntiation
////////////////////////////////////////////////////////////////////////////////
    wire [9:0] tmds_red, tmds_green, tmds_blue;
    
    tmds_enc enc_r(
        .clk    (clk_pix        ), 
        .vd     (red            ), 
        .cd     (2'b00          ), 
        .de     (de             ), 
        .tmds   (tmds_red       )
    );
    
    tmds_enc enc_g(
        .clk    (clk_pix        ), 
        .vd     (green          ), 
        .cd     (2'b00          ), 
        .de     (de             ), 
        .tmds   (tmds_green     )
    );
    
    tmds_enc enc_b(
        .clk    (clk_pix        ), 
        .vd     (blue           ), 
        .cd     ({vsync,hsync}  ), 
        .de     (de             ), 
        .tmds   (tmds_blue      )
    );

/////////////////////////////////////////////////////////////////////////////////
// Serializer Instantiation
////////////////////////////////////////////////////////////////////////////////
    wire ser_red, ser_green, ser_blue;
    
    serializer ser_r(
        .clk_pix    (clk_pix    ),
        .clk_tmds   (clk_tmds   ),
        .data_i     (tmds_red   ),
        .data_o     (ser_red    )
    );
    
    serializer ser_g(
        .clk_pix    (clk_pix    ),
        .clk_tmds   (clk_tmds   ),
        .data_i     (tmds_green ),
        .data_o     (ser_green  )
    );
    
    serializer ser_b(
        .clk_pix    (clk_pix    ),
        .clk_tmds   (clk_tmds   ),
        .data_i     (tmds_blue  ),
        .data_o     (ser_blue   )
    );

/////////////////////////////////////////////////////////////////////////////////
// Differential Output Buffers
////////////////////////////////////////////////////////////////////////////////
    OBUFDS #
    (
        .IOSTANDARD ("DEFAULT"  ),  // Specify the output I/O standard
        .SLEW       ("SLOW"     )   // Specify the output slew rate
    ) OBUFDS_red 
    (
        .O  (TMDSp[2]   ),          // Diff_p output (connect directly to top-level port)
        .OB (TMDSn[2]   ),          // Diff_n output (connect directly to top-level port)
        .I  (ser_red    )           // Buffer input
    );
    
    OBUFDS #
    (
        .IOSTANDARD("DEFAULT"),
        .SLEW("SLOW")
    ) OBUFDS_green 
    (
        .O(TMDSp[1]),
        .OB(TMDSn[1]),
        .I(ser_green)
    );
    
    OBUFDS #
    (
        .IOSTANDARD("DEFAULT"),
        .SLEW("SLOW") 
    ) OBUFDS_blue 
    (
        .O(TMDSp[0]), 
        .OB(TMDSn[0]),
        .I(ser_blue)
    );
    
    OBUFDS #
    (
        .IOSTANDARD("DEFAULT"),
        .SLEW("SLOW")
    ) OBUFDS_clock 
    (
        .O(TMDSp_clock),
        .OB(TMDSn_clock), 
        .I(clk_pix)
    );

endmodule