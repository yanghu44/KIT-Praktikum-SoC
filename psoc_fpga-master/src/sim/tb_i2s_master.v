`timescale 1ns/1ps

// This testbench assumes the following:
// - set LRCLK at 50% duty cycle
// - SDATA read when BCLK falls
// - audio frames begin when LRCLK falls
// - 2 channels per frame
// - ADAU is the I2S slave
// - 48 BCLK cycles per audio frame
// - left channel first
// - MSB first
// - data starts one BCLK after the LRCLK edge (Data delay from LRCLK edge (in BCLK units))
module tb_i2s_master();
    // Generate clocks
    reg clk_soc;
    initial clk_soc <= 0;
    always #4.167 clk_soc <= ~clk_soc;

    reg ac_mclk = 0;
    always #40.69 ac_mclk <= ~ac_mclk;

    // i2s_master signals
    wire bclk;
    wire full;
    wire lrclk;
    wire sdata;
    reg reset;
    reg write_frame;
    reg [23:0] frame_in_l, frame_in_r;

    i2s_master uut(
        .bclk (bclk),
        .lrclk (lrclk),
        .sdata (sdata),
        .full (full),

        .clk_soc (clk_soc),
        .ac_mclk (ac_mclk),
        .reset(reset),
        .frame_in_l (frame_in_l),
        .frame_in_r (frame_in_r),
        .write_frame (write_frame)
    );

    task receive_frame;
        input [23:0] want_l, want_r;
        reg [23:0] l, r;
        integer count;
        begin
            $display("receive_frame(want_l=24'h%06x, want_r=24'h%06x) @ %t", want_l, want_r, $time);
            fork
                begin: receive
                    // Left sample
                    count = 0;
                    while (!lrclk) begin
                        @(negedge bclk or posedge lrclk);
                        if (lrclk) begin
                            // loop will end
                        end else if(!bclk) begin
                            if (count >= 24) begin
                                $error("got more BCLK edges than expected (> 24) while receiving the left sample");
                                #100
                                $finish;
                            end else begin
                                l[23-count] = sdata;
                            end
                            count = count + 1;
                        end
                    end
                    if (count < 24) begin
                        $error("got less BCLK edges than expected (want 24, got %0d)", count);
                        #100
                        $finish;
                    end
                    if (want_l !== l) begin
                        $error("left sample was received incorrectly (want %06x, got %06x)", want_l, l);
                        #100
                        $finish;
                    end

                    // Right sample
                    count = 0;
                    while (lrclk) begin
                        @(negedge bclk or negedge lrclk);
                        if (!lrclk) begin
                            // loop will end
                        end else if (!bclk) begin
                            if (count >= 24) begin
                                $error("got more BCLK edges than expected (> 24) while receiving the right sample");
                                #100
                                $finish;
                            end else begin
                                r[23-count] = sdata;
                            end
                            count = count + 1;
                        end
                    end
                    if (count < 24) begin
                        $error("got less BCLK edges than expected (want 24, got %0d)", count);
                        #100
                        $finish;
                    end
                    if (want_r !== r) begin
                        $error("right sample was received incorrectly (want %06x, got %06x)", want_r, r);
                        #100
                        $finish;
                    end

                    disable timeout;
                end

                begin: timeout
                    #21000;
                    disable receive;
                    $error("Frame transfer timed out (waited for 21us)");
                    #100
                    $finish;
                end
            join
        end
    endtask

    task do_reset;
        begin
            reset <= 1;
            write_frame <= 0;
            repeat (10)
                @(posedge ac_mclk);

            reset <= 0;
            repeat (10)
                @(posedge ac_mclk);
        end
    endtask

    // Uncomment to display the received data:
    // reg [23:0] din;
    // reg last_lrclk = 0;
    // always @(lrclk) begin
    //    $display("%c %06x @ %t", last_lrclk ? "R" : "L", din, $time);
    //    din <= 24'hx;
    //    last_lrclk <= lrclk;
    // end
    // always @(negedge bclk) begin
    //    din <= {din[22:0], sdata};
    // end

    // Uncomment to display FIFO writes:
    // always @(posedge clk_soc) begin
    //    if(write_frame)
    //      $display("FIFO write: %06x %06x", frame_in[47:24], frame_in[23:0]);
    // end

    // Uncomment to display FIFO reads (you might need to change uut.{fifo_read, cur_frame}):
    // always @(posedge ac_mclk) begin
    //    if(uut.fifo_read) begin
    //	 @(posedge ac_mclk);
    //       $display("FIFO read: %06x %06x", uut.cur_frame[47:24], uut.cur_frame[23:0]);
    //    end
    // end

    integer i;

    initial begin
        $timeformat(-9, 5, " ns", 10);

        reset = 1;
        write_frame = 0;
        do_reset;

        // Wait for the FIFO reset to complete.
        wait (full == 0);

        // Push some test data into the FIFO.
        @(posedge clk_soc);
        $display("sending 0x123456 0xabcdef");
        frame_in_l <= 24'h123456;
        frame_in_r <= 24'habcdef;
        write_frame <= 1;

        @(posedge clk_soc);
        $display("sending 0x111111 0x222222");
        frame_in_l <= 24'h111111;
        frame_in_r <= 24'h222222;

        @(posedge clk_soc);
        $display("sending 0x333333 0x444444");
        frame_in_l <= 24'h333333;
        frame_in_r <= 24'h444444;

        @(posedge clk_soc);
        $display("sending 0x555555 0x666666");
        frame_in_l <= 24'h555555;
        frame_in_r <= 24'h666666;

        @(posedge clk_soc);
        frame_in_l <= 24'hxxxxxx;
        frame_in_r <= 24'hxxxxxx;
        write_frame <= 0;

        // Check the received data.
        @(negedge lrclk);  // Wait for frame start.
        receive_frame(24'h123456, 24'habcdef);
        receive_frame(24'h111111, 24'h222222);
        receive_frame(24'h333333, 24'h444444);
        receive_frame(24'h555555, 24'h666666);
        receive_frame(24'h000000, 24'h000000);  // UUT should start sending zeroes when the FIFO is empty.

        // Test the FULL flag.
        do_reset;

        frame_in_l <= 24'hxxxxxx;
        frame_in_r <= 24'hxxxxxx;
        write_frame <= 1;
        @(posedge clk_soc);
        for (i = 0; i < 10000 && !full; i = i+1) begin
            @(posedge clk_soc);
        end
        write_frame <= 0;
        if (!full) begin
            $error("FULL is still low after 10000 writes; this does not seem correct");
            #100
            $finish;
        end

        $display("Test OK");
        $finish;
    end
endmodule
