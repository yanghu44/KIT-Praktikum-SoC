`timescale 1ns / 1ps

module fpga_riscv_top(
        // system clock
        input sys_clk,

        // for debugging
        output [7:0] led,
        input [7:0] dip,
        output [7:0] debug,
        input btn_c,
        input btn_d,
        input btn_l,
        input btn_r,
        input btn_u,

        // ADAU signals
        output ac_mclk,

        output ac_addr0_clatch,
        output ac_addr1_cdata,
        output ac_scl_cclk,

        output ac_dac_sdata,
        output ac_bclk,
        output ac_lrclk
    );

    wire clk_soc;
    wire locked;

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
        // TODO
        .clk(clk_soc),
        .reset(reset),
        .spi_ready(spi_ready),
        .adau_init_done(adau_init_done),
        .command(adau_command),
        .command_valid(adau_command_valid)
    );

    adau_spi_master spi(
        .reset(reset),
        .clk(clk_soc),
        .data_in(adau_command),
        .ready(spi_ready),
        .valid(adau_command_valid),
        .cdata(ac_addr1_cdata),
        .cclk(ac_scl_cclk),
        .clatch_n(ac_addr0_clatch)
    );


    // sin <=> i2s
    wire [23:0] adau_audio_in_l, adau_audio_in_r;
    wire adau_audio_in_valid, adau_audio_full;

    i2s_master i2s(
        .clk_soc(clk_soc),
        .ac_mclk(ac_mclk),
        .reset(reset),
        .bclk(ac_bclk),
        .lrclk(ac_lrclk),
        .sdata(ac_dac_sdata),
        .frame_in_l(adau_audio_in_l),
        .frame_in_r(adau_audio_in_r),
        .full(adau_audio_full),
        .write_frame(adau_audio_in_valid)
    );


    // RAM for the CPU
    wire [14:0] ram_addr;
    wire [31:0] ram_wdata, ram_rdata;
    wire ram_valid, ram_ready;
    wire [3:0] ram_wstrb;

    // This gives exactly 4MiB
    cpu_ram #(.SIZE(13)) ram(
        .clk(clk_soc),
        .reset(reset),
        .addr(ram_addr),
        .wdata(ram_wdata),
        .valid(ram_valid),
        .wstrb(ram_wstrb),
        .rdata(ram_rdata),
        .ready(ram_ready)
    );


    // CPU bus logic
    wire [31:0] bus_addr, bus_wdata, bus_rdata;
    wire bus_valid, bus_ready;
    wire [3:0] bus_wstrb;

    cpu_bus_logic bus(
        .clk(clk_soc),
        .reset(reset),
        .addr(bus_addr),
        .wdata(bus_wdata),
        .wstrb(bus_wstrb),
        .rdata(bus_rdata),
        .valid(bus_valid),
        .ready(bus_ready),

        .dip(dip),
        .buttons({btn_c, btn_d, btn_l, btn_r, btn_u}),
        .led(led),

        .ram_addr(ram_addr),
        .ram_wdata(ram_wdata),
        .ram_valid(ram_valid),
        .ram_wstrb(ram_wstrb),
        .ram_rdata(ram_rdata),
        .ram_ready(ram_ready),

        .adau_audio_l(adau_audio_in_l),
        .adau_audio_r(adau_audio_in_r),
        .adau_audio_valid(adau_audio_in_valid),
        .adau_audio_full(adau_audio_full),
        .adau_init_done(adau_init_done)
    );

   // CPU instance
   picorv32 #(
        .REGS_INIT_ZERO(1),
        .PROGADDR_RESET(32'h0000_0000),
        .PROGADDR_IRQ(32'h0000_0010),
        .ENABLE_MUL(1),
        .ENABLE_IRQ(1),
        .LATCHED_IRQ(32'hffff_ffff),
        .MASKED_IRQ(32'hffff_ff00)
        ) cpu (
            .clk(clk_soc),
            .resetn(!reset),
            .mem_valid(bus_valid),
            .mem_ready(bus_ready),
            .mem_addr(bus_addr),
            .mem_wdata(bus_wdata),
            .mem_wstrb(bus_wstrb),
            .mem_rdata(bus_rdata),
            .pcpi_wr(1'b0),
            .pcpi_rd(32'b0),
            .pcpi_wait(1'b0),
            .pcpi_ready(1'b0),
            .irq({24'b0, btn_c, btn_d, btn_l, btn_r, btn_u, 3'b0})
    );

    // Debug signals
    assign debug[0] = ac_addr0_clatch;
    assign debug[1] = ac_scl_cclk;
    assign debug[2] = reset;
    assign debug[3] = ac_bclk;
    assign debug[4] = ac_lrclk;
    assign debug[5] = ac_addr1_cdata;
    assign debug[6] = ac_dac_sdata;

endmodule
