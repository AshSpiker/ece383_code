----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 07:20:53 AM
-- Design Name: 
-- Module Name: NES - Behavioral
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

entity NES is
    Port ( clk          : in STD_LOGIC;
           reset_n      : in STD_LOGIC;
           data_in      : in STD_LOGIC;
           data_out     : out STD_LOGIC_VECTOR (4 downto 0);
           latch        : out STD_LOGIC;
           clk_pulse    : out STD_LOGIC);
end NES;

architecture Behavioral of NES is

    -- write mode is when the circuits are physically writing to the 8 bit shift register
    -- read mode is all 8 others states
    -- reads the A button, waits for the clock pulse to shift the register, then reads B, and so on

    type state_type is (write_mode, read_A, read_B, read_select, read_start, read_up, read_down, read_left, read_right);
    signal state, next_state : state_type;
    
    signal latch_value, pulse_value : std_logic;
    signal all_values : unsigned(7 downto 0) := "00000000";
begin

    process(clk)
    begin 
        if rising_edge(clk) then
            if reset_n = '0' then
                state <= write_mode;
            else
                pulse_value     <= '1'; -- activate latch
                state           <= next_state;
                pulse_value     <= '0'; -- decativate latch
                
                -- adding value to my 8 bit signal holding all button values
                all_values <= shift_left(all_values, 1); -- shift the signal once
                all_values(0) <= data_in; -- make the LSB of the signal into the input from the NES controller
            end if;
        end if;
    end process;
    
    
    -- next state logic 
    next_state <= read_A        when pulse_value = '1' and state = write_mode   else 
                  read_B        when pulse_value = '1' and state = read_A       else
                  read_select   when pulse_value = '1' and state = read_B       else 
                  read_start    when pulse_value = '1' and state = read_select  else 
                  read_up       when pulse_value = '1' and state = read_start   else 
                  read_down     when pulse_value = '1' and state = read_up      else 
                  read_left     when pulse_value = '1' and state = read_down    else
                  read_right    when pulse_value = '1' and state = read_left    else
                  write_mode    when pulse_value = '1' and state = read_right   else
                  next_state;
                  
                  
    -- output logic
    latch <= latch_value;
    data_out(0) <= all_values(2); -- start button
    data_out(1) <= all_values(4); -- up button
    data_out(2) <= all_values(7); -- right button
    data_out(3) <= all_values(5); -- down button
    data_out(4) <= all_values(6); -- left button

end Behavioral;
