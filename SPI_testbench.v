module SPI_testbench ;

    reg clk , rst_n ;
    reg MOSI , SS_n ;

    wire MISO  ;   

    reg [9:0] combined_data ;
    integer i ;    

reg[7:0] received_data_at_Master  = 8'h00 ; // register to check the correct functionality  

SPI_Wrapper_top_module DUT (.*) ;


//Generate the Clock
localparam T_clk = 10 ;
always
begin
    clk = 0 ; 
    #(T_clk / 2) ;

    clk = 1 ; 
    #(T_clk / 2) ;
end

initial 
begin

$display("---------Strat simulation----------");


/*-------------reset functionaity-------------*/
rst_n = 1'b0 ;

repeat(2)@(negedge clk);
if(1'b0 != MISO)
begin
    $display("Error in reset");
    $stop;
end

@(negedge clk) ;
rst_n = 1 ;


/*-----------------------write address----------------------*/
@(negedge clk) ;   
SS_n = 0 ; // start communication && Go to CHK_CMD state

@(negedge clk) ;   
MOSI = 0 ; SS_n = 0 ; // Go to write state

/*send the selection bits = 2'b00 to write address*/

/*choose the address 0XFF */

combined_data = 10'b00_1111_1111 ;

        for(i=0; i<10; i=i+1) 
            begin
                @(negedge clk);
                MOSI = combined_data[9-i];
            end 

@(negedge clk) ; 
SS_n = 1'b1 ; // stop communication 

#(2*T_clk) ;  // Ensure data is stable

/*-----------------------write Data----------------------*/

@(negedge clk) ; 
SS_n = 1'b0 ; // start communication 

@(negedge clk) ;   
MOSI = 0 ; SS_n = 0 ; // Go to write state

/*send the selection bits = 2'b01 to write address*/

/*Data 1111_1100 (FC) */

combined_data = 10'b01_1111_1100 ;

        for(i=0; i<10; i=i+1) 
        begin
            @(negedge clk);
            MOSI = combined_data[9-i];
        end 

@(negedge clk) ; 
SS_n = 1'b1 ; // stop communication 

#(2*T_clk) ;  // Ensure data is stable


$display("Check address = 0XFF contains Data = 0XFC in RAM");

/*------------------------read address--------------------------*/

@(negedge clk) ; 
SS_n = 1'b0 ; // start communication 

@(negedge clk) ;   
MOSI = 1 ; SS_n = 0 ; // Go to read address state

/*send the selection bits = 2'b10 to read address*/

/*address is 0XFF "1111_1111" */

combined_data = 10'b10_1111_1111 ;

        for(i=0; i<10; i=i+1) 
        begin
            @(negedge clk);
            MOSI = combined_data[9-i];
        end 

@(negedge clk) ; 
SS_n = 1'b1 ; // stop communication 

#(2*T_clk) ;  // Ensure data is stable

/*------------------------------read data-------------------------------*/

@(negedge clk) ; 
SS_n = 1'b0 ; // start communication 

@(negedge clk) ;   
MOSI = 1 ; SS_n = 0 ; // Go to read data

/*send the selection bits = 2'b11 to read data*/

/*we will read the data 0XFC which is written before */

combined_data = 10'b11_00000000 ;

        for(i=0; i<10; i=i+1) 
        begin
            @(negedge clk);
            MOSI = combined_data[9-i];
        end 
    
    @(negedge clk) ; // wait the MOSI to be taken  at next +Ve edge 

    #(T_clk) ; // wait the memory to accept its inputs 

    #(T_clk) ; // wait the memory to deliver its outputs

    #(T_clk) ; // wait clock after tx_valid = 1 --> could be done using [ wait(DUT.mem.tx_valid) ] 

     for(i=0 ; i<8 ; i=i+1)
        begin
            @(negedge clk) ; // as mosi is changed with +Ve edge
            received_data_at_Master = ( received_data_at_Master<<1 ) | MISO ;
        end

if(received_data_at_Master != 8'hFC)
begin
       $display("Error in receiveing MISO "); 
       $display("received_data_at_Master = 0h%0h" , received_data_at_Master); 
       $stop; 
end

@(negedge clk) ; 
SS_n = 1'b1 ; // stop communication 

    $display("The testbench is done successfully :) ");
    $display("--------------------------------------");
    $stop;

end
endmodule
