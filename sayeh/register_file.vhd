library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_file is port (
	WPinput : in std_logic_vector(5 downto 0);
	regSelects : in std_logic_vector(3 downto 0);
	Meminput : in std_logic_vector(15 downto 0);
	clk : in std_logic;
	RFLwrite, RFHwrite : in std_logic;
	Rs, Rd : out std_logic_vector(15 downto 0)
);
end entity;

architecture dataflow of register_file is
	

	type memory is array (0 to 63) of std_logic_vector(15 downto 0);
	signal mem : memory := (others => (others => '0'));
	signal Rd_select : std_logic_vector(1 downto 0);
	signal Rs_select : std_logic_vector(1 downto 0);

begin
	
	Rd_select <= regSelects(3 downto 2);
	Rs_select <= regSelects(1 downto 0);
	Rs <= mem(to_integer(unsigned(WPinput)) + to_integer(unsigned(Rs_select)));
	Rd <= mem(to_integer(unsigned(WPinput)) + to_integer(unsigned(Rd_select)));

	process (clk)
	begin
		if clk'event and clk = '1' then
			if RFLwrite = '1' and RFHwrite = '1' then
				mem(to_integer(unsigned(WPinput)) + to_integer(unsigned(Rd_select))) <= Meminput;
			elsif RFLwrite = '1' then
					mem(to_integer(unsigned(WPinput)) + to_integer(unsigned(Rd_select)))(7 downto 0) 
																<= Meminput(7 downto 0);
			    mem(to_integer(unsigned(WPinput)) + to_integer(unsigned(Rd_select)))(15 downto 8)  <= "ZZZZZZZZ";
			
			elsif RFHwrite = '1' then
					mem(to_integer(unsigned(WPinput)) + to_integer(unsigned(Rd_select)))(15 downto 8) 
									<= Meminput(7 downto 0);
			    mem(to_integer(unsigned(WPinput)) + to_integer(unsigned(Rd_select)))(7 downto 0)  <= "ZZZZZZZZ";
			end if;
		end if;
	end process;

end architecture;
