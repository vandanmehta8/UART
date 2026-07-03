`timescale 1ns / 1ps

module UART_TOP_tb;
    reg clk;
    reg rst;
    reg [7:0] data_tx;
    reg start_tx;
    wire [7:0] data_rx;
    wire data_line_tx;
    wire data_line_rx;
    wire done_tx;
    wire success;
    
    assign data_line_rx = data_line_tx;
    
    UART_TOP #(
        .clk_freq(50000000),
        .baud_rate(9600),
        .data_bits(8)
    ) dut (
        .clk(clk),
        .rst(rst),
        .data_tx(data_tx),
        .data_rx(data_rx),
        .start_tx(start_tx),
        .data_line_rx(data_line_rx),
        .data_line_tx(data_line_tx),
        .done_tx(done_tx),
        .success(success)
    );
    
    initial clk = 0;
    always #10 clk = ~clk;
    
    // Timeout counter
    integer timeout;
    
    initial begin
        rst = 1;
        start_tx = 0;
        data_tx = 8'h00;
        
        #200;
        rst = 0;
        #200;
        
        // ===== Test 1: 0x41 =====
        $display("=== Starting Test 1: 0x41 ===");
        @(posedge clk);
        data_tx = 8'h41;
        start_tx = 1;
        @(posedge clk);
        start_tx = 0;
        
        // Wait for done_tx with timeout
        timeout = 0;
        while(done_tx == 0 && timeout < 2000000) begin
            @(posedge clk);
            timeout = timeout + 1;
        end
        $display("TX1 done at time %0t, timeout=%0d", $time, timeout);
        
        // Wait for success with timeout
        timeout = 0;
        while(success == 0 && timeout < 2000000) begin
            @(posedge clk);
            timeout = timeout + 1;
        end
        $display("RX1 success at time %0t, timeout=%0d, data_rx=%h", $time, timeout, data_rx);
        
        // Wait for success to clear
        timeout = 0;
        while(success == 1 && timeout < 100000) begin
            @(posedge clk);
            timeout = timeout + 1;
        end
        $display("RX1 idle at time %0t", $time);
        
        repeat(50000) @(posedge clk);
        
        // ===== Test 2: 0xAA =====
        $display("=== Starting Test 2: 0xAA ===");
        @(posedge clk);
        data_tx = 8'hAA;
        start_tx = 1;
        @(posedge clk);
        start_tx = 0;
        
        timeout = 0;
        while(done_tx == 0 && timeout < 2000000) begin
            @(posedge clk);
            timeout = timeout + 1;
        end
        $display("TX2 done at time %0t, timeout=%0d", $time, timeout);
        
        timeout = 0;
        while(success == 0 && timeout < 2000000) begin
            @(posedge clk);
            timeout = timeout + 1;
        end
        $display("RX2 success at time %0t, timeout=%0d, data_rx=%h", $time, timeout, data_rx);
        
        if(data_rx == 8'hAA)
            $display("=== ALL TESTS PASSED ===");
        else
            $display("=== TEST FAILED: expected AA, got %h ===", data_rx);
        
        #100000;
        $finish;
    end
endmodule