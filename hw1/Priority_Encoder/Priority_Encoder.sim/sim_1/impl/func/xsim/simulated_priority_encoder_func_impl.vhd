-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
-- Date        : Wed Jan  7 20:36:48 2026
-- Host        : C28-2TK4150H12 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -mode funcsim -nolib -force -file
--               C:/Users/C28Asher.Speicher/Documents/ece383_code/hw1/Priority_Encoder/Priority_Encoder.sim/sim_1/impl/func/xsim/simulated_priority_encoder_func_impl.vhd
-- Design      : simulated_priority_encoder
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7a200tsbg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity simulated_priority_encoder is
  port (
    i_0 : in STD_LOGIC;
    i_1 : in STD_LOGIC;
    i_2 : in STD_LOGIC;
    i_3 : in STD_LOGIC;
    o_Y : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of simulated_priority_encoder : entity is true;
  attribute \DesignAttr:ENABLE_AIE_NETLIST_VIEW\ : boolean;
  attribute \DesignAttr:ENABLE_AIE_NETLIST_VIEW\ of simulated_priority_encoder : entity is std.standard.true;
  attribute \DesignAttr:ENABLE_NOC_NETLIST_VIEW\ : boolean;
  attribute \DesignAttr:ENABLE_NOC_NETLIST_VIEW\ of simulated_priority_encoder : entity is std.standard.true;
  attribute ECO_CHECKSUM : string;
  attribute ECO_CHECKSUM of simulated_priority_encoder : entity is "3b431707";
end simulated_priority_encoder;

architecture STRUCTURE of simulated_priority_encoder is
  signal i_1_IBUF : STD_LOGIC;
  signal i_2_IBUF : STD_LOGIC;
  signal i_3_IBUF : STD_LOGIC;
  signal o_Y_OBUF : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \o_Y_OBUF[0]_inst_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \o_Y_OBUF[1]_inst_i_1\ : label is "soft_lutpair0";
begin
i_1_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => i_1,
      O => i_1_IBUF
    );
i_2_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => i_2,
      O => i_2_IBUF
    );
i_3_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => i_3,
      O => i_3_IBUF
    );
\o_Y_OBUF[0]_inst\: unisim.vcomponents.OBUF
     port map (
      I => o_Y_OBUF(0),
      O => o_Y(0)
    );
\o_Y_OBUF[0]_inst_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"F4"
    )
        port map (
      I0 => i_2_IBUF,
      I1 => i_1_IBUF,
      I2 => i_3_IBUF,
      O => o_Y_OBUF(0)
    );
\o_Y_OBUF[1]_inst\: unisim.vcomponents.OBUF
     port map (
      I => o_Y_OBUF(1),
      O => o_Y(1)
    );
\o_Y_OBUF[1]_inst_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => i_1_IBUF,
      I1 => i_2_IBUF,
      O => o_Y_OBUF(1)
    );
end STRUCTURE;
