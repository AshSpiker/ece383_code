-- Numeric Stepper: Holds a value and increments or decrements it based on button presses
-- James Trimble, 20 Jan 2026

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity numeric_stepper is
  generic (
    num_bits  : integer := 8;
    max_value : integer := 127;
    min_value : integer := -128;
    delta     : integer := 10
  );
  port (
    clk     : in  std_logic;
    btn     : in  std_logic_vector(4 downto 0);
    reset_n : in  std_logic;                    -- active-low synchronous reset
    en      : in  std_logic;                    -- enable
    up      : in  std_logic;                    -- increment on rising edge
    down    : in  std_logic;                    -- decrement on rising edge
    q       : out signed(num_bits-1 downto 0)   -- signed output
  );
end numeric_stepper;

architecture numeric_stepper_arch of numeric_stepper is

    component button_debounce is 
        Port (
            clk: in  STD_LOGIC;
			reset : in  STD_LOGIC;
			button: in STD_LOGIC;
			action: out STD_LOGIC);
		end component;


    signal process_q : signed(num_bits-1 downto 0) := to_signed(((max_value - min_value) / 2) + (min_value), num_bits);
    signal prev_up, prev_down : std_logic := '0';
    signal is_increment, is_decrement : boolean := false;
    signal if_val_too_small, if_val_too_big : boolean := false;
    signal debounced_up, debounced_down  : std_logic := '0';
begin

debouncer_up : button_debounce
    port map (
        clk     => clk,
        reset   => reset_n,
        button  => up,
        action  => debounced_up
    );
    
debouncer_down : button_debounce
    port map (
        clk     => clk,
        reset   => reset_n,
        button  => down,
        action  => debounced_down
    );

process (clk)
    begin
    if (rising_edge(clk)) then
        prev_up   <= debounced_up;
        prev_down <= debounced_down;
        if(reset_n = '0') then -- active low, synchronous reset
            process_q <= to_signed(((max_value - min_value) / 2), num_bits) ; -- set q to the mid point so the triggers start not in the corner of the screen
        elsif(en = '1') then
            if(TO_INTEGER(process_q) - delta <= min_value and is_decrement)    then
                process_q <= TO_SIGNED(min_value, num_bits);
            elsif(TO_INTEGER(process_q) + delta >= max_value and is_increment) then
                process_q <= TO_SIGNED(max_value, num_bits);
            else
                process_q <= (process_q + delta) when (is_increment)                  else -- up is given priority
                             (process_q - delta) when (is_decrement) else 
                              process_q; -- if neither are pressed then do nothing
                
            end if;
        end if;
    end if;
    
end process;
q <= process_q;
if_val_too_small <= (TO_INTEGER(process_q) - delta <= min_value);
if_val_too_big   <= (TO_INTEGER(process_q) + delta >= max_value);
is_increment <= true when (debounced_up = '1' and prev_up = '0')     else false;
is_decrement <= true when (debounced_down = '1' and prev_down = '0') else false;

end numeric_stepper_arch;
