//////////////////////////////////////////////////////////////////////////////////
// Serializer Module
// This module receives prallel encoded data and shifts out the data serially
//////////////////////////////////////////////////////////////////////////////////
module serializer(
    input               clk_pix,    // parallel clock
    input               clk_tmds,   // high-speed tmds clock
    input       [9:0]   data_i,     // input parallel data
    output reg          data_o      // output serial data
);

    reg [3:0] mod10_count = 0;      // modulus 10 counter
    reg load = 0;

    reg [9:0] data_o_temp=0;

    // Load data after 10 tmds clock cycles
    always @(posedge clk_tmds) 
    begin
        mod10_count <= (mod10_count == 4'd9) ? 4'd0 : mod10_count + 4'd1;
        load   <= (mod10_count == 4'd9);
    end

    // shift out serial data every tmds clock
    always @(posedge clk_tmds)
    begin
	   data_o_temp   <= load ? data_i : (data_o_temp >> 1);
	   data_o        <= data_o_temp[0];
    end

endmodule