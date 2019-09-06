library IEEE;
use IEEE.std_logic_1164.all;


entity controller is port(
	IRout : in std_logic_vector(15 downto 0);
	External_Reset : in std_logic;
	MemDataReady : in std_logic;
	Zout : in std_logic;
	Cout : in std_logic;
	clk : in std_logic;
  
	Address_on_Databus : out std_logic := '0';
	Rs_on_AddressUnitRSide : out std_logic := '0';
	Rd_on_AddressUnitRSide : out std_logic := '0';
	ALUout_on_Databus : out std_logic := '0';
	shadow : out std_logic := '0';
	
--	flags
	CSet, CReset, ZSet, ZReset, SRload : out std_logic := '0';
--	register_file
	RFLwrite, RFHwrite : out std_logic := '0';
--	alu
	B15to0 :out std_logic := '0';
	AandB : out std_logic := '0';
	AorB : 	out std_logic := '0';
	Bshl : 	out std_logic := '0';
 	Bshr : 	out std_logic := '0';
	AcmpB : out std_logic := '0';
	AaddB : out std_logic := '0';
	AsubB : out std_logic := '0';
	AxorB : out std_logic := '0';
	Btws : 	out std_logic := '0';
	AmulB : out std_logic := '0';
	AdivB : out std_logic := '0';
	Bsqr : 	out std_logic := '0';
	rand : 	out std_logic := '0';
	AnotB : out std_logic := '0';
	sinB : 	out std_logic := '0';
	cosB : 	out std_logic := '0';
	tanB : 	out std_logic := '0';
	cotB : 	out std_logic := '0';  
--	wp
	WPadd : out std_logic := '0';
	WPreset : out std_logic := '0';
--	address_unit
	ResetPC, PCplusI, PCplus1, RplusI, Rplus0 , EnablePC : out std_logic := '0';
--	ir
	IRload : out std_logic := '0';
	ReadMem,WriteMem , Readio, Writeio: out std_logic := '0'
  );
end entity;

architecture dataflow of controller is
  type state is (BEGIN_TIME1 , BEGIN_TIME2 , BEGIN_TIME3 , BEGIN_TIME4 , Start , Fetch , Decode_16_8 , Decode_16 , Decode_8 , nop0 , mil0 , mih0 , spc0 , jpa0
  , jpr0 , brz0 , brc0 , awp0 , div0 , sqr0 , rand0 , xor0 , twocomp0 , hlt0 , szf0 , czf0 , scf0 , ccf0 
  , cwp0 , mvr0 , lda0 , sta0 , inp0 , oup0 , and0 , orr0 , not0 , shl0 , shr0 , add0 , sub0 , mul0 , cmp0 
  , hlt1 , szf1 , czf1 , scf1 , ccf1 , cwp1 , jpr1 , brz1 , brc1 , awp1 , mil1 , mih1 , spc1 , spc2 
  , jpa1 , jpa2 , jpa3 , and1 , and2 , and3 , and4 , orr1 , orr2 , orr3 , orr4 , not1 , not2 , not3 , not4 
  , shl1 , shl2 , shl3 , shl4 , shr1 , shr2 , shr3 , shr4 , add1 , add2 , add3 , add4 , sub1 , sub2 , sub3
  , sub4 , mul1 , mul2 , mul3 , mul4 , cmp1 , cmp2 , cmp3 , cmp4 , mvr1 , mvr2 , mvr3 , mvr4 , sin0 , cos0 
  , cot0 , tan0 , lda1 , lda2 , lda3 , lda4 , sta1 , sta2 , sta3 , sta4 , spc3 , inp1 , inp2 , inp3 , inp4
  , oup1 , oup2 , oup3 , xor1 , xor2 , xor3 , xor4 , rand1 , rand2 , rand3 , rand4 , twocomp1 , twocomp2  , twocomp3 , twocomp4 , sqr1 , sqr2 , sqr3 , sqr4 , div1 , div2 , div3 , div4);
  Signal currentState : state := Start;
  Signal nextState : state;
  Signal shadow_temp : std_logic := '0';
Begin
	shadow <= shadow_temp;
	process (clk , External_Reset) begin
		if (External_Reset = '1') then
			currentState <= Start;
		elsif (clk'event  and clk = '1') then 
			currentState <= nextState;
		end if;
	end process;
  
	process (currentState) begin
		case currentState is 
			when Start =>
			   nextSTate <= BEGIN_TIME2;
			when BEGIN_TIME2 =>
			   nextSTate <= BEGIN_TIME3;
			   
			when BEGIN_TIME3 =>
			   nextSTate <= BEGIN_TIME1;
			   readmem <= '1';
			when BEGIN_TIME1 =>
			  shadow_temp <= '0';
			  EnablePC <= '0';
				IRload <= '1';
				PCplus1 <= '0';
				readmem <= '1';
				nextState <= Fetch;
			--------------------------
			when Fetch =>
			    IRload <= '0';
					nextState <= Decode_16_8;
			------------------------
			when Decode_16_8 =>
			  IRload <= '0';
				if (IRout(15 downto 12) = "1111") then
					nextState <= Decode_16;
				elsif (IRout(15 downto 8) = "00001111") then 
					nextState <= Decode_16;
				elsif (IRout(15 downto 12) /= "0000") then
					nextState <= Decode_8;
				else
					if (IRout(11 downto 10) = "00" or (IRout(11 downto 10) = "01" 
												and IRout(9 downto 8) /= "11")) then
						nextState <= Decode_8;
					else
						nextState <= Decode_16;
					end if;
				end if;
			
			when Decode_16 => 
				IRload <= '0';
				if (IRout(15 downto 12) = "1111") then
					if (IRout(9 downto 8) = "00") then
						nextState <= mil0;
					elsif (IRout(9 downto 8) = "01") then
						nextState <= mih0;
					elsif (IRout(9 downto 8) = "10") then
						nextState <= spc0;
						readmem <= '0';
					elsif (IRout(9 downto 8) = "11") then
						nextState <= jpa0;
						readmem <= '0';
					end if;
				
				elsif (IRout(11 downto 8) = "0111") then
					nextState <= jpr0;
					readmem <= '0';
				elsif (IRout(11 downto 8) = "1000") then
					nextState <= brz0;
					readmem <= '0';
				elsif (IRout(11 downto 8) = "1001") then
					nextState <= brc0;
					readmem <= '0';
				elsif (IRout(11 downto 8) = "1010") then
					nextState <= awp0;
					readmem <= '0';
				elsif (IRout(15 downto 8) = "00001111") then 
					readmem <= '0';
					if (IRout(7 downto 4) = "0000") then 
						nextState <= div0;
					elsif (IRout(7 downto 4) = "0001") then 
						nextState <= sqr0;
					elsif (IRout(7 downto 4) = "0010") then 
						nextState <= rand0;
					elsif (IRout(7 downto 4) = "0011") then 
						nextState <= xor0;
					elsif (IRout(7 downto 4) = "0100") then 
						nextState <= twocomp0;
					elsif (IRout(7 downto 4) = "0101") then 
						nextState <= sin0;
					elsif (IRout(7 downto 4) = "0110") then 
						nextState <= cos0;
					elsif (IRout(7 downto 4) = "0111") then 
						nextState <= tan0;
					elsif (IRout(7 downto 4) = "1000") then 
						nextState <= cot0;
					end if;
				end if;

			
			when mil0 =>
				RFLwrite <= '1';
				nextState <= mil1;
			when mil1 =>
				RFLwrite <= '0';
				nextState <= Start;
				PCplus1 <= '1';
			  EnablePC <= '1';
			
			when mih0 =>
				RFHwrite <= '1';
				nextState <= mih1;
			when mih1 =>
				RFHwrite <= '0';
				nextState <= Start;
				PCplus1 <= '1';
			  EnablePC <= '1';
			  
			when spc0 => 
				PCplusI <= '1';
				nextState <= spc1;
			when spc1 =>
				PCplusI <= '0';
				Address_on_Databus <= '1';
				nextState <= spc2;
			when spc2 => 
				RFLwrite <= '1';
				RFHwrite <= '1';
				nextState <= spc3;
			when spc3 => 
				Address_on_Databus <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				PCplus1 <= '1';
				nextState <= Start;
			  EnablePC <= '1';
			  
			when jpa0 => 
				Rd_on_AddressUnitRSide <= '1';
				nextState <= jpa1;
			when jpa1 => 
				nextState <= jpa2;
			when jpa2 => 
				Rd_on_AddressUnitRSide <= '0';
				RplusI <= '1';
				nextState <= jpa3;
			when jpa3 => 
				RplusI <= '0';
				nextState <= Start;
			  EnablePC <= '1';
			  
			when jpr0 => 
				PCplusI <= '1';
				nextState <= jpr1;
			when jpr1 => 
				PCplusI <= '0';
				nextState <= Start;
			  EnablePC <= '1';
			  
			when brz0 => 
				if (Zout = '1') then
					PCplusI <= '1';
					nextState <= brz1;
				else
					PCplus1 <= '1';
					nextState <= brz1;
				end if;
			when brz1 =>
				PCplusI <= '0';
				nextState <= Start;
			  EnablePC <= '1';
			  
			when brc0 => 
				if (Cout = '1') then
					PCplusI <= '1';
					nextState <= brc1;
				else
					PCplus1 <= '1';
					nextState <= brc1;
				end if;
			when brc1 =>
				PCplusI <= '0';
				nextState <= Start;
			  EnablePC <= '1';
			  
			when awp0 => 
				WPadd <= '1';
				nextState <= awp1;	
			when awp1 =>
				WPadd <= '0';
				PCplus1 <= '1';
				nextState <= Start;
			  EnablePC <= '1';
			------------------------------------ decode 8
			when Decode_8 =>
				IRload <= '0';
				readmem <= '0';
				if (shadow_temp = '0') then
					if (IRout(15 downto 12) = "0000") then
						if (IRout(11 downto 8) = "0000") then
							nextState <= nop0;
						elsif (IRout(11 downto 8) = "0001") then
							nextState <= hlt0;
						elsif (IRout(11 downto 8) = "0010") then
							nextState <= szf0;
						elsif (IRout(11 downto 8) = "0011") then
							nextState <= czf0;
						elsif (IRout(11 downto 8) = "0100") then
							nextState <= scf0;
						elsif (IRout(11 downto 8) = "0101") then
							nextState <= ccf0;
						elsif (IRout(11 downto 8) = "0110") then
							nextState <= cwp0;
						end if;
					elsif (IRout(15 downto 12) = "0001") then 
						nextState <= mvr0;
					elsif (IRout(15 downto 12) = "0010") then 
						nextState <= lda0;
					elsif (IRout(15 downto 12) = "0011") then 
						nextState <= sta0;
					elsif (IRout(15 downto 12) = "0100") then 
						nextState <= inp0;
					elsif (IRout(15 downto 12) = "0101") then 
						nextState <= oup0;
					elsif (IRout(15 downto 12) = "0110") then 
						nextState <= and0;
					elsif (IRout(15 downto 12) = "0111") then 
						nextState <= orr0;
					elsif (IRout(15 downto 12) = "1000") then 
						nextState <= not0;
					elsif (IRout(15 downto 12) = "1001") then 
						nextState <= shl0;
					elsif (IRout(15 downto 12) = "1010") then 
						nextState <= shr0;
					elsif (IRout(15 downto 12) = "1011") then 
						nextState <= add0;
					elsif (IRout(15 downto 12) = "1100") then 
						nextState <= sub0;	
					elsif (IRout(15 downto 12) = "1101") then 
						nextState <= mul0;
					elsif (IRout(15 downto 12) = "1110") then 
						nextState <= cmp0;
					end if;
				else
					if (IRout(7 downto 4) = "0000") then
						if (IRout(3 downto 0) = "0000") then
							nextState <= nop0;
						elsif (IRout(3 downto 0) = "0001") then
							nextState <= hlt0;
						elsif (IRout(3 downto 0) = "0010") then
							nextState <= szf0;
						elsif (IRout(3 downto 0) = "0011") then
							nextState <= czf0;
						elsif (IRout(3 downto 0) = "0100") then
							nextState <= scf0;
						elsif (IRout(3 downto 0) = "0101") then
							nextState <= ccf0;
						elsif (IRout(3 downto 0) = "0110") then
							nextState <= cwp0;
						end if;
					elsif (IRout(7 downto 4) = "0001") then 
						nextState <= mvr0;
					elsif (IRout(7 downto 4) = "0010") then 
						nextState <= lda0;
					elsif (IRout(7 downto 4) = "0011") then 
						nextState <= sta0;
					elsif (IRout(7 downto 4) = "0100") then 
						nextState <= inp0;
					elsif (IRout(7 downto 4) = "0101") then 
						nextState <= oup0;
					elsif (IRout(7 downto 4) = "0110") then 
						nextState <= and0;
					elsif (IRout(7 downto 4) = "0111") then 
						nextState <= orr0;
					elsif (IRout(7 downto 4) = "1000") then 
						nextState <= not0;
					elsif (IRout(7 downto 4) = "1001") then 
						nextState <= shl0;
					elsif (IRout(7 downto 4) = "1010") then 
						nextState <= shr0;
					elsif (IRout(7 downto 4) = "1011") then 
						nextState <= add0;
					elsif (IRout(7 downto 4) = "1100") then 
						nextState <= sub0;	
					elsif (IRout(7 downto 4) = "1101") then 
						nextState <= mul0;
					elsif (IRout(7 downto 4) = "1110") then 
						nextState <= cmp0;
					end if;	
				end if;

			when oup0 =>
				nextState <= oup1;
				B15to0 <= '1';
				Rd_on_AddressUnitRSide <= '1';
			when oup1 =>
				ALUout_on_Databus <= '1';
				Rplus0 <= '1';
				nextState <= oup2;
			when oup2 =>
				Writeio <= '1';
				nextState <= oup3;
			when oup3 =>
				Writeio <= '0';
				ALUout_on_Databus <= '0';
				B15to0 <= '0';
				Rd_on_AddressUnitRSide <= '0';
				Rplus0 <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;


			
			when inp0 =>
				Rs_on_AddressUnitRSide <= '1';
				nextState <= inp1;
			when inp1 =>
				Rplus0 <= '1';
				nextState <= inp2;
			when inp2 =>
				readio <= '1';
				Rs_on_AddressUnitRSide <= '0';
				nextState <= inp3;
			when inp3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				nextState <= inp4;
			when inp4 =>
				Rplus0 <= '0';
				readio <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
				
				
			when nop0 =>
				if (shadow_temp = '1') then
					nextState <= Start;
					shadow_temp <= '0';
					PCplus1 <= '1';
				else
					EnablePC <= '1';
					shadow_temp <= '1';
					nextState <= Decode_8;
				end if;
			
			when hlt0 => 
				nextState <= hlt1;	
			when hlt1 =>
				nextState <= hlt0;
			
			when szf0 => 
				ZSet <= '1';
				nextState <= szf1;
			when szf1 =>
				ZSet <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when czf0 => 
				ZReset <= '1';
				nextState <= czf1;
			when czf1 =>
				ZReset <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when scf0 => 
				CSet <= '1';
				nextState <= scf1;
			when scf1 =>
				CSet <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when ccf0 => 
				CReset <= '1';
				nextState <= ccf1;
			when ccf1 =>
				
				CReset <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when cwp0 =>
				WPreset <= '1';
				nextState <= cwp1;	
			when cwp1 =>
				
				WPreset <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			----------------------- ALU Instruction
			when mvr0 =>
				B15to0 <= '1';
				nextState <= mvr1;
			when mvr1 => 
				nextState <= mvr2;
			when mvr2 => 
				B15to0 <= '0';
				ALUout_on_Databus <= '1';
				nextState <= mvr3;
			when mvr3 =>
				
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= mvr4;
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when lda0 =>
				Rs_on_AddressUnitRSide <= '1';
				nextState <= lda1;
			when lda1 =>
				Rplus0 <= '1';
				nextState <= lda2;
			when lda2 =>
				readmem <= '1';
				Rs_on_AddressUnitRSide <= '0';
				nextState <= lda3;
			when lda3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				nextState <= lda4;
			when lda4 =>
				Rplus0 <= '0';
				readmem <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when sta0 =>
				nextState <= sta1;
				B15to0 <= '1';
				Rd_on_AddressUnitRSide <= '1';
			when sta1 =>
				ALUout_on_Databus <= '1';
				Rplus0 <= '1';
				nextState <= sta2;
			when sta2 =>
				WriteMem <= '1';
				nextState <= sta3;
			when sta3 =>
				WriteMem <= '0';
				ALUout_on_Databus <= '0';
				B15to0 <= '0';
				Rd_on_AddressUnitRSide <= '0';
				Rplus0 <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when and0 => 
				AandB <= '1';
				nextState <= and1;
			when and1 =>
				nextState <= and2;
			when and2 =>
			  srload <= '1';
				AandB <= '0';
				ALUout_on_Databus <= '1';
				nextState <= and3;
			when and3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= and4;
			when and4 =>
				srload <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when orr0 => 
				AorB <= '1';
				nextState <= orr1;
			when orr1 =>
				nextState <= orr2;
			when orr2 =>
			  srload <= '1';
				AorB <= '0';
				ALUout_on_Databus <= '1';
				nextState <= orr3;
			when orr3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= orr4;
			when orr4 =>
				srload <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when not0 => 
				AnotB <= '1';
				nextState <= not1;
			when not1 =>
				nextState <= not2;
			when not2 =>
			  srload <= '1';
				AnotB <= '0';
				ALUout_on_Databus <= '1';
				nextState <= not3;
			when not3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= not4;
			when not4 =>
			  srload <= '0';
				EnablePC <= '1';
				RFHwrite <= '0';
				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when shl0 => 
				Bshl <= '1';
				nextState <= shl1;
			when shl1 =>
				nextState <= shl2;
			when shl2 =>
			  srload <= '1';
				Bshl <= '0';
				ALUout_on_Databus <= '1';
				nextState <= shl3;
			when shl3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= shl4;
			when shl4 =>
				srload <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when shr0 => 
				Bshr <= '1';
				nextState <= shr1;
			when shr1 =>
				nextState <= shr2;
			when shr2 =>
			  srload <= '1';
				Bshr <= '0';
				ALUout_on_Databus <= '1';
				nextState <= shr3;
			when shr3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= shr4;
			when shr4 =>
				srload <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when add0 => 
				AaddB <= '1';
				nextState <= add1;
			when add1 =>
				nextState <= add2;
			when add2 =>
			  srload <= '1';
				AaddB <= '0';
				ALUout_on_Databus <= '1';
				nextState <= add3;
			when add3 =>
			  srload <= '0';
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= add4;
			when add4 =>
				RFHwrite <= '0';
				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when sub0 => 
				AsubB <= '1';
				nextState <= sub1;
			when sub1 =>
				nextState <= sub2;
			when sub2 =>
			  srload <= '1';
				AsubB <= '0';
				ALUout_on_Databus <= '1';
				nextState <= sub3;
			when sub3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= sub4;
			when sub4 =>
				srload <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when mul0 => 
				AmulB <= '1';
				nextState <= mul1;
			when mul1 =>
				nextState <= mul2;
			when mul2 =>
			  srload <= '1';
				AmulB <= '0';
				ALUout_on_Databus <= '1';
				nextState <= mul3;
			when mul3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= mul4;
			when mul4 =>
			  srload  <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;
			
			when cmp0 => 
				AcmpB <= '1';
				nextState <= cmp1;
			when cmp1 =>
				nextState <= cmp2;
			when cmp2 =>
			  srload <= '1';
--				AcmpB <= '0';
--				ALUout_on_Databus <= '1';
				nextState <= cmp3;
			when cmp3 =>
--				RFHwrite <= '1';
--				RFLwrite <= '1';
--				ALUout_on_Databus <= '0';
				nextState <= cmp4;
			when cmp4 =>
				srload <= '0';
				AcmpB <= '0';
--				RFHwrite <= '0';
--				RFLwrite <= '0';
				if (shadow_temp = '0') then 
					shadow_temp <= '1';
					nextState <= Decode_8;
				else
					EnablePC <= '1';
					shadow_temp <= '0';
					PCplus1 <= '1';
					nextState <= Start;
				end if;

			when rand0 => 
				rand <= '1';
				nextState <= rand1;
			when rand1 =>
				nextState <= rand2;
			when rand2 =>
				srload <= '1';
				rand <= '0';
				ALUout_on_Databus <= '1';
				nextState <= rand3;
			when rand3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= rand4;
			when rand4 =>
				srload  <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				EnablePC <= '1';
				shadow_temp <= '0';
				PCplus1 <= '1';
				nextState <= Start;
			
			when sqr0 => 
				Bsqr <= '1';
				nextState <= sqr1;
			when sqr1 =>
				nextState <= sqr2;
			when sqr2 =>
				srload <= '1';
				Bsqr <= '0';
				ALUout_on_Databus <= '1';
				nextState <= sqr3;
			when sqr3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= sqr4;
			when sqr4 =>
				srload  <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				EnablePC <= '1';
				shadow_temp <= '0';
				PCplus1 <= '1';
				nextState <= Start;
			
			when div0 => 
				AdivB <= '1';
				nextState <= div1;
			when div1 =>
				nextState <= div2;
			when div2 =>
				srload <= '1';
				AdivB <= '0';
				ALUout_on_Databus <= '1';
				nextState <= div3;
			when div3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= div4;
			when div4 =>
				srload  <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				EnablePC <= '1';
				shadow_temp <= '0';
				PCplus1 <= '1';
				nextState <= Start;
			
			when xor0 => 
				AxorB <= '1';
				nextState <= xor1;
			when xor1 =>
				nextState <= xor2;
			when xor2 =>
				srload <= '1';
				AxorB <= '0';
				ALUout_on_Databus <= '1';
				nextState <= xor3;
			when xor3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= xor4;
			when xor4 =>
				srload  <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				EnablePC <= '1';
				shadow_temp <= '0';
				PCplus1 <= '1';
				nextState <= Start;
			
			when twocomp0 =>
				Btws <= '1';
				nextState <= twocomp1;
			when twocomp1 =>
				nextState <= twocomp2;
			when twocomp2 => 
				srload <= '1';
				Btws <= '0';
				ALUout_on_Databus <= '1';
				nextState <= twocomp3;
			when twocomp3 =>
				RFHwrite <= '1';
				RFLwrite <= '1';
				ALUout_on_Databus <= '0';
				nextState <= twocomp4;
			when twocomp4 =>
				srload  <= '0';
				RFHwrite <= '0';
				RFLwrite <= '0';
				EnablePC <= '1';
				shadow_temp <= '0';
				PCplus1 <= '1';
				nextState <= Start;
			
			when Others =>
			   nextState <= Start;
		end case;
	end process;
end architecture;






