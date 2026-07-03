`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2026 18:54:32
// Design Name: 
// Module Name: UART
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


module UART#(
    parameter clk_freq = 50000000,
    parameter baud_rate = 9600 

    )(
    input clk ,
    input rst ,
    output baud_tx ,
    output baud_rx
    );
    
    localparam baud_perbit_tx = clk_freq / baud_rate;
    localparam baud_perbit_rx = clk_freq / (baud_rate * 16);
    
    reg [12:0] counter_tx;
    always @(posedge clk) begin
        if(rst) counter_tx <= 0;
        else if (counter_tx == baud_perbit_tx -1) counter_tx <= 0;
        else counter_tx <= counter_tx + 1;
    end    
    
    reg[15:0] counter_rx;
    always @(posedge clk) begin
        if(rst) counter_rx <= 0;
        else if (counter_rx == baud_perbit_rx -1) counter_rx <=0;
        else counter_rx <= counter_rx + 1;
    end     
    
    assign baud_tx = (counter_tx == baud_perbit_tx - 1);
    assign baud_rx = (counter_rx == baud_perbit_rx - 1);
endmodule
