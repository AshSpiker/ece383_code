----------------------------------------------------------------------------------
-- Company: USAFA ECE 383 Spring 2026
-- Engineer: C3C Asher Speicher
-- 
-- Create Date: 04/23/2026 07:31:45 AM
-- Design Name: CrossyRoad
-- Module Name: FinalProject - Behavioral
-- Project Name: ECE383 Final Project
-- Target Devices: Nexys Video FPGA
-- Tool Versions: 
-- Description: This is the culimnation of ECE383 for C3C Speicher in project form.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FinalProject is
  Port ( 
        clk             : in  STD_LOGIC;        -- clock input, board clock is 48 MHz
        reset_n         : in  STD_LOGIC;        -- active low reset 
        
        
        ac_mclk         : out STD_LOGIC;        -- ******************************************
        ac_adc_sdata    : in STD_LOGIC;         --
        ac_dac_sdata    : out STD_LOGIC;        --
        ac_bclk         : out STD_LOGIC;        -- Audio Codec inputs and outputs
        ac_lrclk        : out STD_LOGIC;        --
        scl             : inout STD_LOGIC;      --
        sda             : inout STD_LOGIC;      -- ******************************************
        
        tmds : out  STD_LOGIC_VECTOR (3 downto 0);  -- used in the video component
        tmdsb : out  STD_LOGIC_VECTOR (3 downto 0); -- used in the video component
        
-- all encompassed in ja
--        latch           : out STD_LOGIC;        -- latch signal for NES controller
--        clk_pulse       : out STD_LOGIC;        -- clock pulse for NES controller
--        data            : in STD_LOGIC;         -- data input line for NES controller
        
        ja              : inout STD_LOGIC_VECTOR(2 downto 0) -- physical JA ports on the board
  );
end FinalProject;

architecture Behavioral of FinalProject is

    -- signal wire and control wire declarations 
    signal sw : STD_LOGIC_VECTOR(4 downto 0);
        -- sw break down:
        -- sw(0) : play button, this will correspond to the start button on the NES controller
        -- sw(1) : corresponds to the up button on the NES controller
        -- sw(2) : coresponds to the right button on the NES controller
        -- sw(3) : corresponds to the down button on the NES controller
        -- sw(4) : corresponds to the left button on the NES controller
    signal cw : STD_LOGIC_VECTOR(27 downto 0);
        -- cw break down:
        -- cw(0)            : fsm_wENB
        -- cw(5 downto 1)   : fsm_row
        -- cw(11 downto 6)  : fsm_col
        -- cw(27 downto 12) : fsm_data
        
        
    -- component declarations
    component datapath
        Port ( 
            clk             : in STD_LOGIC;         -- clock input
            reset_n         : in STD_LOGIC;         -- active low reset
            
            ac_mclk         : out STD_LOGIC;        -- ******************************************
            ac_adc_sdata    : in STD_LOGIC;         --
            ac_dac_sdata    : out STD_LOGIC;        --
            ac_bclk         : out STD_LOGIC;        -- Audio Codec inputs and outputs
            ac_lrclk        : out STD_LOGIC;        --
            scl             : inout STD_LOGIC;      --
            sda             : inout STD_LOGIC;      -- ******************************************
            
            tmds : out  STD_LOGIC_VECTOR (3 downto 0);  -- used in the video component
            tmdsb : out  STD_LOGIC_VECTOR (3 downto 0); -- used in the video component
          
-- these are actually the adc and dac I think  
--            audio_in        : in STD_LOGIC_VECTOR(15 downto 0);  -- audio input wire
--            audio_out       : out STD_LOGIC_VECTOR(15 downto 0); -- audio output wire
           
-- encompassed by cw 
--            fsm_wENB        : in STD_LOGIC;                         -- **************************
--            fsm_row         : in STD_LOGIC_VECTOR(4 downto 0);      -- for the 2Darray_mem
--            fsm_col         : in STD_LOGIC_VECTOR(5 downto 0);      --
--            fsm_data        : in STD_LOGIC_VECTOR(15 downto 0);     -- **************************
            
            data_in         : in STD_LOGIC;                         -- **************************
            clk_pulse       : out STD_LOGIC;                        -- NES controller wires
            latch           : out STD_LOGIC;                        --
-- encompassed by sw 
--            data_out        : out STD_LOGIC_VECTOR(4 downto 0);     -- **************************
            
            sw              : out STD_LOGIC_VECTOR(4 downto 0);
            cw              : in STD_LOGIC_VECTOR(27 downto 0)
        );
    end component datapath;
    
    
    component control_unit
        Port (
            clk             : in STD_LOGIC;
            reset_n         : in STD_LOGIC;
            sw              : in STD_LOGIC_VECTOR(4 downto 0);
            cw              : out STD_LOGIC_VECTOR(27 downto 0)
        );
    end component control_unit;
            
        
begin

    datapath_uut: datapath 
        port map(
            clk => clk,
            reset_n => reset_n,
            
            
            ac_mclk => ac_mclk,
            ac_adc_sdata => ac_adc_sdata,
            ac_dac_sdata => ac_dac_sdata,
            ac_bclk => ac_bclk,
            ac_lrclk => ac_lrclk,
            scl => scl,
            sda => sda,
            
            tmds => tmds,
            tmdsb => tmdsb,
            
            
            data_in => ja(2),
            clk_pulse => ja(1),
            latch => ja(0),
            
            
            sw => sw,
            cw => cw
        );
            
            
    control_unit_uut : control_unit
        port map(
            clk => clk,
            reset_n => reset_n,
            sw => sw,
            cw => cw
        );
              
end Behavioral;
