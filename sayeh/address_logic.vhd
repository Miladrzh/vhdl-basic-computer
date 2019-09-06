library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY address_logic IS PORT (
	PCside, Rside : IN std_logic_vector (15 DOWNTO 0); 
	Iside : IN std_logic_vector (7 DOWNTO 0);
	ALout : OUT std_logic_vector (15 DOWNTO 0) := "0000000000000000"; 
	ResetPC, PCplusI, PCplus1, RplusI, Rplus0 : IN std_logic ); 
END ENTITY; 

ARCHITECTURE dataflow of address_logic IS
BEGIN 
	PROCESS (PCside, Rside, Iside, ResetPC, PCplusI, PCplus1, RplusI, Rplus0) 
	BEGIN
		if (ResetPC = '1') then
			ALout <= "0000000000000000";
		elsif (PCplusI'event and PCplusI = '1') then
			ALout <= std_logic_vector(unsigned(PCside) + unsigned(Iside));
		elsif (PCplus1'event and PCplus1 = '1') then
			ALout <= std_logic_vector(unsigned(PCside) + 1);
		elsif (RplusI'event  and RplusI = '1') then
			ALout <= std_logic_vector(unsigned(Rside) + unsigned(Iside));
		elsif (Rplus0'event and Rplus0 = '1') then
			ALout <= Rside;
		end if;
	END PROCESS; 
END dataflow;
