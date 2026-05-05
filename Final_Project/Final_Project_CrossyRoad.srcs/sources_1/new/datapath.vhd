----------------------------------------------------------------------------------
-- Company: USAFA ECE 383 Spring 2026
-- Engineer: C3C Asher Speicher
-- 
-- Create Date: 04/23/2026 09:19:15 AM
-- Design Name: 
-- Module Name: datapath - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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
use work.ece383_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
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
        
        data_in         : in STD_LOGIC;                         -- **************************
        clk_pulse       : out STD_LOGIC;                        -- NES controller wires
        latch           : out STD_LOGIC;                        -- **************************
        
        sw              : out STD_LOGIC_VECTOR(4 downto 0);
        cw              : in STD_LOGIC_VECTOR(27 downto 0);
        
        btn             : in STD_LOGIC_VECTOR(3 downto 0);
        led             : out std_logic_vector(7 downto 0)
    );

end datapath;


architecture Behavioral of datapath is
    -- signal declarations 
    signal video_to_mem_row : unsigned(4 downto 0);
    signal video_to_mem_col : unsigned(5 downto 0);
    -- special note for the prior two signals, they will need to be changed and more signals added when the combonational logic is implemented for 
    -- calculating the offset to calculate which row the pixel is on, for when the screen slant is implemented
    signal mem_data_to_video: STD_LOGIC_VECTOR(15 downto 0);
    
    
    
    -- video signals 
    signal ch1, ch2 : channel_t;
    signal position : coordinate_t;
    
    signal map_array_uut : map_array := ("00", "01", "00", "01", "10", "10", "10", "00", "10", "00", "11", "11", "11", "00", "01", "10", "11", "00", "01", "10");
    
    -- confused here, figure out later 
    component Audio_Codec_Wrapper 
        Port ( 
            clk             : in STD_LOGIC;
            reset_n         : in STD_LOGIC;
            ac_mclk         : out STD_LOGIC;
            ac_adc_sdata    : in STD_LOGIC;
            ac_dac_sdata    : out STD_LOGIC;
            ac_bclk         : out STD_LOGIC;
            ac_lrclk        : out STD_LOGIC;
            ready           : out STD_LOGIC;
            L_bus_in        : in std_logic_vector(17 downto 0); -- left channel input to DAC
            R_bus_in        : in std_logic_vector(17 downto 0); -- right channel input to DAC
            L_bus_out       : out  std_logic_vector(17 downto 0); -- left channel output from ADC
            R_bus_out       : out  std_logic_vector(17 downto 0); -- right channel output from ADC
            scl             : inout STD_LOGIC;
            sda             : inout STD_LOGIC
        );
	end component;
	
--    component NES
--	    Port (
--	        clk         : in STD_LOGIC;                     -- clk input for the FSM in the NES
--	        reset_n     : in STD_LOGIC;                     -- active low reset
--	        data_in     : in STD_LOGIC;                     -- 1 bit input from NES controller 
--	        data_out    : out STD_LOGIC_VECTOR(4 downto 0); -- 5 bit output to be sent on sw to control unit
--	        latch       : out STD_LOGIC;                    -- 1 bit output to be sent to the NES to control data reading/ data transmission
--	        clk_pulse   : out STD_LOGIC;                     -- clock pulse to be sent out to the NES controller to control shift register data transmission
--	        led         : out std_logic_vector(7 downto 0)
--	    );
--    end component NES;
    
--    component Two_Darray_Mem 
--        Port (
--            wRow        : in STD_LOGIC_VECTOR(4 downto 0);  -- pixel row
--            wCol        : in STD_LOGIC_VECTOR(5 downto 0);  -- pixel col
--            data_in     : in STD_LOGIC_VECTOR(15 downto 0); -- input data
--            wrENB       : in STD_LOGIC;                     -- 1 bit write enable
--            rRow        : in STD_LOGIC_VECTOR(4 downto 0);  -- video screen row
--            rCol        : in STD_LOGIC_VECTOR(5 downto 0);  -- video screen col
--            data_out    : out STD_LOGIC_VECTOR(15 downto 0) -- ouput data line to video
--        );
--    end component Two_Darray_Mem;
    
    component video
        Port (
            clk         : in  STD_LOGIC;
            reset_n     : in  STD_LOGIC;
            tmds        : out  STD_LOGIC_VECTOR (3 downto 0);
            tmdsb       : out  STD_LOGIC_VECTOR (3 downto 0);
            --trigger     : in trigger_t; -- not using trigger
            position    : out coordinate_t;
            ch1         : in channel_t;
            ch2         : in channel_t;
            game_map    : in map_array;
            btn         : in STD_LOGIC_VECTOR(3 downto 0);
            led         : out std_logic_vector(7 downto 0));
    end component video;
    
begin

    
    -- init of audio codec here
    
    
--    NES_uut : NES
--        port map (
--            clk         => clk,         
--            reset_n     => reset_n,
--            data_in     => data_in,     -- connected directly to the exterior of the board through the upper level
--            data_out    => sw,          -- sends to the control unit
--            latch       => latch,       -- connected directly to the exterior of the board through the upper level
--            clk_pulse   => clk_pulse,    -- connected directly to the exterior of the board through the upper level
--            led         => led
--        );
        
--    Two_Darray_Mem_uut : Two_Darray_Mem
--        port map (
--            wRow        => cw(5 downto 1),
--            wCol        => cw(11 downto 6),
--            data_in     => cw(27 downto 12),
--            wrENB       => cw(0),
--            rRow        => std_logic_vector(video_to_mem_row), -- this will have to be changed eventually to different signals when the combo logic for the screen slant is implemented 
--            rCol        => std_logic_vector(video_to_mem_col), -- this will have to be changed eventually to different signals when the combo logic for the screen slant is implemented 
--            data_out    => mem_data_to_video
--        );
        
    video_uut : video
        port map (
            clk         => clk,
            reset_n     => reset_n,
            tmds        => tmds,
            tmdsb       => tmdsb,
            ch1         => ch1, 
            ch2         => ch2,        -- not using ch2 
            game_map    => map_array_uut,
            btn         => btn,
            led         => led
        );
        
        
    
            
            


end Behavioral;