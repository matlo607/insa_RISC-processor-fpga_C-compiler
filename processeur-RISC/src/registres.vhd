----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:33:17 03/05/2013 
-- Design Name: 
-- Module Name:    registres - Behavioral 
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity registres is
    Port ( AddrA : in  STD_LOGIC_VECTOR (3 downto 0);
           AddrB : in  STD_LOGIC_VECTOR (3 downto 0);
           AddrW : in  STD_LOGIC_VECTOR (3 downto 0);
           W : in  STD_LOGIC;
           DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           QA : out  STD_LOGIC_VECTOR (7 downto 0);
           QB : out  STD_LOGIC_VECTOR (7 downto 0));
end registres;

architecture Behavioral of registres is
	type TabRegisters is array(0 to 15) of STD_LOGIC_VECTOR(7 downto 0); 
	signal registres : TabRegisters;
begin

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '0' then
				registres <= (others => (others => '0'));
			else				
				if(W = '1') then
					registres( to_integer(unsigned(AddrW)) ) <= DATA;
				end if;
				
--				if(AddrA = AddrW and W = '1') then
--					QA <= DATA;
--				else
--					QA <= registres(to_integer(unsigned(AddrA)));
--				end if;
--				
--				if(AddrB = AddrW and W = '1') then
--					QB <= DATA;
--				else
--					QB <= registres(to_integer(unsigned(AddrB)));
--				end if;
			end if;
		end if;
	end process;
	
	QA <= DATA when AddrA = AddrW and W = '1' -- lecture et écriture sur le même registre
			else registres(to_integer(unsigned(AddrA))); -- lecture
	QB <= DATA when AddrB = AddrW	and W = '1' -- lecture et écriture sur le même registre
			else registres(to_integer(unsigned(AddrB))); -- lecture
end Behavioral;

