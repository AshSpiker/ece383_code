-- vga_signal_generator Generates the hsync, vsync, blank, and row, col for the VGA signal

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity vga_signal_generator is
    Port ( clk      : in STD_LOGIC;
           reset_n  : in STD_LOGIC;
           position : out coordinate_t;
           vga      : out vga_t);
end vga_signal_generator;

architecture vga_signal_generator_arch of vga_signal_generator is

    signal horizontal_roll, vertical_roll: std_logic := '0';		
    signal h_counter_ctrl, v_counter_ctrl: std_logic := '1'; -- Default to counting up
    signal h_sync_is_low, v_sync_is_low, h_blank_is_low, v_blank_is_low : boolean := false;
    signal current_pos : coordinate_t;
begin

-- horizontal counter
    horizontal_counter_inst : counter 
    generic map(
        num_bits => 10,
        max_value => 799
    )
    port map(
        clk     => clk,
        reset_n => reset_n,
        ctrl    => h_counter_ctrl,
        roll    => horizontal_roll,
        Q       => current_pos.col -- col because we are in the same row counting over 
    );
-- Glue code to connect the horizontal and vertical counters
v_counter_ctrl <= horizontal_roll; -- gluing roll to ctrl of the counters 

-- vertical counter
vertical_counter_inst : counter 
    generic map(
        num_bits => 10,
        max_value => 524
        )
    port map(
        clk     => clk,
        reset_n => reset_n,
        ctrl    => v_counter_ctrl,
        roll    => vertical_roll,
        Q       => current_pos.row -- row because we are in the same col counting down 
    );


-- Assign VGA outputs in a gated manner
        -- horizontal signals 
        
h_sync_is_low  <= false when ((current_pos.col >= 0  and current_pos.col <= 639) or (current_pos.col = 799)) else
                  false when (current_pos.col >= 640 and current_pos.col <= 655) else 
                  true  when (current_pos.col >= 656 and current_pos.col <= 751) else 
                  false when (current_pos.col >= 752 and current_pos.col < 799); 

h_blank_is_low <= true  when ((current_pos.col >= 0  and current_pos.col < 639) or (current_pos.col = 799)) else
                  false when (current_pos.col >= 640 and current_pos.col < 655) else
                  false when (current_pos.col >= 656 and current_pos.col < 751) else
                  false when (current_pos.col >= 752 and current_pos.col < 799);
                  
                  
v_sync_is_low  <= false when ((current_pos.row >= 0  and current_pos.row < 479) or (current_pos.row = 524)) else
                  false when (current_pos.row >= 480 and current_pos.row < 489) else
                  true  when (current_pos.row >= 490 and current_pos.row < 491) else
                  false when (current_pos.row >= 492 and current_pos.row < 524);
                  
                  
v_blank_is_low <= true  when ((current_pos.row >= 0  and current_pos.row < 479) or (current_pos.row = 524)) else
                  false when (current_pos.row >= 480 and current_pos.row < 489) else
                  false when (current_pos.row >= 490 and current_pos.row < 491) else
                  false when (current_pos.row >= 492 and current_pos.row < 524);
                  
--if((current_pos.col >= 0 and current_pos.col < 639) or (current_pos.col = 799 )) then 
--    h_sync_is_low  <= false;
--    h_blank_is_low <= true;

--elsif((current_pos.col >= 640 and current_pos.col < 655) or (current_pos.col = 639)) then 
--    h_sync_is_low  <= false;
--    h_blank_is_low <= false;

--elsif((current_pos.col >= 656 and current_pos.col < 751) or (current_pos.col = 655)) then 
--    h_sync_is_low  <= true;
--    h_blank_is_low <= false;

--elsif((current_pos.col >= 752 and current_pos.col < 799) or (current_pos.col = 751)) then
--    h_sync_is_low  <= false;
--    h_blank_is_low <= false;
--end if;

---- vertical signals 
--if((current_pos.row >= 0 and current_pos.row < 479) or (current_pos.row = 524)) then 
--    v_sync_is_low  <= false;
--    v_blank_is_low <= true;

--elsif((current_pos.row >= 480 and current_pos.row < 489) or (current_pos.row = 479)) then 
--    v_sync_is_low  <= false;
--    v_blank_is_low <= false;

--elsif((current_pos.row >= 490 and current_pos.row < 491) or (current_pos.row = 489)) then
--    v_sync_is_low  <= true;
--    v_blank_is_low <= false;

--elsif((current_pos.row >= 492 and current_pos.row < 524) or (current_pos.row = 491)) then
--    v_sync_is_low  <= false;
--    v_blank_is_low <= false;
--end if;

process (clk)
    
begin
   if (rising_edge(clk)) then
    -- gate these functions 
        vga.hsync <= '1' when (h_sync_is_low = false) else '0';
        vga.vsync <= '1' when (v_sync_is_low = false) else '0';
        vga.blank <= '1' when (v_blank_is_low = false or h_blank_is_low = false) else '0';
        position.row <= current_pos.row;
        position.col <= current_pos.col;
   end if;
end process;



end vga_signal_generator_arch;
