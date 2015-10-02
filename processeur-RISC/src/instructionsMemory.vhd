----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:15:23 03/07/2013 
-- Design Name: 
-- Module Name:    instructionsMemory - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instructionsMemory is
    Port ( Addr : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK : in  STD_LOGIC;
           DATA_OUT : out  STD_LOGIC_VECTOR (31 downto 0)
			  --DATA_OUT_NEXT : out STD_LOGIC_VECTOR (31 downto 0)
			 );
end instructionsMemory;

architecture Behavioral of instructionsMemory is
	type TabRegisters is array(0 to 255) of STD_LOGIC_VECTOR(31 downto 0); 
	signal registres : TabRegisters := (others => X"00000000");
begin
	
	registres(0) <= X"000C2300"; --AFC R0,0x23
	registres(1) <= X"010B0000"; --COP R1,R0
	registres(2) <= X"02010001"; --ADD R2, R0, R1 R2<-R0+R1
	registres(3) <= X"04020002"; --MUL R4, R0, R2 R4<-R0*R2
	registres(4) <= X"00050400"; --JMP 0x4 (ip <= ip +4)
	registres(5) <= X"060C2300"; --AFC R6,0x23
	registres(6) <= X"070C7800"; --AFC R7,0x78
	registres(7) <= X"090C9900"; --AFC R9,0x99
	registres(8) <= X"020E0400"; --STORE 0x2, R4
	--registres(9) <= X"040D0200"; --LOAD R4, 0x2
	registres(9) <= X"00000000";
	registres(10) <= X"030E0400"; --STORE 0x3, R4
	registres(11) <= X"0D070100"; --INF R13, R1 , R0 => false
	registres(12) <= X"0E070004"; --INF R14, R0 , R4 => true
	registres(13) <= X"0F090100"; --EQU R15, R1 , R0 => true
	registres(14) <= X"0C090400"; --EQU R12, R4 , R0 => false
	registres(15) <= X"0B080400"; --SUP R11, R4 , R0 => true
	registres(16) <= X"0A080004"; --SUP R10, R0 , R4 => false
	registres(17) <= X"000A0000"; --PRI R0
	registres(18) <= X"0006FA0D"; --JMF R13, 0xFA (jump -6 impossible car R13 = false)
	registres(19) <= X"0006FA0E"; --JMF R14, 0xFA (jump -6 avec R14 = true)
	registres(20) <= X"00000000";
	registres(21) <= X"00000000";
	registres(22) <= X"00000000";
	registres(23) <= X"00000000";
	registres(24) <= X"00000000";
	registres(25) <= X"00000000";
	registres(26) <= X"00000000";
	registres(27) <= X"00000000";
	registres(28) <= X"00000000";
	registres(29) <= X"00000000";
	registres(30) <= X"00000000";
	registres(31) <= X"00000000";
	
	process(CLK)
	begin
		if rising_edge(CLK) then
			DATA_OUT <= registres( to_integer(unsigned(Addr)) );
			--DATA_OUT_NEXT <= registres( to_integer(unsigned(Addr)) + 1 );
		end if;
	end process;

end Behavioral;

