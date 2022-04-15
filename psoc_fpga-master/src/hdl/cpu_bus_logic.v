// MEMORY MAP:
// - 0x00010000 - 0x00017fff: RAM (read-write)
// - 0x80000000: DIP switches (read-only)
// - 0x80000004: LEDs (read-write)
// - 0x80000008: buttons (read-only)
// - 0x8000000c: audio status (read-only)
//   - bit 0: audio FIFO full
//   - bit 1: ADAU configuration complete
// - 0x80000010: left audio sample (write-only)
// - 0x80000014: right audio sample (write-only)
//   Writing to the right channel triggers a write into the audio FIFO.
module cpu_bus_logic(
      input clk,
      input reset,

      // CPU connections
      input [31:0] addr,
      input [31:0] wdata,
      output reg [31:0] rdata,
      input [3:0] wstrb,
      input valid,
      output reg ready,

      // debugging stuff
      input [7:0] dip,
      input [4:0] buttons,
      output reg [7:0] led,

      // RAM interface
      output [14:0] ram_addr,
      output [31:0] ram_wdata,
      output reg ram_valid,
      output [3:0] ram_wstrb,
      input [31:0] ram_rdata,
      input ram_ready,

      // adau_interface signals
      output reg [23:0] adau_audio_l, adau_audio_r,
      output reg adau_audio_valid,
      input adau_audio_full,
      input adau_init_done
   );

   assign ram_addr = addr[14:0];
   assign ram_wstrb = wstrb;
   assign ram_wdata = wdata;

   // read logic
   always @(*) begin
      ram_valid = 0;
      ready = 1;
      casez(addr)
         // 15 bit address / 256 kiBit
         // 0x0000_0000 - 0x0000_7FFF
         32'b0000_0000_0000_0000_0???_????_????_????: begin
            rdata = ram_rdata;
            ram_valid = valid;
            ready = ram_ready;
         end

         32'h8000_0000: begin
            rdata = {24'b0, dip};
            ram_valid = 0;
            ready = 1;
         end

         32'h8000_0004: begin
            rdata = {24'b0,led};
            ram_valid = 0;
            ready = 1;
         end

         32'h8000_0008: begin
            rdata = {24'b0,buttons};
            ram_valid = 0;
            ready = 1;
         end

         32'h8000_000c: begin
            rdata = {24'b0,adau_init_done, adau_audio_full};
            ram_valid = 0;
            ready = 1;
         end

         default: begin
            rdata = 32'h0000_0000;
            ram_valid = 0;
            ready = 1;
         end
      endcase
   end

   // write logic
   always @(posedge clk) begin
      if(reset) begin
         led <= 8'h00;
         adau_audio_l <= 24'h000000;                        //initial write for left and right data
         adau_audio_r <= 24'h000000;
      end else begin
          if (!adau_audio_full && adau_audio_valid)
              adau_audio_valid <= 0;                        //reset valid bit, if FIFO is full and no new data can be read

          if(valid) begin
             case(addr)
               32'h8000_0004: begin
                   if(wstrb[0])
                      led <= wdata[7:0];
                end
                // TODO
               
               32'h8000_0010: begin 
                  if(wstrb[2] && wstrb[1] && wstrb[0])
                     adau_audio_l[23:0] <= wdata[23:0];        //Data from the left channel is written to the FIFO
               end
               
               32'h8000_0014: begin
                  if(wstrb[2] && wstrb[1] && wstrb[0]) begin
                     adau_audio_valid <= 1;                    //valid for write enable in FIFO, should only be set once until FIFO is full
                     adau_audio_r[23:0] <= wdata[23:0];        //Data from the right channel is written to the FIFO
                  end
               end
               
             endcase
         end
      end
   end
endmodule
