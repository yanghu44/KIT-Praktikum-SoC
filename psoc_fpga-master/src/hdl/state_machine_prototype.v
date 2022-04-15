`timescale 1ns/1ps

module adau_spi_master(
        input clk,
        input reset,

        input [31:0] data_in,
        input valid,
        output ready,

        output cdata,
        output cclk,
        output reg clatch_n,
        // some example debug signals
        output [2:0] led,

        //--------------------------------------------------
        
        input [6:0] Chip_Adress,
        input RW,
        input [7:0] Reg_MSB, 
        input [7:0] Reg_LSB,
        input [7:0] DATA, 
        output MOSI_output 
        
    );

    reg [31:0] SPI_bit_stream;
    reg Bit_Counter;

   
    assign  SPI_bit_stream[31:25] = Chip_Adress;
    assign  SPI_bit_stream[24:24] = RW;
    assign  SPI_bit_stream[23:16] = Reg_MSB;
    assign  SPI_bit_stream[15:8] = Reg_LSB;
    assign  SPI_bit_stream[7:0] = DATA;

    //--------------------------------------------------
  
    // // Placeholder example debug code. Replace with your SPI implementation
    // assign ac_addr0_clatch = 'b0;
    // assign ac_addr1_cdata = 'b0;
    // assign ac_scl_cclk = 'b0;
    // assign ready = 'b0;
    // assign cdata = 'b0;
    // assign cclk = 'b0;

    // reg [2:0] ledreg = 0;
    // reg [24:0] counter = 0;

    // assign led = ledreg;

    //--------------------------------------------------
    
    
    always @(posedge Clk or posedge Dlatch)
    begin
        if (Dlatch)
            case (sr[8:7])
                IDLE:
                    state = S_IDLE;
                SEND_BIT:
                    state = S_SEND_BIT;
                // ADDRESS_1:
                //     state = S_ADDRESS_1;
                // ADDRESS_2:
                //     state = S_ADDRESS_2;
                // DATA:
                //     state = S_DATA;    
                default:
                    state = S_IDLE;
            endcase
        else
            case (state)
                S_IDLE: begin
                    if (Bit_Counter == 0) begin
                        state = S_SEND_BIT
                    end
                    state = S_IDLE;
                    end
                S_HEADER: begin
                    
                    
                    
                    
                    
                    address <= sr[3:0];
                    state = S_IDLE;
                    end
                
                
                
                
                
                
                
                
                
                
                
                // S_ADDRESS_1: begin
                //     address <= address;
                //     state = S_WR;
                //     end
                // S_ADDRESS_2: begin
                //     address <= address;
                //     state = S_IDLE;
                //     end
                // S_DATA: begin
                //     address <= address;
                //     state = S_IDLE;
                //     end
            endcase
    end

    // Latch and Cleat control
    always @(state)
    begin
        case (state)
            default: begin
                    clear <= 0;
                    write_latch <= 0;
                end
            S_GOTO_POS: begin
                    clear <= 0;
                    write_latch <= 0;
                end
            S_LOAD_ADV: begin
                    clear <= 0;
                    write_latch <= 0;
                end
            S_CLEAR: begin
                    clear <= 1;
                    write_latch <= 0;
                end
            S_WR: begin
                    clear <= 0;
                    write_latch <= 1;
                end
            S_ADV_WR: begin
                    clear <= 0;
                    write_latch <= 1;
                end
        endcase
    end
        
        
        
    



    //--------------------------------------------------

    always @(posedge clk or posedge reset) begin
        clatch_n = 'b0;
        if(reset) begin
            ledreg <= 0;
        end
        else begin
            if (counter == 0) begin
                if(ledreg == 0)
                    ledreg <= 1;
            else
                ledreg <= {ledreg[1:0], 1'b0};
            end
            counter <= counter +1;
        end
    end

endmodule
