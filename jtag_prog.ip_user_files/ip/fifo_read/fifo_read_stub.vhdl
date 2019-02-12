-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.1 (lin64) Build 1846317 Fri Apr 14 18:54:47 MDT 2017
-- Date        : Thu Mar 29 11:22:27 2018
-- Host        : justin-desktop running 64-bit unknown
-- Command     : write_vhdl -force -mode synth_stub
--               /home/justin/Vivado/jtag_prog/jtag_prog.srcs/sources_1/ip/fifo_read/fifo_read_stub.vhdl
-- Design      : fifo_read
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tftg256-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fifo_read is
  Port ( 
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 7 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 0 to 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC
  );

end fifo_read;

architecture stub of fifo_read is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,srst,din[7:0],wr_en,rd_en,dout[0:0],full,empty";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v13_1_4,Vivado 2017.1";
begin
end;
