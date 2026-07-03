`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2026 15:00:18
// Design Name: 
// Module Name: UART_tx
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


module UART_tx #(
    parameter data_bits = 8 
    )(
    input clk ,
    input [data_bits - 1 : 0] data_tx , 
    input rst ,
    input baud_tick ,
    input start_tx ,
    output reg data_line_tx ,
    output reg done_tx 
    );
    
    localparam IDLE = 0;
    localparam START = 1;
    localparam  DATA = 2;
    localparam STOP = 3;
    
    reg [1:0] state ;
    reg [data_bits - 1 : 0]shift_reg;
    reg [data_bits - 1 : 0] bit_counter;
    always @(posedge clk) begin
    if(rst) begin
        state <= IDLE;
        done_tx <= 0;
        data_line_tx <= 1;
        bit_counter <= 0;
        shift_reg <= 0;
    end else begin
        case(state)
            IDLE  : begin
                    if (start_tx == 1) state <= START;
                    else               state <= IDLE;
                    done_tx <= 0;
                    end 
            START : begin data_line_tx <= 0 ;
                    if(baud_tick == 1) begin state <= DATA ; shift_reg <= data_tx; end
                    else               state <= START; end
            DATA  : begin
                    data_line_tx <= shift_reg[0];
                    if(baud_tick == 1) begin
                        if(bit_counter == data_bits - 1)begin
                            state <= STOP;
                            bit_counter <= 0; end
                         else begin
                            shift_reg <= shift_reg>>1;
                            bit_counter <= bit_counter + 1 ;   
                         end
                    end         
                    end      
             STOP : begin
                    data_line_tx <= 1 ;
                    if(baud_tick == 1) begin
                        state <= IDLE ;
                        done_tx <= 1; end
                    else 
                        state <= STOP;    
                    
                    end           
        endcase
       end
    end
    
    
endmodule
