library IEEE;
use IEEE.std_logic_1164.all;

entity main is port (
	external_reset : in std_logic;
	clk : in std_logic);
end entity;


architecture dataflow of main is

	component sayeh is port (
		external_reset : in std_logic;
		clk : in std_logic;
		memdataready : in std_logic;
		databus : inout std_logic_vector (15 downto 0);
		address_out : out std_logic_vector (15 downto 0);
		sayeh_read_mem : out std_logic;
		sayeh_write_mem : out std_logic;
		sayeh_readio : out std_logic;
		sayeh_writeio : out std_logic);
	end component;

	component memory is
		generic (blocksize : integer := 1024);
	
		port (clk, readmem, writemem : in std_logic;
			addressbus: in std_logic_vector (15 downto 0);
			databus : inout std_logic_vector (15 downto 0);
			memdataready : out std_logic);
	end component;

	component port_manager is
		generic (blocksize : integer := 64);
	
		port (clk, readio, writeio : in std_logic;
			addressbus: in std_logic_vector (15 downto 0);
			databus : inout std_logic_vector (15 downto 0));
	end component;

--		sayeh
		signal memdataready : std_logic;

--		memory
	   	signal readmem, writemem, readio, writeio : std_logic;

--		common
		signal databus : std_logic_vector (15 downto 0) :=  (others => 'Z');
		signal addressbus: std_logic_vector (15 downto 0) := (others => '0');

begin

	label_sayeh: sayeh port map (external_reset=>external_reset, clk=>clk, memdataready=>memdataready,
								databus=>databus, address_out=>addressbus, sayeh_read_mem=>readmem,
								sayeh_write_mem=>writemem, sayeh_readio=>readio, sayeh_writeio=>writeio);

	label_memory: memory port map (clk=>clk, readmem=>readmem, writemem=>writemem, addressbus=>addressbus,
								  databus=>databus, memdataready=>memdataready);

	label_port_manager: port_manager port map (clk=>clk, readio=>readio, writeio=>writeio,
											   addressbus=>addressbus, databus=>databus);


	

end architecture;
