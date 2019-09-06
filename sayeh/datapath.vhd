library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity datapath is port (
	clk : in std_logic;
	Address_on_Databus : in std_logic;
	Rs_on_AddressUnitRSide : in std_logic;
	Rd_on_AddressUnitRSide : in std_logic;
	ALUout_on_Databus : in std_logic;
	shadow : in std_logic;
	on_databus : inout std_logic_vector(15 downto 0);
	Zout : out std_logic;
	Cout : out std_logic;
	datapath_IRout : out std_logic_vector (15 downto 0);
	datapath_address_output : out std_logic_vector (15 downto 0);	
	read_bus : in std_logic;
	write_bus : in std_logic;

--	flags
	CSet, CReset, ZSet, ZReset, SRload : in std_logic;
--	register_file
	RFLwrite, RFHwrite : in std_logic;
--	alu
	B15to0 : in std_logic;
	AandB : in std_logic;
	AorB : in std_logic;
	Bshl : in std_logic;
 	Bshr : in std_logic;
	AcmpB : in std_logic;
	AaddB : in std_logic;
	AsubB : in std_logic;
	AxorB : in std_logic;
	Btws : in std_logic;
	AmulB : in std_logic;
	AdivB : in std_logic;
	Bsqr : in std_logic;
	rand : in std_logic;
	AnotB : in std_logic;
	sinB : in std_logic;
	cosB : in std_logic;
	tanB : in std_logic;
	cotB : in std_logic;  
--	wp
	WPadd : IN std_logic;
	WPreset : IN std_logic;
--	address_unit
	ResetPC, PCplusI, PCplus1, RplusI, Rplus0 , EnablePC : IN std_logic;
--	ir
	IRload : IN std_logic);
end entity;

architecture dataflow of datapath is 

	component IR is port (
		data : in std_logic_vector(15 downto 0);
		clk : in std_logic;
		IRload : in std_logic;
		IRout : out std_logic_vector(15 downto 0));
	end component;

	component WP IS PORT ( 
		WPadd : IN std_logic;
	   	WPreset : IN std_logic;
	   	input: IN std_logic_vector (5 DOWNTO 0);  
	   	clk : IN std_logic;  
	   	output: OUT std_logic_vector (5 DOWNTO 0));  
	END component;

	component flags is port(
		flag_Zin, flag_Cin : in std_logic;
		clk : in std_logic;
		CSet, CReset, ZSet, ZReset, SRload : in std_logic;
		flag_Zout, flag_Cout : out std_logic);
	end component;

	component register_file is port (
		WPinput : in std_logic_vector(5 downto 0);
		regSelects : in std_logic_vector(3 downto 0);
		Meminput : in std_logic_vector(15 downto 0);
		clk : in std_logic;
		RFLwrite, RFHwrite : in std_logic;
		Rs, Rd : out std_logic_vector(15 downto 0));
	end component;

	component ALU IS PORT ( 
   		clk : in std_logic;	
    	 
		A : in std_logic_vector(15 downto 0);
		B : in std_logic_vector(15 downto 0);
		output : out std_logic_vector (15 downto 0);
		
		ALU_Cin : in std_logic;
		ALU_Zin : in std_logic;
		
		ALU_Cout : out std_logic;
		ALU_Zout : out std_logic;

		B15to0 : in std_logic;
		AandB : in std_logic;
		AorB : in std_logic;
		Bshl : in std_logic;
  		Bshr : in std_logic;
		AcmpB : in std_logic;
		AaddB : in std_logic;
		AsubB : in std_logic;
		AxorB : in std_logic;
		Btws : in std_logic;
		AmulB : in std_logic;
		AdivB : in std_logic;
		Bsqr : in std_logic;
		rand : in std_logic;
		AnotB : in std_logic;
		sinB : in std_logic;
		cosB : in std_logic;
		tanB : in std_logic;
		cotB : in std_logic);  
	END component;
	
	component memory is port (
		address : in std_logic_vector(15 downto 0);
		data_in : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0);
		clk, rwbar : in std_logic);
	end component memory;

	component PC IS PORT ( 
    	EnablePC : IN std_logic;
    	input: IN std_logic_vector (15 DOWNTO 0);  
    	clk : IN std_logic;  output: 
    	OUT std_logic_vector (15 DOWNTO 0));  
	END component;


	component address_logic IS PORT (
		PCside, Rside : IN std_logic_vector (15 DOWNTO 0); 
		Iside : IN std_logic_vector (7 DOWNTO 0);
		ALout : OUT std_logic_vector (15 DOWNTO 0); 
		ResetPC, PCplusI, PCplus1, RplusI, Rplus0 : IN std_logic ); 
	END component;


	component address_unit is port (
		EnablePC : in std_logic;
		PCinput : in std_logic_vector(15 downto 0);
		Rside : in std_logic_vector(15 downto 0);
		Iside : in std_logic_vector(7 downto 0);
		clk : in std_logic;
		ResetPC, PCplusI, PCplus1, RplusI, Rplus0 : IN std_logic;
		output : out std_logic_vector(15 downto 0));
	end component;

	component shadow_handler is port (
		shadow0to3 : in std_logic_vector(3 downto 0);
		shadow8to11 : in std_logic_vector(3 downto 0);
	 	shadow_select : in std_logic;
	  	shadow_out : out std_logic_vector(3 downto 0));
	end component;


--	ir
	signal ir_data : std_logic_vector(15 downto 0);
--	signal IRload : std_logic;
	signal IRout : std_logic_vector(15 downto 0);

--	address_unit
	signal PCinput : std_logic_vector(15 downto 0);
	signal Rside : std_logic_vector(15 downto 0);
	signal Iside : std_logic_vector(7 downto 0);
--	signal ResetPC, PCplusI, PCplus1, RplusI, Rplus0 : std_logic;
	signal address_output : std_logic_vector(15 downto 0);

--	register_file
	signal reg_WPinput : std_logic_vector(5 downto 0);
	signal regSelects : std_logic_vector(3 downto 0);
	signal Meminput : std_logic_vector(15 downto 0);
--	signal RFLwrite, RFHwrite : std_logic;
	signal Rs, Rd : std_logic_vector(15 downto 0);

--	flags
	signal flag_Zin, flag_Cin : std_logic;
--	signal CSet, CReset, ZSet, ZReset, SRload : std_logic;
	signal flag_Zout, flag_Cout : std_logic;

--	alu
	signal alu_A : std_logic_vector(15 downto 0);
	signal alu_B : std_logic_vector(15 downto 0);
	signal alu_output : std_logic_vector (15 downto 0);
	signal alu_Cin : std_logic;
	signal alu_Zin : std_logic;
	signal alu_Cout : std_logic;
	signal alu_Zout : std_logic;
--	signal AandB : std_logic;
--	signal AorB : std_logic;
--	signal Bshl : std_logic;
--	signal AcmpB : std_logic;
--	signal AaddB : std_logic;
--	signal AsubB : std_logic;
--	signal AxorB : std_logic; 

--	wp
--	signal WPadd : std_logic;
--	signal WPreset : std_logic;
	signal wp_input: std_logic_vector (5 DOWNTO 0);  
	signal wp_output: std_logic_vector (5 DOWNTO 0); 

--	shadow_handler

	signal shadow0to3 : std_logic_vector(3 downto 0);
	signal shadow8to11 : std_logic_vector(3 downto 0);
--	signal shadow_select : std_logic;
	signal shadow_out : std_logic_vector(3 downto 0);
	
	signal common : std_logic_vector(15 downto 0) := (others => 'Z');
	signal Address_unit_rside_bus : std_logic_vector(15 downto 0); 


begin
	ir_data <= common;
	alu_A <= Rd;
	alu_B <= Rs;
	wp_input <= IRout(5 downto 0);
	reg_WPinput <= wp_output;
	Iside <= IRout(7 downto 0);
	shadow0to3 <= IRout(3 downto 0);
	shadow8to11 <= IRout(11 downto 8);
	regSelects <= shadow_out;
	Meminput <= common;
	flag_Cin <= alu_Cout;
	flag_Zin <= alu_Zout;
	alu_Cin <= flag_Cout;
	alu_Zin <= flag_Zout;
	Rside <= Address_unit_rside_bus;
	PCinput <= address_output;
	datapath_address_output <= address_output;
	--on_databus <= common;
	datapath_IRout <= IRout;
  
  Cout <= flag_Cout;
  Zout <= flag_Zout;
	label_ir: IR port map (data=>ir_data, clk=>clk, IRload=>IRload, IRout=>IRout);

	label_address_unit: address_unit port map (EnablePC=>EnablePc , PCinput=>PCinput, Rside=>Rside, 
							Iside=>Iside, clk=>clk, ResetPC=>ResetPC, PCplusI=>PCplusI, PCplus1=>PCplus1, 
							RplusI=>RplusI, Rplus0=>Rplus0, output=>address_output);

	label_register_file: register_file port map(WPinput=>reg_WPinput, regSelects=>regSelects,
											   	Meminput=>Meminput, clk=>clk, RFLwrite=>RFLwrite, 
							 RFHwrite=>RFHwrite, Rs=>Rs, Rd=>Rd);

	label_flags: flags port map (flag_Zin=>flag_Zin, flag_Cin=>flag_Cin, clk=>clk, CSet=>cset,
								 CReset=>CReset, ZSet=>ZSet, ZReset=>ZReset, SRload=> SRload, 
								 flag_Zout=>flag_Zout, flag_Cout=>flag_Cout);


	label_alu: ALU port map (clk=>clk, A=>alu_A, B=>alu_B, output=>alu_output,
							 ALU_Cin=>alu_Cin, ALU_Zin=>alu_Zin,
							 ALU_Cout=>alu_Cout, ALU_Zout=>alu_Zout, B15to0=>B15to0, 
							 AandB=>AandB, AorB=>AorB, Bshl=>Bshl, Bshr=>Bshr, AcmpB=>AcmpB,
							 AaddB=>AaddB, AsubB=>AsubB, AxorB=>AxorB, Btws=>Btws, AmulB=>AmulB,
							 AdivB=>AdivB, Bsqr=>Bsqr, rand=>rand, AnotB=>AnotB, sinB=>sinB, cosB=>cosB,
							 tanB=>tanB, cotB=>cotB);

	label_wp: WP port map (WPadd=>WPadd, WPreset=>WPreset, input=>wp_input, clk=>clk, output=>wp_output);


	label_shadow_handler: shadow_handler port map (shadow0to3=>shadow0to3, shadow8to11=>shadow8to11, 
												  shadow_select=>shadow, shadow_out=>shadow_out);


	
	process (Rs_on_AddressUnitRSide, Rd_on_AddressUnitRSide, Address_on_Databus, ALUout_on_Databus ,
	   	read_bus, write_bus , clk) 
	begin
	  if (clk = '0') then
	  on_databus <= (others => 'Z');
		if (Rs_on_AddressUnitRSide = '1') then
			Address_unit_rside_bus <= Rs;
		elsif (Rd_on_AddressUnitRSide = '1') then
			Address_unit_rside_bus <= Rd;
		else
			Address_unit_rside_bus <= (others => 'Z');
		end if;

		if (Address_on_Databus = '1') then
			common <= address_output;
		elsif (ALUout_on_Databus = '1') then
			common <= alu_output;
		elsif (read_bus = '1') then
		   common <= on_databus;
	   	elsif (write_bus = '1') then
	 		on_databus <= common;		
		end if;
		end if;
	end process;
	
end architecture;	
	
