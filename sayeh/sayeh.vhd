library IEEE;
use IEEE.std_logic_1164.all;

entity sayeh is port (
	external_reset : in std_logic;
	clk : in std_logic;
	memdataready : in std_logic;
	databus : inout std_logic_vector (15 downto 0);
	address_out : out std_logic_vector (15 downto 0);
	sayeh_read_mem : out std_logic;
	sayeh_write_mem : out std_logic;
	sayeh_readio : out std_logic;
	sayeh_writeio : out std_logic);
end entity;


architecture dataflow of sayeh is 

	component controller is port(
  		IRout : in std_logic_vector(15 downto 0);
  		External_Reset : in std_logic;
  		MemDataReady : in std_logic;
  		Zout : in std_logic;
  		Cout : in std_logic;
  		clk : in std_logic;
  		
  		Address_on_Databus : out std_logic;
  		Rs_on_AddressUnitRSide : out std_logic;
  		Rd_on_AddressUnitRSide : out std_logic;
  		ALUout_on_Databus : out std_logic;
  		shadow : out std_logic;
  		
--		  flags
  		CSet, CReset, ZSet, ZReset, SRload : out std_logic;
--		  register_file
  		RFLwrite, RFHwrite : out std_logic;
--		  alu
		B15to0 : out std_logic;
		AandB : out std_logic;
		AorB : 	out std_logic;
		Bshl : 	out std_logic;
	  	Bshr : 	out std_logic;
		AcmpB : out std_logic;
		AaddB : out std_logic;
		AsubB : out std_logic;
		AxorB : out std_logic;
		Btws : 	out std_logic;
		AmulB : out std_logic;
		AdivB : out std_logic;
		Bsqr : 	out std_logic;
		rand : 	out std_logic;
		AnotB : out std_logic;
		sinB : 	out std_logic;
		cosB : 	out std_logic;
		tanB : 	out std_logic;
		cotB : 	out std_logic;  
--		  wp
  		WPadd : out std_logic;
  		WPreset : out std_logic;
--		  address_unit
  		ResetPC, PCplusI, PCplus1, RplusI, Rplus0 , EnablePC : out std_logic;
--		  ir
  		IRload : out std_logic;
  		readmem, writemem, readio, writeio : out std_logic);
	end component;


	component datapath is port (
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

--		flags
		CSet, CReset, ZSet, ZReset, SRload : in std_logic;
--		register_file
		RFLwrite, RFHwrite : in std_logic;
--		alu
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
--		wp
		WPadd : IN std_logic;
		WPreset : IN std_logic;
--		address_unit
		ResetPC, PCplusI, PCplus1, RplusI, Rplus0 , EnablePC : IN std_logic;
--		ir
		IRload : in std_logic);
	end component;
	
	--	datapath
	signal	Address_on_Databus : std_logic;
	signal	Rs_on_AddressUnitRSide : std_logic;
	signal	Rd_on_AddressUnitRSide : std_logic;
	signal	ALUout_on_Databus : std_logic;
	signal	shadow : std_logic;
	signal	on_databus : std_logic_vector(15 downto 0);
	signal 	Zout : std_logic;
	signal 	Cout : std_logic;
	signal	read_bus : std_logic;
	signal	write_bus : std_logic;

--	signal	flags
	signal	CSet, CReset, ZSet, ZReset, SRload : std_logic;
--	signal	register_file
	signal	RFLwrite, RFHwrite : std_logic;
--	signal	alu
	signal	B15to0 : std_logic;
	signal	AandB : std_logic;
	signal	AorB : std_logic;
	signal	Bshl : std_logic;
	signal 	Bshr : std_logic;
	signal	AcmpB : std_logic;
	signal	AaddB : std_logic;
	signal	AsubB : std_logic;
	signal	AxorB : std_logic;
	signal	Btws : std_logic;
	signal	AmulB : std_logic;
	signal	AdivB : std_logic;
	signal	Bsqr : std_logic;
	signal	rand : std_logic;
	signal	AnotB : std_logic;
	signal	sinB : std_logic;
	signal	cosB : std_logic;
	signal	tanB : std_logic;
	signal	cotB : std_logic;  
--	signal	wp
	signal	WPadd : std_logic;
	signal	WPreset : std_logic;
--	signal	address_unit
	signal	ResetPC, PCplusI, PCplus1, RplusI, Rplus0  , EnablePC: std_logic;
--	signal	ir
	signal	IRload : std_logic;

--	common
	signal read_mem, write_mem, readio, writeio: std_logic;
	signal IRout : std_logic_vector (15 downto 0);

begin

	sayeh_read_mem <= read_mem;
	sayeh_write_mem <= write_mem;
	sayeh_readio <= readio;
	sayeh_writeio <= writeio;
	read_bus <= read_mem or readio;
	write_bus <= writeio or write_mem;
--	on_databus <= databus;
--	databus <= on_databus;
--	address_out <= datapath_address_output;
	

	
	label_datapath: datapath port map (clk=>clk, Address_on_Databus=>Address_on_Databus,
						   Rs_on_AddressUnitRSide=>Rs_on_AddressUnitRSide,
						   Rd_on_AddressUnitRSide=>Rd_on_AddressUnitRSide, 
						   ALUout_on_Databus=>ALUout_on_Databus, shadow=>shadow, on_databus=>databus,
						   Zout=>Zout, Cout=>Cout, datapath_IRout=>IRout, 
						   datapath_address_output=>address_out, read_bus=>read_bus, write_bus=>write_bus,  
						   CSet=>CSet, CReset=>CReset, ZSet=>ZSet, ZReset=>ZReset, SRload=>SRload,
				   		   RFLwrite=>RFLwrite, RFHwrite=>RFHwrite,B15to0=>B15to0, 
						   AandB=>AandB, AorB=>AorB, Bshl=>Bshl, Bshr=>Bshr, AcmpB=>AcmpB,
						   AaddB=>AaddB, AsubB=>AsubB, AxorB=>AxorB, Btws=>Btws, AmulB=>AmulB,
						   AdivB=>AdivB, Bsqr=>Bsqr, rand=>rand, AnotB=>AnotB, sinB=>sinB, cosB=>cosB,
						   tanB=>tanB, cotB=>cotB, WPadd=>WPadd,
				  		   WPreset=>WPreset, ResetPC=>ResetPC, PCplusI=>PCplusI, PCplus1=>PCplus1,
						   RplusI=>RplusI, Rplus0=>Rplus0 , EnablePC => EnablePc, IRload=>IRload);

	label_controller: controller port map (IRout=>IRout, External_Reset=>external_reset,
						   MemDataReady=>MemDataReady, Zout=>Zout, Cout=>Cout, 
						   clk=>clk, Address_on_Databus=>Address_on_Databus,
						   Rs_on_AddressUnitRSide=>Rs_on_AddressUnitRSide,
						   Rd_on_AddressUnitRSide=>Rd_on_AddressUnitRSide, 
						   ALUout_on_Databus=>ALUout_on_Databus,shadow=>shadow,
						   CSet=>CSet, CReset=>CReset, ZSet=>ZSet, ZReset=>ZReset, SRload=>SRload,
				   		   RFLwrite=>RFLwrite, RFHwrite=>RFHwrite,  B15to0=>B15to0, 
						   AandB=>AandB, AorB=>AorB, Bshl=>Bshl, Bshr=>Bshr, AcmpB=>AcmpB,
						   AaddB=>AaddB, AsubB=>AsubB, AxorB=>AxorB, Btws=>Btws, AmulB=>AmulB,
						   AdivB=>AdivB, Bsqr=>Bsqr, rand=>rand, AnotB=>AnotB, sinB=>sinB, cosB=>cosB,
						   tanB=>tanB, cotB=>cotB, WPadd=>WPadd,
				  		   WPreset=>WPreset, ResetPC=>ResetPC, PCplusI=>PCplusI, PCplus1=>PCplus1,
						   RplusI=>RplusI, Rplus0=>Rplus0 , EnablePC => EnablePC , IRload=>IRload, 
						   readmem=>read_mem, writemem=>write_mem,
						   readio=>readio, writeio=>writeio);


end architecture;
