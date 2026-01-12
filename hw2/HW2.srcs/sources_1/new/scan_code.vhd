----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/11/2026 10:05:48 PM
-- Design Name: 
-- Module Name: scan_code - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scan_code is
    Port ( 
    scancode : std_logic_vector (7 downto 0);
    decoded_value : out std_logic_vector (3 downto 0)
    );
    
end scan_code;

architecture Behavioral of scan_code is

begin
decoded_value <= x"0" when (scancode = x"45") else
                 x"1" when (scancode = x"16") else
                 x"2" when (scancode = x"1E") else
                 x"3" when (scancode = x"26") else
                 x"4" when (scancode = x"25") else
                 x"5" when (scancode = x"2E") else
                 x"6" when (scancode = x"36") else
                 x"7" when (scancode = x"3D") else
                 x"8" when (scancode = x"3E") else
                 x"9" when (scancode = x"46");


end Behavioral;
