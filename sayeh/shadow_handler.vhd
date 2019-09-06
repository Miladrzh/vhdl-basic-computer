library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shadow_handler is port (
	shadow0to3 : in std_logic_vector(3 downto 0);
	shadow8to11 : in std_logic_vector(3 downto 0);
  shadow_select : in std_logic;
  shadow_out : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of shadow_handler is begin 
  shadow_out <= (shadow0to3 and (shadow_select & shadow_select & shadow_select & shadow_select)) or ((shadow8to11) and (not shadow_select & not shadow_select & not shadow_select & not shadow_select));
end architecture;
  	

-- shadow0to3 <= IRout(3 downto 0);
-- shadow8to11 <= IRout(11 downto 8);
