----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/07/2026 07:32:18 PM
-- Design Name: 
-- Module Name: simulated_priority_encoder - Behavioral
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

entity simulated_priority_encoder is
    port ( 
        i_0 : in std_logic;
        i_1 : in std_logic;
        i_2 : in std_logic;
        i_3 : in std_logic;
        o_1 : out std_logic;
        o_0 : out std_logic
        
    );
end simulated_priority_encoder;

architecture Behavioral of simulated_priority_encoder is
    signal w_in : std_logic_vector (3 downto 0);
begin
    w_in(0) <= i_0;
    w_in(1) <= i_1;
    w_in(2) <= i_2;
    w_in(3) <= i_3;
    
    o_1 <= i_2 or i_3;
    o_0 <= (i_1 and (not i_2)) or i_3;

end Behavioral;
