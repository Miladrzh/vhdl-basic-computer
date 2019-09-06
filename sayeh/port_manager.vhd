library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity port_manager is
	generic (blocksize : integer := 64);

	port (clk, readio, writeio : in std_logic;
		addressbus: in std_logic_vector (15 downto 0);
		databus : inout std_logic_vector (15 downto 0));
end entity;

architecture behavioral of port_manager is
	type mem is array (0 to blocksize - 1) of std_logic_vector (15 downto 0);
begin
	process (clk)
		variable buffermem : mem := (others => (others => '0'));
		variable ad : integer;
		variable init : boolean := true;
	begin
		if init = true then
			-- some initiation
			buffermem(0) := "0000000000000000";
			init := false;
		end if;

		databus <= (others => 'Z');

		if  clk'event and clk = '1' then
			ad := to_integer(unsigned(addressbus));

			if readio = '1' then -- Readiing :)
				if ad >= blocksize then
					databus <= (others => 'Z');
				else
					databus <= buffermem(ad);
				end if;
			elsif writeio = '1' then -- Writing :)
				if ad < blocksize then
					buffermem(ad) := databus;
				end if;
			end if;
		end if;
	end process;
end architecture behavioral;
