module SPI_Wrapper_top_module
(
    input  wire clk , rst_n ,
    input  wire MOSI , SS_n ,
    output wire MISO     
);

wire [9:0] RAM_data_in ;
wire [7:0] RAM_data_out ;
wire rx , tx ;

SPI_Single_Port_RAM mem ( 
                          .clk(clk) ,
                          .rst_n(rst_n) ,
                          .rx_valid(rx) ,
                          .tx_valid(tx) ,
                          .din(RAM_data_in) , 
                          .dout(RAM_data_out) 
                        ) ;

SPI_Slave DUT (   
                  .clk(clk)             ,
                  .SS_n(SS_n)           ,     
                  .MOSI(MOSI)           ,
                  .MISO(MISO)           ,
                  .rst_n(rst_n)         ,
                  .tx_valid(tx)         ,
                  .rx_valid(rx)         ,
                  .rx_data(RAM_data_in) ,
                  .tx_data(RAM_data_out)
              ) ;



endmodule