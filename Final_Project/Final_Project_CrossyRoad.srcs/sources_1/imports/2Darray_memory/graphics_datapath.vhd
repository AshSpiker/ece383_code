----------------------------------------------------------------------------------
-- Name:	George York
-- Date:	Spring 2020
-- File:    graphics_datapath.vhd
-- HW:	    2Darray MEMORY example: 2 bits per grid cell (really has 16 bits), for a 64 x 32 grid of 8x8 pixel cells
-- Pupr:	need to update!!!!.  
--
-- Doc:	Adapted from Dr Coulston's Lab exercise
-- 	
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
use work.GraphicsParts.all;		
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity graphics_datapath is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
		   fsmCol: in std_logic_vector(5 downto 0);
           fsmRow: in std_logic_vector(4 downto 0);
           fsmWen : in std_logic;
           fsmData: in std_logic_vector(15 downto 0);
           exCol : in  STD_LOGIC_VECTOR (5 downto 0);
           exRow : in  STD_LOGIC_VECTOR (4 downto 0);
           exWen, exSel : in  STD_LOGIC;
           exData : in  STD_LOGIC_VECTOR (15 downto 0));
end graphics_datapath;

architecture Behavioral of graphics_datapath is
	
    signal muxData, data_word_out: std_logic_vector(15 downto 0); 
	signal muxWen  : std_logic;
	signal ch2 : std_logic;
	signal ch1 : std_logic_vector(15 downto 0);
	signal row, column: unsigned(9 downto 0);
	signal uMuxCol: unsigned(5 downto 0);
    signal uMuxRow: unsigned(4 downto 0);
	signal muxCol : std_logic_vector(5 downto 0);
	signal muxRow : std_logic_vector(4 downto 0);	
	
	type  TwoDarray is array(0 to 63, 0 to 31) of std_logic_vector(15 downto 0);
	signal TwoDarray_Grid : TwoDarray;

	signal v_synch : std_logic;


begin


    muxRow <= exRow when exSel = '1' else fsmRow;
    muxCol <= exCol when exSel = '1' else fsmCol;
    uMuxRow <= unsigned(muxRow);
    uMuxCol <= unsigned(muxCol);
    
    muxData <= exData when exSel = '1' else fsmData;        
    
    muxWen <= exWen when exSel = '1' else fsmWen;

    
    ----------------------------------------------------
	-- Write to the 2Darray_Grid (by FSM or Microblaze)
	----------------------------------------------------
    
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				--2Darray_Grid(muxCol, muxRow) <= "0000000000000000"; 
                -- add code to initialize all 64x32 grid locations here?				
			else 
				if muxWen = '1' then
					TwoDarray_Grid(to_integer(uMuxCol), to_integer(uMuxRow)) <= muxData;
				end if;
			end if;
		end if;
	end process;

	--------------------------------------------
	-- Read from the 2Darray_Grid (by Scopeface)
	--------------------------------------------
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				--2Darray_Grid(muxCol, muxRow) <= "0000000000000000"; 
                -- add code to initialize all 64x32 grid locations here?
				data_word_out <= "0000000000000000";				
			else 
				data_word_out <= TwoDarray_Grid(to_integer(column(8 downto 3)), to_integer(row(7 downto 3)));
			end if;
		end if;
	end process;
    ch1 <= data_word_out;
    
	-------------------------------------------------------------------------------
	-- Instantiate the video driver from Lab1 - should integrate smoothly
	-------------------------------------------------------------------------------
	video_inst: video port map( 
		clk =>clk,
		reset_n => reset_n,
        tmds => tmds,
		tmdsb => tmdsb,
		row => row,
		column => column,
		ch1 => ch1,
		ch1_enb => '1',
		ch2 => ch2,
		ch2_enb => ch2,
		v_synch => v_synch);



end Behavioral;

