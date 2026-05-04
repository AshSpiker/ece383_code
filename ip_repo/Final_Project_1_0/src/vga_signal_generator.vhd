-- vga_signal_generator Generates the hsync, vsync, blank, and row, col for the VGA signal

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity vga_signal_generator is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           position: out coordinate_t;
           vga : out vga_t);
end vga_signal_generator;

architecture vga_signal_generator_arch of vga_signal_generator is

    signal horizontal_roll, vertical_roll: std_logic := '0';		
    signal h_counter_ctrl, v_counter_ctrl: std_logic := '1'; -- Default to counting up
    signal h_sync_is_low, v_sync_is_low, h_blank_is_low, v_blank_is_low : boolean := false;
    signal current_pos : coordinate_t;
begin

-- 800 columns across
horizontal_counter : counter
generic map (
    num_bits => 10,
    max_value => 799
)
port map (
    clk => clk,
    reset_n => reset_n,
    ctrl => h_counter_ctrl,
    roll => horizontal_roll,
    Q => current_pos.col
);

-- Glue code to connect the horizontal and vertical counters
v_counter_ctrl <= horizontal_roll; -- Enable the vertical counter when the horizontal counter rolls over
			
-- 525 rows tall			
vertical_counter : counter
generic map (
    num_bits => 10,
    max_value => 524
)
port map (
    clk => clk,
    reset_n => reset_n,
    ctrl => v_counter_ctrl,
    roll => vertical_roll,
    Q => current_pos.row);

-- Determine when signals should go low
h_sync_is_low <= (current_pos.col >= 656 and current_pos.col <= 751); -- This is between the front and back porch
v_sync_is_low <= (current_pos.row >= 490 and current_pos.row <= 491); -- This is between the front and back porch
h_blank_is_low <= (current_pos.col >= 0 and current_pos.col <= 639);
v_blank_is_low <= (current_pos.row >= 0 and current_pos.row <= 479);

-- Assign VGA outputs in a gated manner
process (clk)
begin
   if (rising_edge(clk)) then
      if reset_n = '0' then
        vga.hsync <= '0';
        vga.vsync <= '0';
        vga.blank <= '0'; 
      else
        if h_sync_is_low then vga.hsync <= '0'; else vga.hsync <= '1'; end if;
        if v_sync_is_low then vga.vsync <= '0'; else vga.vsync <= '1'; end if;
        if (h_blank_is_low and v_blank_is_low) then vga.blank <= '0'; else vga.blank <= '1'; end if;                
      end if;
   end if;
end process;

-- Assign output ports
position <= current_pos; -- Output the current position

end vga_signal_generator_arch;
