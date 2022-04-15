`timescale 1ns/1ps

module adau_spi_master(
        input clk,
        input reset,

        input [31:0] data_in,
        input valid,
        output reg ready,   //TO DO

        output reg cdata,
        output reg cclk = 1,  
        output reg clatch_n        
    );

    reg [6:0] clk_div = 0;
    reg [6:0] Bit_Counter = 7'b0011111;
    reg [31:0] temp_save_reg; //Zwischenspeicher
    reg cclk_counter;
    reg [1:0]state;
    
    localparam S_IDLE = 1'b0;
    localparam S_SEND_BIT = 1'b1;
    localparam S_CLATCH = 2'b10;

    
    // // CLOCK DIVIDER
    //             if(clk_div == 9)begin
    //                 clk_div <= 0; //1b`0
    //                 cclk <= ~cclk; // 1b`1
    //             end     
    //             else begin
    //                 clk_div <= clk_div + 1;
    //             end  

    // STATE MACHINE
    always @(posedge clk) begin
            if(reset == 1) begin
                ready <= 1; //ADDED
                state <= S_IDLE;
                //cclk <= 0;
                cclk_counter <= 0;
                Bit_Counter <= 32;
                cdata <= 0;
            end else begin
                case (state)        
                        S_IDLE: begin // input valid ready hier rein
                            //led <= 3'b010; // LED
                            if (valid == 1) begin
                                ready <= 0;
                                Bit_Counter <= 32;
                                state <= S_SEND_BIT;
                                temp_save_reg <= data_in;
                                clatch_n <= 1;
                            end
                        end
                        S_SEND_BIT: begin // ready und hier den clk divider
                            //cckl_counter
                                                        
                            if(clk_div == 11) begin 
                                clk_div <= 0; //1b`0
                                cclk <= ~cclk; // 1b`1
                                
                                if(cclk == 1) begin // should trigger at negative edge
                                    Bit_Counter <= Bit_Counter - 1;
                                    clatch_n <= 0;
                                    if (Bit_Counter == 0) begin
                                        state <= S_CLATCH;
                                        clatch_n <= 1;
                                        cclk <= 1;
                                        cclk_counter <= 0;
                                    end else begin
                                        cdata <= temp_save_reg[Bit_Counter - 1];  //zwischenspeicher verwenden
                                    end

                                end     
                            end     
                            else begin
                                clk_div <= clk_div + 1;
                            end 
                            //led <= 3'b100; // LED
                        end
                        S_CLATCH: begin // ready und hier den clk divider
                            //cckl_counter
                                                        
                            if(clk_div == 12) begin 
                                ready <= 1;
                                clk_div <= 0;
                                state <= S_IDLE; 
                            end     
                            else begin
                                clk_div <= clk_div + 1;
                            end 
                            
                            //led <= 3'b100; // LED
                        end 
                endcase
           end
    end
endmodule
