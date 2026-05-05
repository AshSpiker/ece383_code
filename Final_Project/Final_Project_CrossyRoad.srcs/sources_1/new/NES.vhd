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
use work.ece383_pkg.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity NES is
    Port ( clk          : in STD_LOGIC;
           reset_n      : in STD_LOGIC;
           data_in      : in STD_LOGIC;
           data_out     : out STD_LOGIC_VECTOR (4 downto 0);
           latch        : out STD_LOGIC;
           clk_pulse    : out STD_LOGIC;
           led          : out std_logic_vector(7 downto 0)
           );
end NES;

architecture Behavioral of NES is

    -- write mode is when the circuits are physically writing to the 8 bit shift register
    -- read mode is all 8 others states
    -- reads the A button, waits for the clock pulse to shift the register, then reads B, and so on

    --type state_type is (set_latch, wait_6u_1, clear_latch, read_data_1, send_clk_pulse, wait_6u_2, read_data_2, cmp, wait_6u_3, wait_6u_4);
    type state_type is (set_latch, wait_6u_1, clear_latch, wait_6u_2, init_counter_7, read_data, set_clock_pulse , wait_6u_3, clear_clock_pulse, wait_6u_4, cmp, load_values); 
    signal state, next_state : state_type:=set_latch;

    signal all_values : unsigned(8 downto 0) := "000000000";
    
    -- 6us counter
    signal counter_6us_reset_n : std_logic;
    signal been_6us : std_logic;
    signal Q_6us : unsigned(9 downto 0) := (others => '0');
    signal ctrl_6us : std_logic;
    
    -- 7 bit data line counter
    signal counter_7_reset_n : std_logic;
    signal been_7            : std_logic;
    signal Q_7               : unsigned(3 downto 0);
    signal ctrl_7            : std_logic;
    
    signal all_shift_vals   : std_logic_vector(7 downto 0);
            
    
begin
    -- counter instatiations 
    -- clock is 100 MHz, need to count up to 600 to have 6us to pass
    counter_6us : counter 
        generic map (
            num_bits    => 10, -- needs to count to 600, 2^10 is 1024
            max_value   => 600
        )        
        port map (
            clk     => clk,
            reset_n => counter_6us_reset_n,
            ctrl    => ctrl_6us,
            roll    => been_6us,
            Q       => Q_6us
        );
        
        
    counter_7 : counter
        generic map (
            num_bits => 4,
            max_value => 8
        )
        port map (
            clk => clk,
            reset_n => counter_7_reset_n,
            ctrl => ctrl_7,
            roll => been_7,
            Q => Q_7
        );

    -- process for running FSM
--    process(clk)
--    begin 
--        if rising_edge(clk) then
--            if reset_n = '0' then
--                state <= set_latch;
--            else
--                state <= next_state;
                
--                if (state = send_clk_pulse) then 
--                    all_values(7 downto 1)          <= all_values(6 downto 0);
--                end if;
--                if ( state = read_data_1 or state = read_data_2) then
--                    all_values(0)       <= data_in; 
--                end if;
--            end if;
--        end if;
--    end process;
--    process(clk)
--    begin
--        if(reset_n = '0') then
--            state <= set_latch;
--        else
--            state <= next_state;
--        end if;
--    end process;

process(clk)
begin
    if rising_edge(clk) then
        if reset_n = '0' then
            state <= set_latch;
        else
            case state is
                when set_latch =>
                    state <= wait_6u_1;

                when wait_6u_1 =>
                    if Q_6us >= 600 then
                        state <= clear_latch;
                    end if;

                when clear_latch =>
                    state <= wait_6u_2;

                when wait_6u_2 =>
                    if Q_6us >= 600 then
                        state <= init_counter_7;
                    end if;

                when init_counter_7 =>

                    state <= read_data;

                when read_data =>

                    state <= set_clock_pulse;

                when set_clock_pulse =>
                    state <= wait_6u_3;

                when wait_6u_3 =>
                    if Q_6us >= 600 then
                        state <= clear_clock_pulse;
                    end if;

                when clear_clock_pulse =>
                    state <= wait_6u_4;

                when wait_6u_4 =>
                    if Q_6us >= 600 then
                        state <= cmp;
                    end if;

                when cmp =>
                    if Q_7 >= 8 then
                        state <= load_values;
                    else
                        state <= read_data;
                    end if;

                when load_values =>
                    state <= set_latch;

                when others =>
                    state <= set_latch;
            end case;
        end if;
    end if;
end process;
    
    
    -- next state logic 
--    next_state <= wait_6u_1         when (state = set_latch)                                        else
--                  clear_latch       when (been_6us = '1' and state = wait_6u_1)                     else
--                  read_data_1       when (state = clear_latch)                                      else
--                  send_clk_pulse    when ((state = read_data_1) or (state = wait_6u_4))             else
--                  wait_6u_2         when (state = send_clk_pulse)                                   else
--                  read_data_2       when (been_6us = '1' and state = wait_6u_2)                     else
--                  cmp               when (state = read_data_2)                                      else
--                  wait_6u_4         when (state = cmp and been_7 = '0')                             else
--                  wait_6u_3         when (been_7 = '1' and state = cmp)                             else
--                  set_latch         when (been_6us = '1' and state = wait_6u_3)                     else
--                  next_state;
--    next_state <= wait_6u_1         when (state = set_latch)                                    else
--                  clear_latch       when (state = wait_6u_1 and Q_6us >= 600)                   else
--                  wait_6u_2         when (state = clear_latch)                                  else
--                  init_counter_7    when (state = wait_6u_2 and Q_6us >= 600)                   else 
--                  read_data         when (state = init_counter_7 or (state = cmp and Q_7 < 7))  else
--                  set_clock_pulse   when (state = read_data)                                    else
--                  wait_6u_3         when (state = set_clock_pulse)                              else 
--                  clear_clock_pulse when (state = wait_6u_3 and Q_6us >= 600)                   else
--                  wait_6u_4         when (state = clear_clock_pulse)                            else 
--                  cmp               when (state = wait_6u_4 and Q_6us >= 600)                   else
--                  load_values       when (state = cmp and Q_7 >= 7)                             else 
--                  set_latch         when (state = load_values);
                  
                  
    -- output logic
-- wait 6us counter signals 
--counter_6us_reset_n <= '0' when (state = set_latch or state = send_clk_pulse or state = cmp)            else '1'; -- active low
--ctrl_6us            <= '1' when (state = wait_6u_1 or state = wait_6u_2 or state = wait_6u_3 or state = wait_6u_4)           else '0';

counter_6us_reset_n <= '0' when (state = set_latch or state = clear_latch or state = set_clock_pulse or state = clear_clock_pulse) else '1';
ctrl_6us            <= '1' when (state = wait_6u_1 or state = wait_6u_2 or state = wait_6u_3 or state = wait_6u_4) else '0'; -- 1 is increment, 0 is hold

-- 7 clock pulse counter signals 
--counter_7_reset_n   <= '0' when (state = read_data_1)                                                   else '1'; -- active low
--ctrl_7              <= '1' when (state = read_data_2)                                                   else '0'; 
counter_7_reset_n   <= '0' when (state = init_counter_7) else '1';
ctrl_7              <= '1' when (state = read_data) else '0';


-- outputs
--clk_pulse           <= '1' when (state = send_clk_pulse or state = wait_6u_2 or state = read_data_2)    else '0';
--latch               <= '1' when (state = set_latch)  else '0' when (state = clear_latch)                else latch;
latch       <= '1' when (state = set_latch or state = wait_6u_1) else '0';
clk_pulse   <= '1' when (state = set_clock_pulse or state = wait_6u_3) else '0';


process(clk) 
    begin
    if rising_edge(clk) then
        if(reset_n = '0') then
            all_values <= (others => '0');
        elsif(state = set_clock_pulse) then
            all_values(8 downto 1) <= all_values(7 downto 0);
        elsif(state = read_data) then
            all_values(0) <= data_in;
        end if;
    end if;
end process;


process(clk)
    begin
    if rising_edge(clk) then
        if(state = load_values) then
        
--            data_out(0) <= all_values(2); -- start button || ACTUALLY THE DOWN BUTTON
--            data_out(1) <= all_values(4); -- up button || ACTUALLY THE START BUTTON
--            data_out(2) <= all_values(7); -- right button || ACTUALLY A BUTTON
--            data_out(3) <= all_values(5); -- down button || ACTUALLY SELECT BUTTON
--            data_out(4) <= all_values(6); -- left button || ACTUALLY THE B BUTTON
            data_out(0) <= all_values(4); -- start button
            data_out(1) <= all_values(3); -- up button
            data_out(2) <= all_values(0); -- right button
            data_out(3) <= all_values(2); -- down button 
            data_out(4) <= all_values(1); -- left button
            all_shift_vals <= not(std_logic_vector(all_values(8 downto 1)));
        end if;
    end if;
end process;
-- debugging 
--led <= all_shift_vals;

end Behavioral;
