module SPI_Slave
(
    input clk , rst_n  ,        // active low asynchronous reset
    input MOSI ,                // Master out slave in 
    input SS_n ,               //Active low signal used by the master 
                              // to select the specific slave device for communication.
    input tx_valid ,         // control for inpit data
    input [7 : 0] tx_data , // input data for SPI slave  

    output reg MISO ,              // Data output
    output reg rx_valid ,         // control for output data 
    output reg [9 : 0] rx_data  // output data from SPI slave
);


 reg [2:0] CS , NS ;
 reg [3:0] counter_1 ; // counts from zero to 9 based on #of received bits (from series to parallel)
 reg [2:0] counter_2 ; // counts from zero to 7 based on #of transmitted bits (from parallel to series)
 reg Is_the_address_sent = 1'b0; // to go to read address first

// storage data from serial to parallel
 reg [9 : 0] SPI_Slave_register ;   //{   2 selectio bits  ,   8 bit  Data    } 
                                   // {       First        ,      second      }  

 localparam IDLE      = 3'b000  ;
 localparam CHK_CMD   = 3'b001  ;
 localparam WRITE     = 3'b010  ;
 localparam READ_ADD  = 3'b011  ;
 localparam READ_DATA = 3'b100  ;

/* Gray Encoding for FSM */

(* fsm_encoding = "Gray"  *)

//state memory
always @(posedge clk or negedge rst_n) 
begin
        if( ! rst_n )

                CS <= IDLE ; 
        else
                CS <= NS ;
            
end

// next state logic 
    always @(*) 
    begin
        case (CS)
            IDLE: 
                begin
                    if( SS_n || !rst_n )
                        NS = IDLE ;
                    else
                        NS = CHK_CMD ;    
                end

            CHK_CMD:
                    begin
                        if(SS_n)
                            NS = IDLE;

                        else if( (SS_n == 0) && (MOSI == 0) ) 
                            NS = WRITE; // still in write to receive the Data

                        else if((SS_n == 0) && (MOSI == 1)) 
                            begin
                                if(Is_the_address_sent) 
                                    NS = READ_DATA; // read the data of address written before

                                else 
                                    NS = READ_ADD;    
                            end
                        else
                            NS = CHK_CMD; // terminate with else to avoid the inferring latch
                    end

            WRITE:
                begin
                    if(SS_n)
                        NS = IDLE;
                    else
                        NS = WRITE; // stay in write to receive the data then write the data in RAM 
                end

            READ_ADD:
                begin
                    if(SS_n)
                        NS = IDLE;
                    else
                        NS = READ_ADD; // stay in read to receive the address then go to memory 
                end

            READ_DATA:
                begin
                    if(SS_n)
                        NS = IDLE;
                    else 
                        NS = READ_DATA; // stay in read to receive the Data then go to memory 
                end

            default: NS = IDLE; // to avoid inferring latch

        endcase
    end


// output logic  sensitive to clock as the MOSI is sent bit by bit with Clock
always @(posedge clk)  
begin
        if(rst_n) // Output appears when the reset is de-asserted.
        begin
            case (CS) 
                IDLE: /*zero outputs*/
                    begin
                        MISO <= 0;
                        counter_1 <= 4'b0000 ;
                        counter_2 <= 3'b000 ;
                        rx_valid  <= 1'b0 ;
                        rx_data   <= 10'b0 ;
                    end

                CHK_CMD: 
                        begin
                            MISO <= 0;
                            rx_data <= 0;
                            rx_valid <= 0;        
                        end

                WRITE: 
                    begin
                            if (counter_1 < 10) 
                                begin
                                    SPI_Slave_register <= (SPI_Slave_register<<1) | MOSI  ; // convert from series to parallel
                                    counter_1 <= counter_1 + 1;
                                    rx_valid  <= 1'b0;
                                end 
                            else 
                                begin
                                    counter_1 <= 4'h0;
                                    rx_data  <= SPI_Slave_register;
                                    rx_valid <= 1'b1;
                                    SPI_Slave_register <= 10'd0;
                                end
                    end
                                
                READ_ADD: 
                        begin

                              Is_the_address_sent <= 1'b1 ; // to make the upcoming state is read data 

                            if (counter_1 < 10) 
                                begin
                                    SPI_Slave_register <= (SPI_Slave_register<<1) | MOSI  ; // convert from series to parallel
                                    counter_1 <= counter_1 + 1;
                                    rx_valid  <= 1'b0;
                                end 
                            else 
                                begin
                                    counter_1 <= 4'h0;
                                    rx_data  <= SPI_Slave_register;
                                    rx_valid <= 1'b1;
                                    SPI_Slave_register <= 10'd0;
                                end
                        end

                    READ_DATA: 
                            begin
                                Is_the_address_sent <= 1'b0;  // to make the upcoming state is to read address
                                
                                // Receiving data logic
                                if (counter_1 < 10) 
                                    begin
                                        SPI_Slave_register <= (SPI_Slave_register << 1) | MOSI;
                                        // convert from series to parallel
                                        counter_1 <= counter_1 + 1;
                                        rx_valid  <= 1'b0;
                                    end 
                                else 
                                    begin
                                        counter_1 <= 4'h0;
                                        rx_data  <= SPI_Slave_register;
                                        rx_valid <= 1'b1;
                                        SPI_Slave_register <= 10'd0;
                                    end
                                
                                // Transmitting data on MISO
                                if ( tx_valid ) 
                                    begin
                                        MISO <= tx_data[7 - counter_2];
                                        counter_2 <= counter_2 + 1;
                                    end 
                                    
                                else
                                    begin
                                        MISO <= 0; // Ensure MISO is low if tx_valid is not asserted
                                    end
                            end
                            
                default: 
                    begin
                         MISO <= 0;
                        counter_1 <= 4'b0000 ;
                        counter_2 <= 3'b000 ;
                        Is_the_address_sent <= 1'b0 ;
                        rx_valid <= 1'b0 ;
                        rx_data <= 10'b0 ;
                    end

            endcase
        end

end
endmodule
