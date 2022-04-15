`timescale 1ns/1ps

module i2s_master(
        //other signals
        input clk_soc,
        input ac_mclk,
        input reset,
        //input adau_init_done,
        //input enable_sound,
                
        //I2S signals
        output reg bclk,
        output reg lrclk,
        output reg sdata,    
        
        //audio input data
        input [23:0] frame_in_l, frame_in_r,
        input write_frame,
        output full
    );

reg [0:0] i2s_state ;
localparam S_LEFT = 1'b0;
localparam S_RIGHT = 1'b1;

reg rd_en;
reg data_av_flag;                       //used to signal the first data read from the FIFO

reg [6:0] clk_counter;                  //Counts the clock cycles to time the bclk
reg [5:0] Bit_Counter;                  //Counts the number of transmitted bits on the bus

wire [23:0] left_data;                  //Signal to read in the data for the left channel from the FIFO
reg [23:0] left_data_buffer;            //Buffers the FIFO signal to be put on the bus
wire [23:0] right_data;                 //Signal to read in the data for the left channel from the FIFO
reg[23:0] right_data_buffer;

wire full_l, full_r;
wire empty_l, empty_r;


assign full = full_l | full_r;
assign empty = empty_l | empty_r;

fifo_generator_0 fifo_left (
  .rst(reset),                          // input wire rst
  .wr_clk(clk_soc),                     // input wire wr_clk
  .rd_clk(ac_mclk),                     // input wire rd_clk
  .din(frame_in_l),                     // input wire [23 : 0] din
  .wr_en(write_frame),                  // input wire wr_en
  .rd_en(rd_en),                        // input wire rd_en
  .dout(left_data),                     // output wire [23 : 0] dout
  .full(full_l),                        // output wire full
  .empty(empty_l),                      // output wire empty
  .wr_rst_busy(wr_rst_busy_l),          // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy_l)           // output wire rd_rst_busy
  );  
  
fifo_generator_0 fifo_right (
  .rst(reset),                          // input wire rst
  .wr_clk(clk_soc),                     // input wire wr_clk
  .rd_clk(ac_mclk),                     // input wire rd_clk
  .din(frame_in_r),                     // input wire [23 : 0] din
  .wr_en(write_frame),                  // input wire wr_en
  .rd_en(rd_en),                        // input wire rd_en
  .dout(right_data),                    // output wire [23 : 0] dout
  .full(full_r),                        // output wire full
  .empty(empty_r),                      // output wire empty
  .wr_rst_busy(wr_rst_busy_r),          // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy_r)           // output wire rd_rst_busy
);

always @(posedge ac_mclk) begin

    //clk_counter initialization and reset condition
    if (clk_counter == 0 || reset == 1) begin
        clk_counter <= 7'b0111111;  // 63       //counts 64 clock cycles, to create 32 bclk cycles
    end else begin
        clk_counter <= clk_counter - 1;   
    end

    //common reset condition
    if (reset == 1) begin
        i2s_state <= S_RIGHT;
        bclk <= 0;
        lrclk <= 1'b1;
        Bit_Counter <= 23;
        rd_en <= 1'b1;
        data_av_flag <= 1'b0;
                        
    end else begin
    
    if (empty == 0)                     //check if FIFO has already received data

        rd_en <= 0;
        
        case (i2s_state) 
       
            S_LEFT: begin               //Left channel data transfer

                //still data left to be sent                
                if (clk_counter > 16) begin     //check if 24 Bits / 48 cycles have already passed
                        if (bclk == 1) begin
                            sdata <= left_data_buffer[Bit_Counter]; //Left channel data is put on the bus serially
                            Bit_Counter <= Bit_Counter - 1;                
                        end
                        
                        bclk <= ~bclk;

                //all 24 bits have been send, waiting for 8 bits /16 cycles
                end else if (clk_counter > 0 && clk_counter <= 15)begin 
                    bclk <= 0;                  //blck set to 0 while no data is transmitted
                    sdata <= 1'b0;
                    Bit_Counter = 23;           //Counter reset
                    
                    if (clk_counter == 1) begin
                    lrclk <= 1'b1;
                    end
                    

                //32 bits / 64 ac_mclk cycles have passed
                end else if (clk_counter == 0) begin
                    i2s_state <= S_RIGHT;      //Change the state to the other channel
                    bclk <= 1'b1;                                       
                end

            end
        
            S_RIGHT: begin              //Right channel data transfer

                if (clk_counter > 16) begin     //check if 24 Bits / 48 cycles have already passed
                    if (data_av_flag == 1) begin    //only transmit data if there is some data in the buffer
                        if (bclk == 1) begin
                            sdata <= right_data_buffer[Bit_Counter];    //Right channel data is put on the bus serially
                            Bit_Counter <= Bit_Counter - 1;                
                        end
                        
                       bclk <= ~bclk;
                    end

                //all 24 bits have been send, waiting for 8 bits /16 cycles
                end else if (clk_counter > 0 && clk_counter <= 15)begin
                    bclk <= 0;
                    Bit_Counter <= 23;

                    if (clk_counter == 2) begin
                        rd_en <= 1;

                    end else if (clk_counter == 1) begin
                        left_data_buffer <= left_data;      //read in the data from the FIFO for both channes
                        right_data_buffer <= right_data;
                        data_av_flag = 1'b1;                //set data available flag to signal that there is now data available
                        lrclk <= 1'b0;
                    end
                    

                end else if (clk_counter == 0) begin
                    i2s_state <= S_LEFT;        //Change the state to the other channel
                    bclk <= 1'b1;
                                       
                end
                
            end
        endcase
    end    

end



endmodule
