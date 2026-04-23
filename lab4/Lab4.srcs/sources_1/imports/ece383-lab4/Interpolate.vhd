----------------------------------------------------------------------------------
-- Title: IndexOffsetReg
-- Engineer: 
-- Date:   
-- Description:  Stores a value for the index.offset and increments it by phase_inc 
--   on the rising edge of the clock if en = '1'
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Interpolate is
    generic (
        whole_bits : natural := 4;
        frac_bits : natural := 4;
        data_size : natural := 16);
    port ( offset : in STD_LOGIC_VECTOR (frac_bits-1 downto 0);
           base_value : in STD_LOGIC_VECTOR (data_size-1 downto 0);
           next_value : in STD_LOGIC_VECTOR (data_size-1 downto 0);
           interpolated_out : out STD_LOGIC_VECTOR (data_size-1 downto 0));
end Interpolate;

architecture Interpolate_arch of Interpolate is
    signal delta_x_offset : signed((frac_bits+1+data_size)-1 downto 0) := (others => '0');
    signal base_plus_delta_x_offset : signed(data_size-1 downto 0) := (others => '0');
    signal signed_base, signed_next : signed(data_size-1 downto 0) := (others => '0');
    signal signed_offset : signed(frac_bits downto 0) := (others => '0');
begin
    signed_base <= signed(base_value); -- base is the first number in interpolation. so like with 1.38, base is the 1
    signed_next <= signed(next_value); -- next would be 2, because 2 is the next number after the 1 
    signed_offset <= signed('0' & offset); -- the offset is the decimal in between the two numbers, so would be the .38
    -- already preappeneded the 0
    
    delta_x_offset <= (signed_base - signed_next) * signed_offset;
    -- this needs to find the difference between the first point and second point, multiply by offset, add first base 
    -- Base + (Base - Next)*offset
    -- TODO: Compute the delta*offset; -- (Q16.0 - Q16.0) * Q1.8 = Q17.8
    
    -- removing the MSB, and truncate    
    base_plus_delta_x_offset <= signed_base + delta_x_offset((data_size-1) downto 0);
    -- TODO: Compute the base + delta*offset to get the interpolated value; -- Q16.0 + [Q17.8 sliced to Q16.0]
  
    interpolated_out <= std_logic_vector(base_plus_delta_x_offset);
    
end Interpolate_arch;
