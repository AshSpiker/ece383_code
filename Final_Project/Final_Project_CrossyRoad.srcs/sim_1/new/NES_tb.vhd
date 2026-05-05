library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity NES_tb is
end NES_tb;

architecture Behavioral of NES_tb is

    component NES is
        Port ( 
            clk          : in STD_LOGIC;
            reset_n      : in STD_LOGIC;
            data_in      : in STD_LOGIC;
            data_out     : out STD_LOGIC_VECTOR (4 downto 0);
            latch        : out STD_LOGIC;
            clk_pulse    : out STD_LOGIC;
            led          : out std_logic_vector(7 downto 0)
        );
    end component;

    signal clk          : std_logic := '0';
    signal reset_n      : std_logic := '0';
    signal data_in      : std_logic := '1'; -- Idle high
    signal data_out     : std_logic_vector(4 downto 0);
    signal latch        : std_logic;
    signal clk_pulse    : std_logic;
    signal led          : std_logic_vector(7 downto 0);

    constant clk_period : time := 10 ns;
    -- Test pattern: 11010100 
    -- This means bits are fed in order: 1, 1, 0, 1, 0, 1, 0, 0
    constant test_pattern : std_logic_vector(7 downto 0) := "11010100";

begin

    UUT: NES port map (
        clk        => clk,
        reset_n    => reset_n,
        data_in    => data_in,
        data_out   => data_out,
        latch      => latch,
        clk_pulse  => clk_pulse,
        led        => led
    );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
        variable expected_data_out : std_logic_vector(4 downto 0);
    begin
        -- Initialize
        reset_n <= '0';
        data_in <= '1';
        wait for 100 ns;
        reset_n <= '1';

        -- 1. WAIT FOR LATCH
        wait until latch = '1';
        -- As soon as latch is high, we provide the FIRST bit (Bit 7)
        -- This ensures data is ready before the FSM transitions to read_data
        data_in <= test_pattern(7); 
        
        wait until latch = '0';
        report "Latch released, starting bit sequence..." severity note;

        -- 2. PROVIDE SUBSEQUENT BITS
        -- We loop 7 more times for the remaining bits
        for i in 6 downto 0 loop
            -- Wait for the FSM to signal it is ready for the next bit
            wait until clk_pulse = '1';
            
            -- Small hold time/propagation delay simulation
            wait for 20 ns; 
            
            -- Apply the next bit in the sequence
            data_in <= test_pattern(i);
            
            -- Wait for the pulse to end before looking for the next one
            wait until clk_pulse = '0';
        end loop;

        -- 3. VERIFICATION
        -- Based on your load_values logic:
        -- data_out(0) <= all_values(2); -- start
        -- data_out(1) <= all_values(4); -- up
        -- data_out(2) <= all_values(7); -- right
        -- data_out(3) <= all_values(5); -- down
        -- data_out(4) <= all_values(6); -- left
        
        expected_data_out(0) := test_pattern(2);
        expected_data_out(1) := test_pattern(4);
        expected_data_out(2) := test_pattern(7);
        expected_data_out(3) := test_pattern(5);
        expected_data_out(4) := test_pattern(6);

        -- Give the FSM time to reach load_values state
        wait until latch = '1'; 
        wait for 20 ns;

        assert (data_out = expected_data_out)
            report "FAILURE: Expected " & to_hstring(expected_data_out) & 
                   " but got " & to_hstring(data_out)
            severity error;

        if (data_out = expected_data_out) then
            report "SUCCESS: Controller data correctly sampled and mapped!" severity note;
        end if;

        wait;
    end process;

end Behavioral;