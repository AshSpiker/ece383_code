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
signal car_row      : unsigned(299 downto 0);             -- 6 rows per car, 50 cars
signal car_col      : unsigned(299 downto 0);             -- 6 cols per car, 50 cars
signal car_index    : std_logic_vector(399 downto 0);   -- 8 bits per index, 50 cars
signal car_rgb      : std_logic_vector(1199 downto 0);    -- every car should look the same (for now), so just a 24 bit rgb value


-- lilypad signals
signal is_lilypad       : std_logic_vector(19 downto 0);    -- 20 lilypads
signal lilypad_row      : unsigned(99 downto 0);            -- 5 rows per lilypad
signal lilypad_col      : unsigned(99 downto 0);            -- 5 cols per lilypad 
signal lilypad_index    : std_logic_vector(159 downto 0);   -- 8 bits per
signal lilypad_rgb      : std_logic_vector(479 downto 0);    -- all look the same

-- log signals
signal is_log           : std_logic_vector(59 downto 0);    -- 60 log sprites
signal log_row          : unsigned(299 downto 0);           -- 5 rows per log
signal log_col          : unsigned(419 downto 0);           -- 7 cols per log
signal log_index        : std_logic_vector(479 downto 0);   -- 8 bits per
signal log_rgb          : std_logic_vector(1439 downto 0);    -- all look the same

-- location arrays (refers to what row 

begin
----------------------------------------------------------------------------------------------------------------------
-- 50 car instationations --------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
car_0 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(5 downto 0),
        col_addr => position.col(5 downto 0) - car_col(5 downto 0),
        color_index => car_index(7 downto 0)
    );
    
car_1 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(11 downto 6),
        col_addr => position.col(5 downto 0) - car_col(11 downto 6),
        color_index => car_index(15 downto 8)
    );
    
car_2 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(17 downto 12),
        col_addr => position.col(5 downto 0) - car_col(17 downto 12),
        color_index => car_index(23 downto 16)
    );

car_3 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(23 downto 18),
        col_addr => position.col(5 downto 0) - car_col(23 downto 18),
        color_index => car_index(31 downto 24)
    );

car_4 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(29 downto 24),
        col_addr => position.col(5 downto 0) - car_col(29 downto 24),
        color_index => car_index(39 downto 32)
    );

car_5 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(35 downto 30),
        col_addr => position.col(5 downto 0) - car_col(35 downto 30),
        color_index => car_index(47 downto 40)
    );
    
car_6 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(41 downto 36),
        col_addr => position.col(5 downto 0) - car_col(41 downto 36),
        color_index => car_index(55 downto 48)
    );
    
car_7 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(47 downto 42),
        col_addr => position.col(5 downto 0) - car_col(47 downto 42),
        color_index => car_index(63 downto 56)
    );
    
car_8 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(53 downto 48),
        col_addr => position.col(5 downto 0) - car_col(53 downto 48),
        color_index => car_index(71 downto 64)
    );

car_9 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(59 downto 54),
        col_addr => position.col(5 downto 0) - car_col(59 downto 54),
        color_index => car_index(79 downto 72)
    );

car_10 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(65 downto 60),
        col_addr => position.col(5 downto 0) - car_col(65 downto 60),
        color_index => car_index(87 downto 80)
    );

car_11 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(71 downto 66),
        col_addr => position.col(5 downto 0) - car_col(71 downto 66),
        color_index => car_index(95 downto 88)
    );
    
car_12 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(77 downto 72),
        col_addr => position.col(5 downto 0) - car_col(77 downto 72),
        color_index => car_index(103 downto 96)
    );
    
car_13 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(83 downto 78),
        col_addr => position.col(5 downto 0) - car_col(83 downto 78),
        color_index => car_index(111 downto 104)
    );
    
car_14 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(89 downto 84),
        col_addr => position.col(5 downto 0) - car_col(89 downto 84),
        color_index => car_index(119 downto 112)
    );
    
car_15 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(95 downto 90),
        col_addr => position.col(5 downto 0) - car_col(95 downto 90),
        color_index => car_index(127 downto 120)
    );

car_16 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(101 downto 96),
        col_addr => position.col(5 downto 0) - car_col(101 downto 96),
        color_index => car_index(135 downto 128)
    );

car_17 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(107 downto 102),
        col_addr => position.col(5 downto 0) - car_col(107 downto 102),
        color_index => car_index(143 downto 136)
    );

car_18 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(113 downto 108),
        col_addr => position.col(5 downto 0) - car_col(113 downto 108),
        color_index => car_index(151 downto 144)
    );
    
car_19 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(119 downto 114),
        col_addr => position.col(5 downto 0) - car_col(119 downto 114),
        color_index => car_index(159 downto 152)
    );
    
car_20 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(125 downto 120),
        col_addr => position.col(5 downto 0) - car_col(125 downto 120),
        color_index => car_index(167 downto 160)
    );
    
car_21 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(131 downto 126),
        col_addr => position.col(5 downto 0) - car_col(131 downto 126),
        color_index => car_index(175 downto 168)
    );
    
car_22 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(137 downto 132),
        col_addr => position.col(5 downto 0) - car_col(137 downto 132),
        color_index => car_index(183 downto 176)
    );

car_23 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(143 downto 138),
        col_addr => position.col(5 downto 0) - car_col(143 downto 138),
        color_index => car_index(191 downto 184)
    );

car_24 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(149 downto 144),
        col_addr => position.col(5 downto 0) - car_col(149 downto 144),
        color_index => car_index(199 downto 192)
    );

car_25 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(155 downto 150),
        col_addr => position.col(5 downto 0) - car_col(155 downto 150),
        color_index => car_index(207 downto 200)
    );
    
car_26 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(161 downto 156),
        col_addr => position.col(5 downto 0) - car_col(161 downto 156),
        color_index => car_index(215 downto 208)
    );
    
car_27 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(167 downto 162),
        col_addr => position.col(5 downto 0) - car_col(167 downto 162),
        color_index => car_index(223 downto 216)
    );
    
car_28 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(173 downto 168),
        col_addr => position.col(5 downto 0) - car_col(173 downto 168),
        color_index => car_index(231 downto 224)
    );
    
car_29 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(179 downto 174),
        col_addr => position.col(5 downto 0) - car_col(179 downto 174),
        color_index => car_index(239 downto 232)
    );

car_30 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(185 downto 180),
        col_addr => position.col(5 downto 0) - car_col(185 downto 180),
        color_index => car_index(247 downto 240)
    );
    
car_31 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(191 downto 186),
        col_addr => position.col(5 downto 0) - car_col(191 downto 186),
        color_index => car_index(255 downto 248)
    );
    
car_32 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(197 downto 192),
        col_addr => position.col(5 downto 0) - car_col(197 downto 192),
        color_index => car_index(263 downto 256)
    );
    
car_33 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(203 downto 198),
        col_addr => position.col(5 downto 0) - car_col(203 downto 198),
        color_index => car_index(271 downto 264)
    );
    
car_34 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(209 downto 204),
        col_addr => position.col(5 downto 0) - car_col(209 downto 204),
        color_index => car_index(279 downto 272)
    );

car_35 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(215 downto 210),
        col_addr => position.col(5 downto 0) - car_col(215 downto 210),
        color_index => car_index(287 downto 280)
    );

car_36 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(221 downto 216),
        col_addr => position.col(5 downto 0) - car_col(221 downto 216),
        color_index => car_index(295 downto 288)
    );

car_37 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(227 downto 222),
        col_addr => position.col(5 downto 0) - car_col(227 downto 222),
        color_index => car_index(303 downto 296)
    );
    
car_38 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(233 downto 228),
        col_addr => position.col(5 downto 0) - car_col(233 downto 228),
        color_index => car_index(311 downto 304)
    );
    
car_39 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(239 downto 234),
        col_addr => position.col(5 downto 0) - car_col(239 downto 234),
        color_index => car_index(319 downto 312)
    );
    
car_40 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(245 downto 240),
        col_addr => position.col(5 downto 0) - car_col(245 downto 240),
        color_index => car_index(327 downto 320)
    );
    
car_41 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(251 downto 246),
        col_addr => position.col(5 downto 0) - car_col(251 downto 246),
        color_index => car_index(335 downto 328)
    );

car_42 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(257 downto 252),
        col_addr => position.col(5 downto 0) - car_col(257 downto 252),
        color_index => car_index(343 downto 336)
    );

car_43 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(263 downto 258),
        col_addr => position.col(5 downto 0) - car_col(263 downto 258),
        color_index => car_index(351 downto 344)
    );

car_44 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(269 downto 264),
        col_addr => position.col(5 downto 0) - car_col(269 downto 264),
        color_index => car_index(359 downto 352)
    );
    
car_45 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(275 downto 270),
        col_addr => position.col(5 downto 0) - car_col(275 downto 270),
        color_index => car_index(367 downto 360)
    );
    
car_46 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(281 downto 276),
        col_addr => position.col(5 downto 0) - car_col(281 downto 276),
        color_index => car_index(375 downto 368)
    );
    
car_47 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(287 downto 282),
        col_addr => position.col(5 downto 0) - car_col(287 downto 282),
        color_index => car_index(383 downto 376)
    );
    
car_48 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(293 downto 288),
        col_addr => position.col(5 downto 0) - car_col(293 downto 288),
        color_index => car_index(391 downto 384)
    );

car_49 : car_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(5 downto 0) - car_row(299 downto 294),
        col_addr => position.col(5 downto 0) - car_col(299 downto 294),
        color_index => car_index(399 downto 392)
    );
    
    
----------------------------------------------------------------------------------------------------------------------
-- END 50 car instationations ----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
-- 60 log instationations --------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
log_0 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(4 downto 0),
        col_addr => position.col(6 downto 0) - log_col(6 downto 0),
        color_index => log_index(7 downto 0)
    );

log_1 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(9 downto 5),
        col_addr => position.col(6 downto 0) - log_col(13 downto 7),
        color_index => log_index(15 downto 8)
    );

log_2 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(14 downto 10),
        col_addr => position.col(6 downto 0) - log_col(20 downto 14),
        color_index => log_index(23 downto 16)
    );

log_3 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(19 downto 15),
        col_addr => position.col(6 downto 0) - log_col(27 downto 21),
        color_index => log_index(31 downto 24)
    );

log_4 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(24 downto 20),
        col_addr => position.col(6 downto 0) - log_col(34 downto 28),
        color_index => log_index(39 downto 32)
    );

log_5 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(29 downto 25),
        col_addr => position.col(6 downto 0) - log_col(41 downto 35),
        color_index => log_index(47 downto 40)
    );

log_6 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(34 downto 30),
        col_addr => position.col(6 downto 0) - log_col(48 downto 42),
        color_index => log_index(55 downto 48)
    );

log_7 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(39 downto 35),
        col_addr => position.col(6 downto 0) - log_col(55 downto 49),
        color_index => log_index(63 downto 56)
    );

log_8 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(44 downto 40),
        col_addr => position.col(6 downto 0) - log_col(62 downto 56),
        color_index => log_index(71 downto 64)
    );

log_9 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(49 downto 45),
        col_addr => position.col(6 downto 0) - log_col(69 downto 63),
        color_index => log_index(79 downto 72)
    );

log_10 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(54 downto 50),
        col_addr => position.col(6 downto 0) - log_col(76 downto 70),
        color_index => log_index(87 downto 80)
    );

log_11 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(59 downto 55),
        col_addr => position.col(6 downto 0) - log_col(83 downto 77),
        color_index => log_index(95 downto 88)
    );

log_12 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(64 downto 60),
        col_addr => position.col(6 downto 0) - log_col(90 downto 84),
        color_index => log_index(103 downto 96)
    );

log_13 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(69 downto 65),
        col_addr => position.col(6 downto 0) - log_col(97 downto 91),
        color_index => log_index(111 downto 104)
    );

log_14 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(74 downto 70),
        col_addr => position.col(6 downto 0) - log_col(104 downto 98),
        color_index => log_index(119 downto 112)
    );

log_15 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(79 downto 75),
        col_addr => position.col(6 downto 0) - log_col(111 downto 105),
        color_index => log_index(127 downto 120)
    );

log_16 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(84 downto 80),
        col_addr => position.col(6 downto 0) - log_col(118 downto 112),
        color_index => log_index(135 downto 128)
    );

log_17 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(89 downto 85),
        col_addr => position.col(6 downto 0) - log_col(125 downto 119),
        color_index => log_index(143 downto 136)
    );

log_18 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(94 downto 90),
        col_addr => position.col(6 downto 0) - log_col(132 downto 126),
        color_index => log_index(151 downto 144)
    );

log_19 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(99 downto 95),
        col_addr => position.col(6 downto 0) - log_col(139 downto 133),
        color_index => log_index(159 downto 152)
    );

log_20 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(104 downto 100),
        col_addr => position.col(6 downto 0) - log_col(146 downto 140),
        color_index => log_index(167 downto 160)
    );

log_21 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(109 downto 105),
        col_addr => position.col(6 downto 0) - log_col(153 downto 147),
        color_index => log_index(175 downto 168)
    );

log_22 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(114 downto 110),
        col_addr => position.col(6 downto 0) - log_col(160 downto 154),
        color_index => log_index(183 downto 176)
    );

log_23 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(119 downto 115),
        col_addr => position.col(6 downto 0) - log_col(167 downto 161),
        color_index => log_index(191 downto 184)
    );

log_24 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(124 downto 120),
        col_addr => position.col(6 downto 0) - log_col(174 downto 168),
        color_index => log_index(199 downto 192)
    );

log_25 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(129 downto 125),
        col_addr => position.col(6 downto 0) - log_col(181 downto 175),
        color_index => log_index(207 downto 200)
    );

log_26 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(134 downto 130),
        col_addr => position.col(6 downto 0) - log_col(188 downto 182),
        color_index => log_index(215 downto 208)
    );

log_27 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(139 downto 135),
        col_addr => position.col(6 downto 0) - log_col(195 downto 189),
        color_index => log_index(223 downto 216)
    );

log_28 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(144 downto 140),
        col_addr => position.col(6 downto 0) - log_col(202 downto 196),
        color_index => log_index(231 downto 224)
    );

log_29 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(149 downto 145),
        col_addr => position.col(6 downto 0) - log_col(209 downto 203),
        color_index => log_index(239 downto 232)
    );

log_30 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(154 downto 150),
        col_addr => position.col(6 downto 0) - log_col(216 downto 210),
        color_index => log_index(247 downto 240)
    );

log_31 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(159 downto 155),
        col_addr => position.col(6 downto 0) - log_col(223 downto 217),
        color_index => log_index(255 downto 248)
    );

log_32 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(164 downto 160),
        col_addr => position.col(6 downto 0) - log_col(230 downto 224),
        color_index => log_index(263 downto 256)
    );

log_33 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(169 downto 165),
        col_addr => position.col(6 downto 0) - log_col(237 downto 231),
        color_index => log_index(271 downto 264)
    );

log_34 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(174 downto 170),
        col_addr => position.col(6 downto 0) - log_col(244 downto 238),
        color_index => log_index(279 downto 272)
    );

log_35 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(179 downto 175),
        col_addr => position.col(6 downto 0) - log_col(251 downto 245),
        color_index => log_index(287 downto 280)
    );

log_36 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(184 downto 180),
        col_addr => position.col(6 downto 0) - log_col(258 downto 252),
        color_index => log_index(295 downto 288)
    );

log_37 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(189 downto 185),
        col_addr => position.col(6 downto 0) - log_col(265 downto 259),
        color_index => log_index(303 downto 296)
    );

log_38 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(194 downto 190),
        col_addr => position.col(6 downto 0) - log_col(272 downto 266),
        color_index => log_index(311 downto 304)
    );

log_39 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(199 downto 195),
        col_addr => position.col(6 downto 0) - log_col(279 downto 273),
        color_index => log_index(319 downto 312)
    );

log_40 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(204 downto 200),
        col_addr => position.col(6 downto 0) - log_col(286 downto 280),
        color_index => log_index(327 downto 320)
    );

log_41 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(209 downto 205),
        col_addr => position.col(6 downto 0) - log_col(293 downto 287),
        color_index => log_index(335 downto 328)
    );

log_42 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(214 downto 210),
        col_addr => position.col(6 downto 0) - log_col(300 downto 294),
        color_index => log_index(343 downto 336)
    );

log_43 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(219 downto 215),
        col_addr => position.col(6 downto 0) - log_col(307 downto 301),
        color_index => log_index(351 downto 344)
    );
    
log_44 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(224 downto 220),
        col_addr => position.col(6 downto 0) - log_col(314 downto 308),
        color_index => log_index(359 downto 352)
    );

log_45 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(229 downto 225),
        col_addr => position.col(6 downto 0) - log_col(321 downto 315),
        color_index => log_index(367 downto 360)
    );

log_46 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(234 downto 230),
        col_addr => position.col(6 downto 0) - log_col(328 downto 322),
        color_index => log_index(375 downto 368)
    );

log_47 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(239 downto 235),
        col_addr => position.col(6 downto 0) - log_col(335 downto 329),
        color_index => log_index(383 downto 376)
    );

log_48 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(244 downto 240),
        col_addr => position.col(6 downto 0) - log_col(342 downto 336),
        color_index => log_index(391 downto 384)
    );

log_49 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(249 downto 245),
        col_addr => position.col(6 downto 0) - log_col(349 downto 343),
        color_index => log_index(399 downto 392)
    );

log_50 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(254 downto 250),
        col_addr => position.col(6 downto 0) - log_col(356 downto 350),
        color_index => log_index(407 downto 400)
    );

log_51 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(259 downto 255),
        col_addr => position.col(6 downto 0) - log_col(363 downto 357),
        color_index => log_index(415 downto 408)
    );

log_52 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(264 downto 260),
        col_addr => position.col(6 downto 0) - log_col(370 downto 364),
        color_index => log_index(423 downto 416)
    );

log_53 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(269 downto 265),
        col_addr => position.col(6 downto 0) - log_col(377 downto 371),
        color_index => log_index(431 downto 424)
    );

log_54 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(274 downto 270),
        col_addr => position.col(6 downto 0) - log_col(384 downto 378),
        color_index => log_index(439 downto 432)
    );

log_55 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(279 downto 275),
        col_addr => position.col(6 downto 0) - log_col(391 downto 385),
        color_index => log_index(447 downto 440)
    );

log_56 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(284 downto 280),
        col_addr => position.col(6 downto 0) - log_col(398 downto 392),
        color_index => log_index(455 downto 448)
    );

log_57 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(289 downto 285),
        col_addr => position.col(6 downto 0) - log_col(405 downto 399),
        color_index => log_index(463 downto 456)
    );

log_58 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(294 downto 290),
        col_addr => position.col(6 downto 0) - log_col(412 downto 406),
        color_index => log_index(471 downto 464)
    );

log_59 : log_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - log_row(299 downto 295),
        col_addr => position.col(6 downto 0) - log_col(419 downto 413),
        color_index => log_index(479 downto 472)
    );

----------------------------------------------------------------------------------------------------------------------
-- END 60 log instationations ----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
-- 20 lilypad instationations ----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
lilypad_0 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(4 downto 0),
        col_addr => position.col(4 downto 0) - lilypad_col(4 downto 0),
        color_index => lilypad_index(7 downto 0)
    );

lilypad_1 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(9 downto 5),
        col_addr => position.col(4 downto 0) - lilypad_col(9 downto 5),
        color_index => lilypad_index(15 downto 8)
    );

lilypad_2 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(14 downto 10),
        col_addr => position.col(4 downto 0) - lilypad_col(14 downto 10),
        color_index => lilypad_index(23 downto 16)
    );

lilypad_3 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(19 downto 15),
        col_addr => position.col(4 downto 0) - lilypad_col(19 downto 15),
        color_index => lilypad_index(31 downto 24)
    );

lilypad_4 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(24 downto 20),
        col_addr => position.col(4 downto 0) - lilypad_col(24 downto 20),
        color_index => lilypad_index(39 downto 32)
    );

lilypad_5 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(29 downto 25),
        col_addr => position.col(4 downto 0) - lilypad_col(29 downto 25),
        color_index => lilypad_index(47 downto 40)
    );

lilypad_6 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(34 downto 30),
        col_addr => position.col(4 downto 0) - lilypad_col(34 downto 30),
        color_index => lilypad_index(55 downto 48)
    );

lilypad_7 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(39 downto 35),
        col_addr => position.col(4 downto 0) - lilypad_col(39 downto 35),
        color_index => lilypad_index(63 downto 56)
    );

lilypad_8 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(44 downto 40),
        col_addr => position.col(4 downto 0) - lilypad_col(44 downto 40),
        color_index => lilypad_index(71 downto 64)
    );

lilypad_9 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(49 downto 45),
        col_addr => position.col(4 downto 0) - lilypad_col(49 downto 45),
        color_index => lilypad_index(79 downto 72)
    );

lilypad_10 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(54 downto 50),
        col_addr => position.col(4 downto 0) - lilypad_col(54 downto 50),
        color_index => lilypad_index(87 downto 80)
    );

lilypad_11 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(59 downto 55),
        col_addr => position.col(4 downto 0) - lilypad_col(59 downto 55),
        color_index => lilypad_index(95 downto 88)
    );

lilypad_12 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(64 downto 60),
        col_addr => position.col(4 downto 0) - lilypad_col(64 downto 60),
        color_index => lilypad_index(103 downto 96)
    );

lilypad_13 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(69 downto 65),
        col_addr => position.col(4 downto 0) - lilypad_col(69 downto 65),
        color_index => lilypad_index(111 downto 104)
    );

lilypad_14 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(74 downto 70),
        col_addr => position.col(4 downto 0) - lilypad_col(74 downto 70),
        color_index => lilypad_index(119 downto 112)
    );

lilypad_15 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(79 downto 75),
        col_addr => position.col(4 downto 0) - lilypad_col(79 downto 75),
        color_index => lilypad_index(127 downto 120)
    );

lilypad_16 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(84 downto 80),
        col_addr => position.col(4 downto 0) - lilypad_col(84 downto 80),
        color_index => lilypad_index(135 downto 128)
    );

lilypad_17 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(89 downto 85),
        col_addr => position.col(4 downto 0) - lilypad_col(89 downto 85),
        color_index => lilypad_index(143 downto 136)
    );

lilypad_18 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(94 downto 90),
        col_addr => position.col(4 downto 0) - lilypad_col(94 downto 90),
        color_index => lilypad_index(151 downto 144)
    );

lilypad_19 : lilypad_index_rom
    port map(
        clk => clk,
        en => '1',
        row_addr => position.row(4 downto 0) - lilypad_row(99 downto 95),
        col_addr => position.col(4 downto 0) - lilypad_col(99 downto 95),
        color_index => lilypad_index(159 downto 152)
    );


----------------------------------------------------------------------------------------------------------------------
-- END 20 lilypad instationations ------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- 4 different directions of chicken sprite rom instationans 
chicken_forward : chicken_forward_index_rom
    port map (
        clk => clk,
        en => '1',
        row_addr => (position.row(4 downto 0) - unsigned(chicken_row(4 downto 0))),
        col_addr => (position.col(4 downto 0) - unsigned(chicken_col(4 downto 0))),
        color_index => chicken_forward_out
    );
    
chicken_backward : chicken_backward_index_rom
    port map (
        clk => clk,
        en => '1',
        row_addr => (position.row(4 downto 0) - unsigned(chicken_row(4 downto 0))),
        col_addr => (position.col(4 downto 0) - unsigned(chicken_col(4 downto 0))),
        color_index => chicken_backward_out
    );
    
chicken_left : chicken_left_index_rom
    port map (
        clk => clk,
        en => '1',
        row_addr => (position.row(4 downto 0) - unsigned(chicken_row(4 downto 0))),
        col_addr => (position.col(4 downto 0) - unsigned(chicken_col(4 downto 0))),
        color_index => chicken_left_out
    );
    
chicken_right : chicken_right_index_rom
    port map (
        clk => clk,
        en => '1',
        row_addr => (position.row(4 downto 0) - unsigned(chicken_row(4 downto 0))),
        col_addr => (position.col(4 downto 0) - unsigned(chicken_col(4 downto 0))),
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
        clk => clk,
        en => '1',
        color_index => chicken_index,
        rgb => chicken_rgb
    );
    
-- log color instations 
log_0_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(7 downto 0),
        rgb => log_rgb(23 downto 0)
    );

log_1_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(15 downto 8),
        rgb => log_rgb(47 downto 24)
    );

log_2_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(23 downto 16),
        rgb => log_rgb(71 downto 48)
    );

log_3_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(31 downto 24),
        rgb => log_rgb(95 downto 72)
    );

log_4_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(39 downto 32),
        rgb => log_rgb(119 downto 96)
    );

log_5_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(47 downto 40),
        rgb => log_rgb(143 downto 120)
    );

log_6_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(55 downto 48),
        rgb => log_rgb(167 downto 144)
    );

log_7_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(63 downto 56),
        rgb => log_rgb(191 downto 168)
    );

log_8_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(71 downto 64),
        rgb => log_rgb(215 downto 192)
    );

log_9_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(79 downto 72),
        rgb => log_rgb(239 downto 216)
    );

log_10_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(87 downto 80),
        rgb => log_rgb(263 downto 240)
    );

log_11_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(95 downto 88),
        rgb => log_rgb(287 downto 264)
    );

log_12_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(103 downto 96),
        rgb => log_rgb(311 downto 288)
    );

log_13_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(111 downto 104),
        rgb => log_rgb(335 downto 312)
    );

log_14_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(119 downto 112),
        rgb => log_rgb(359 downto 336)
    );

log_15_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(127 downto 120),
        rgb => log_rgb(383 downto 360)
    );

log_16_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(135 downto 128),
        rgb => log_rgb(407 downto 384)
    );

log_17_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(143 downto 136),
        rgb => log_rgb(431 downto 408)
    );

log_18_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(151 downto 144),
        rgb => log_rgb(455 downto 432)
    );

log_19_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(159 downto 152),
        rgb => log_rgb(479 downto 456)
    );

log_20_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(167 downto 160),
        rgb => log_rgb(503 downto 480)
    );

log_21_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(175 downto 168),
        rgb => log_rgb(527 downto 504)
    );

log_22_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(183 downto 176),
        rgb => log_rgb(551 downto 528)
    );

log_23_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(191 downto 184),
        rgb => log_rgb(575 downto 552)
    );

log_24_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(199 downto 192),
        rgb => log_rgb(599 downto 576)
    );

log_25_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(207 downto 200),
        rgb => log_rgb(623 downto 600)
    );

log_26_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(215 downto 208),
        rgb => log_rgb(647 downto 624)
    );

log_27_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(223 downto 216),
        rgb => log_rgb(671 downto 648)
    );

log_28_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(231 downto 224),
        rgb => log_rgb(695 downto 672)
    );

log_29_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(239 downto 232),
        rgb => log_rgb(719 downto 696)
    );

log_30_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(247 downto 240),
        rgb => log_rgb(743 downto 720)
    );

log_31_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(255 downto 248),
        rgb => log_rgb(767 downto 744)
    );

log_32_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(263 downto 256),
        rgb => log_rgb(791 downto 768)
    );

log_33_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(271 downto 264),
        rgb => log_rgb(815 downto 792)
    );

log_34_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(279 downto 272),
        rgb => log_rgb(839 downto 816)
    );

log_35_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(287 downto 280),
        rgb => log_rgb(863 downto 840)
    );

log_36_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(295 downto 288),
        rgb => log_rgb(887 downto 864)
    );

log_37_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(303 downto 296),
        rgb => log_rgb(911 downto 888)
    );

log_38_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(311 downto 304),
        rgb => log_rgb(935 downto 912)
    );

log_39_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(319 downto 312),
        rgb => log_rgb(959 downto 936)
    );

log_40_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(327 downto 320),
        rgb => log_rgb(983 downto 960)
    );

log_41_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(335 downto 328),
        rgb => log_rgb(1007 downto 984)
    );

log_42_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(343 downto 336),
        rgb => log_rgb(1031 downto 1008)
    );

log_43_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(351 downto 344),
        rgb => log_rgb(1055 downto 1032)
    );

log_44_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(359 downto 352),
        rgb => log_rgb(1079 downto 1056)
    );

log_45_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(367 downto 360),
        rgb => log_rgb(1103 downto 1080)
    );

log_46_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(375 downto 368),
        rgb => log_rgb(1127 downto 1104)
    );

log_47_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(383 downto 376),
        rgb => log_rgb(1151 downto 1128)
    );

log_48_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(391 downto 384),
        rgb => log_rgb(1175 downto 1152)
    );

log_49_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(399 downto 392),
        rgb => log_rgb(1199 downto 1176)
    );

log_50_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(407 downto 400),
        rgb => log_rgb(1223 downto 1200)
    );

log_51_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(415 downto 408),
        rgb => log_rgb(1247 downto 1224)
    );

log_52_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(423 downto 416),
        rgb => log_rgb(1271 downto 1248)
    );

log_53_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(431 downto 424),
        rgb => log_rgb(1295 downto 1272)
    );

log_54_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(439 downto 432),
        rgb => log_rgb(1319 downto 1296)
    );

log_55_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(447 downto 440),
        rgb => log_rgb(1343 downto 1320)
    );

log_56_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(455 downto 448),
        rgb => log_rgb(1367 downto 1344)
    );

log_57_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(463 downto 456),
        rgb => log_rgb(1391 downto 1368)
    );

log_58_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(471 downto 464),
        rgb => log_rgb(1415 downto 1392)
    );

log_59_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => log_index(479 downto 472),
        rgb => log_rgb(1439 downto 1416)
    );

   
-- lily pad color palletes 
lilypad_0_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(7 downto 0),
        rgb => lilypad_rgb(23 downto 0)
    );

lilypad_1_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(15 downto 8),
        rgb => lilypad_rgb(47 downto 24)
    );

lilypad_2_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(23 downto 16),
        rgb => lilypad_rgb(71 downto 48)
    );

lilypad_3_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(31 downto 24),
        rgb => lilypad_rgb(95 downto 72)
    );

lilypad_4_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(39 downto 32),
        rgb => lilypad_rgb(119 downto 96)
    );

lilypad_5_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(47 downto 40),
        rgb => lilypad_rgb(143 downto 120)
    );

lilypad_6_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(55 downto 48),
        rgb => lilypad_rgb(167 downto 144)
    );

lilypad_7_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(63 downto 56),
        rgb => lilypad_rgb(191 downto 168)
    );

lilypad_8_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(71 downto 64),
        rgb => lilypad_rgb(215 downto 192)
    );

lilypad_9_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(79 downto 72),
        rgb => lilypad_rgb(239 downto 216)
    );

lilypad_10_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(87 downto 80),
        rgb => lilypad_rgb(263 downto 240)
    );

lilypad_11_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(95 downto 88),
        rgb => lilypad_rgb(287 downto 264)
    );

lilypad_12_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(103 downto 96),
        rgb => lilypad_rgb(311 downto 288)
    );

lilypad_13_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(111 downto 104),
        rgb => lilypad_rgb(335 downto 312)
    );

lilypad_14_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(119 downto 112),
        rgb => lilypad_rgb(359 downto 336)
    );

lilypad_15_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(127 downto 120),
        rgb => lilypad_rgb(383 downto 360)
    );

lilypad_16_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(135 downto 128),
        rgb => lilypad_rgb(407 downto 384)
    );

lilypad_17_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(143 downto 136),
        rgb => lilypad_rgb(431 downto 408)
    );

lilypad_18_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(151 downto 144),
        rgb => lilypad_rgb(455 downto 432)
    );

lilypad_19_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => lilypad_index(159 downto 152),
        rgb => lilypad_rgb(479 downto 456)
    );


-- car color palltets 
    
car_0_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(7 downto 0),
        rgb => car_rgb(23 downto 0)
    );

car_1_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(15 downto 8),
        rgb => car_rgb(47 downto 24)
    );

car_2_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(23 downto 16),
        rgb => car_rgb(71 downto 48)
    );

car_3_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(31 downto 24),
        rgb => car_rgb(95 downto 72)
    );

car_4_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(39 downto 32),
        rgb => car_rgb(119 downto 96)
    );

car_5_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(47 downto 40),
        rgb => car_rgb(143 downto 120)
    );

car_6_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(55 downto 48),
        rgb => car_rgb(167 downto 144)
    );

car_7_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(63 downto 56),
        rgb => car_rgb(191 downto 168)
    );

car_8_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(71 downto 64),
        rgb => car_rgb(215 downto 192)
    );

car_9_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(79 downto 72),
        rgb => car_rgb(239 downto 216)
    );

car_10_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(87 downto 80),
        rgb => car_rgb(263 downto 240)
    );

car_11_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(95 downto 88),
        rgb => car_rgb(287 downto 264)
    );

car_12_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(103 downto 96),
        rgb => car_rgb(311 downto 288)
    );

car_13_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(111 downto 104),
        rgb => car_rgb(335 downto 312)
    );

car_14_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(119 downto 112),
        rgb => car_rgb(359 downto 336)
    );

car_15_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(127 downto 120),
        rgb => car_rgb(383 downto 360)
    );

car_16_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(135 downto 128),
        rgb => car_rgb(407 downto 384)
    );

car_17_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(143 downto 136),
        rgb => car_rgb(431 downto 408)
    );

car_18_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(151 downto 144),
        rgb => car_rgb(455 downto 432)
    );

car_19_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(159 downto 152),
        rgb => car_rgb(479 downto 456)
    );

car_20_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(167 downto 160),
        rgb => car_rgb(503 downto 480)
    );

car_21_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(175 downto 168),
        rgb => car_rgb(527 downto 504)
    );

car_22_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(183 downto 176),
        rgb => car_rgb(551 downto 528)
    );

car_23_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(191 downto 184),
        rgb => car_rgb(575 downto 552)
    );

car_24_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(199 downto 192),
        rgb => car_rgb(599 downto 576)
    );

car_25_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(207 downto 200),
        rgb => car_rgb(623 downto 600)
    );

car_26_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(215 downto 208),
        rgb => car_rgb(647 downto 624)
    );

car_27_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(223 downto 216),
        rgb => car_rgb(671 downto 648)
    );

car_28_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(231 downto 224),
        rgb => car_rgb(695 downto 672)
    );

car_29_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(239 downto 232),
        rgb => car_rgb(719 downto 696)
    );

car_30_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(247 downto 240),
        rgb => car_rgb(743 downto 720)
    );

car_31_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(255 downto 248),
        rgb => car_rgb(767 downto 744)
    );

car_32_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(263 downto 256),
        rgb => car_rgb(791 downto 768)
    );

car_33_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(271 downto 264),
        rgb => car_rgb(815 downto 792)
    );

car_34_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(279 downto 272),
        rgb => car_rgb(839 downto 816)
    );

car_35_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(287 downto 280),
        rgb => car_rgb(863 downto 840)
    );

car_36_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(295 downto 288),
        rgb => car_rgb(887 downto 864)
    );

car_37_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(303 downto 296),
        rgb => car_rgb(911 downto 888)
    );

car_38_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(311 downto 304),
        rgb => car_rgb(935 downto 912)
    );

car_39_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(319 downto 312),
        rgb => car_rgb(959 downto 936)
    );

car_40_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(327 downto 320),
        rgb => car_rgb(983 downto 960)
    );

car_41_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(335 downto 328),
        rgb => car_rgb(1007 downto 984)
    );

car_42_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(343 downto 336),
        rgb => car_rgb(1031 downto 1008)
    );

car_43_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(351 downto 344),
        rgb => car_rgb(1055 downto 1032)
    );

car_44_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(359 downto 352),
        rgb => car_rgb(1079 downto 1056)
    );

car_45_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(367 downto 360),
        rgb => car_rgb(1103 downto 1080)
    );

car_46_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(375 downto 368),
        rgb => car_rgb(1127 downto 1104)
    );

car_47_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(383 downto 376),
        rgb => car_rgb(1151 downto 1128)
    );

car_48_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(391 downto 384),
        rgb => car_rgb(1175 downto 1152)
    );

car_49_color : clipart2902856_palette
    port map (
        clk => clk,
        en => '1',
        color_index => car_index(399 downto 392),
        rgb => car_rgb(1199 downto 1176)
    );

    
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
is_car(0)   <= '1' when ((position.row >= car_row(5 downto 0) and position.row < car_row(5 downto 0) + 45) and ((position.col >= car_col(5 downto 0) and position.col < car_col(5 downto 0) + 60))) else '0';
is_car(1)   <= '1' when ((position.row >= car_row(11 downto 6) and position.row < car_row(11 downto 6) + 45) and ((position.col >= car_col(11 downto 6) and position.col < car_col(11 downto 6) + 60))) else '0';
is_car(2)   <= '1' when ((position.row >= car_row(17 downto 12) and position.row < car_row(17 downto 12) + 45) and ((position.col >= car_col(17 downto 12) and position.col < car_col(17 downto 12) + 60))) else '0';
is_car(3)   <= '1' when ((position.row >= car_row(23 downto 18) and position.row < car_row(23 downto 18) + 45) and ((position.col >= car_col(23 downto 18) and position.col < car_col(23 downto 18) + 60))) else '0';
is_car(4)   <= '1' when ((position.row >= car_row(29 downto 24) and position.row < car_row(29 downto 24) + 45) and ((position.col >= car_col(29 downto 24) and position.col < car_col(29 downto 24) + 60))) else '0';
is_car(5)   <= '1' when ((position.row >= car_row(35 downto 30) and position.row < car_row(35 downto 30) + 45) and ((position.col >= car_col(35 downto 30) and position.col < car_col(35 downto 30) + 60))) else '0';
is_car(6)   <= '1' when ((position.row >= car_row(41 downto 36) and position.row < car_row(41 downto 36) + 45) and ((position.col >= car_col(41 downto 36) and position.col < car_col(41 downto 36) + 60))) else '0';
is_car(7)   <= '1' when ((position.row >= car_row(47 downto 42) and position.row < car_row(47 downto 42) + 45) and ((position.col >= car_col(47 downto 42) and position.col < car_col(47 downto 42) + 60))) else '0';
is_car(8)   <= '1' when ((position.row >= car_row(53 downto 48) and position.row < car_row(53 downto 48) + 45) and ((position.col >= car_col(53 downto 48) and position.col < car_col(53 downto 48) + 60))) else '0';
is_car(9)   <= '1' when ((position.row >= car_row(59 downto 54) and position.row < car_row(59 downto 54) + 45) and ((position.col >= car_col(59 downto 54) and position.col < car_col(59 downto 54) + 60))) else '0';

is_car(10)  <= '1' when ((position.row >= car_row(65 downto 60) and position.row < car_row(65 downto 60) + 45) and ((position.col >= car_col(65 downto 60) and position.col < car_col(65 downto 60) + 60))) else '0';
is_car(11)  <= '1' when ((position.row >= car_row(71 downto 66) and position.row < car_row(71 downto 66) + 45) and ((position.col >= car_col(71 downto 66) and position.col < car_col(71 downto 66) + 60))) else '0';
is_car(12)  <= '1' when ((position.row >= car_row(77 downto 72) and position.row < car_row(77 downto 72) + 45) and ((position.col >= car_col(77 downto 72) and position.col < car_col(77 downto 72) + 60))) else '0';
is_car(13)  <= '1' when ((position.row >= car_row(83 downto 78) and position.row < car_row(83 downto 78) + 45) and ((position.col >= car_col(83 downto 78) and position.col < car_col(83 downto 78) + 60))) else '0';
is_car(14)  <= '1' when ((position.row >= car_row(89 downto 84) and position.row < car_row(89 downto 84) + 45) and ((position.col >= car_col(89 downto 84) and position.col < car_col(89 downto 84) + 60))) else '0';
is_car(15)  <= '1' when ((position.row >= car_row(95 downto 90) and position.row < car_row(95 downto 90) + 45) and ((position.col >= car_col(95 downto 90) and position.col < car_col(95 downto 90) + 60))) else '0';
is_car(16)  <= '1' when ((position.row >= car_row(101 downto 96) and position.row < car_row(101 downto 96) + 45) and ((position.col >= car_col(101 downto 96) and position.col < car_col(101 downto 96) + 60))) else '0';
is_car(17)  <= '1' when ((position.row >= car_row(107 downto 102) and position.row < car_row(107 downto 102) + 45) and ((position.col >= car_col(107 downto 102) and position.col < car_col(107 downto 102) + 60))) else '0';
is_car(18)  <= '1' when ((position.row >= car_row(113 downto 108) and position.row < car_row(113 downto 108) + 45) and ((position.col >= car_col(113 downto 108) and position.col < car_col(113 downto 108) + 60))) else '0';
is_car(19)  <= '1' when ((position.row >= car_row(119 downto 114) and position.row < car_row(119 downto 114) + 45) and ((position.col >= car_col(119 downto 114) and position.col < car_col(119 downto 114) + 60))) else '0';

is_car(20)  <= '1' when ((position.row >= car_row(125 downto 120) and position.row < car_row(125 downto 120) + 45) and ((position.col >= car_col(125 downto 120) and position.col < car_col(125 downto 120) + 60))) else '0';
is_car(21)  <= '1' when ((position.row >= car_row(131 downto 126) and position.row < car_row(131 downto 126) + 45) and ((position.col >= car_col(131 downto 126) and position.col < car_col(131 downto 126) + 60))) else '0';
is_car(22)  <= '1' when ((position.row >= car_row(137 downto 132) and position.row < car_row(137 downto 132) + 45) and ((position.col >= car_col(137 downto 132) and position.col < car_col(137 downto 132) + 60))) else '0';
is_car(23)  <= '1' when ((position.row >= car_row(143 downto 138) and position.row < car_row(143 downto 138) + 45) and ((position.col >= car_col(143 downto 138) and position.col < car_col(143 downto 138) + 60))) else '0';
is_car(24)  <= '1' when ((position.row >= car_row(149 downto 144) and position.row < car_row(149 downto 144) + 45) and ((position.col >= car_col(149 downto 144) and position.col < car_col(149 downto 144) + 60))) else '0';
is_car(25)  <= '1' when ((position.row >= car_row(155 downto 150) and position.row < car_row(155 downto 150) + 45) and ((position.col >= car_col(155 downto 150) and position.col < car_col(155 downto 150) + 60))) else '0';
is_car(26)  <= '1' when ((position.row >= car_row(161 downto 156) and position.row < car_row(161 downto 156) + 45) and ((position.col >= car_col(161 downto 156) and position.col < car_col(161 downto 156) + 60))) else '0';
is_car(27)  <= '1' when ((position.row >= car_row(167 downto 162) and position.row < car_row(167 downto 162) + 45) and ((position.col >= car_col(167 downto 162) and position.col < car_col(167 downto 162) + 60))) else '0';
is_car(28)  <= '1' when ((position.row >= car_row(173 downto 168) and position.row < car_row(173 downto 168) + 45) and ((position.col >= car_col(173 downto 168) and position.col < car_col(173 downto 168) + 60))) else '0';
is_car(29)  <= '1' when ((position.row >= car_row(179 downto 174) and position.row < car_row(179 downto 174) + 45) and ((position.col >= car_col(179 downto 174) and position.col < car_col(179 downto 174) + 60))) else '0';

is_car(30)  <= '1' when ((position.row >= car_row(185 downto 180) and position.row < car_row(185 downto 180) + 45) and ((position.col >= car_col(185 downto 180) and position.col < car_col(185 downto 180) + 60))) else '0';
is_car(31)  <= '1' when ((position.row >= car_row(191 downto 186) and position.row < car_row(191 downto 186) + 45) and ((position.col >= car_col(191 downto 186) and position.col < car_col(191 downto 186) + 60))) else '0';
is_car(32)  <= '1' when ((position.row >= car_row(197 downto 192) and position.row < car_row(197 downto 192) + 45) and ((position.col >= car_col(197 downto 192) and position.col < car_col(197 downto 192) + 60))) else '0';
is_car(33)  <= '1' when ((position.row >= car_row(203 downto 198) and position.row < car_row(203 downto 198) + 45) and ((position.col >= car_col(203 downto 198) and position.col < car_col(203 downto 198) + 60))) else '0';
is_car(34)  <= '1' when ((position.row >= car_row(209 downto 204) and position.row < car_row(209 downto 204) + 45) and ((position.col >= car_col(209 downto 204) and position.col < car_col(209 downto 204) + 60))) else '0';
is_car(35)  <= '1' when ((position.row >= car_row(215 downto 210) and position.row < car_row(215 downto 210) + 45) and ((position.col >= car_col(215 downto 210) and position.col < car_col(215 downto 210) + 60))) else '0';
is_car(36)  <= '1' when ((position.row >= car_row(221 downto 216) and position.row < car_row(221 downto 216) + 45) and ((position.col >= car_col(221 downto 216) and position.col < car_col(221 downto 216) + 60))) else '0';
is_car(37)  <= '1' when ((position.row >= car_row(227 downto 222) and position.row < car_row(227 downto 222) + 45) and ((position.col >= car_col(227 downto 222) and position.col < car_col(227 downto 222) + 60))) else '0';
is_car(38)  <= '1' when ((position.row >= car_row(233 downto 228) and position.row < car_row(233 downto 228) + 45) and ((position.col >= car_col(233 downto 228) and position.col < car_col(233 downto 228) + 60))) else '0';
is_car(39)  <= '1' when ((position.row >= car_row(239 downto 234) and position.row < car_row(239 downto 234) + 45) and ((position.col >= car_col(239 downto 234) and position.col < car_col(239 downto 234) + 60))) else '0';

is_car(40)  <= '1' when ((position.row >= car_row(245 downto 240) and position.row < car_row(245 downto 240) + 45) and ((position.col >= car_col(245 downto 240) and position.col < car_col(245 downto 240) + 60))) else '0';
is_car(41)  <= '1' when ((position.row >= car_row(251 downto 246) and position.row < car_row(251 downto 246) + 45) and ((position.col >= car_col(251 downto 246) and position.col < car_col(251 downto 246) + 60))) else '0';
is_car(42)  <= '1' when ((position.row >= car_row(257 downto 252) and position.row < car_row(257 downto 252) + 45) and ((position.col >= car_col(257 downto 252) and position.col < car_col(257 downto 252) + 60))) else '0';
is_car(43)  <= '1' when ((position.row >= car_row(263 downto 258) and position.row < car_row(263 downto 258) + 45) and ((position.col >= car_col(263 downto 258) and position.col < car_col(263 downto 258) + 60))) else '0';
is_car(44)  <= '1' when ((position.row >= car_row(269 downto 264) and position.row < car_row(269 downto 264) + 45) and ((position.col >= car_col(269 downto 264) and position.col < car_col(269 downto 264) + 60))) else '0';
is_car(45)  <= '1' when ((position.row >= car_row(275 downto 270) and position.row < car_row(275 downto 270) + 45) and ((position.col >= car_col(275 downto 270) and position.col < car_col(275 downto 270) + 60))) else '0';
is_car(46)  <= '1' when ((position.row >= car_row(281 downto 276) and position.row < car_row(281 downto 276) + 45) and ((position.col >= car_col(281 downto 276) and position.col < car_col(281 downto 276) + 60))) else '0';
is_car(47)  <= '1' when ((position.row >= car_row(287 downto 282) and position.row < car_row(287 downto 282) + 45) and ((position.col >= car_col(287 downto 282) and position.col < car_col(287 downto 282) + 60))) else '0';
is_car(48)  <= '1' when ((position.row >= car_row(293 downto 288) and position.row < car_row(293 downto 288) + 45) and ((position.col >= car_col(293 downto 288) and position.col < car_col(293 downto 288) + 60))) else '0';
is_car(49)  <= '1' when ((position.row >= car_row(299 downto 294) and position.row < car_row(299 downto 294) + 45) and ((position.col >= car_col(299 downto 294) and position.col < car_col(299 downto 294) + 60))) else '0';

-- log bools
is_log(0)  <= '1' when ((position.row >= log_row(4 downto 0) and position.row < log_row(4 downto 0) + 27) and ((position.col >= log_col(6 downto 0) and position.col < log_col(6 downto 0) + 120))) else '0';
is_log(1)  <= '1' when ((position.row >= log_row(9 downto 5) and position.row < log_row(9 downto 5) + 27) and ((position.col >= log_col(13 downto 7) and position.col < log_col(13 downto 7) + 120))) else '0';
is_log(2)  <= '1' when ((position.row >= log_row(14 downto 10) and position.row < log_row(14 downto 10) + 27) and ((position.col >= log_col(20 downto 14) and position.col < log_col(20 downto 14) + 120))) else '0';
is_log(3)  <= '1' when ((position.row >= log_row(19 downto 15) and position.row < log_row(19 downto 15) + 27) and ((position.col >= log_col(27 downto 21) and position.col < log_col(27 downto 21) + 120))) else '0';
is_log(4)  <= '1' when ((position.row >= log_row(24 downto 20) and position.row < log_row(24 downto 20) + 27) and ((position.col >= log_col(34 downto 28) and position.col < log_col(34 downto 28) + 120))) else '0';
is_log(5)  <= '1' when ((position.row >= log_row(29 downto 25) and position.row < log_row(29 downto 25) + 27) and ((position.col >= log_col(41 downto 35) and position.col < log_col(41 downto 35) + 120))) else '0';
is_log(6)  <= '1' when ((position.row >= log_row(34 downto 30) and position.row < log_row(34 downto 30) + 27) and ((position.col >= log_col(48 downto 42) and position.col < log_col(48 downto 42) + 120))) else '0';
is_log(7)  <= '1' when ((position.row >= log_row(39 downto 35) and position.row < log_row(39 downto 35) + 27) and ((position.col >= log_col(55 downto 49) and position.col < log_col(55 downto 49) + 120))) else '0';
is_log(8)  <= '1' when ((position.row >= log_row(44 downto 40) and position.row < log_row(44 downto 40) + 27) and ((position.col >= log_col(62 downto 56) and position.col < log_col(62 downto 56) + 120))) else '0';
is_log(9)  <= '1' when ((position.row >= log_row(49 downto 45) and position.row < log_row(49 downto 45) + 27) and ((position.col >= log_col(69 downto 63) and position.col < log_col(69 downto 63) + 120))) else '0';

is_log(10) <= '1' when ((position.row >= log_row(54 downto 50) and position.row < log_row(54 downto 50) + 27) and ((position.col >= log_col(76 downto 70) and position.col < log_col(76 downto 70) + 120))) else '0';
is_log(11) <= '1' when ((position.row >= log_row(59 downto 55) and position.row < log_row(59 downto 55) + 27) and ((position.col >= log_col(83 downto 77) and position.col < log_col(83 downto 77) + 120))) else '0';
is_log(12) <= '1' when ((position.row >= log_row(64 downto 60) and position.row < log_row(64 downto 60) + 27) and ((position.col >= log_col(90 downto 84) and position.col < log_col(90 downto 84) + 120))) else '0';
is_log(13) <= '1' when ((position.row >= log_row(69 downto 65) and position.row < log_row(69 downto 65) + 27) and ((position.col >= log_col(97 downto 91) and position.col < log_col(97 downto 91) + 120))) else '0';
is_log(14) <= '1' when ((position.row >= log_row(74 downto 70) and position.row < log_row(74 downto 70) + 27) and ((position.col >= log_col(104 downto 98) and position.col < log_col(104 downto 98) + 120))) else '0';
is_log(15) <= '1' when ((position.row >= log_row(79 downto 75) and position.row < log_row(79 downto 75) + 27) and ((position.col >= log_col(111 downto 105) and position.col < log_col(111 downto 105) + 120))) else '0';
is_log(16) <= '1' when ((position.row >= log_row(84 downto 80) and position.row < log_row(84 downto 80) + 27) and ((position.col >= log_col(118 downto 112) and position.col < log_col(118 downto 112) + 120))) else '0';
is_log(17) <= '1' when ((position.row >= log_row(89 downto 85) and position.row < log_row(89 downto 85) + 27) and ((position.col >= log_col(125 downto 119) and position.col < log_col(125 downto 119) + 120))) else '0';
is_log(18) <= '1' when ((position.row >= log_row(94 downto 90) and position.row < log_row(94 downto 90) + 27) and ((position.col >= log_col(132 downto 126) and position.col < log_col(132 downto 126) + 120))) else '0';
is_log(19) <= '1' when ((position.row >= log_row(99 downto 95) and position.row < log_row(99 downto 95) + 27) and ((position.col >= log_col(139 downto 133) and position.col < log_col(139 downto 133) + 120))) else '0';

is_log(20) <= '1' when ((position.row >= log_row(104 downto 100) and position.row < log_row(104 downto 100) + 27) and ((position.col >= log_col(146 downto 140) and position.col < log_col(146 downto 140) + 120))) else '0';
is_log(21) <= '1' when ((position.row >= log_row(109 downto 105) and position.row < log_row(109 downto 105) + 27) and ((position.col >= log_col(153 downto 147) and position.col < log_col(153 downto 147) + 120))) else '0';
is_log(22) <= '1' when ((position.row >= log_row(114 downto 110) and position.row < log_row(114 downto 110) + 27) and ((position.col >= log_col(160 downto 154) and position.col < log_col(160 downto 154) + 120))) else '0';
is_log(23) <= '1' when ((position.row >= log_row(119 downto 115) and position.row < log_row(119 downto 115) + 27) and ((position.col >= log_col(167 downto 161) and position.col < log_col(167 downto 161) + 120))) else '0';
is_log(24) <= '1' when ((position.row >= log_row(124 downto 120) and position.row < log_row(124 downto 120) + 27) and ((position.col >= log_col(174 downto 168) and position.col < log_col(174 downto 168) + 120))) else '0';
is_log(25) <= '1' when ((position.row >= log_row(129 downto 125) and position.row < log_row(129 downto 125) + 27) and ((position.col >= log_col(181 downto 175) and position.col < log_col(181 downto 175) + 120))) else '0';
is_log(26) <= '1' when ((position.row >= log_row(134 downto 130) and position.row < log_row(134 downto 130) + 27) and ((position.col >= log_col(188 downto 182) and position.col < log_col(188 downto 182) + 120))) else '0';
is_log(27) <= '1' when ((position.row >= log_row(139 downto 135) and position.row < log_row(139 downto 135) + 27) and ((position.col >= log_col(195 downto 189) and position.col < log_col(195 downto 189) + 120))) else '0';
is_log(28) <= '1' when ((position.row >= log_row(144 downto 140) and position.row < log_row(144 downto 140) + 27) and ((position.col >= log_col(202 downto 196) and position.col < log_col(202 downto 196) + 120))) else '0';
is_log(29) <= '1' when ((position.row >= log_row(149 downto 145) and position.row < log_row(149 downto 145) + 27) and ((position.col >= log_col(209 downto 203) and position.col < log_col(209 downto 203) + 120))) else '0';

is_log(30) <= '1' when ((position.row >= log_row(154 downto 150) and position.row < log_row(154 downto 150) + 27) and ((position.col >= log_col(216 downto 210) and position.col < log_col(216 downto 210) + 120))) else '0';
is_log(31) <= '1' when ((position.row >= log_row(159 downto 155) and position.row < log_row(159 downto 155) + 27) and ((position.col >= log_col(223 downto 217) and position.col < log_col(223 downto 217) + 120))) else '0';
is_log(32) <= '1' when ((position.row >= log_row(164 downto 160) and position.row < log_row(164 downto 160) + 27) and ((position.col >= log_col(230 downto 224) and position.col < log_col(230 downto 224) + 120))) else '0';
is_log(33) <= '1' when ((position.row >= log_row(169 downto 165) and position.row < log_row(169 downto 165) + 27) and ((position.col >= log_col(237 downto 231) and position.col < log_col(237 downto 231) + 120))) else '0';
is_log(34) <= '1' when ((position.row >= log_row(174 downto 170) and position.row < log_row(174 downto 170) + 27) and ((position.col >= log_col(244 downto 238) and position.col < log_col(244 downto 238) + 120))) else '0';
is_log(35) <= '1' when ((position.row >= log_row(179 downto 175) and position.row < log_row(179 downto 175) + 27) and ((position.col >= log_col(251 downto 245) and position.col < log_col(251 downto 245) + 120))) else '0';
is_log(36) <= '1' when ((position.row >= log_row(184 downto 180) and position.row < log_row(184 downto 180) + 27) and ((position.col >= log_col(258 downto 252) and position.col < log_col(258 downto 252) + 120))) else '0';
is_log(37) <= '1' when ((position.row >= log_row(189 downto 185) and position.row < log_row(189 downto 185) + 27) and ((position.col >= log_col(265 downto 259) and position.col < log_col(265 downto 259) + 120))) else '0';
is_log(38) <= '1' when ((position.row >= log_row(194 downto 190) and position.row < log_row(194 downto 190) + 27) and ((position.col >= log_col(272 downto 266) and position.col < log_col(272 downto 266) + 120))) else '0';
is_log(39) <= '1' when ((position.row >= log_row(199 downto 195) and position.row < log_row(199 downto 195) + 27) and ((position.col >= log_col(279 downto 273) and position.col < log_col(279 downto 273) + 120))) else '0';

is_log(40) <= '1' when ((position.row >= log_row(204 downto 200) and position.row < log_row(204 downto 200) + 27) and ((position.col >= log_col(286 downto 280) and position.col < log_col(286 downto 280) + 120))) else '0';
is_log(41) <= '1' when ((position.row >= log_row(209 downto 205) and position.row < log_row(209 downto 205) + 27) and ((position.col >= log_col(293 downto 287) and position.col < log_col(293 downto 287) + 120))) else '0';
is_log(42) <= '1' when ((position.row >= log_row(214 downto 210) and position.row < log_row(214 downto 210) + 27) and ((position.col >= log_col(300 downto 294) and position.col < log_col(300 downto 294) + 120))) else '0';
is_log(43) <= '1' when ((position.row >= log_row(219 downto 215) and position.row < log_row(219 downto 215) + 27) and ((position.col >= log_col(307 downto 301) and position.col < log_col(307 downto 301) + 120))) else '0';
is_log(44) <= '1' when ((position.row >= log_row(224 downto 220) and position.row < log_row(224 downto 220) + 27) and ((position.col >= log_col(314 downto 308) and position.col < log_col(314 downto 308) + 120))) else '0';
is_log(45) <= '1' when ((position.row >= log_row(229 downto 225) and position.row < log_row(229 downto 225) + 27) and ((position.col >= log_col(321 downto 315) and position.col < log_col(321 downto 315) + 120))) else '0';
is_log(46) <= '1' when ((position.row >= log_row(234 downto 230) and position.row < log_row(234 downto 230) + 27) and ((position.col >= log_col(328 downto 322) and position.col < log_col(328 downto 322) + 120))) else '0';
is_log(47) <= '1' when ((position.row >= log_row(239 downto 235) and position.row < log_row(239 downto 235) + 27) and ((position.col >= log_col(335 downto 329) and position.col < log_col(335 downto 329) + 120))) else '0';
is_log(48) <= '1' when ((position.row >= log_row(244 downto 240) and position.row < log_row(244 downto 240) + 27) and ((position.col >= log_col(342 downto 336) and position.col < log_col(342 downto 336) + 120))) else '0';
is_log(49) <= '1' when ((position.row >= log_row(249 downto 245) and position.row < log_row(249 downto 245) + 27) and ((position.col >= log_col(349 downto 343) and position.col < log_col(349 downto 343) + 120))) else '0';

is_log(50) <= '1' when ((position.row >= log_row(254 downto 250) and position.row < log_row(254 downto 250) + 27) and ((position.col >= log_col(356 downto 350) and position.col < log_col(356 downto 350) + 120))) else '0';
is_log(51) <= '1' when ((position.row >= log_row(259 downto 255) and position.row < log_row(259 downto 255) + 27) and ((position.col >= log_col(363 downto 357) and position.col < log_col(363 downto 357) + 120))) else '0';
is_log(52) <= '1' when ((position.row >= log_row(264 downto 260) and position.row < log_row(264 downto 260) + 27) and ((position.col >= log_col(370 downto 364) and position.col < log_col(370 downto 364) + 120))) else '0';
is_log(53) <= '1' when ((position.row >= log_row(269 downto 265) and position.row < log_row(269 downto 265) + 27) and ((position.col >= log_col(377 downto 371) and position.col < log_col(377 downto 371) + 120))) else '0';
is_log(54) <= '1' when ((position.row >= log_row(274 downto 270) and position.row < log_row(274 downto 270) + 27) and ((position.col >= log_col(384 downto 378) and position.col < log_col(384 downto 378) + 120))) else '0';
is_log(55) <= '1' when ((position.row >= log_row(279 downto 275) and position.row < log_row(279 downto 275) + 27) and ((position.col >= log_col(391 downto 385) and position.col < log_col(391 downto 385) + 120))) else '0';
is_log(56) <= '1' when ((position.row >= log_row(284 downto 280) and position.row < log_row(284 downto 280) + 27) and ((position.col >= log_col(398 downto 392) and position.col < log_col(398 downto 392) + 120))) else '0';
is_log(57) <= '1' when ((position.row >= log_row(289 downto 285) and position.row < log_row(289 downto 285) + 27) and ((position.col >= log_col(405 downto 399) and position.col < log_col(405 downto 399) + 120))) else '0';
is_log(58) <= '1' when ((position.row >= log_row(294 downto 290) and position.row < log_row(294 downto 290) + 27) and ((position.col >= log_col(412 downto 406) and position.col < log_col(412 downto 406) + 120))) else '0';
is_log(59) <= '1' when ((position.row >= log_row(299 downto 295) and position.row < log_row(299 downto 295) + 27) and ((position.col >= log_col(419 downto 413) and position.col < log_col(419 downto 413) + 120))) else '0';


-- lilypad bools
is_lilypad(0)  <= '1' when ((position.row >= lilypad_row(4 downto 0) and position.row < lilypad_row(4 downto 0) + 20) and ((position.col >= lilypad_col(4 downto 0) and position.col < lilypad_col(4 downto 0) + 25))) else '0';
is_lilypad(1)  <= '1' when ((position.row >= lilypad_row(9 downto 5) and position.row < lilypad_row(9 downto 5) + 20) and ((position.col >= lilypad_col(9 downto 5) and position.col < lilypad_col(9 downto 5) + 25))) else '0';
is_lilypad(2)  <= '1' when ((position.row >= lilypad_row(14 downto 10) and position.row < lilypad_row(14 downto 10) + 20) and ((position.col >= lilypad_col(14 downto 10) and position.col < lilypad_col(14 downto 10) + 25))) else '0';
is_lilypad(3)  <= '1' when ((position.row >= lilypad_row(19 downto 15) and position.row < lilypad_row(19 downto 15) + 20) and ((position.col >= lilypad_col(19 downto 15) and position.col < lilypad_col(19 downto 15) + 25))) else '0';
is_lilypad(4)  <= '1' when ((position.row >= lilypad_row(24 downto 20) and position.row < lilypad_row(24 downto 20) + 20) and ((position.col >= lilypad_col(24 downto 20) and position.col < lilypad_col(24 downto 20) + 25))) else '0';
is_lilypad(5)  <= '1' when ((position.row >= lilypad_row(29 downto 25) and position.row < lilypad_row(29 downto 25) + 20) and ((position.col >= lilypad_col(29 downto 25) and position.col < lilypad_col(29 downto 25) + 25))) else '0';
is_lilypad(6)  <= '1' when ((position.row >= lilypad_row(34 downto 30) and position.row < lilypad_row(34 downto 30) + 20) and ((position.col >= lilypad_col(34 downto 30) and position.col < lilypad_col(34 downto 30) + 25))) else '0';
is_lilypad(7)  <= '1' when ((position.row >= lilypad_row(39 downto 35) and position.row < lilypad_row(39 downto 35) + 20) and ((position.col >= lilypad_col(39 downto 35) and position.col < lilypad_col(39 downto 35) + 25))) else '0';
is_lilypad(8)  <= '1' when ((position.row >= lilypad_row(44 downto 40) and position.row < lilypad_row(44 downto 40) + 20) and ((position.col >= lilypad_col(44 downto 40) and position.col < lilypad_col(44 downto 40) + 25))) else '0';
is_lilypad(9)  <= '1' when ((position.row >= lilypad_row(49 downto 45) and position.row < lilypad_row(49 downto 45) + 20) and ((position.col >= lilypad_col(49 downto 45) and position.col < lilypad_col(49 downto 45) + 25))) else '0';

is_lilypad(10) <= '1' when ((position.row >= lilypad_row(54 downto 50) and position.row < lilypad_row(54 downto 50) + 20) and ((position.col >= lilypad_col(54 downto 50) and position.col < lilypad_col(54 downto 50) + 25))) else '0';
is_lilypad(11) <= '1' when ((position.row >= lilypad_row(59 downto 55) and position.row < lilypad_row(59 downto 55) + 20) and ((position.col >= lilypad_col(59 downto 55) and position.col < lilypad_col(59 downto 55) + 25))) else '0';
is_lilypad(12) <= '1' when ((position.row >= lilypad_row(64 downto 60) and position.row < lilypad_row(64 downto 60) + 20) and ((position.col >= lilypad_col(64 downto 60) and position.col < lilypad_col(64 downto 60) + 25))) else '0';
is_lilypad(13) <= '1' when ((position.row >= lilypad_row(69 downto 65) and position.row < lilypad_row(69 downto 65) + 20) and ((position.col >= lilypad_col(69 downto 65) and position.col < lilypad_col(69 downto 65) + 25))) else '0';
is_lilypad(14) <= '1' when ((position.row >= lilypad_row(74 downto 70) and position.row < lilypad_row(74 downto 70) + 20) and ((position.col >= lilypad_col(74 downto 70) and position.col < lilypad_col(74 downto 70) + 25))) else '0';
is_lilypad(15) <= '1' when ((position.row >= lilypad_row(79 downto 75) and position.row < lilypad_row(79 downto 75) + 20) and ((position.col >= lilypad_col(79 downto 75) and position.col < lilypad_col(79 downto 75) + 25))) else '0';
is_lilypad(16) <= '1' when ((position.row >= lilypad_row(84 downto 80) and position.row < lilypad_row(84 downto 80) + 20) and ((position.col >= lilypad_col(84 downto 80) and position.col < lilypad_col(84 downto 80) + 25))) else '0';
is_lilypad(17) <= '1' when ((position.row >= lilypad_row(89 downto 85) and position.row < lilypad_row(89 downto 85) + 20) and ((position.col >= lilypad_col(89 downto 85) and position.col < lilypad_col(89 downto 85) + 25))) else '0';
is_lilypad(18) <= '1' when ((position.row >= lilypad_row(94 downto 90) and position.row < lilypad_row(94 downto 90) + 20) and ((position.col >= lilypad_col(94 downto 90) and position.col < lilypad_col(94 downto 90) + 25))) else '0';
is_lilypad(19) <= '1' when ((position.row >= lilypad_row(99 downto 95) and position.row < lilypad_row(99 downto 95) + 20) and ((position.col >= lilypad_col(99 downto 95) and position.col < lilypad_col(99 downto 95) + 25))) else '0';


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
        led <= std_logic_vector(chicken_row(9 downto 2));
        
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
