----------------------------------------------------------------------------------
-- Lt Col James Trimble, 16-Jan-2025
-- color_mapper (previously scope face) determines the pixel color value based on the row, column, triggers, and channel inputs 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity color_mapper is
    Port ( 
        clk      : in std_logic;
        color    : out color_t;
        position : in coordinate_t;
        --trigger  : in trigger_t;
        ch1      : in channel_t;
        ch2      : in channel_t;
        game_map : in map_array;
        btn      : in STD_LOGIC_VECTOR(3 downto 0);
        reset_n  : in STD_LOGIC
        );
end color_mapper;

architecture color_mapper_arch of color_mapper is

    component clipart2902856_index_rom is 
        Port (
            clk      : in  std_logic;
            en       : in  std_logic;
            row_addr : in  unsigned(4 downto 0);
            col_addr : in  unsigned(4 downto 0);
            color_index : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component clipart2902856_palette is 
        Port (
            clk         : in  std_logic;
            en          : in  std_logic;
            color_index : in  std_logic_vector(7 downto 0);
            rgb         : out std_logic_vector(23 downto 0)
        );
    end component;
            
  
        
-- colors
signal light_grass_color    : color_t := LGRASS; 
signal dark_grass_color     : color_t := DGRASS;
signal road_color           : color_t := ROAD;
signal water_color          : color_t := WATER;


signal row_0, row_1, row_2, row_3, row_4, row_5, row_6, row_7, row_8, row_9, row_10, row_11, row_12, row_13, row_14, row_15, row_16, row_17, row_18, row_19 : boolean := false;
    
signal is_chicken : boolean := false;
signal chicken_index : std_logic_vector(7 downto 0);
signal chicken_rgb : std_logic_vector(23 downto 0);

signal chicken_row : signed(4 downto 0);
signal chicken_col : signed(4 downto 0);


begin

chicken_sprite : clipart2902856_index_rom
    port map (
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - unsigned(chicken_row), --to_unsigned(100,5),
        col_addr => position.col(4 downto 0) - unsigned(chicken_col), --to_unsigned(200,5),--
        color_index => chicken_index
    );
    
chicken_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => chicken_index,
        rgb => chicken_rgb
    );
    
numeric_stepper_row : numeric_stepper
    generic map(
        num_bits  => 5,
        max_value => 449,
        min_value => 0,
        delta     => 30
    )
    port map(
        clk     => clk,
        reset_n => '1',
        en      => '1',
        up      => btn(DOWN),
        down    => btn(UP),
        q       => chicken_row
    );
    
numeric_stepper_col : numeric_stepper
    generic map(
        num_bits  => 5,
        max_value => 609,
        min_value => 30,
        delta     => 30
    )
    port map(
        clk     => clk,
        reset_n => '1',
        en      => '1',
        up      => btn(RIGHT),
        down    => btn(LEFT),
        q       => chicken_col
    );


-- Assign values to booleans here
is_chicken  <= true when ((position.row >= unsigned(chicken_row) and position.row < unsigned(chicken_row) + 32) and ((position.col >= unsigned(chicken_col) and position.col < unsigned(chicken_col) + 20))) else false;
--is_chicken  <= true when ((position.row >= 100 and position.row < 132) and ((position.col >= 200 and position.col < 220))) else false;


-- row positions. Row 19 is closest to top of screen, row 0 is on the bottom of the screen
row_19      <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 - 120) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 - 90))  else false;
row_18      <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 - 90)  and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 - 60))  else false;
row_17      <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 - 60)  and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 - 30))  else false;
row_16      <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 - 30)  and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 0))   else false;
row_15      <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 0)   and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 29))  else false;
row_14      <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 29)  and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 59))  else false;
row_13      <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 59)  and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 89))  else false;
row_12      <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 89)  and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 119)) else false;
row_11      <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 119) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 149)) else false;
row_10      <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 149) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 179)) else false;
row_9       <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 179) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 209)) else false;
row_8       <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 209) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 239)) else false;
row_7       <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 239) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 269)) else false;
row_6       <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 269) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 299)) else false;
row_5       <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 299) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 329)) else false;
row_4       <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 329) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 359)) else false;
row_3       <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 359) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 389)) else false;
row_2       <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 389) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 419)) else false;
row_1       <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 419) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 449)) else false;
row_0       <= true when (signed("0" & position.row) > (3 * signed(("0" & position.col)) / 16 + 449) and signed("0" & position.row) < (3 * signed(("0" & position.col)) / 16 + 479)) else false;
                         --            y =   m          x        +  b
-- Use your booleans to choose the color
color <= chicken_rgb        when is_chicken                     else
         
         -- row 0
         water_color        when (row_0 and game_map(0) = "11") else
         road_color         when (row_0 and game_map(0) = "10") else
         dark_grass_color   when (row_0 and game_map(0) = "01") else
         light_grass_color  when (row_0 and game_map(0) = "00") else
         
         -- row 1
         water_color        when (row_1 and game_map(1) = "11") else
         road_color         when (row_1 and game_map(1) = "10") else
         dark_grass_color   when (row_1 and game_map(1) = "01") else
         light_grass_color  when (row_1 and game_map(1) = "00") else
         
         -- row 2
         water_color        when (row_2 and game_map(2) = "11") else
         road_color         when (row_2 and game_map(2) = "10") else
         dark_grass_color   when (row_2 and game_map(2) = "01") else
         light_grass_color  when (row_2 and game_map(2) = "00") else
         
         -- row 3
         water_color        when (row_3 and game_map(3) = "11") else
         road_color         when (row_3 and game_map(3) = "10") else
         dark_grass_color   when (row_3 and game_map(3) = "01") else
         light_grass_color  when (row_3 and game_map(3) = "00") else
         
         -- row 4
         water_color        when (row_4 and game_map(4) = "11") else
         road_color         when (row_4 and game_map(4) = "10") else
         dark_grass_color   when (row_4 and game_map(4) = "01") else
         light_grass_color  when (row_4 and game_map(4) = "00") else
         
         -- row 5
         water_color        when (row_5 and game_map(5) = "11") else
         road_color         when (row_5 and game_map(5) = "10") else
         dark_grass_color   when (row_5 and game_map(5) = "01") else
         light_grass_color  when (row_5 and game_map(5) = "00") else
         
         -- row 6
         water_color        when (row_6 and game_map(6) = "11") else
         road_color         when (row_6 and game_map(6) = "10") else
         dark_grass_color   when (row_6 and game_map(6) = "01") else
         light_grass_color  when (row_6 and game_map(6) = "00") else
         
         -- row 7
         water_color        when (row_7 and game_map(7) = "11") else
         road_color         when (row_7 and game_map(7) = "10") else
         dark_grass_color   when (row_7 and game_map(7) = "01") else
         light_grass_color  when (row_7 and game_map(7) = "00") else
         
         -- row 8
         water_color        when (row_8 and game_map(8) = "11") else
         road_color         when (row_8 and game_map(8) = "10") else
         dark_grass_color   when (row_8 and game_map(8) = "01") else
         light_grass_color  when (row_8 and game_map(8) = "00") else
        
         -- row 9
         water_color        when (row_9 and game_map(9) = "11") else
         road_color         when (row_9 and game_map(9) = "10") else
         dark_grass_color   when (row_9 and game_map(9) = "01") else
         light_grass_color  when (row_9 and game_map(9) = "00") else
         
         -- row 10
         water_color        when (row_10 and game_map(10) = "11") else
         road_color         when (row_10 and game_map(10) = "10") else
         dark_grass_color   when (row_10 and game_map(10) = "01") else
         light_grass_color  when (row_10 and game_map(10) = "00") else
         
         -- row 11
         water_color        when (row_11 and game_map(11) = "11") else
         road_color         when (row_11 and game_map(11) = "10") else
         dark_grass_color   when (row_11 and game_map(11) = "01") else
         light_grass_color  when (row_11 and game_map(11) = "00") else
         
         -- row 12
         water_color        when (row_12 and game_map(12) = "11") else
         road_color         when (row_12 and game_map(12) = "10") else
         dark_grass_color   when (row_12 and game_map(12) = "01") else
         light_grass_color  when (row_12 and game_map(12) = "00") else
         
         -- row 13
         water_color        when (row_13 and game_map(13) = "11") else
         road_color         when (row_13 and game_map(13) = "10") else
         dark_grass_color   when (row_13 and game_map(13) = "01") else
         light_grass_color  when (row_13 and game_map(13) = "00") else
         
         -- row 14
         water_color        when (row_14 and game_map(14) = "11") else
         road_color         when (row_14 and game_map(14) = "10") else
         dark_grass_color   when (row_14 and game_map(14) = "01") else
         light_grass_color  when (row_14 and game_map(14) = "00") else
         
         -- row 15
         water_color        when (row_15 and game_map(15) = "11") else
         road_color         when (row_15 and game_map(15) = "10") else
         dark_grass_color   when (row_15 and game_map(15) = "01") else
         light_grass_color  when (row_15 and game_map(15) = "00") else
         
         -- row 16
         water_color        when (row_16 and game_map(16) = "11") else
         road_color         when (row_16 and game_map(16) = "10") else
         dark_grass_color   when (row_16 and game_map(16) = "01") else
         light_grass_color  when (row_16 and game_map(16) = "00") else
         
         -- row 16
         water_color        when (row_17 and game_map(17) = "11") else
         road_color         when (row_17 and game_map(17) = "10") else
         dark_grass_color   when (row_17 and game_map(17) = "01") else
         light_grass_color  when (row_17 and game_map(17) = "00") else
         
         -- row 16
         water_color        when (row_18 and game_map(18) = "11") else
         road_color         when (row_18 and game_map(18) = "10") else
         dark_grass_color   when (row_18 and game_map(18) = "01") else
         light_grass_color  when (row_18 and game_map(18) = "00") else
         
         -- row 16
         water_color        when (row_19 and game_map(19) = "11") else
         road_color         when (row_19 and game_map(19) = "10") else
         dark_grass_color   when (row_19 and game_map(19) = "01") else
         light_grass_color  when (row_19 and game_map(19) = "00") else
         
         -- default colors
         BLACK;


        -- chicken position registers
        process (clk)
    
        begin
           if (rising_edge(clk)) then
               --if (reset_n = '0')  then
                   -- add base position / default position
               --end if;
               
                
           end if;
        end process;
                                   

end color_mapper_arch;
