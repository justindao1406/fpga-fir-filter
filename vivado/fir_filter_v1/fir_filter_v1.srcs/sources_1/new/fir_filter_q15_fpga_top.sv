`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 09:32:27 PM
// Design Name: 
// Module Name: fir_filter_q15_fpga_top
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


module fir_filter_q15_fpga_top(
    input logic sysclk,
    input logic reset_button,
    output logic led_pass,
    output logic led_fail,
    output logic led_done
    );
    
    logic fir_clk;
    logic cpu_locked;
    
    clk_wiz_25mhz cpu_clk_inst ( .clk_out1(fir_clk), .reset(1'b0), .locked(cpu_locked), .clk_in1(sysclk) );
    
    logic signed [15:0] sample_in; 
    logic sample_valid; 
    logic signed [15:0] sample_out; 
    logic output_valid;
    
    // reset logic
    
    logic raw_reset; // immediate reset request
    assign raw_reset = reset_button || !cpu_locked;
    
    logic [2:0] reset_pipe;
    logic fir_reset;
    
    
    always_ff @(posedge fir_clk or posedge raw_reset) begin // raw reset async
        if (raw_reset) begin
            reset_pipe <= 3'b111;     
        end
        else begin
            reset_pipe <= {reset_pipe[1:0], 1'b0}; // w/ reset_pipe = 111 : 111 -> 110 -> 100 -> (0)00 (fir_reset = 0 on a clock edge)
            // avoids metastability
        end    
    end
    
    assign fir_reset = reset_pipe[2];
    
    // FPGA -> FIR logic
    
    fir_filter_q15_top fir_inst 
    ( .clk(fir_clk), .reset(fir_reset), .sample_in(sample_in), .sample_valid(sample_valid),
    .sample_out(sample_out), .output_valid(output_valid) );
    
    logic signed [15:0] input_samples [0:479];
    logic signed [15:0] predicted_outputs [0:479];
    logic [8:0] input_position;
    logic [8:0] output_position;
    logic found_mismatch;
    logic test_running;
    
    initial begin
        $readmemh("input_samples.mem", input_samples);
        $readmemh("predicted_outputs.mem", predicted_outputs);
    end
    
    always_ff @(posedge fir_clk) begin
        if (fir_reset) begin
            sample_in <= 0;
            sample_valid <= 0;
            input_position <= 9'd0;
            output_position <= 9'd0;
            found_mismatch <= 1'd0;
            test_running <= 1'd0;        
            led_pass <= 0;
            led_fail <= 0;
            led_done <= 0;
        end       
        else begin
            // input
            
            if (!test_running && !led_done) begin // starts test by feeding first sample
                test_running <= 1;
                sample_in <= input_samples[0];
                sample_valid <= 1;
                input_position <= 1;
            end
            else if (test_running && input_position < 480) begin // continue feeding and incrementing 
                sample_valid <= 1;
                sample_in <= input_samples[input_position];
                input_position <= input_position + 1;
            end
            else begin
                sample_valid <= 0; // turn off sample valid when test stops running
            end
            
            // output
            
            if (output_position == 480) begin
                led_done <= 1;
                test_running <= 0;
                if (found_mismatch == 1) begin
                    led_fail <= 1;
                end
                else begin
                    led_pass <= 1;
                end
            end   
            if (output_valid && output_position < 480) begin
                if (sample_out != predicted_outputs[output_position]) begin
                    found_mismatch <= 1;        
                end
                output_position <= output_position + 1;
            end
            
        end
    end
    
endmodule
