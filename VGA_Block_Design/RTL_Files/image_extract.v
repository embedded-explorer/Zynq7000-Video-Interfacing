`timescale 1ns/1ps

`define PixelsPerLine 512
`define TotalLines 512
`define ImageSize 512*512

//////////////////////////////////////////////////////////////////////////////////
// This Module Converts Hex Data of 24-Bit bmp colour image into decimal
// Usage: Remove 54 Byte image header using HXd tool, copy rest of Hex data
//        into a text file and pass that file to this module
//////////////////////////////////////////////////////////////////////////////////

module image_extract(  );
    reg [7:0] data[786431:0];
    integer file_in, file_out, i, j;

    initial 
    begin
        file_out = $fopen("F:\\VGA\\file_io\\file_o.txt", "w");
        file_in  = $fopen("F:\\VGA\\file_io\\file_i.txt", "r");
        //$readmemh("F:\\VGA\\file_io\\file_i.txt", data);
        
        for(i=0; i<(`ImageSize*3); i=i+1)
        begin
            $fscanf(file_in, "%h", data[i]);
        end
        
        // Vertically flip the image data for proper displaying    
        for(i=(`TotalLines-1); i>=0; i=i-1)
        begin
            for(j=(i*(`PixelsPerLine*3)); j<((i+1)*(`PixelsPerLine*3)); j=j+1)
            begin
                #1
                $fwrite(file_out, "%d,", data[j]);
            end
        end
        
        $fclose(file_out);
        $fclose(file_in);
        
        #10 
        $finish;
    end    
      
endmodule