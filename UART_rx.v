`timescale 1ns / 1ps

module UART_rx#(
    parameter data_bits = 8 
    )(
    input clk,
    input rst,
    output reg [data_bits - 1 : 0] data_rx,
    input data_line_rx, 
    input baud_tick_16x,
    output reg success
    );
    
    localparam IDLE = 0;
    localparam START = 1;
    localparam DATA = 2;
    localparam STOP = 3;
    
    reg [1:0] state;
    reg [data_bits - 1 : 0] shift_reg;
    reg [data_bits - 1 : 0] bit_counter;
    reg [3:0] tick_counter;
    
    always @(posedge clk) begin
        if(rst == 1) begin
            state <= IDLE;
            success <= 0;
            bit_counter <= 0;
            tick_counter <= 0;
            shift_reg <= 0;
            data_rx <= 0;
        end else begin
            case(state)
                IDLE: begin 
                    if(data_line_rx == 0) begin
                        state <= START;
                        tick_counter <= 0;
                    end else begin
                        state <= IDLE;
                    end
                    success <= 0;
                end
                
                START: begin
                    if(baud_tick_16x == 1) begin
                        if(tick_counter == 7) begin
                            state <= DATA;
                            tick_counter <= 0;
                            bit_counter <= 0;
                        end else begin
                            tick_counter <= tick_counter + 1;
                        end
                    end
                end
                
                DATA: begin
                    if(baud_tick_16x == 1) begin
                        if(tick_counter == 15) begin
                            shift_reg <= {data_line_rx, shift_reg[data_bits-1:1]};
                            bit_counter <= bit_counter + 1;
                            tick_counter <= 0;
                            if(bit_counter == data_bits - 1) begin
                                state <= STOP;
                                tick_counter <= 0;
                            end else begin
                                state <= DATA;
                            end
                        end else begin
                            tick_counter <= tick_counter + 1;
                        end
                    end
                end
                
                STOP: begin
                    if(baud_tick_16x == 1) begin
                        if(tick_counter == 15) begin
                            if(data_line_rx == 1) begin
                                data_rx <= shift_reg;
                                success <= 1;
                                state <= IDLE;
                                tick_counter <= 0;
                                bit_counter <= 0;
                            end else begin
                                state <= IDLE;
                                tick_counter <= 0;
                                bit_counter <= 0;
                            end
                        end else begin
                            tick_counter <= tick_counter + 1;
                        end
                    end
                end
            endcase
        end
    end                
endmodule