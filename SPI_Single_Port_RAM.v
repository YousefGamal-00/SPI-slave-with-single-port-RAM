module SPI_Single_Port_RAM 
(
    input clk , rst_n , 
    input [9:0] din ,  
    input rx_valid ,  
    output reg [7:0] dout ,  
    output reg tx_valid    
);

localparam MEM_DEPTH = 256 ; 
localparam MEM_WIDTH = 8   ; 

reg [MEM_WIDTH-1 : 0] RAM [MEM_DEPTH-1 : 0] ;  
reg [7:0] temp_address ;  

integer i ;
always @(posedge clk) 
begin
    if(!rst_n)
        begin
            dout <= 8'h00;  
            tx_valid <= 1'b0;  
            temp_address <= 8'h00;
            for(i=0 ; i<MEM_DEPTH ; i=i+1)
               begin
                    RAM[i] <= { MEM_WIDTH{1'b0} } ;                
               end

        end
    else
        begin
            if (rx_valid) 
            begin
                case (din[9:8])  
                    2'b00: 
                        temp_address <= din[7:0];  

                    2'b01: 
                        RAM[temp_address] <= din[7:0];  

                    2'b10: 
                        temp_address <= din[7:0];  

                    2'b11: 
                        dout <= RAM[temp_address];  
                endcase
            end
            tx_valid <= (din[9:8] == 2'b11) ? 1'b1 : 1'b0;  
        end
end
endmodule
