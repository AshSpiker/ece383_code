----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2026 09:26:56 AM
-- Design Name: 
-- Module Name: hw3 - Behavioral
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

entity hw3 is
  port ( 
    d : in unsigned(7 downto 0);
    h : out std_logic
  );
end hw3;

architecture Behavioral of hw3 is
    signal top, bottom : unsigned(3 downto 0);
begin
    top <= d(7 downto 4);
    bottom <= d(3 downto 0);
    
    h <= '1' when (top = bottom) else '0';


end Behavioral;
