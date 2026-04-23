----------------------------------------------------------------------------------
-- Name:	Capt Jeff Falkinburg
-- Date:	Spring 2017
-- File:    vga.vhd
-- HW:	    Lab 2 
-- Pupr:	VGA component entity description for Lab 1.  This component sweeps across
--			the display from left to right, and then return to the left side of the 
--			next lower row. The VGA interface determines the color of each pixel on
--			this journey with the help of the scopeFace component.
-- Doc:	Adapted from Dr Coulston's Lab exercise
-- 	
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           h_sync : out  STD_LOGIC;
           v_sync : out  STD_LOGIC;
           blank : out  STD_LOGIC;
           r : out  STD_LOGIC_VECTOR (7 downto 0);
           g : out  STD_LOGIC_VECTOR (7 downto 0);
           b : out  STD_LOGIC_VECTOR (7 downto 0);
           row : out  unsigned (9 downto 0);
           column : out  unsigned (9 downto 0);
           ch1 : in  std_logic_vector(15 downto 0);
           ch1_enb : in  STD_LOGIC;
           ch2 : in  STD_LOGIC;
           ch2_enb : in  STD_LOGIC);
end VGA;

architecture Behavioral of vga is

	signal h_complete, v_complete: STD_LOGIC;
	signal local_blank, h_blank, v_blank: STD_LOGIC;
	signal rsf, gsf, bsf : std_logic_vector(7 downto 0);
	signal h_count, v_count: unsigned(9 downto 0); 
	signal t_time, t_volt: unsigned(9 downto 0); 

	component scopeFace is
		Port (	row : in  unsigned(9 downto 0);
					column : in  unsigned(9 downto 0);
					r : out  std_logic_vector(7 downto 0);
					g : out  std_logic_vector(7 downto 0);
					b : out  std_logic_vector(7 downto 0);
					ch1: in  std_logic_vector(15 downto 0);
					ch1_enb: in std_logic;
					ch2: in std_logic;
					ch2_enb: in std_logic);
		end component;

begin
	Inst_scopeFace: scopeFace  
	PORT MAP( 
					row				=> v_count,
					column			=> h_count,
					r					=> rsf,
					g 					=> gsf,
					b					=> bsf,
					ch1				=> ch1,
					ch1_enb			=> ch1_enb,
					ch2				=> ch2,
					ch2_enb			=> ch2_enb);
	
	-----------------------------------------------------------------------------
	-- vert_count			State					v_synch		v_blank
	--	[0,479]				Active Video		1				0	
	--	[480,489]			Front Porch			1				1	
	--	[490,491]			Synch					0				1	
	--	[492,524]			Back Porch			1				1	
	-----------------------------------------------------------------------------

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				v_count <= (others => '0');
			elsif ((v_count < 524) and (h_complete = '1')) then
				v_count <= v_count + 1;
			elsif ((v_count = 524) and (h_complete = '1')) then
				v_count <= (others => '0');
			end if;
		end if;
	end process;

	row <= v_count;
	v_complete <= '1' when (v_count = 525) else '0';

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				v_sync <= '1';
				v_blank <= '0';
			elsif ((v_count = 0) and (v_count < 480)) then			-- Active Video	[0,479]
				v_sync <= '1';
				v_blank <= '0';
			elsif (v_count >= 480) and (v_count < 490) then			-- Front Porch		[480,489]
				v_sync <= '1';
				v_blank <= '1';
			elsif (v_count >= 490) and (v_count < 492) then			-- Synch				[490,491]
				v_sync <= '0';
				v_blank <= '1';
			elsif (v_count >= 492) and (v_count < 525) then			-- Back Porch		[492,524]
				v_sync <= '1';
				v_blank <= '1';
			end if;
		end if;
	end process;


	-----------------------------------------------------------------------------
	-- horz_count			State					h_synch		h_blank		h_completed
	--	[0,  639]			Active Video		1				0				0
	--	[640,655]			Front Porch			1				1				0
	--	[656,751]			Synch					0				1				0
	--	[752,799]			Back Porch			1				1				0/1
	-----------------------------------------------------------------------------

	process(clk)
	begin	
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				h_count <= (others => '0');
			elsif (h_count < 799) then
				h_count <= h_count + 1;
			elsif (h_count = 799) then
				h_count <= (others => '0');
			end if;
		end if; 
	end process;

	column <= h_count;
	h_complete <= '1' when (h_count = 799) else '0';

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				h_sync <= '1';
				h_blank <= '0';			
			elsif ((h_count = 0) and (h_count < 640)) then			-- Active Video	[0,639]
				h_sync <= '1';
				h_blank <= '0';
			elsif (h_count >= 640) and (h_count < 656) then			-- Front Porch		[640,655]
				h_sync <= '1';
				h_blank <= '1';
			elsif (h_count >= 656) and (h_count < 752) then			-- Synch				[656,751]
				h_sync <= '0';
				h_blank <= '1';
			elsif (h_count >= 752) and (h_count < 800) then			-- Back Porch		[752,799]
				h_sync <= '1';
				h_blank <= '1';
			end if;
		end if;
	end process;


	local_blank <= h_blank or v_blank;
	blank <= local_blank;
	
	r <= rsf when local_blank = '0' else "00000000";
	g <= gsf when local_blank = '0' else "00000000";
	b <= bsf when local_blank = '0' else "00000000";	


end Behavioral;

