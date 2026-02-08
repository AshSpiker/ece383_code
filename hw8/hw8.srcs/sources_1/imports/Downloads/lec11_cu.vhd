----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/07/2026 07:37:10 PM
-- Design Name: 
-- Module Name: lec11_cu - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lec11_cu is
    Port(	clk: in  STD_LOGIC;
			reset : in  STD_LOGIC;
			kbClk: in std_logic;
			cw: out STD_LOGIC_VECTOR(3 downto 0);
			sw: in STD_LOGIC;
			busy: out std_logic);
end lec11_cu;

architecture Behavioral of lec11_cu is

type state_type is (waitStart, readData, wait_0, comp_0, wait_1);
signal state: state_type;


begin

--- state logic ---
state_process: process(clk)
	 begin
		if (rising_edge(clk)) then
			if (reset = '0') then 
				state <= waitStart;
			else
                case state is
                    when waitStart =>
                        if (kbclk = '0') then state <= readData; end if;
                    when readData =>
                        state <= wait_0;
                    when wait_0 =>
                        if (kbclk = '1') then state <= comp_0; end if;
                    when comp_0 =>
                        state <= wait_1 when (sw = '0') else
                                 waitStart;
                    when wait_1 =>
                        if (kbclk = '0') then state <= readData; end if;              
				end case;
			end if;
		end if;
	end process;

--- output table ---
busy <= '0' when (state = waitStart) else '1';

cw <= "0011" when state = waitStart else
      "0101" when state = readData  else
      "0000" when state = wait_0    else
      "1000" when state = comp_0    else
      "0000" when state = wait_1;
      
end Behavioral;
