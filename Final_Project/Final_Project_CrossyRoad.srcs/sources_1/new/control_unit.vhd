----------------------------------------------------------------------------------
-- Company: USAFA ECE 383 Spring 2026
-- Engineer: C3C Asher Speicher
-- 
-- Create Date: 04/23/2026 09:19:15 AM
-- Design Name: 
-- Module Name: control_unit - Behavioral
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

entity control_unit is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (4 downto 0);
           cw : out STD_LOGIC_VECTOR (27 downto 0));
end control_unit;

architecture Behavioral of control_unit is

begin


end Behavioral;
