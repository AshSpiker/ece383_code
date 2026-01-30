----------------------------------------------------------------------------------
--	Title
--  Name
--  Description
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity lab1 is
    Port ( clk     : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
		   btn     : in	STD_LOGIC_VECTOR(4 downto 0);
		   led     : out STD_LOGIC_VECTOR(4 downto 0);
		   sw      : in STD_LOGIC_VECTOR(1 downto 0);
           tmds    : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb   : out  STD_LOGIC_VECTOR (3 downto 0));
end lab1;

architecture structure of lab1 is

    constant CENTER : integer := 4;
    constant DOWN   : integer := 1;
    constant LEFT   : integer := 0;
    constant RIGHT  : integer := 2;
    constant UP     : integer := 3;

    signal trigger                                : trigger_t;
	signal pixel                                  : pixel_t;
	signal ch1, ch2                               : channel_t;
	signal time_trigger_value, volt_trigger_value : signed(10 downto 0);
	
	component video is 
	   Port(
	        clk        : in  STD_LOGIC;
            reset_n    : in  STD_LOGIC;
            tmds       : out  STD_LOGIC_VECTOR (3 downto 0);
            tmdsb      : out  STD_LOGIC_VECTOR (3 downto 0);
            trigger    : in trigger_t;
            position   : out coordinate_t;
            ch1        : in channel_t;
            ch2        : in channel_t
            );
    end component video;
    
    component numeric_stepper is 
        generic (
            num_bits  : integer := 11;
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
   end component numeric_stepper;
   
begin
   
-- Add numeric steppers for time and voltage trigger
    numeric_stepper_v : numeric_stepper
        generic map(
            num_bits  => 11,
            max_value => 420,
            min_value => 20,
            delta     => 10
        )
        port map(
            clk     => clk,
            reset_n => reset_n,
            en      => reset_n,
            up      => btn(RIGHT),
            down    => btn(LEFT),
            q       => volt_trigger_value
        );
        
    numeric_stepper_t : numeric_stepper
        generic map(
            num_bits  => 11,
            max_value => 620,
            min_value => 20,
            delta     => 10
        )
        port map(
            clk     => clk,
            reset_n => reset_n,
            en      => reset_n,
            up      => btn(UP),
            down    => btn(DOWN),
            q       => time_trigger_value
        );
-- Assign trigger.t and trigger.v
       	trigger.t <= unsigned(time_trigger_value);
       	trigger.v <= unsigned(volt_trigger_value);
-- Instantiate video
    video_inst : video
        port map(
            clk       => clk,
            reset_n   => reset_n, 
            tmds      => tmds,
            tmdsb     => tmdsb, 
            trigger   => trigger,
            position  => pixel.coordinate,
            ch1       => ch1,
            ch2       => ch2
        );
-- Determine if ch1 and or ch2 are active
ch1.active <= '1' when (pixel.coordinate.row = pixel.coordinate.col)       else '0';
ch2.active <= '1' when (440 - pixel.coordinate.row = pixel.coordinate.col) else '0';
-- Connect board hardware to signals
ch1.en <= sw(0);
ch2.en <= sw(1);

end structure;
