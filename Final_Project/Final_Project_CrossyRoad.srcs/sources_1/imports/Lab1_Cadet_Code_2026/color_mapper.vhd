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
        reset_n  : in STD_LOGIC;
        led      : out std_logic_vector(7 downto 0)
        );
end color_mapper;

architecture color_mapper_arch of color_mapper is


-- Sprite ROM component declarations 
    component chicken_forward_index_rom is 
        Port (
            clk      : in  std_logic;
            en       : in  std_logic;
            row_addr : in  unsigned(4 downto 0);
            col_addr : in  unsigned(4 downto 0);
            color_index : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component chicken_backward_index_rom is 
        Port (
            clk      : in  std_logic;
            en       : in  std_logic;
            row_addr : in  unsigned(4 downto 0);
            col_addr : in  unsigned(4 downto 0);
            color_index : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component chicken_left_index_rom is 
        Port (
            clk      : in  std_logic;
            en       : in  std_logic;
            row_addr : in  unsigned(4 downto 0);
            col_addr : in  unsigned(4 downto 0);
            color_index : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component chicken_right_index_rom is 
        Port (
            clk      : in  std_logic;
            en       : in  std_logic;
            row_addr : in  unsigned(4 downto 0);
            col_addr : in  unsigned(4 downto 0);
            color_index : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component car_index_rom is 
        port (
            clk         : in  std_logic;
            en          : in  std_logic;
            row_addr    : in  unsigned(5 downto 0);
            col_addr    : in  unsigned(5 downto 0);
            color_index : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component lilypad_index_rom is
        port (
            clk         : in  std_logic;
            en          : in  std_logic;
            row_addr    : in  unsigned(4 downto 0);
            col_addr    : in  unsigned(4 downto 0);
            color_index : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component log_index_rom is 
        port (
            clk         : in  std_logic;
            en          : in  std_logic;
            row_addr    : in  unsigned(4 downto 0);
            col_addr    : in  unsigned(6 downto 0);
            color_index : out std_logic_vector(7 downto 0)
        );
    end component;
    
    
    -- palate websafe 216 declaration (all sprite roms use this pallate)
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

-- log Sprite location array type def --
type log_sprite_loc_array is array (0 to 59) of std_logic_vector(4 downto 0);

-- lilypad Sprite location array type def --
type lilypad_sprite_loc_array is array (0 to 19) of std_logic_vector(4 downto 0);

-- car Sprite location array type def --
type car_sprite_loc_array is array (0 to 49) of std_logic_vector(4 downto 0);

signal row_0, row_1, row_2, row_3, row_4, row_5, row_6, row_7, row_8, row_9, row_10, row_11, row_12, row_13, row_14, row_15, row_16, row_17, row_18, row_19 : boolean := false;

-- chicken signals
signal is_chicken           : boolean := false;
signal chicken_index        : std_logic_vector(7 downto 0);
signal chicken_forward_out  : std_logic_vector(7 downto 0);
signal chicken_backward_out : std_logic_vector(7 downto 0);
signal chicken_left_out     : std_logic_vector(7 downto 0);
signal chicken_right_out    : std_logic_vector(7 downto 0);
signal chicken_rgb          : std_logic_vector(23 downto 0);
signal chicken_row          : signed(9 downto 0);
signal chicken_col          : signed(10 downto 0);

-- button mux signals for last button pressed register (1 hot decoder for the MUX)
signal button_pressed       : std_logic_vector(3 downto 0):= "1000"; -- default to chicken looking forward 


-- cars signals 
signal is_car       : std_logic_vector(49 downto 0);    -- will be a 1 if its true, 0 if its false, so 1 bit per car, 50 cars
signal car_row      : unsigned(449 downto 0):= (others => '1');             -- 9 rows per car, 50 cars
signal car_col      : unsigned(499 downto 0):= (others => '1');             -- 10 cols per car, 50 cars
signal car_index    : std_logic_vector(399 downto 0);   -- 8 bits per index, 50 cars
signal car_rgb      : std_logic_vector(1199 downto 0);    -- every car should look the same (for now), so just a 24 bit rgb value


-- lilypad signals
signal is_lilypad       : std_logic_vector(19 downto 0);    -- 20 lilypads
signal lilypad_row      : unsigned(179 downto 0):= (others => '1');            -- 9 rows per lilypad
signal lilypad_col      : unsigned(199 downto 0):= (others => '1');            -- 10 cols per lilypad 
signal lilypad_index    : std_logic_vector(159 downto 0);   -- 8 bits per
signal lilypad_rgb      : std_logic_vector(479 downto 0);    -- all look the same

-- log signals
signal is_log           : std_logic_vector(59 downto 0);    -- 60 log sprites
signal log_row          : unsigned(539 downto 0):= (others => '1');           -- 9 rows per log
signal log_col          : unsigned(599 downto 0):= (others => '1');           -- 10 cols per log
signal log_index        : std_logic_vector(479 downto 0);   -- 8 bits per
signal log_rgb          : std_logic_vector(1439 downto 0);    -- all look the same


constant ROW_BITS : integer := 9;
constant COL_BITS : integer := 10;
-- location arrays (refers to what row 

begin
car_component_uuts : for i in 0 to 49 generate
    begin
        car_uut : car_index_rom
            port map(
                clk         => clk,
                en          => '1',
                row_addr    => position.row(5 downto 0) - car_row((i*6 + 5) downto (i*6)),
                col_addr    => position.col(5 downto 0) - car_col((i*6 + 5) downto (i*6)),
                color_index => car_index((8*i + 7) downto (8*i))
            );
    end generate;

log_component_uuts : for i in 0 to 59 generate
    begin
        log_uut : log_index_rom
            port map(
                clk         => clk,
                en          => '1',
                row_addr    => position.row(4 downto 0) - log_row((i*5 + 4) downto (i*5)),
                col_addr    => position.col(6 downto 0) - log_col((i*7 + 6) downto (i*7)),
                color_index => log_index((8*i + 7) downto (8*i))
            );
    end generate;

lilypad_component_uuts : for i in 0 to 19 generate
    begin
        lilypad_uut : lilypad_index_rom
            port map(
                clk         => clk,
                en          => '1',
                row_addr    => position.row(4 downto 0) - lilypad_row((i*5 + 4) downto (i*5)),
                col_addr    => position.col(4 downto 0) - lilypad_col((i*5 + 4) downto (i*5)),
                color_index => lilypad_index((8*i + 7) downto (8*i))
            );
    end generate;


-- 4 different directions of chicken sprite rom instationans 
chicken_forward : chicken_forward_index_rom
    port map (
        clk         => clk,
        en          => '1',
        row_addr    => (position.row(4 downto 0) - unsigned(chicken_row(4 downto 0))),
        col_addr    => (position.col(4 downto 0) - unsigned(chicken_col(4 downto 0))),
        color_index => chicken_forward_out
    );
    
chicken_backward : chicken_backward_index_rom
    port map (
        clk         => clk,
        en          => '1',
        row_addr    => (position.row(4 downto 0) - unsigned(chicken_row(4 downto 0))),
        col_addr    => (position.col(4 downto 0) - unsigned(chicken_col(4 downto 0))),
        color_index => chicken_backward_out
    );
    
chicken_left : chicken_left_index_rom
    port map (
        clk         => clk,
        en          => '1',
        row_addr    => (position.row(4 downto 0) - unsigned(chicken_row(4 downto 0))),
        col_addr    => (position.col(4 downto 0) - unsigned(chicken_col(4 downto 0))),
        color_index => chicken_left_out
    );
    
chicken_right : chicken_right_index_rom
    port map (
        clk         => clk,
        en          => '1',
        row_addr    => (position.row(4 downto 0) - unsigned(chicken_row(4 downto 0))),
        col_addr    => (position.col(4 downto 0) - unsigned(chicken_col(4 downto 0))),
        color_index => chicken_right_out
    );
    
-- MUX FOR CHOOSING CHICKEN DIRECTION:
chicken_index <= chicken_forward_out    when (button_pressed = "1000") else
                 chicken_backward_out   when (button_pressed = "0100") else
                 chicken_right_out      when (button_pressed = "0010") else
                 chicken_left_out       when (button_pressed = "0001");
    
-- palate instation
chicken_color : clipart2902856_palette
    port map (
        clk         => clk,
        en          => '1',
        color_index => chicken_index,
        rgb         => chicken_rgb
    );
    
-- log color instations 
log_color_uuts : for i in 0 to 59 generate
    begin
        log_color_uut : clipart2902856_palette
            port map(
                clk         => clk,
                en          => '1',
                color_index => log_index((i*8 + 7) downto (i*8)),
                rgb         => log_rgb((i*24 + 23) downto (i*24))
            );
    end generate;

car_color_uuts : for i in 0 to 49 generate
    begin
        car_color_uut : clipart2902856_palette
            port map(
                clk         => clk,
                en          => '1',
                color_index => car_index((i*8 +7) downto (i*8)),
                rgb         => car_rgb((i*24 + 23) downto (i*24))
            );
    end generate;
    
lilypad_color_uuts : for i in 0 to 19 generate
    begin
        lilypad_color_uut : clipart2902856_palette
            port map(
                clk         => clk,
                en          => '1',
                color_index => lilypad_index((i*8 +7) downto (i*8)),
                rgb         => lilypad_rgb((i*24 + 23) downto (i*24))
            );
    end generate;
    



    
-- numeric steppers for controlling chicken with the buttons 
numeric_stepper_row : numeric_stepper
    generic map(
        num_bits  => 10,
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
        num_bits  => 11,
        max_value => 609,
        min_value => 0,
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


-- Booleans for drawing colors 
is_chicken  <= true when ((position.row >= unsigned(chicken_row) and position.row < unsigned(chicken_row) + 30) and ((position.col >= unsigned(chicken_col(9 downto 0)) and position.col < unsigned(chicken_col(9 downto 0)) + 30))) else false;

-- car bools
is_car_generate : for i in 0 to 49 generate
    begin
        is_car(i) <= '1' when (
            (position.row >= car_row((i*9 + 8) downto (i*9)) and position.row < car_row((i*9 + 8) downto (i*9)) + 45) and 
            (position.col >= car_col((i*10 + 9) downto (i*10)) and position.col < car_col((i*10 + 9) downto (i*10)) + 60)
        ) else '0';
    end generate;

-- log bools
is_log_generate : for i in 0 to 59 generate
    begin
        is_log(i) <= '1' when (
            (position.row >= log_row((i*9 + 8) downto (i*9)) and position.row < log_row((i*9 + 8) downto (i*9)) + 45) and 
            (position.col >= log_col((i*10 + 9) downto (i*10)) and position.col < log_col((i*10 + 9) downto (i*10)) + 60)
        ) else '0';
    end generate;

-- lilypad bools
is_lilypad_generate : for i in 0 to 19 generate
    begin
        is_lilypad(i) <= '1' when (
            (position.row >= lilypad_row((i*9 + 8) downto (i*9)) and position.row < lilypad_row((i*9 + 8) downto (i*9)) + 45) and 
            (position.col >= lilypad_col((i*10 + 9) downto (i*10)) and position.col < lilypad_col((i*10 + 9) downto (i*10)) + 60)
        ) else '0';
    end generate;

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

-- Use your booleans to choose the color
color <= chicken_rgb        when (is_chicken) and not (chicken_rgb = MAGENTA or chicken_rgb = BLACK)           else
         
         -- lilypads, logs, and cars (will eventually want to give cars priority over chicken, but leave lilypads and logs having precedence under chicken
         
    
--log_rgb_generate : for i in 0 to 59 generate
--    begin
--        log_rgb((i*24 + 23) downto (i*24)) when (is_log(i) = '1' and not (log_rgb((i*24) + 23 downto (i*24))) = MAGENTA)
--    end generate;
         
        log_rgb(23 downto 0) when is_log(0) = '1' and not (log_rgb(23 downto 0) = MAGENTA) else
        log_rgb(47 downto 24) when is_log(1) = '1' and not (log_rgb(47 downto 24) = MAGENTA) else
        log_rgb(71 downto 48) when is_log(2) = '1' and not (log_rgb(71 downto 48) = MAGENTA) else
        log_rgb(95 downto 72) when is_log(3) = '1' and not (log_rgb(95 downto 72) = MAGENTA) else
        log_rgb(119 downto 96) when is_log(4) = '1' and not (log_rgb(119 downto 96) = MAGENTA) else
        log_rgb(143 downto 120) when is_log(5) = '1' and not (log_rgb(143 downto 120) = MAGENTA) else
        log_rgb(167 downto 144) when is_log(6) = '1' and not (log_rgb(167 downto 144) = MAGENTA) else
        log_rgb(191 downto 168) when is_log(7) = '1' and not (log_rgb(191 downto 168) = MAGENTA) else
        log_rgb(215 downto 192) when is_log(8) = '1' and not (log_rgb(215 downto 192) = MAGENTA) else
        log_rgb(239 downto 216) when is_log(9) = '1' and not (log_rgb(239 downto 216) = MAGENTA) else
        
        log_rgb(263 downto 240) when is_log(10) = '1' and not (log_rgb(263 downto 240) = MAGENTA) else
        log_rgb(287 downto 264) when is_log(11) = '1' and not (log_rgb(287 downto 264) = MAGENTA) else
        log_rgb(311 downto 288) when is_log(12) = '1' and not (log_rgb(311 downto 288) = MAGENTA) else
        log_rgb(335 downto 312) when is_log(13) = '1' and not (log_rgb(335 downto 312) = MAGENTA) else
        log_rgb(359 downto 336) when is_log(14) = '1' and not (log_rgb(359 downto 336) = MAGENTA) else
        log_rgb(383 downto 360) when is_log(15) = '1' and not (log_rgb(383 downto 360) = MAGENTA) else
        log_rgb(407 downto 384) when is_log(16) = '1' and not (log_rgb(407 downto 384) = MAGENTA) else
        log_rgb(431 downto 408) when is_log(17) = '1' and not (log_rgb(431 downto 408) = MAGENTA) else
        log_rgb(455 downto 432) when is_log(18) = '1' and not (log_rgb(455 downto 432) = MAGENTA) else
        log_rgb(479 downto 456) when is_log(19) = '1' and not (log_rgb(479 downto 456) = MAGENTA) else
        
        log_rgb(503 downto 480) when is_log(20) = '1' and not (log_rgb(503 downto 480) = MAGENTA) else
        log_rgb(527 downto 504) when is_log(21) = '1' and not (log_rgb(527 downto 504) = MAGENTA) else
        log_rgb(551 downto 528) when is_log(22) = '1' and not (log_rgb(551 downto 528) = MAGENTA) else
        log_rgb(575 downto 552) when is_log(23) = '1' and not (log_rgb(575 downto 552) = MAGENTA) else
        log_rgb(599 downto 576) when is_log(24) = '1' and not (log_rgb(599 downto 576) = MAGENTA) else
        log_rgb(623 downto 600) when is_log(25) = '1' and not (log_rgb(623 downto 600) = MAGENTA) else
        log_rgb(647 downto 624) when is_log(26) = '1' and not (log_rgb(647 downto 624) = MAGENTA) else
        log_rgb(671 downto 648) when is_log(27) = '1' and not (log_rgb(671 downto 648) = MAGENTA) else
        log_rgb(695 downto 672) when is_log(28) = '1' and not (log_rgb(695 downto 672) = MAGENTA) else
        log_rgb(719 downto 696) when is_log(29) = '1' and not (log_rgb(719 downto 696) = MAGENTA) else
        
        log_rgb(743 downto 720) when is_log(30) = '1' and not (log_rgb(743 downto 720) = MAGENTA) else
        log_rgb(767 downto 744) when is_log(31) = '1' and not (log_rgb(767 downto 744) = MAGENTA) else
        log_rgb(791 downto 768) when is_log(32) = '1' and not (log_rgb(791 downto 768) = MAGENTA) else
        log_rgb(815 downto 792) when is_log(33) = '1' and not (log_rgb(815 downto 792) = MAGENTA) else
        log_rgb(839 downto 816) when is_log(34) = '1' and not (log_rgb(839 downto 816) = MAGENTA) else
        log_rgb(863 downto 840) when is_log(35) = '1' and not (log_rgb(863 downto 840) = MAGENTA) else
        log_rgb(887 downto 864) when is_log(36) = '1' and not (log_rgb(887 downto 864) = MAGENTA) else
        log_rgb(911 downto 888) when is_log(37) = '1' and not (log_rgb(911 downto 888) = MAGENTA) else
        log_rgb(935 downto 912) when is_log(38) = '1' and not (log_rgb(935 downto 912) = MAGENTA) else
        log_rgb(959 downto 936) when is_log(39) = '1' and not (log_rgb(959 downto 936) = MAGENTA) else
        
        log_rgb(983 downto 960) when is_log(40) = '1' and not (log_rgb(983 downto 960) = MAGENTA) else
        log_rgb(1007 downto 984) when is_log(41) = '1' and not (log_rgb(1007 downto 984) = MAGENTA) else
        log_rgb(1031 downto 1008) when is_log(42) = '1' and not (log_rgb(1031 downto 1008) = MAGENTA) else
        log_rgb(1055 downto 1032) when is_log(43) = '1' and not (log_rgb(1055 downto 1032) = MAGENTA) else
        log_rgb(1079 downto 1056) when is_log(44) = '1' and not (log_rgb(1079 downto 1056) = MAGENTA) else
        log_rgb(1103 downto 1080) when is_log(45) = '1' and not (log_rgb(1103 downto 1080) = MAGENTA) else
        log_rgb(1127 downto 1104) when is_log(46) = '1' and not (log_rgb(1127 downto 1104) = MAGENTA) else
        log_rgb(1151 downto 1128) when is_log(47) = '1' and not (log_rgb(1151 downto 1128) = MAGENTA) else
        log_rgb(1175 downto 1152) when is_log(48) = '1' and not (log_rgb(1175 downto 1152) = MAGENTA) else
        log_rgb(1199 downto 1176) when is_log(49) = '1' and not (log_rgb(1199 downto 1176) = MAGENTA) else
        
        log_rgb(1223 downto 1200) when is_log(50) = '1' and not (log_rgb(1223 downto 1200) = MAGENTA) else
        log_rgb(1247 downto 1224) when is_log(51) = '1' and not (log_rgb(1247 downto 1224) = MAGENTA) else
        log_rgb(1271 downto 1248) when is_log(52) = '1' and not (log_rgb(1271 downto 1248) = MAGENTA) else
        log_rgb(1295 downto 1272) when is_log(53) = '1' and not (log_rgb(1295 downto 1272) = MAGENTA) else
        log_rgb(1319 downto 1296) when is_log(54) = '1' and not (log_rgb(1319 downto 1296) = MAGENTA) else
        log_rgb(1343 downto 1320) when is_log(55) = '1' and not (log_rgb(1343 downto 1320) = MAGENTA) else
        log_rgb(1367 downto 1344) when is_log(56) = '1' and not (log_rgb(1367 downto 1344) = MAGENTA) else
        log_rgb(1391 downto 1368) when is_log(57) = '1' and not (log_rgb(1391 downto 1368) = MAGENTA) else
        log_rgb(1415 downto 1392) when is_log(58) = '1' and not (log_rgb(1415 downto 1392) = MAGENTA) else
        log_rgb(1439 downto 1416) when is_log(59) = '1' and not (log_rgb(1439 downto 1416) = MAGENTA) else


    
        lilypad_rgb(23 downto 0) when is_lilypad(0) = '1' and not (lilypad_rgb(23 downto 0) = MAGENTA) else
        lilypad_rgb(47 downto 24) when is_lilypad(1) = '1' and not (lilypad_rgb(47 downto 24) = MAGENTA) else
        lilypad_rgb(71 downto 48) when is_lilypad(2) = '1' and not (lilypad_rgb(71 downto 48) = MAGENTA) else
        lilypad_rgb(95 downto 72) when is_lilypad(3) = '1' and not (lilypad_rgb(95 downto 72) = MAGENTA) else
        lilypad_rgb(119 downto 96) when is_lilypad(4) = '1' and not (lilypad_rgb(119 downto 96) = MAGENTA) else
        lilypad_rgb(143 downto 120) when is_lilypad(5) = '1' and not (lilypad_rgb(143 downto 120) = MAGENTA) else
        lilypad_rgb(167 downto 144) when is_lilypad(6) = '1' and not (lilypad_rgb(167 downto 144) = MAGENTA) else
        lilypad_rgb(191 downto 168) when is_lilypad(7) = '1' and not (lilypad_rgb(191 downto 168) = MAGENTA) else
        lilypad_rgb(215 downto 192) when is_lilypad(8) = '1' and not (lilypad_rgb(215 downto 192) = MAGENTA) else
        lilypad_rgb(239 downto 216) when is_lilypad(9) = '1' and not (lilypad_rgb(239 downto 216) = MAGENTA) else
        
        lilypad_rgb(263 downto 240) when is_lilypad(10) = '1' and not (lilypad_rgb(263 downto 240) = MAGENTA) else
        lilypad_rgb(287 downto 264) when is_lilypad(11) = '1' and not (lilypad_rgb(287 downto 264) = MAGENTA) else
        lilypad_rgb(311 downto 288) when is_lilypad(12) = '1' and not (lilypad_rgb(311 downto 288) = MAGENTA) else
        lilypad_rgb(335 downto 312) when is_lilypad(13) = '1' and not (lilypad_rgb(335 downto 312) = MAGENTA) else
        lilypad_rgb(359 downto 336) when is_lilypad(14) = '1' and not (lilypad_rgb(359 downto 336) = MAGENTA) else
        lilypad_rgb(383 downto 360) when is_lilypad(15) = '1' and not (lilypad_rgb(383 downto 360) = MAGENTA) else
        lilypad_rgb(407 downto 384) when is_lilypad(16) = '1' and not (lilypad_rgb(407 downto 384) = MAGENTA) else
        lilypad_rgb(431 downto 408) when is_lilypad(17) = '1' and not (lilypad_rgb(431 downto 408) = MAGENTA) else
        lilypad_rgb(455 downto 432) when is_lilypad(18) = '1' and not (lilypad_rgb(455 downto 432) = MAGENTA) else
        lilypad_rgb(479 downto 456) when is_lilypad(19) = '1' and not (lilypad_rgb(479 downto 456) = MAGENTA) else



         
        car_rgb(23 downto 0) when is_car(0) = '1' and not (car_rgb(23 downto 0) = MAGENTA) else
        car_rgb(47 downto 24) when is_car(1) = '1' and not (car_rgb(47 downto 24) = MAGENTA) else
        car_rgb(71 downto 48) when is_car(2) = '1' and not (car_rgb(71 downto 48) = MAGENTA) else
        car_rgb(95 downto 72) when is_car(3) = '1' and not (car_rgb(95 downto 72) = MAGENTA) else
        car_rgb(119 downto 96) when is_car(4) = '1' and not (car_rgb(119 downto 96) = MAGENTA) else
        car_rgb(143 downto 120) when is_car(5) = '1' and not (car_rgb(143 downto 120) = MAGENTA) else
        car_rgb(167 downto 144) when is_car(6) = '1' and not (car_rgb(167 downto 144) = MAGENTA) else
        car_rgb(191 downto 168) when is_car(7) = '1' and not (car_rgb(191 downto 168) = MAGENTA) else
        car_rgb(215 downto 192) when is_car(8) = '1' and not (car_rgb(215 downto 192) = MAGENTA) else
        car_rgb(239 downto 216) when is_car(9) = '1' and not (car_rgb(239 downto 216) = MAGENTA) else
        
        car_rgb(263 downto 240) when is_car(10) = '1' and not (car_rgb(263 downto 240) = MAGENTA) else
        car_rgb(287 downto 264) when is_car(11) = '1' and not (car_rgb(287 downto 264) = MAGENTA) else
        car_rgb(311 downto 288) when is_car(12) = '1' and not (car_rgb(311 downto 288) = MAGENTA) else
        car_rgb(335 downto 312) when is_car(13) = '1' and not (car_rgb(335 downto 312) = MAGENTA) else
        car_rgb(359 downto 336) when is_car(14) = '1' and not (car_rgb(359 downto 336) = MAGENTA) else
        car_rgb(383 downto 360) when is_car(15) = '1' and not (car_rgb(383 downto 360) = MAGENTA) else
        car_rgb(407 downto 384) when is_car(16) = '1' and not (car_rgb(407 downto 384) = MAGENTA) else
        car_rgb(431 downto 408) when is_car(17) = '1' and not (car_rgb(431 downto 408) = MAGENTA) else
        car_rgb(455 downto 432) when is_car(18) = '1' and not (car_rgb(455 downto 432) = MAGENTA) else
        car_rgb(479 downto 456) when is_car(19) = '1' and not (car_rgb(479 downto 456) = MAGENTA) else
        
        car_rgb(503 downto 480) when is_car(20) = '1' and not (car_rgb(503 downto 480) = MAGENTA) else
        car_rgb(527 downto 504) when is_car(21) = '1' and not (car_rgb(527 downto 504) = MAGENTA) else
        car_rgb(551 downto 528) when is_car(22) = '1' and not (car_rgb(551 downto 528) = MAGENTA) else
        car_rgb(575 downto 552) when is_car(23) = '1' and not (car_rgb(575 downto 552) = MAGENTA) else
        car_rgb(599 downto 576) when is_car(24) = '1' and not (car_rgb(599 downto 576) = MAGENTA) else
        car_rgb(623 downto 600) when is_car(25) = '1' and not (car_rgb(623 downto 600) = MAGENTA) else
        car_rgb(647 downto 624) when is_car(26) = '1' and not (car_rgb(647 downto 624) = MAGENTA) else
        car_rgb(671 downto 648) when is_car(27) = '1' and not (car_rgb(671 downto 648) = MAGENTA) else
        car_rgb(695 downto 672) when is_car(28) = '1' and not (car_rgb(695 downto 672) = MAGENTA) else
        car_rgb(719 downto 696) when is_car(29) = '1' and not (car_rgb(719 downto 696) = MAGENTA) else
        
        car_rgb(743 downto 720) when is_car(30) = '1' and not (car_rgb(743 downto 720) = MAGENTA) else
        car_rgb(767 downto 744) when is_car(31) = '1' and not (car_rgb(767 downto 744) = MAGENTA) else
        car_rgb(791 downto 768) when is_car(32) = '1' and not (car_rgb(791 downto 768) = MAGENTA) else
        car_rgb(815 downto 792) when is_car(33) = '1' and not (car_rgb(815 downto 792) = MAGENTA) else
        car_rgb(839 downto 816) when is_car(34) = '1' and not (car_rgb(839 downto 816) = MAGENTA) else
        car_rgb(863 downto 840) when is_car(35) = '1' and not (car_rgb(863 downto 840) = MAGENTA) else
        car_rgb(887 downto 864) when is_car(36) = '1' and not (car_rgb(887 downto 864) = MAGENTA) else
        car_rgb(911 downto 888) when is_car(37) = '1' and not (car_rgb(911 downto 888) = MAGENTA) else
        car_rgb(935 downto 912) when is_car(38) = '1' and not (car_rgb(935 downto 912) = MAGENTA) else
        car_rgb(959 downto 936) when is_car(39) = '1' and not (car_rgb(959 downto 936) = MAGENTA) else
        
        car_rgb(983 downto 960) when is_car(40) = '1' and not (car_rgb(983 downto 960) = MAGENTA) else
        car_rgb(1007 downto 984) when is_car(41) = '1' and not (car_rgb(1007 downto 984) = MAGENTA) else
        car_rgb(1031 downto 1008) when is_car(42) = '1' and not (car_rgb(1031 downto 1008) = MAGENTA) else
        car_rgb(1055 downto 1032) when is_car(43) = '1' and not (car_rgb(1055 downto 1032) = MAGENTA) else
        car_rgb(1079 downto 1056) when is_car(44) = '1' and not (car_rgb(1079 downto 1056) = MAGENTA) else
        car_rgb(1103 downto 1080) when is_car(45) = '1' and not (car_rgb(1103 downto 1080) = MAGENTA) else
        car_rgb(1127 downto 1104) when is_car(46) = '1' and not (car_rgb(1127 downto 1104) = MAGENTA) else
        car_rgb(1151 downto 1128) when is_car(47) = '1' and not (car_rgb(1151 downto 1128) = MAGENTA) else
        car_rgb(1175 downto 1152) when is_car(48) = '1' and not (car_rgb(1175 downto 1152) = MAGENTA) else
        car_rgb(1199 downto 1176) when is_car(49) = '1' and not (car_rgb(1199 downto 1176) = MAGENTA) else


        

         
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
         
         -- row 17
         water_color        when (row_17 and game_map(17) = "11") else
         road_color         when (row_17 and game_map(17) = "10") else
         dark_grass_color   when (row_17 and game_map(17) = "01") else
         light_grass_color  when (row_17 and game_map(17) = "00") else
         
         -- row 18
         water_color        when (row_18 and game_map(18) = "11") else
         road_color         when (row_18 and game_map(18) = "10") else
         dark_grass_color   when (row_18 and game_map(18) = "01") else
         light_grass_color  when (row_18 and game_map(18) = "00") else
         
         -- row 19
         water_color        when (row_19 and game_map(19) = "11") else
         road_color         when (row_19 and game_map(19) = "10") else
         dark_grass_color   when (row_19 and game_map(19) = "01") else
         light_grass_color  when (row_19 and game_map(19) = "00") else
         
         -- default colors
         BLACK;


        -- debugging
        --led <= std_logic_vector(chicken_row(9 downto 2));
        
        -- last button pressed 1 hot decoder register process
        process (clk)
        begin
            if (rising_edge(clk)) then
                button_pressed <= "1000" when btn(UP)       = '1' else 
                                  "0100" when btn(DOWN)     = '1' else
                                  "0010" when btn(RIGHT)    = '1' else
                                  "0001" when btn(LEFT)     = '1' else
                                  button_pressed;
            end if;
	   end process;
end color_mapper_arch;
