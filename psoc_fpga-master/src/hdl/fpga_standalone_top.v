`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Description:
// Standalone top module which does not include the picorv32 processor.
// This is used for simple debugging to get the ADAU driver working first.
//
//////////////////////////////////////////////////////////////////////////////////


module fpga_standalone_top(
        // system clock
        input sys_clk,

        // for debugging
        output [7:0] led,
        output [7:0] debug,
        input [7:0] dip,
        input btn_c,
        input btn_d,
        input btn_l,
        input btn_r,
        input btn_u,

        // TODO: ADAU signals
       
        output ac_mclk,
        output cdata,
        output sdata,
        output cclk,  
        output clatch_n,
        output bclk,
        output lrclk
                
    );

    // global fast clock
    wire clk_soc;
    wire locked;
    
    //I2S Sinewave dont know if needed
    wire [23:0] frame_in_l; 
    wire [23:0] frame_in_r; 
    wire full, write_frame;

    assign  frame_in_r = frame_in_l;
    
    // Generate all required clocks
    clk_wiz_0 pll(
        .clk_in1(sys_clk),
        .reset(0),
        .clk_soc(clk_soc),
        .ac_mclk(ac_mclk),
        .locked(locked)
    );

    // stretch the reset pulse
    reg [5:0] reset_counter = 6'b111111;
    wire reset = reset_counter[5];
    always @(posedge clk_soc) begin
        if (btn_c == 1)
            reset_counter <= 6'b111111;
        else if(!locked)
            reset_counter <= 6'b111111;
        else if(|reset_counter)
            reset_counter <= reset_counter - 1;
    end


    // ctrl <=> spi interface
    wire [31:0] adau_command;
    wire adau_command_valid, spi_ready, adau_init_done;

    adau_command_list ctrl(
        // TODO: Assign ports
        .clk(clk_soc),
        .reset(reset),
        .command(adau_command),
        .adau_init_done(adau_init_done),
        .command_valid(adau_command_valid),
        .spi_ready(spi_ready)
        
    );

    adau_spi_master spi(
        .clk(clk_soc),
        .reset(reset),

        .data_in(adau_command),
        .valid(adau_command_valid),
        .ready(spi_ready),

        .cdata(cdata),
        .cclk(cclk),
        .clatch_n(clatch_n)

        // DEBUG signals
        //.led(led[7:5])
    );
    

    i2s_master i2s (
        .clk_soc(clk_soc),
        .ac_mclk(ac_mclk),
        .reset(reset),
        .bclk(bclk),
        .lrclk(lrclk),
        .sdata(sdata),
        .frame_in_l(frame_in_l),
        .write_frame(write_frame),
        .frame_in_r(frame_in_r),
        .full(full)
    );

    sine_generator sin(     
        .clk(clk_soc),
        .reset(reset),
        .ready(full),
        .valid(write_frame),
        .out(frame_in_l)
        //.out(frame_in_r)

    );


    // Default LED outputs for debugging signals
    //assign led[4:0] = dip[4:0] & {btn_c, btn_d, btn_l, btn_r, btn_u};
    
    //assign debug = led;
    //assign the debug port to the signals that need to be read on logic analyzer
    assign debug[0] = clatch_n;
    assign debug[1] = cclk;
    assign debug[2] = reset;
    assign debug[3] = bclk;
    assign debug[4] = lrclk;
    assign debug[5] = cdata;
    assign debug[6] = sdata;
    //assign debug[7] = sys_clk;
    
    
 endmodule
