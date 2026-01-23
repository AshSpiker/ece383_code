----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2026 02:04:32 PM
-- Design Name: 
-- Module Name: hw4_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hw4_tb is
--  Port ( );
end hw4_tb;

architecture Behavioral of hw4_tb is

component counter is 
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           ctrl : in STD_LOGIC;
           roll : out STD_LOGIC;
           Q : out unsigned (3 downto 0));
     end component;
     
     signal w_clk : std_logic;
     signal w_reset : std_logic;
     signal w_ctrl : std_logic;
     signal w_roll_LSB : std_logic;
     signal w_roll_MSB : std_logic;
     signal w_Q_LSB : unsigned (3 downto 0);
     signal w_Q_MSB : unsigned (3 downto 0);
     

begin

    counter_inst : counter port map(
        clk => w_clk,
        reset_n => w_reset,
        ctrl => w_ctrl,
        roll => w_roll_LSB,
        Q => w_Q_LSB
        );
        
    counter2_inst : counter port map (
        clk => w_clk,
        reset_n => w_reset,
        ctrl => w_roll_LSB,
        roll => w_roll_MSB,
        Q => w_Q_MSB
        );  
        
    ---- clk process -----
    clk_process : process
    begin
        w_clk <= '0';
        wait for 10 ns;
        w_clk <= '1';
        wait for 10 ns;
    end process clk_process;
    ----------------------
    
    test_process : process
    begin 
        w_ctrl <= '0';
        w_reset <= '0';
        wait for 20 ns;
            assert w_Q_LSB = x"0" severity error; -- check to see if reset works 
        w_reset <= '1';
        wait for 20 ns;
        
        w_ctrl <= '0'; wait for 20 ns;
            assert w_Q_LSB = x"0" severity error;
        w_ctrl <= '1'; wait for 20 ns;  
            assert w_Q_LSB = x"1" severity error;
        wait for 20 ns;  
            assert w_Q_LSB = x"2" severity error;
        wait for 20 ns;  
            assert w_Q_LSB = x"3" severity error;
        wait for 20 ns;  
            assert w_Q_LSB = x"4" severity error;  
            w_ctrl <= '0';  
        wait for 40 ns;  
            w_ctrl <= '1';
            assert w_Q_LSB = x"5" severity error;    
        wait for 20 ns;  
            assert w_Q_LSB = x"6" severity error;    
        wait for 20 ns;  
            assert w_Q_LSB = x"7" severity error;    
        wait for 20 ns;  
            assert w_Q_LSB = x"8" severity error;      
        wait for 20 ns;  
            assert w_Q_LSB = x"9" severity error;   
            --assert w_roll_LSB = '1' severity error; 
            assert w_Q_MSB = x"1" severity error;
        wait;
    end process;
        

end Behavioral;
