----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:16:00 03/07/2013 
-- Design Name: 
-- Module Name:    global - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity global is
    Port (
			CLK : in  STD_LOGIC;
			RST : in STD_LOGIC;
			Dout7Seg : out  STD_LOGIC_VECTOR (7 downto 0);
			Ctrl7Seg : out  STD_LOGIC_VECTOR (3 downto 0)
		);
end global;

architecture Behavioral of global is

	constant ADD : STD_LOGIC_VECTOR(7 downto 0) := X"01";
	constant MUL : STD_LOGIC_VECTOR(7 downto 0) := X"02";
	constant SUB : STD_LOGIC_VECTOR(7 downto 0) := X"03";
	constant DIV : STD_LOGIC_VECTOR(7 downto 0) := X"04";
	constant JMP : STD_LOGIC_VECTOR(7 downto 0) := X"05";
	constant JMF : STD_LOGIC_VECTOR(7 downto 0) := X"06";
	constant INF : STD_LOGIC_VECTOR(7 downto 0) := X"07";
	constant SUP : STD_LOGIC_VECTOR(7 downto 0) := X"08";
	constant EQU : STD_LOGIC_VECTOR(7 downto 0) := X"09";
	constant PRI : STD_LOGIC_VECTOR(7 downto 0) := X"0A";
	constant COP : STD_LOGIC_VECTOR(7 downto 0) := X"0B";
	constant AFC : STD_LOGIC_VECTOR(7 downto 0) := X"0C";
	constant LOAD : STD_LOGIC_VECTOR(7 downto 0) := X"0D";
	constant STORE : STD_LOGIC_VECTOR(7 downto 0) := X"0E";
	constant BUBBLE : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
	constant NOP : STD_LOGIC_VECTOR(7 downto 0) := X"00";
	
	
	component frequencyDivisor
		Port ( CLOCK100MHz : in  STD_LOGIC;
         --CLOCKOUT1Hz : out  STD_LOGIC;
         CLOCKOUT1KHz : out  STD_LOGIC
         );
	end component;
	
	component sevenSegments
		Port ( CLOCK : in STD_LOGIC;
				Din : in  STD_LOGIC_VECTOR (15 downto 0);
				Dout : out  STD_LOGIC_VECTOR (7 downto 0);
				Ctrl : out  STD_LOGIC_VECTOR (3 downto 0)
			);
	end component;
	
	component ALU 
		Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
				  B : in  STD_LOGIC_VECTOR (7 downto 0);
				  S : out  STD_LOGIC_VECTOR (7 downto 0);
				  N : out  STD_LOGIC;
				  O : out  STD_LOGIC;
				  Z : out  STD_LOGIC;
				  C : out  STD_LOGIC;
				  Ctrl_Alu : in  STD_LOGIC_VECTOR (3 downto 0)
		);
	end component;
	--Inputs
   signal ALU_A : std_logic_vector(7 downto 0) := (others => '0');
   signal ALU_B : std_logic_vector(7 downto 0) := (others => '0');
   signal ALU_Ctrl : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal ALU_S : std_logic_vector(7 downto 0);
   signal ALU_Flag_N : std_logic;
   signal ALU_Flag_V : std_logic;
   signal ALU_Flag_Z : std_logic;
   signal ALU_Flag_C : std_logic;
	
	component dataMemory 
		Port ( Addr : in  STD_LOGIC_VECTOR (7 downto 0);
           DATA_IN : in  STD_LOGIC_VECTOR (7 downto 0);
           RW : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           DATA_OUT : out  STD_LOGIC_VECTOR (7 downto 0)
		);
	end component;
	--Inputs
	signal RAM_Addr : std_logic_vector(7 downto 0);
	signal RAM_DATA_IN : std_logic_vector(7 downto 0);
	signal RAM_RW : std_logic;
	--Output
	signal RAM_DATA_OUT : std_logic_vector(7 downto 0);
	
	component instructionsMemory
		Port ( Addr : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK : in  STD_LOGIC;
           DATA_OUT : out  STD_LOGIC_VECTOR (31 downto 0)
		);
	end component;
	--Inputs
	signal INSTREG_Addr : std_logic_vector(7 downto 0);
	--Output
	signal INSTREG_DATA_OUT : std_logic_vector(31 downto 0);
	
	component registres
		Port ( AddrA : in  STD_LOGIC_VECTOR (3 downto 0);
           AddrB : in  STD_LOGIC_VECTOR (3 downto 0);
           AddrW : in  STD_LOGIC_VECTOR (3 downto 0);
           W : in  STD_LOGIC;
           DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           QA : out  STD_LOGIC_VECTOR (7 downto 0);
           QB : out  STD_LOGIC_VECTOR (7 downto 0)
		);
	end component;
	signal REG_AddrA : std_logic_vector(3 downto 0);
	signal REG_AddrB : std_logic_vector(3 downto 0);
	signal REG_AddrW : std_logic_vector(3 downto 0);
	signal REG_W : std_logic;
	signal REG_DATA : std_logic_vector(7 downto 0);
	signal REG_QA : std_logic_vector(7 downto 0);
	signal REG_QB : std_logic_vector(7 downto 0);
	
	subtype INDEX_A is NATURAL range 31 downto 24;
	subtype INDEX_OP is NATURAL range 23 downto 16;
	subtype INDEX_B is NATURAL range 15 downto 8;
	subtype INDEX_C is NATURAL range 7 downto 0;
	
	signal LIDI : STD_LOGIC_VECTOR (31 downto 0) := X"00000000";	
	signal DIEX : STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	signal EXMem : STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	signal MemRE : STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	
	signal IP : STD_LOGIC_VECTOR (7 downto 0) := X"00";
	signal alea : STD_LOGIC;
	signal jump_JMP : STD_LOGIC;
	signal jump_JMF : STD_LOGIC;
	signal decrementationIP : STD_LOGIC := '0';
	
	signal REG_AFFICHEUR : STD_LOGIC_VECTOR(15 downto 0);
	signal s1KHz : STD_LOGIC;
	--signal s1Hz : STD_LOGIC;
	
	signal FLAGS_CNZV : STD_LOGIC_VECTOR (3 downto 0) := X"0";
	
begin
	-- Diviseur de fréquence + afficheur 7 segments
	FREQ_DIV : frequencyDivisor port map(CLK, s1KHz);
	AFFICHEUR : sevenSegments port map(s1KHz, REG_AFFICHEUR, Dout7Seg, Ctrl7Seg);

	-- Bloc ROM + IP
	INSTREG_Addr <= IP;
	ROM : instructionsMemory port map (INSTREG_Addr, CLK, INSTREG_DATA_OUT);
	
	------------------------------------------------------------------------
	-- GESTION DES ALEAS
	------------------------------------------------------------------------
	alea <= '1' when (	(
								-- gestion de la copie et du store
								(LIDI(INDEX_OP) = COP or LIDI(INDEX_OP) = STORE)
								and (
									(LIDI(INDEX_B) = DIEX(INDEX_A) and DIEX(INDEX_OP) /= NOP) or
									(LIDI(INDEX_B) = EXMem(INDEX_A) and EXMem(INDEX_OP) /= NOP))
								) or (
									-- gestion des opérations arithmétiques
									(LIDI(INDEX_OP) = ADD
								or LIDI(INDEX_OP) = MUL
								or LIDI(INDEX_OP) = DIV
								or LIDI(INDEX_OP) = SUB
								or LIDI(INDEX_OP) = INF 
								or LIDI(INDEX_OP) = SUP
								or LIDI(INDEX_OP) = EQU )
								and (
										(LIDI(INDEX_B) = DIEX(INDEX_A) and DIEX(INDEX_OP) /= NOP) or
										(LIDI(INDEX_B) = EXMem(INDEX_A) and EXMem(INDEX_OP) /= NOP) or
										(LIDI(INDEX_C) = DIEX(INDEX_A) and DIEX(INDEX_OP) /= NOP) or
										(LIDI(INDEX_C) = EXMem(INDEX_A) and EXMem(INDEX_OP) /= NOP)
									)
								)
							)
					else '0';
	
	
	jump_JMP <= '1' when ( (LIDI(INDEX_OP) = JMP and DIEX(INDEX_OP) /= NOP) or DIEX(INDEX_OP) = JMP or EXMem(INDEX_OP) = JMP )
				else '0';
	
	jump_JMF <= '1' when (LIDI(INDEX_OP) = JMF and DIEX(INDEX_OP) /= NOP) or DIEX(INDEX_OP) = JMF or EXMem(INDEX_OP) = JMF
				else '0';
	
	------------------------------------------------------------------------
	-- CHEMIN DE DONNEES
	------------------------------------------------------------------------
	
	-- étage 0
	process(CLK)
	begin
		if(rising_edge(CLK)) then
			if RST = '0' then
				IP <= X"00";
				LIDI <= (others => '0');
				--REG_AFFICHEUR <= (others => '0');
			else
				if alea = '0' then
					if(jump_JMP = '1') then
						LIDI <= BUBBLE;
					else
						LIDI <= INSTREG_DATA_OUT;
					end if;
					
					if(jump_JMF = '1' and DIEX(INDEX_OP) = JMF) then
						LIDI <= BUBBLE; -- on insère la bulle que si JMF est validé
					end if;
					
					decrementationIP <= '0';
					
					if DIEX(INDEX_OP) = JMP or DIEX(INDEX_OP) = JMF then -- saut
						IP <= ALU_S;
					else -- incrémentation du compteur ordinal
						IP <= IP + 1;
					end if;
				else 
					if decrementationIP = '0' then
						IP <= IP - 1;
						decrementationIP <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- étage 1
	process(CLK)
	begin
		if(rising_edge(CLK)) then
			if RST = '0' then
				DIEX <= (others => '0');
			else
				if alea = '1' then
					DIEX <= BUBBLE;
				
				else
					DIEX(31 downto 24) <= LIDI(31 downto 24);
					
					if( LIDI(INDEX_OP) = JMF and REG_QB = X"00" ) then
						DIEX(23 downto 16) <= NOP;
					else
						DIEX(23 downto 16) <= LIDI(23 downto 16);
					end if;
					
					-- multiplexeur
					if(LIDI(INDEX_OP) = AFC or LIDI(INDEX_OP) = LOAD) or LIDI(INDEX_OP) = JMP or LIDI(INDEX_OP) = JMF then
						DIEX(INDEX_B) <= LIDI(INDEX_B);
					elsif(LIDI(INDEX_OP) = PRI) then
						REG_AFFICHEUR(15 downto 8) <= X"00";
						REG_AFFICHEUR(7 downto 0) <= REG_QA;
					else
						DIEX(INDEX_B) <= REG_QA;
					end if;
					
					if( LIDI(INDEX_OP) = JMP ) then
						DIEX(INDEX_C) <= IP;
					elsif( LIDI(INDEX_OP) = JMF and REG_QB = X"01") then
						DIEX(INDEX_C) <= IP;
					else
						DIEX(INDEX_C) <= REG_QB;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- étage 2
	process(CLK)
	begin
		if(rising_edge(CLK)) then
			if RST = '0' then
				EXMem <= (others => '0');
			else
				EXMem(31 downto 16) <= DIEX(31 downto 16);
				
				-- multiplexeur
				if( DIEX(INDEX_OP) = ADD or DIEX(INDEX_OP) = SUB or
					 DIEX(INDEX_OP) = MUL or DIEX(INDEX_OP) = DIV ) then -- sortie ALU
					FLAGS_CNZV <= ALU_Flag_C & ALU_Flag_N & ALU_Flag_Z & ALU_Flag_V;
					EXMem(INDEX_B) <= ALU_S;
				
				elsif DIEX(INDEX_OP) = INF or DIEX(INDEX_OP) = SUP then -- flag N
					FLAGS_CNZV <= ALU_Flag_C & ALU_Flag_N & ALU_Flag_Z & ALU_Flag_V;
					EXMem(INDEX_B) <= "0000000" & ALU_Flag_N;
					
				elsif DIEX(INDEX_OP) = EQU then -- flag Z
					FLAGS_CNZV <= ALU_Flag_C & ALU_Flag_N & ALU_Flag_Z & ALU_Flag_V;
					EXMem(INDEX_B) <= "0000000" & ALU_Flag_Z;
				
				elsif DIEX(INDEX_OP) /= JMP then -- si JMP progression dans pipeline stoppée
					EXMem(INDEX_B) <= DIEX(INDEX_B);
				end if;
			end if;
		end if;
	end process;
	
	-- étage 3
	process(CLK)
	begin
		if(rising_edge(CLK)) then
			if RST = '0' then
				MemRE <= (others => '0');
			else
				MemRE(31 downto 16) <= EXMem(31 downto 16);
				
				-- multiplexeur
				if( EXMem(INDEX_OP) = LOAD) then
					MemRE(INDEX_B) <= RAM_DATA_OUT;
				else
					MemRE(INDEX_B) <= EXMem(INDEX_B);
				end if;
			end if;
		end if;
	end process;
	
	
	-- bloc des registres
	REG_AddrA <= LIDI(11 downto 8);
	REG_AddrB <= LIDI(3 downto 0);
	REG_AddrW <= MemRE(27 downto 24);
	REG_W <= '1' when ( MemRE(INDEX_OP) = AFC
						or MemRE(INDEX_OP) = COP
						or MemRE(INDEX_OP) = ADD
						or MemRE(INDEX_OP) = SUB
						or MemRE(INDEX_OP) = MUL
						or MemRE(INDEX_OP) = DIV
						or MemRE(INDEX_OP) = LOAD
						or MemRE(INDEX_OP) = INF
						or MemRE(INDEX_OP) = SUP
						or MemRE(INDEX_OP) = EQU
						)
				else '0'; --implementation de LC
	REG_DATA <= MemRE(INDEX_B);
	REG_BLOC : registres port map (REG_AddrA, REG_AddrB, REG_AddrW, REG_W, REG_DATA,	RST,
				CLK, REG_QA, REG_QB);
	
	-- bloc ALU
	ALU_A <= DIEX(INDEX_B);
	ALU_B <= DIEX(INDEX_C);
	ALU_Ctrl <= DIEX(19 downto 16) when DIEX(INDEX_OP) = ADD
													or DIEX(INDEX_OP) = MUL
													or DIEX(INDEX_OP) = SUB
													or DIEX(INDEX_OP) = DIV
													or DIEX(INDEX_OP) = JMP
													or DIEX(INDEX_OP) = SUP
													or DIEX(INDEX_OP) = INF
													or DIEX(INDEX_OP) = EQU
													or DIEX(INDEX_OP) = JMF
				else X"0";
	ALU_Module : ALU port map (ALU_A, ALU_B, ALU_S, ALU_Flag_N, ALU_Flag_V, ALU_Flag_Z, ALU_Flag_C, ALU_Ctrl);
	
	-- RAM
	RAM_Addr <= EXMem(INDEX_B) when EXMem(INDEX_OP) = LOAD -- implementation du multiplexeur
				else EXMem(INDEX_A); -- when STORE
	RAM_DATA_IN <= EXMem(INDEX_B);
	RAM_RW <= '0' when EXMem(INDEX_OP) = STORE -- implementation du LC
				else '1'; -- when LOAD
	RAM : dataMemory port map (RAM_Addr, RAM_DATA_IN, RAM_RW, RST, CLK, RAM_DATA_OUT);
	
end Behavioral;

