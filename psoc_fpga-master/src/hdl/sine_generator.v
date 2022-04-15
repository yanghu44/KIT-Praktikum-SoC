`timescale 1ns/1ps

module sine_generator(
        // TODO: Add ports
        input clk,
        input reset,
        input ready,

        output reg valid,
        output reg [23:0] out
    );
    
localparam LUT_HEIGHT = 91;
reg [23:0] lut [0:LUT_HEIGHT-1];
initial $readmemh("sin_lut_90x24.mem", lut);

reg [7:0] cnt;

always @(posedge clk) begin
    if (reset==1) begin
        cnt <=0;
        valid <= 0;
        out <= 24'b0;
    end
    else begin 
        if (ready == 0) begin
            out <= lut[cnt];
            valid <= 1;
            if(cnt < LUT_HEIGHT -2)
                cnt <= cnt +1;
            else
                cnt <= 0;
        end
       
    end    
end

endmodule
