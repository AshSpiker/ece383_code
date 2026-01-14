----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2026 09:56:02 AM
-- Design Name: 
-- Module Name: hw3_tb - Behavioral
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

entity hw3_tb is
--  Port ( );
end hw3_tb;

architecture Behavioral of hw3_tb is

    component hw3 is 
        port (
        d: in unsigned(7 downto 0);
        h: out std_logic
        );
    end component;
    
    --signal w_top, w_bottom : unsigned(3 downto 0) := (others=> '0');
    signal w_d : unsigned(7 downto 0);
    signal w_h : std_logic;
    
begin

    hw3_inst : hw3 port map (
        d => w_d,
        h => w_h
    );
    
    test_process : process
    begin
        w_d <= x"11"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"10"; wait for 10 ns; 
            assert w_h = '0' report "error on x11" severity error;
        w_d <= x"22"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"23"; wait for 10 ns; 
            assert w_h = '0' report "error on x11" severity error;
        w_d <= x"33"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"44"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"55"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"66"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"77"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"88"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"99"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"AA"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"BB"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"CC"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"DD"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"EE"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        w_d <= x"FF"; wait for 10 ns; 
            assert w_h = '1' report "error on x11" severity error;
        
        wait;
    end process;


end Behavioral;
