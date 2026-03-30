----------------------------------------------------------------------------------
-- Lt Col James Trimble, 16-Jan-2025
-- color_mapper (previously scope face) determines the pixel color value based on the row, column, triggers, and channel inputs 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity color_mapper is
    Port ( color    : out color_t;
           position : in coordinate_t;
		   trigger  : in trigger_t;
           ch1      : in channel_t;
           ch2      : in channel_t);
end color_mapper;

architecture color_mapper_arch of color_mapper is

signal trigger_color    : color_t := YELLOW; 
signal ch1_color        : color_t := YELLOW;
signal ch2_color        : color_t := GREEN;
signal background_color : color_t := BLACK;
signal hatch_color      : color_t := WHITE;
-- Add other colors you want to use here

signal is_vertical_gridline, is_horizontal_gridline, is_within_grid, is_trigger_time, is_trigger_volt, is_ch1_line, is_ch2_line,
    is_horizontal_hash, is_vertical_hash : boolean := false;

-- Fill in values here
constant grid_start_row            : integer := 20;
constant grid_stop_row             : integer := 620;
constant grid_start_col            : integer := 20;
constant grid_stop_col             : integer := 420;
constant num_horizontal_gridblocks : integer := 10;
constant num_vertical_gridblocks   : integer := 8;
constant center_column             : integer := 320;
constant center_row                : integer := 220;
constant hash_size                 : integer := 5; -- assuming this means how far up and down they go
constant hash_horizontal_spacing   : integer := 15;
constant hash_vertical_spacing     : integer := 10;

begin

-- Assign values to booleans here
is_horizontal_gridline <= true when (position.row mod 50 = 20 and is_within_grid)                                           else false;
is_vertical_gridline   <= true when (position.col mod 60 = 20 and is_within_grid)                                           else false;
is_within_grid         <= true when (position.row > 19 and position.row < 421 and position.col > 19 and position.col < 621) else false; --might be backwards
is_trigger_time        <= true when ((trigger.t >= position.col - 5 and trigger.t <= position.col + 5 and position.row = 20 and is_within_grid) or (trigger.t >= position.col - 4 and trigger.t <= position.col + 4 and position.row = 21 and is_within_grid) or (trigger.t >= position.col - 3 and trigger.t <= position.col + 3 and position.row = 22 and is_within_grid) or (trigger.t >= position.col - 2 and trigger.t <= position.col + 2 and position.row = 23 and is_within_grid) or (trigger.t >= position.col - 1 and trigger.t <= position.col + 1 and position.row = 24 and is_within_grid) or (trigger.t = position.col and position.row = 25 and is_within_grid))                                            else false;
is_trigger_volt        <= true when ((trigger.v >= position.row - 5 and trigger.v <= position.row + 5 and position.col = 20 and is_within_grid) or (trigger.v >= position.row - 4 and trigger.v <= position.row + 4 and position.col = 21 and is_within_grid) or (trigger.v >= position.row - 3 and trigger.v <= position.row + 3 and position.col = 22 and is_within_grid) or (trigger.v >= position.row - 2 and trigger.v <= position.row + 2 and position.col = 23 and is_within_grid) or (trigger.v >= position.row - 1 and trigger.v <= position.row + 1 and position.col = 24 and is_within_grid) or (trigger.v = position.row and position.col = 25 and is_within_grid))                                                    else false;
is_ch1_line            <= true when (ch1.active = '1' and ch1.en = '1' and is_within_grid)                                  else false;
is_ch2_line            <= true when (ch2.active = '1' and ch2.en = '1' and is_within_grid)                                  else false;
is_horizontal_hash     <= true when ((position.col mod 20 = 10 and is_within_grid and not is_vertical_gridline)   and (position.row <= (center_row + hash_size)) and (position.row >= (center_row - hash_size)))             else false;
is_vertical_hash       <= true when ((position.row mod 10 = 0  and is_within_grid and not is_horizontal_gridline) and (position.col <= (center_column + hash_size))    and (position.col >= (center_column - hash_size)))           else false;

-- Use your booleans to choose the color
color <= trigger_color     when (is_trigger_volt or is_trigger_time)                                                       else 
         ch1_color         when (is_ch1_line)                                                                              else
         ch2_color         when (is_ch2_line)                                                                              else
         hatch_color       when (is_horizontal_gridline or is_vertical_gridline or is_horizontal_hash or is_vertical_hash) else
         background_color;
                                   

end color_mapper_arch;
