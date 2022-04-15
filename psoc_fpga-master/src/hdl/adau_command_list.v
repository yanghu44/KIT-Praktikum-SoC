`timescale 1ns/1ps

module adau_command_list(
        // TODO: Add ports
        input spi_ready,
        input reset,
        input clk,

        //adau_init_done high when all data has been sent
        output reg adau_init_done,
        output reg [31:0] command,
        output reg command_valid
        //output [4:3] led
    );

    //there are 15 commands, each has 32 bits of messages
    reg [31:0] cmds[0:14];
    //there are only two states. one bit is enough
    reg [0:0] state;
    //send command state or idle state
    parameter SEND_C = 1'b0, IDLE = 1'b1;
    //set an index to show the exact position in cmds array
    reg[5:0] cmd_index = 5'b00000; 
    
    //wire locked;
    //reg[2:0] ledreg = 2'b00;
    //assign led = ledreg;
    //assign ready_reg = ready;

    //initialize the cmds with the required commands
    initial begin
        cmds [0] = 32'h00_0000_00;
        cmds [1] = 32'h00_0000_00;
        cmds [2] = 32'h00_0000_00;
        cmds [3] = 32'h00_4000_01;
        cmds [4] = 32'h00_4015_00;
        cmds [5] = 32'h00_4016_40;
        cmds [6] = 32'h00_401C_21;
        cmds [7] = 32'h00_401E_41;
        cmds [8] = 32'h00_4023_E7;
        cmds [9] = 32'h00_4024_E7;
        cmds [10] = 32'h00_4029_03;
        cmds [11] = 32'h00_402A_03;
        cmds [12] = 32'h00_40F2_01;
        cmds [13] = 32'h00_40F9_FF;
        cmds [14] = 32'h00_40FA_01;
        //commands for initilizing master mode (task 2.3c)
        // cmds [0] = 32'h00_0000_00;
        // cmds [1] = 32'h00_0000_00;
        // cmds [2] = 32'h00_0000_00;
        // cmds [3] = 32'h00_4000_01;
        // cmds [4] = 32'h00_4015_01;
        // cmds [5] = 32'h00_4016_40;
        // cmds [6] = 32'h00_401C_21;
        // cmds [7] = 32'h00_401E_41;
        // cmds [8] = 32'h00_4023_E7;
        // cmds [9] = 32'h00_4024_E7;
        // cmds [10] = 32'h00_4029_03;
        // cmds [11] = 32'h00_402A_03;
        // cmds [12] = 32'h00_40F2_01;
        // cmds [13] = 32'h00_40F9_FF;
        // cmds [14] = 32'h00_40FA_03;
    end
    
    
    always @(posedge clk) begin
        /*when reset signal arrive
        set the state to send code SEND_C
        set the index to 0
        commands are ready to be sent 
        command_valid set to high
        */
        if(reset == 1'b1) begin
            state <= SEND_C;
            cmd_index <= 5'b00000; 
            //command <= cmds[0];
            adau_init_done <= 0;
            command_valid <= 1;
            command <= cmds[cmd_index];
        end
        else
            case (state)
                //state send command
                SEND_C: begin
                    //if spi is initialsed spi_ready=1
                    if(spi_ready) begin
                        //if there are still unsent commands
                        if(cmd_index <= 13) begin
                            //send out the next command
                            cmd_index <= cmd_index + 1;
                            command <= cmds[cmd_index + 1];
                        end
                        //after all the commands are sent 
                        //goto idle state and set init_done to high
                        else begin
                            state <= IDLE;
                            //adau_init_done high when all data has been sent
                            adau_init_done <= 1;
                        end
                    end
                end

                    
                   // if(cmd_index <= 14 && spi_ready) begin
                   //     state <= SEND_C;
                   //     command <= cmds[cmd_index];
                   //     cmd_index <= cmd_index + 1;
                        
                  //  end
                  //  else if (spi_ready && cmd_index == 15)
                  //  begin
                  //      state <= IDLE;
                  //  end
                //ledreg <=2'b01;
                
                //idle state no command valid
                IDLE: begin
                    command_valid <= 0;
                    //ledreg <= 2'b10;
                    //if(spi_ready) begin
                    //    state <= SEND_C;
                    //end
                end
                default:;
            endcase

            // case (state)
            //     SEND_C: begin
            //         if(spi_ready) begin
            //             if(cmd_index <= 13) begin
            //                 cmd_index <= cmd_index + 1;
            //                 command <= cmds[cmd_index + 1];
            //             end
            //             else begin
            //                 state <= IDLE;
            //                 adau_init_done <= 1;
            //             end
            //         end
            //        // if(cmd_index <= 14 && spi_ready) begin
            //        //     state <= SEND_C;
            //        //     command <= cmds[cmd_index];
            //        //     cmd_index <= cmd_index + 1;
                        
            //       //  end
            //       //  else if (spi_ready && cmd_index == 15)
            //       //  begin
            //       //      state <= IDLE;
            //       //  end
            //     //ledreg <=2'b01;
                
            // end
            // IDLE: begin
            //     command_valid <= 0;
            //     //ledreg <= 2'b10;
                
            // end
            // default:;
            // endcase



        //command <= cmds[cmd_index];
    end


endmodule
