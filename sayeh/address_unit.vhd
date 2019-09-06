library IEEE;
use IEEE.std_logic_1164.all;


entity address_unit is port (
	EnablePC : in std_logic;
	PCinput : in std_logic_vector(15 downto 0);
	Rside : in std_logic_vector(15 downto 0);
	Iside : in std_logic_vector(7 downto 0);
	clk : in std_logic;
	ResetPC, PCplusI, PCplus1, RplusI, Rplus0 : IN std_logic;
	output : out std_logic_vector(15 downto 0) := "0000000000000000"
);

end entity;

architecture dataflow of address_unit is 

	component PC IS PORT ( 
     EnablePC : IN std_logic;
     input: IN std_logic_vector (15 DOWNTO 0);  
     clk : IN std_logic;  
 	 output: OUT std_logic_vector (15 DOWNTO 0)  
  );  
	END component;



	component  address_logic IS PORT (
		PCside, Rside : IN std_logic_vector (15 DOWNTO 0); 
		Iside : IN std_logic_vector (7 DOWNTO 0);
		ALout : OUT std_logic_vector (15 DOWNTO 0); 
		ResetPC, PCplusI, PCplus1, RplusI, Rplus0 : IN std_logic ); 
	END component;

	signal output_signal : std_logic_vector(15 downto 0);
	signal pcout : std_logic_vector(15 downto 0) := "0000000000000000";

begin

	output <= output_signal;
	l1 : PC port map (EnablePC=>EnablePC, input=>PCinput, clk=>clk, output=>pcout);
	
	l2: address_logic port map (PCside=>pcout, Rside=>Rside, Iside=>Iside
								  , ALout=>output_signal, ResetPC=>ResetPC, PCplusI=>PCplusI,
								  PCplus1=>PCplus1, RplusI=>RplusI, Rplus0=>Rplus0);


end architecture;


