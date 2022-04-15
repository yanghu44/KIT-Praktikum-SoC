# Debug PMOD pins
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN A87 [get_ports {jc1_p}];  
#set_property IOSTANDARD LVCMOS33 [get_ports {jc1_p}];
#set_property PACKAGE_PIN A86 [get_ports {jc1_n}];  
#set_property IOSTANDARD LVCMOS33 [get_ports {jc1_n}];
#set_property PACKAGE_PIN Y4 [get_ports {jc2_p}];  
#set_property IOSTANDARD LVCMOS33 [get_ports {jc2_p}];

# TODO: Add Pins

#set_property PACKAGE_PIN AA4 [get_ports {jc2_n}];  # "JD1_N"
#set_property IOSTANDARD LVCMOS33 [get_ports {jc2_n}];  # "JD1_P"

#clks (bclk and rclk)

#set_property PACKAGE_PIN V7 [get_ports {ac_bclk}];  # "JD2_N"
#set_property IOSTANDARD LVCMOS33 [get_ports {ac_bclk}];  # "JD2_P"
#set_property PACKAGE_PIN W7 [get_ports {ac_lrclk}];  # "JD2_N"
#set_property IOSTANDARD LVCMOS33 [get_ports {ac_lrclk}];  # "JD2_P"
#set_property PACKAGE_PIN V6 [get_ports {jd2_p}];        # "JD2_N"
#set_property IOSTANDARD LVCMOS33 [get_ports {jd2_p}];  # "JD2_P"
#set_property PACKAGE_PIN V4 [get_ports {jd2_n}];        # "JD2_N"
#set_property IOSTANDARD LVCMOS33 [get_ports {jd2_n}];  # "JD2_P"


# ----------------------------------------------------------------------------
# Bank 13
# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard.
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN AB1 [get_ports {debug[0]}];  # "JD2_N"
#set_property IOSTANDARD LVCMOS33 [get_ports {debug[0]}];  # "JD2_P"
#set_property PACKAGE_PIN Y5 [get_ports {debug[1]}];  # "JD2_N"
#set_property IOSTANDARD LVCMOS33 [get_ports {debug[1]}];  # "JD2_P"
#set_property PACKAGE_PIN AB5 [get_ports {debug[2]}];        # "JD2_N"
#set_property IOSTANDARD LVCMOS33 [get_ports {debug[2]}];  # "JD2_P"
#set_property PACKAGE_PIN AB4 [get_ports {debug[3]}];        # "JD2_N"
#set_property IOSTANDARD LVCMOS33 [get_ports {debug[3]}];  # "JD2_P"


# Audio Codec

# ----------------------------------------------------------------------------
# Audio Codec - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN AB1 [get_ports {ac_addr0_clatch}];  # "AC-ADR0"
set_property IOSTANDARD LVCMOS33 [get_ports {ac_addr0_clatch}]; # set the voltage to 3.3V
set_property PACKAGE_PIN Y5  [get_ports {ac_addr1_cdata}];  # "AC-ADR1"
set_property IOSTANDARD LVCMOS33 [get_ports {ac_addr1_cdata}];
set_property PACKAGE_PIN Y8  [get_ports {ac_dac_sdata}];  # "AC-GPIO0"
set_property IOSTANDARD LVCMOS33 [get_ports {ac_dac_sdata}];
#set_property PACKAGE_PIN AA7 [get_ports {AC_GPIO1}];  # "AC-GPIO1"
set_property PACKAGE_PIN AA6 [get_ports {ac_bclk}];  # "AC-GPIO2"
set_property IOSTANDARD LVCMOS33 [get_ports {ac_bclk}];
set_property PACKAGE_PIN Y6  [get_ports {ac_lrclk}];  # "AC-GPIO3"
set_property IOSTANDARD LVCMOS33 [get_ports {ac_lrclk}];
set_property PACKAGE_PIN AB2 [get_ports {ac_mclk}];  # "AC-MCLK"
set_property IOSTANDARD LVCMOS33 [get_ports {ac_mclk}];
set_property PACKAGE_PIN AB4 [get_ports {ac_scl_cclk}];  # "AC-SCK"
set_property IOSTANDARD LVCMOS33 [get_ports {ac_scl_cclk}];
#set_property PACKAGE_PIN AB5 [get_ports {AC-SDA}];  # "AC-SDA"

# TODO: Add Pins

# Clock source
set_property PACKAGE_PIN Y9  [get_ports {sys_clk}];             # "GCLK"
set_property IOSTANDARD LVCMOS33 [get_ports {sys_clk}];



# ----------------------------------------------------------------------------
# Bank 35
# ----------------------------------------------------------------------------

# DIP switches
set_property PACKAGE_PIN M15 [get_ports {dip[7]}];              # "SW7"
set_property IOSTANDARD LVCMOS18 [get_ports {dip[7]}];
set_property PACKAGE_PIN H17 [get_ports {dip[6]}];              # "SW6"
set_property IOSTANDARD LVCMOS18 [get_ports {dip[6]}];
set_property PACKAGE_PIN H18 [get_ports {dip[5]}];              # "SW5"
set_property IOSTANDARD LVCMOS18 [get_ports {dip[5]}];
set_property PACKAGE_PIN H19 [get_ports {dip[4]}];              # "SW4"
set_property IOSTANDARD LVCMOS18 [get_ports {dip[4]}];
set_property PACKAGE_PIN F21 [get_ports {dip[3]}];              # "SW3"
set_property IOSTANDARD LVCMOS18 [get_ports {dip[3]}];
set_property PACKAGE_PIN H22 [get_ports {dip[2]}];              # "SW2"
set_property IOSTANDARD LVCMOS18 [get_ports {dip[2]}];
set_property PACKAGE_PIN G22 [get_ports {dip[1]}];              # "SW1"
set_property IOSTANDARD LVCMOS18 [get_ports {dip[1]}];
set_property PACKAGE_PIN F22 [get_ports {dip[0]}];              # "SW0"
set_property IOSTANDARD LVCMOS18 [get_ports {dip[0]}];


# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
# ---------------------------------------------------------------------------- 

set_property PACKAGE_PIN W7 [get_ports {debug[1]}];  # "JD1_N" cclk
set_property IOSTANDARD LVCMOS33 [get_ports {debug[1]}];
set_property PACKAGE_PIN V7 [get_ports {debug[0]}];  # "JD1_P" clatch_n
set_property IOSTANDARD LVCMOS33 [get_ports {debug[0]}];
set_property PACKAGE_PIN V4 [get_ports {debug[3]}];  # "JD2_N" bclk
set_property IOSTANDARD LVCMOS33 [get_ports {debug[3]}];
set_property PACKAGE_PIN V5 [get_ports {debug[2]}];  # "JD2_P" reset
set_property IOSTANDARD LVCMOS33 [get_ports {debug[2]}];
set_property PACKAGE_PIN AB6 [get_ports {debug[4]}];  # "JC1_N" lrclk
set_property IOSTANDARD LVCMOS33 [get_ports {debug[4]}];
set_property PACKAGE_PIN AB7 [get_ports {debug[5]}];  # "JC1_P" cdata
set_property IOSTANDARD LVCMOS33 [get_ports {debug[5]}];
set_property PACKAGE_PIN AA4 [get_ports {debug[6]}];  # "JC2_N" sdata
set_property IOSTANDARD LVCMOS33 [get_ports {debug[6]}];
set_property PACKAGE_PIN Y4 [get_ports {debug[7]}];  # "JC2_P"
set_property IOSTANDARD LVCMOS33 [get_ports {debug[7]}];
# ----------------------------------------------------------------------------
# Bank 33
# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard.
# ----------------------------------------------------------------------------

# LED outputs
set_property PACKAGE_PIN U14 [get_ports {led[7]}];              # "LD7"
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}];
set_property PACKAGE_PIN U19 [get_ports {led[6]}];              # "LD6"
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}];
set_property PACKAGE_PIN W22 [get_ports {led[5]}];              # "LD5"
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}];
set_property PACKAGE_PIN V22 [get_ports {led[4]}];              # "LD4"
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}];
set_property PACKAGE_PIN U21 [get_ports {led[3]}];              # "LD3"
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}];
set_property PACKAGE_PIN U22 [get_ports {led[2]}];              # "LD2"
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}];
set_property PACKAGE_PIN T21 [get_ports {led[1]}];              # "LD1"
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}];
set_property PACKAGE_PIN T22 [get_ports {led[0]}];              # "LD0"
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}];



# ----------------------------------------------------------------------------
# Bank 34
# ----------------------------------------------------------------------------

# Push buttons
set_property PACKAGE_PIN P16 [get_ports {btn_c}];               # "BTNC"
set_property IOSTANDARD LVCMOS18 [get_ports {btn_c}];
set_property PACKAGE_PIN R16 [get_ports {btn_d}];               # "BTND"
set_property IOSTANDARD LVCMOS18 [get_ports {btn_d}];
set_property PACKAGE_PIN N15 [get_ports {btn_l}];               # "BTNL"
set_property IOSTANDARD LVCMOS18 [get_ports {btn_l}];
set_property PACKAGE_PIN R18 [get_ports {btn_r}];               # "BTNR"
set_property IOSTANDARD LVCMOS18 [get_ports {btn_r}];
set_property PACKAGE_PIN T18 [get_ports {btn_u}];               # "BTNU"
set_property IOSTANDARD LVCMOS18 [get_ports {btn_u}];

# Clock domain crossing for reset signal
set_false_path -from [get_pins {reset_counter_reg[5]/C}]