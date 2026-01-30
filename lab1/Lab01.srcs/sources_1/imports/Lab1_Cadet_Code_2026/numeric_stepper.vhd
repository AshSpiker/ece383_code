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
    reset_n : in  std_logic;                    -- active-low synchronous reset
    en      : in  std_logic;                    -- enable
    up      : in  std_logic;                    -- increment on rising edge
    down    : in  std_logic;                    -- decrement on rising edge
    q       : out signed(num_bits-1 downto 0)   -- signed output
  );
end numeric_stepper;

architecture numeric_stepper_arch of numeric_stepper is
    signal process_q : signed(num_bits-1 downto 0) := to_signed(0,num_bits);
    signal prev_up, prev_down : std_logic := '0';
    signal is_increment, is_decrement : boolean := false;
    signal if_val_too_small, if_val_too_big : boolean := false;
begin

process (clk)
    begin
    if (rising_edge(clk)) then
        prev_up   <= up;
        prev_down <= down;
        if(reset_n = '0') then -- active low, synchronous reset
            process_q <= (others => '0'); -- set q to 0
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
is_increment <= true when (up = '1' and prev_up = '0')     else false;
is_decrement <= true when (down = '1' and prev_down = '0') else false;

end numeric_stepper_arch;
