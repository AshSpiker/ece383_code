----------------------------------------------------------------------------------
-- Name:	George York
-- Date:	Spring 2020
-- File:    graphics_fsm.vhd
-- HW:	    State Machine to test the graphics memory
--          2D_Array GRID MEMORY example: 16 bits per grid cell, for a 64 x 32 grid of 8x8 pixel cells
-- Pupr:	need to update!!!!.  
--
-- Doc:	Adapted from Dr Coulston's Lab exercise
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity graphics_fsm is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
		   fsmCol: out std_logic_vector(5 downto 0);
           fsmRow: out std_logic_vector(4 downto 0);
           fsmWen : out std_logic;
           fsmData: out std_logic_vector(15 downto 0));
end graphics_fsm;

architecture Behavioral of graphics_fsm is

	type state_type is (SWAP, DELAY, CHANGE_DATA, SET, CLEAR, INCCOL, LASTCOL, INCROW, LASTROW );
	signal state: state_type;
	signal writeCntr: unsigned(17 downto 0);
	signal col : unsigned(5 downto 0);
    signal row : unsigned(4 downto 0);
	signal Data, Old_Data: std_logic_vector(15 downto 0);
	signal Wen: std_logic;

begin
    fsmCol <= std_logic_vector(col);
    fsmRow <= std_logic_vector(row);
    fsmData <= Data;
    fsmWen <= Wen;
	-------------------------------------------------------------------------------
	-- Long delay counter
	-------------------------------------------------------------------------------	
	writeCounter: process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				writeCntr <= "000000000000000000";  -- change for graphics memory test
			else 
			    writeCntr <= writeCntr+1;
			end if;
		end if;
	end process;
		
	state_proces: process(clk)  
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then 
				state <= SWAP;
				row <= "00000";
				col <= "000000";                             
				Data <= "0000000000000001";
				Wen <= '0';
			else 
				case state is
					when SWAP =>
						state <= DELAY;    		
					when DELAY => 
						if (writeCntr = "000000000000000000") then state <= CHANGE_DATA; end if;
                    when CHANGE_DATA => 
                            -- Alternate Object #1, Object #2, Object #3 
                            if (Old_Data = "0000000000000001") then Data <= "0000000000000010";
                            elsif (Old_Data = "0000000000000010") then Data <= "0000000000000011";
                            elsif (Old_Data = "0000000000000011") then Data <= "0000000000000001";
                            end if;
                            state <= SET;
					when SET =>
						state <= CLEAR;
						Wen <= '1';
					when CLEAR =>
						state <= INCCOL;
                        Wen <= '0';
                    when INCCOL =>
						state <= LASTCOL;
                        col <= col + 1;					
                    when LASTCOL =>  -- 64, roll over to zero 
                        if (col = "000000") then state <= INCROW; else state <= DELAY; end if; 
                    when INCROW =>
                            state <= LASTROW;
                            row <= row + 1;                    
                   when LASTROW => -- 32, roll over to zero
                            if (row = "00000") then state <= SWAP; else state <= DELAY; end if;
				end case;
			end if;
		end if;
	end process;

    Old_Data <= Data;


end Behavioral;

