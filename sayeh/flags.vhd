library IEEE;
use IEEE.std_logic_1164.all;

entity flags is port(
	flag_Zin, flag_Cin : in std_logic;
	clk : in std_logic;
	CSet, CReset, ZSet, ZReset, SRload : in std_logic;
	flag_Zout, flag_Cout : out std_logic := '0'
);
end entity;

architecture rtl of flags is
--	signal flag_Zin, flag_Cin : std_logic;
--	signal clk : std_logic;
--	signal CSet, CReset, ZSet, ZReset, SRload : std_logic;
--	signal flag_Zout, flag_Cout : std_logic
begin
	
	process(clk)
	begin
		if (clk'event and clk = '1') then
			if (CSet = '1') then
				flag_Cout <= '1';
			elsif (CReset = '1') then 
				flag_Cout <= '0';
			end if;
			if (ZSet = '1') then
				flag_Zout <= '1';
			elsif (ZReset = '1') then
				flag_Zout <= '0';
			end if;
			if (SRload = '1' and CSet = '0' and CReset = '0' and ZSet = '0' and ZReset = '0') then
				flag_Zout <= flag_Zin;
				flag_Cout <= flag_Cin;
			end if;
		end if;
	end process;

end architecture;

