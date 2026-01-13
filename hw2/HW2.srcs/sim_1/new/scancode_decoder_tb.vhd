----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/11/2026 10:23:53 PM
-- Design Name: 
-- Module Name: scan_code_tb - Behavioral
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

entity scan_code_tb is
--  Port ( );
end scan_code_tb;

architecture Behavioral of scan_code_tb is
    component scancode_decoder is 
        port(
        scancode : std_logic_vector (7 downto 0);
        decoded_value : out std_logic_vector (3 downto 0)
        );
    end component;
    
    signal w_I : std_logic_vector (7 downto 0) := (others => '0');
    signal w_O : std_logic_vector (3 downto 0) := (others => '0');
begin

    scan_code_inst : scancode_decoder port map(
        scancode => w_I,
        decoded_value => w_O
    );
    
    test_process : process 
    begin
        w_I <= x"45"; wait for 10ns;
            assert w_O = x"0" report "error on x0" severity error; 
        w_I <= x"16"; wait for 10ns;
            assert w_O = x"1" report "error on x1" severity error; 
        w_I <= x"1E"; wait for 10ns;
            assert w_O = x"2" report "error on x2" severity error; 
        w_I <= x"26"; wait for 10ns;
            assert w_O = x"3" report "error on x3" severity error; 
        w_I <= x"25"; wait for 10ns;
            assert w_O = x"4" report "error on x4" severity error; 
        w_I <= x"2E"; wait for 10ns;
            assert w_O = x"5" report "error on x5" severity error; 
        w_I <= x"36"; wait for 10ns;
            assert w_O = x"6" report "error on x6" severity error; 
        w_I <= x"3D"; wait for 10ns;
            assert w_O = x"7" report "error on x7" severity error; 
        w_I <= x"3E"; wait for 10ns;
            assert w_O = x"8" report "error on x8" severity error; 
        w_I <= x"46"; wait for 10ns;
            assert w_O = x"9" report "error on x9" severity error; 
            
        wait;
    end process;
        

end Behavioral;
