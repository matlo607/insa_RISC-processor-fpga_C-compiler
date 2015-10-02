----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:10:02 03/07/2013 
-- Design Name: 
-- Module Name:    dataMemory - Behavioral 
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

entity dataMemory is
    Port ( Addr : in  STD_LOGIC_VECTOR (7 downto 0);
           DATA_IN : in  STD_LOGIC_VECTOR (7 downto 0);
           RW : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           DATA_OUT : out  STD_LOGIC_VECTOR (7 downto 0));
end dataMemory;

architecture Behavioral of dataMemory is
	type TabRegisters is array(0 to 255) of STD_LOGIC_VECTOR(7 downto 0); 
	signal registres : TabRegisters := (others => X"00");
begin

	--registres(0) <= X"AA";

	process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '0' then
				registres <= (others => (others => '0'));
			elsif RW = '0' then
				registres( to_integer(unsigned(Addr)) ) <= DATA_IN;
			--elsif RW = '1'  then
				
			end if;
		end if;
	end process;

	DATA_OUT <= registres( to_integer(unsigned(Addr)) ) when RW = '1';

end Behavioral;

