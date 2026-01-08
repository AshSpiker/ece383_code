----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/07/2026 07:32:18 PM
-- Design Name: 
-- Module Name: simulated_priority_encoder_tb - Behavioral
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

entity simulated_priority_encoder_tb is
--  Port ( );
end simulated_priority_encoder_tb;

architecture Behavioral of simulated_priority_encoder_tb is

    component simulated_priority_encoder is 
        port(
        i_0 : in std_logic;
        i_1 : in std_logic;
        i_2 : in std_logic;
        i_3 : in std_logic;
        o_1 : out std_logic;
        o_0 : out std_logic
        );
    end component;
    
    signal w_sw : std_logic_vector (3 downto 0):= (others=> '0');
    signal w_Y  : std_logic_vector (1 downto 0):= (others=> '0');

begin
    simulated_priority_encoder_inst : simulated_priority_encoder port map(
        i_0 => w_sw(0),
        i_1 => w_sw(1),
        i_2 => w_sw(2),
        i_3 => w_sw(3),
        o_1 => w_Y(1),
        o_0 => w_Y(0)
    );
    
    test_process : process
    begin
        --w_sw <= x"0"; wait for 10ns;
            --assert w_Y = x"0" report "error on x0" severity failure;
        w_sw <= x"1"; wait for 10ns;
            assert w_Y = x"0" report "error on x1" severity error;
        w_sw <= x"2"; wait for 10ns;
            assert w_Y = x"1" report "error on x2" severity error;
        w_sw <= x"3"; wait for 10ns;
            assert w_Y = x"1" report "error on x3" severity error;
        w_sw <= x"4"; wait for 10ns;
            assert w_Y = x"2" report "error on x4" severity error;
        w_sw <= x"5"; wait for 10ns;
            assert w_Y = x"2" report "error on x5" severity error;
        w_sw <= x"6"; wait for 10ns;
            assert w_Y = x"2" report "error on x6" severity error;
        w_sw <= x"7"; wait for 10ns;
            assert w_Y = x"2" report "error on x7" severity error;
        w_sw <= x"8"; wait for 10ns;
            assert w_Y = x"3" report "error on x8" severity error;
        w_sw <= x"9"; wait for 10ns;
            assert w_Y = x"3" report "error on x9" severity error;
        w_sw <= x"A"; wait for 10ns;
            assert w_Y = x"3" report "error on xA" severity error;
        w_sw <= x"B"; wait for 10ns;
            assert w_Y = x"3" report "error on xB" severity error;
        w_sw <= x"C"; wait for 10ns;
            assert w_Y = x"3" report "error on xC" severity error;
        w_sw <= x"D"; wait for 10ns;
            assert w_Y = x"3" report "error on xD" severity error;
        w_sw <= x"E"; wait for 10ns;
            assert w_Y = x"3" report "error on xE" severity error;
        w_sw <= x"F"; wait for 10ns;
            assert w_Y = x"3" report "error on xF" severity error;
            
        wait; 
    end process;

end Behavioral;
