module tb_adau_spi_master_and_command_list();
    

    //Inputs and Outputs of modules
    reg clk;
    reg reset;
    wire adau_init_done;
    reg clk32 = 0;
    reg [6:0] clk_div = 0;


    // wires between modules
    wire ready;
    wire [31:0] data_in;
    wire valid;


    // Instantiations
    adau_spi_master uut_1(
        //Inputs
        .clk        (clk), //this clock runs faster
        .reset      (reset),
        .data_in    (data_in),
        .valid      (valid),
        //Outputs
        .ready      (ready),   
        .cdata      (cdata),
        .cclk       (cclk), //doesnt have functionality right now  
        .clatch_n   (clatch_n)
    );

    adau_command_list uut_2(
        //Inputs
        .spi_ready      (ready),
        .reset          (reset),
        .clk            (clk32), // one cycle of this clock spans an entire command (32 normal clk cycles)
        //Outputs
        .adau_init_done (adau_init_done),
        .command        (data_in),
        .command_valid  (valid)
        //output [4:3] led
    );

    

    
    initial clk <= 0;
    always #100 clk <= ~clk;
    
    
   // CLOCK DIVIDER (one clk32 cycle = 32 regular clock cycles)
   always @(posedge clk) begin    
       if(clk_div == 15) begin
           clk_div <= 0; //1b`0
           clk32 <= ~clk32; // 1b`1
       end     
       else begin
           clk_div <= clk_div + 1;
       end  
   end

    //IMPORTANT: CHANGE IN ADUAU_SPI_MASTER during reset, ready must be set to 1



    //task handshake;
    initial begin
        // resetting
        reset <= 1;
        repeat(2) begin
            @(posedge clk);
        end
        reset <= 0;
        

    end        
//        //----------S_IDLE state--------------
        

//        repeat(1) begin // next cycle
//            @(posedge clk);
//        end
//        //----------S_SEND_BIT state--------------
//        // sending data in 32 cycles
//        // repeat(32) begin // next cycle
//        //     @(posedge clk);
//        //     if(ready) begin // ready should be high
//        //     $warning("ready is high during send bit stage!");
//        //     #100
//        //     $finish;                
//        //     end
//        // end
//        repeat(14) begin // 14 init commands
//            @(posedge clk32);
//        end
//        repeat(1) begin // next cycle
//            @(posedge clk);
//        end

//        //----------S_IDLE state--------------
//        // ready = 1
//        // next cycle
//        if(!adau_init_done) begin // ready should be high
//            $warning("ready is low during idle stage");
//            //#100
//            $finish;                
//        end
endmodule        