----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2026 01:15:23 PM
-- Design Name: 
-- Module Name: counter - Behavioral
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

entity counter is
    generic (
           num_bits : integer := 4;
           max_value : integer := 9
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           ctrl : in STD_LOGIC;
           roll : out STD_LOGIC;
           Q : out unsigned (num_bits-1 downto 0));
end counter;

architecture Behavioral of counter is
signal processQ : unsigned (num_bits-1 downto 0);


begin
    process(clk)
        begin
        if(rising_edge(clk)) then -- only on rising edge of clock 
            if(reset_n = '1') then -- check if reset = 1
                if(ctrl = '1') then
                    roll <= '0';
                    processQ <= processQ + 1;
                    if(processQ = max_value - 1) then
                        roll <= '1';
                    elsif(processQ = max_value) then 
                        processQ <= (others => '0');
                        --roll <= '1';
                    end if;
                
                
                
                elsif(ctrl = '0') then -- if ctrl = 0 then Q = Q
                    processQ <= processQ;
                end if;
                    
            
            
            
            elsif(reset_n = '0') then -- if reset = 0, then Q = Q
                processQ <= (others => '0');
                roll <= '0';
                
            end if;
        
        
        end if;
        
    end process;
Q <= processQ;
--roll <= '1' when (processQ = max_value - 1) else '0';
end Behavioral;
