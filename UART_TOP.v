`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2026 18:51:20
// Design Name: 
// Module Name: UART_TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_TOP#(
    parameter clk_freq = 50000000 ,
    parameter baud_rate = 9600 ,
    parameter data_bits = 8
    )(
    input clk , 
    input rst ,
    input [data_bits -1 : 0]data_tx ,
    output [data_bits-1 : 0] data_rx , 
    input start_tx ,
    input data_line_rx ,
    output  data_line_tx , 
    output  done_tx,
    output  success  
    
    );
    
    wire baud_tick ;
    wire baud_tick_16x;
    
    UART #(
        .clk_freq(clk_freq),
        .baud_rate(baud_rate)
    )baud_gen_list(
        .clk(clk) ,
        .rst(rst) ,
        .baud_tx(baud_tick),
        .baud_rx(baud_tick_16x)
    );
    
    UART_tx #(
        .data_bits(data_bits)
    )tx_gen_list(
        .clk(clk) ,
        .rst(rst) ,
        .data_tx(data_tx),
        .data_line_tx(data_line_tx) ,
        .start_tx(start_tx) ,
        .done_tx(done_tx),
        .baud_tick(baud_tick)
        
    );
    
     UART_rx #(
        .data_bits(data_bits)
    )rx_gen_list(
        .clk(clk) ,
        .rst(rst) ,
        .data_rx(data_rx),
        .data_line_rx(data_line_rx) ,
        .baud_tick_16x(baud_tick_16x) , 
        .success(success)
        
    );
    
    
    
endmodule
