----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:20:05 03/05/2013 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
           B : in  STD_LOGIC_VECTOR (7 downto 0);
           S : out  STD_LOGIC_VECTOR (7 downto 0);
           N : out  STD_LOGIC;
           O : out  STD_LOGIC;
           Z : out  STD_LOGIC;
           C : out  STD_LOGIC;
           Ctrl_Alu : in  STD_LOGIC_VECTOR (3 downto 0));
			  -- 1 : addition
			  -- 2 : multiplication
			  -- 3 : soustraction
			  -- 4 : division
			  -- 5 : addition (JMP)
			  -- 6 : addition (JMF) suivant valeur flag
			  -- 7 : soustraction A - B et chargement du flag N = 1
			  -- 8 : soustraction A - B et chargement du flag N = 0
			  -- 9 : soustraction A - B et chargement du flag Z = 1
end ALU;

architecture Behavioral of ALU is
	signal Res : STD_LOGIC_VECTOR(15 downto 0);
	signal As : STD_LOGIC_VECTOR(15 downto 0);
	signal Bs : STD_LOGIC_VECTOR(15 downto 0);
begin
	As <= X"00" & A;
	Bs <= X"00" & B;

	with Ctrl_Alu select
		Res <= 	As + Bs when X"1", -- 1 : addition
					As + Bs when X"5", -- 5 : addition (JMP)
					As + Bs when X"6", -- 6 : addition (JMF) suivant valeur flag
					As - Bs when X"3", -- 3 : soustraction
					As - Bs when X"7", -- 7 : soustraction A - B et chargement du flag N = 1
					Bs - As when X"8", -- 8 : soustraction A - B et chargement du flag N = 0
					As - Bs when X"9", -- 9 : soustraction A - B et chargement du flag Z = 1
					A * B when X"2", -- 2 : multiplication
					As + Bs when others; -- opération bidon par défaut
					--As / Bs when X"4"; -- 4 : division
	
	S <= Res(7 downto 0);
	
	N <= Res(7);
	
	with Res(7 downto 0) select
		Z <= 	'1' when X"00",
				'0' when others;
				
	C <= 	Res(8); --when Ctrl_Alu = "001" or Ctrl_Alu = "011";

        -- 4 cas
        -- http://homepages.laas.fr/flonesan/arch
        -- nb_positif + nb_positif => nb_négatif
        -- nb_negatif + nb_negatif => nb_positif
        -- nb_positif - nb_negatif => nb_negatif
        -- nb_negatif - nb_positif => nb_positif
        -- Multiplication à réfléchir
	

	O <= '1' when ( 	(A(7)='0' and B(7)='0' and Res(7)='1' and Ctrl_Alu = "001")
						or	(A(7)='1' and B(7)='1' and Res(7)='0' and Ctrl_Alu = "001")
						or (A(7)='0' and B(7)='1' and Res(7)='1' and Ctrl_Alu = "011")
						or (A(7)='1' and B(7)='0' and Res(7)='0' and Ctrl_Alu = "011")
						)
			else '0';
	
end Behavioral;

