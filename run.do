# open work for projec 
vlib work

# compile the files 
vlog SPI_Single_Port_RAM.v  SPI_Slave.v SPI_Wrapper.v SPI_testbench.v 

# simulate testbench 
vsim -voptargs="+acc" work.SPI_testbench

# Add signals to wave
add wave -position insertpoint \
sim:/SPI_testbench/clk \
sim:/SPI_testbench/rst_n \
sim:/SPI_testbench/SS_n \
sim:/SPI_testbench/MOSI \
sim:/SPI_testbench/MISO \
sim:/SPI_testbench/received_data_at_Master \
sim:/SPI_testbench/DUT/mem/din \
sim:/SPI_testbench/DUT/DUT/rx_data \
sim:/SPI_testbench/DUT/mem/rx_valid \
sim:/SPI_testbench/DUT/DUT/CS \
sim:/SPI_testbench/DUT/DUT/NS \
sim:/SPI_testbench/DUT/mem/dout \
sim:/SPI_testbench/DUT/DUT/tx_data \
sim:/SPI_testbench/DUT/mem/tx_valid \
sim:/SPI_testbench/DUT/DUT/Is_the_address_sent \
sim:/SPI_testbench/DUT/DUT/SPI_Slave_register \
sim:/SPI_testbench/DUT/mem/RAM \
sim:/SPI_testbench/DUT/DUT/counter_1 \
sim:/SPI_testbench/DUT/DUT/counter_2

# run the simulation

 run -all
