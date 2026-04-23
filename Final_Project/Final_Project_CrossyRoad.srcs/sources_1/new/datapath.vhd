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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

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
        cw              : in STD_LOGIC_VECTOR(27 downto 0)
    );

end datapath;


architecture Behavioral of datapath is
    -- signal declarations 
    signal video_to_mem_row : STD_LOGIC_VECTOR(4 downto 0);
    signal video_to_mem_col : STD_LOGIC_VECTOR(5 downto 0);
    -- special note for the prior two signals, they will need to be changed and more signals added when the combonational logic is implemented for 
    -- calculating the offset to calculate which row the pixel is on, for when the screen slant is implemented
    signal mem_data_to_video: STD_LOGIC_VECTOR(15 downto 0);
    signal v_synch          : STD_LOGIC; -- copying from the graphics datapath, not entirely sure what this does yet
    
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
	
    component NES
	    Port (
	        clk         : in STD_LOGIC;                     -- clk input for the FSM in the NES
	        reset_n     : in STD_LOGIC;                     -- active low reset
	        data_in     : in STD_LOGIC;                     -- 1 bit input from NES controller 
	        data_out    : out STD_LOGIC_VECTOR(4 downto 0); -- 5 bit output to be sent on sw to control unit
	        latch       : out STD_LOGIC;                    -- 1 bit output to be sent to the NES to control data reading/ data transmission
	        clk_pulse   : out STD_LOGIC                     -- clock pulse to be sent out to the NES controller to control shift register data transmission
	    );
    end component NES;
    
    component Two_Darray_Mem 
        Port (
            wRow        : in STD_LOGIC_VECTOR(4 downto 0);  -- pixel row
            wCol        : in STD_LOGIC_VECTOR(5 downto 0);  -- pixel col
            data_in     : in STD_LOGIC_VECTOR(15 downto 0); -- input data
            wrENB       : in STD_LOGIC;                     -- 1 bit write enable
            rRow        : in STD_LOGIC_VECTOR(4 downto 0);  -- video screen row
            rCol        : in STD_LOGIC_VECTOR(5 downto 0);  -- video screen col
            data_out    : out STD_LOGIC_VECTOR(15 downto 0) -- ouput data line to video
        );
    end component Two_Darray_Mem;
    
    component video
        Port (
            clk         : in  STD_LOGIC;
            reset_n     : in  STD_LOGIC;
            tmds        : out  STD_LOGIC_VECTOR (3 downto 0);
            tmdsb       : out  STD_LOGIC_VECTOR (3 downto 0);
			row         : out unsigned(9 downto 0);
			column      : out unsigned(9 downto 0);
			ch1         : in  std_logic_vector(15 downto 0);
			ch1_enb     : in std_logic;
			ch2         : in std_logic;
			ch2_enb     : in std_logic;
			v_synch     : out std_logic
	   );
    end component video;
    
begin

    
    -- init of audio codec here
    
    
    NES_uut : NES
        port map (
            clk         => clk,         
            reset_n     => reset_n,
            data_in     => data_in,     -- connected directly to the exterior of the board through the upper level
            data_out    => sw,          -- sends to the control unit
            latch       => latch,       -- connected directly to the exterior of the board through the upper level
            clk_pulse   => clk_pulse    -- connected directly to the exterior of the board through the upper level
        );
        
    Two_Darray_Mem_uut : Two_Darray_Mem
        port map (
            wRow        => cw(5 downto 1),
            wCol        => cw(11 downto 6),
            data_in     => cw(27 downto 12),
            wrENB       => cw(0),
            rRow        => video_to_mem_row, -- this will have to be changed eventually to different signals when the combo logic for the screen slant is implemented 
            rCol        => video_to_mem_col, -- this will have to be changed eventually to different signals when the combo logic for the screen slant is implemented 
            data_out    => mem_data_to_video
        );
        
    video_uut : video
        port map (
            clk => clk,
            reset_n => reset_n,
            tmds => tmds,
            tmdsb => tmdsb,
            row => video_to_mem_row, -- this will have to be changed eventually to different signals when the combo logic for the screen slant is implemented
            col => video_to_mem_col, -- this will have to be changed eventually to different signals when the combo logic for the screen slant is implemented
            ch1 => mem_data_to_video,
            ch1_enb => '1',
            ch2 => OPEN,
            ch2_enb => '0',
            v_synch => v_synch
        );
            
            


end Behavioral;