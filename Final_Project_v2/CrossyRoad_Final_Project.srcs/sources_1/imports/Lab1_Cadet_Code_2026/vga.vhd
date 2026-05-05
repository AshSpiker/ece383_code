                        ------
-- Lt Col James Trimble, 15 Jan 2025
-- Generates VGA signal with graphics
------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;
 
entity vga is
	Port(	clk      : in  STD_LOGIC;
			reset_n  : in  STD_LOGIC;
			vga      : out vga_t;
            pixel    : out pixel_t;
            ch1      : in channel_t;
            ch2      : in channel_t;
            game_map : in map_array;
            btn      : in STD_LOGIC_VECTOR(3 downto 0);
            led      : out std_logic_vector(7 downto 0);
            NES_btns : in std_logic_vector(4 downto 0)
            );
end vga;

architecture vga_arch of vga is
-- signal declaration
    signal w_position   : coordinate_t;
-- component declaration

    -- vga signal gen component 
    component vga_signal_generator is 
        Port (
           clk      : in STD_LOGIC;
           reset_n  : in STD_LOGIC;
           position : out coordinate_t;
           vga      : out vga_t
           );
    end component vga_signal_generator;
        
    -- color mapper component 
    component color_mapper is 
        Port (
           clk      : in std_logic;
           color    : out color_t;
           position : in coordinate_t;
           ch1      : in channel_t;
           ch2      : in channel_t;
           game_map : in map_array;
           btn      : in STD_LOGIC_VECTOR(3 downto 0);
           reset_n  : in STD_LOGIC;
           led      : out std_logic_vector(7 downto 0);
           NES_btns : in std_logic_vector(4 downto 0)
           );
    end component color_mapper;
begin
    vga_signal_generator_inst : vga_signal_generator
    port map(
        clk        => clk,
        reset_n    => reset_n,
        position   => w_position,
        vga        => vga
        );
        
    color_mapper_inst : color_mapper
    port map(
        clk         => clk,
        color       => pixel.color,
        position    => w_position,
        ch1         => ch1,
        ch2         => ch2,
        game_map    => game_map,
        btn         => btn,
        reset_n     => reset_n,
        led         => led,
        NES_btns    => NES_btns
        );

    pixel.coordinate <= w_position;
end vga_arch;
