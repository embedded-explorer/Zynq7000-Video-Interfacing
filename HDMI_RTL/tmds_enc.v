//////////////////////////////////////////////////////////////////////////////////
// 8B/10 Encoder Module
// This module receives prallel 8 bit data and encodes it into 10 bit data
//////////////////////////////////////////////////////////////////////////////////
module tmds_enc(
    input  wire clk,        // clock
    input  wire [7:0] vd,   // colour data
    input  wire [1:0] cd,   // control data
    input  wire de,         // display enable (active high)
    output reg [9:0] tmds   // encoded TMDS data
    );

    // 1. Count number of 1's in input data byte
    wire [3:0] d_ones = vd[0] + vd[1] + vd[2] + vd[3] + 
                        vd[4] + vd[5] + vd[6] + vd[7];
                        
    // 2. If number of 1's > 4 or number of 1's is = 4 and vd[0] = 0
    //    use XNOR operation else use XOR operation to minimize transitions                  
    wire use_xnor = (d_ones > 4'd4) || ((d_ones == 4'd4) && (vd[0] == 0));

    // 3. encode colour data with xor/xnor, 9th bit indicates operation
    wire [8:0] enc_qm;
    assign enc_qm[0] = vd[0];
    assign enc_qm[1] = (use_xnor) ? (enc_qm[0] ~^ vd[1]) : (enc_qm[0] ^ vd[1]);
    assign enc_qm[2] = (use_xnor) ? (enc_qm[1] ~^ vd[2]) : (enc_qm[1] ^ vd[2]);
    assign enc_qm[3] = (use_xnor) ? (enc_qm[2] ~^ vd[3]) : (enc_qm[2] ^ vd[3]);
    assign enc_qm[4] = (use_xnor) ? (enc_qm[3] ~^ vd[4]) : (enc_qm[3] ^ vd[4]);
    assign enc_qm[5] = (use_xnor) ? (enc_qm[4] ~^ vd[5]) : (enc_qm[4] ^ vd[5]);
    assign enc_qm[6] = (use_xnor) ? (enc_qm[5] ~^ vd[6]) : (enc_qm[5] ^ vd[6]);
    assign enc_qm[7] = (use_xnor) ? (enc_qm[6] ~^ vd[7]) : (enc_qm[6] ^ vd[7]);
    assign enc_qm[8] = (use_xnor) ? 0 : 1;

    // 4a. count the 1's in encoded data enc_qm[7:0]
    wire signed [4:0] ones = enc_qm[0] + enc_qm[1] + enc_qm[2] + enc_qm[3] + 
                             enc_qm[4] + enc_qm[5] + enc_qm[6] + enc_qm[7];

    // 4b. Calculate number of 0's in encoded data
    wire signed [4:0] zeros = 5'b01000 - ones;
    
    // 4c. calculate disparity
    wire signed [4:0] balance = ones - zeros;

    // record ongoing DC bias
    reg signed [4:0] bias;

    always @ (posedge clk)
    begin
        
        if (de == 0)    // send control data in blanking interval
        begin
            case (cd)   // ctrl sequences (always have 7 transitions)
                2'b00:   tmds <= 10'b1101010100;
                2'b01:   tmds <= 10'b0010101011;
                2'b10:   tmds <= 10'b0101010100;
                default: tmds <= 10'b1010101011;
            endcase
            bias <= 5'sb00000;
        end
        
        else  // send pixel colour data (at most 5 transitions)
        begin
            if (bias == 0 || balance == 0)  // no prior bias or disparity
            begin
                if (enc_qm[8] == 0)
                begin
                    tmds[9:0] <= {2'b10, ~enc_qm[7:0]};
                    bias <= bias - balance;
                end
                else begin
                    tmds[9:0] <= {2'b01, enc_qm[7:0]};
                    bias <= bias + balance;
                end
            end
            else if ((bias > 0 && balance > 0) || (bias < 0 && balance < 0))
            begin
                tmds[9:0] <= {1'b1, enc_qm[8], ~enc_qm[7:0]};
                bias <= bias + {3'b0, enc_qm[8], 1'b0} - balance;
            end
            else
            begin
                tmds[9:0] <= {1'b0, enc_qm[8], enc_qm[7:0]};
                bias <= bias - {3'b0, ~enc_qm[8], 1'b0} + balance;
            end
        end
    end
endmodule