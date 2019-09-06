library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


ENTITY WP IS 
  PORT ( 
     WPadd : IN std_logic;
     WPreset : IN std_logic;
     input: IN std_logic_vector (5 DOWNTO 0);  
     clk : IN std_logic;  
     output: OUT std_logic_vector (5 DOWNTO 0)  
  );  
END WP;


ARCHITECTURE dataflow OF WP IS 

Signal temp : unsigned(5 downto 0) := "000000";
Signal uinput : unsigned(5 downto 0);

BEGIN
  output <= std_logic_vector(temp); 
  uinput <= unsigned(input);
  PROCESS (clk) BEGIN 
  
    IF (clk = '1' and clk'event) THEN 
     	IF (WPreset = '1') THEN 
	        temp <= "000000"; 
		ELSIF (WPadd = '1') THEN
      		temp <= temp + uinput;
      	END IF;
    END IF;
 END PROCESS;

END dataflow;

