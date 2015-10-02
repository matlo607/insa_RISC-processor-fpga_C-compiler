----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:38:27 02/11/2013 
-- Design Name: 
-- Module Name:    frequencyDivisor - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity frequencyDivisor is
  Port ( CLOCK100MHz : in  STD_LOGIC;
         --CLOCKOUT1Hz : out  STD_LOGIC;
         CLOCKOUT1KHz : out  STD_LOGIC
         );
end frequencyDivisor;

architecture Behavioral of frequencyDivisor is
  --signal CLOCK1Hz_count : STD_LOGIC_VECTOR(26 downto 0);
  signal CLOCK1KHz_count : STD_LOGIC_VECTOR(26 downto 0);
begin
  
--  process(CLOCK100MHz)
--  begin
--    if rising_edge(CLOCK100MHz) then
--      if CLOCK1Hz_count < 100000000 then
--        CLOCK1Hz_count <= CLOCK1Hz_count + 1;
--      else
--        CLOCK1Hz_count <= (others => '0');
--      end if;
--      
--      if CLOCK1Hz_count < 50000000 then
--        CLOCKOUT1Hz <= '1';
--      else
--        CLOCKOUT1Hz <= '0';
--      end if;
--    end if;
--  end process;

  process(CLOCK100MHz)
  begin
    if rising_edge(CLOCK100MHz) then
      if CLOCK1KHz_count < 100000 then
        CLOCK1KHz_count <= CLOCK1KHz_count + 1;
      else
        CLOCK1KHz_count <= (others => '0');
      end if;
      
      if CLOCK1KHz_count < 50000 then
        CLOCKOUT1KHz <= '1';
      else
        CLOCKOUT1KHz <= '0';
      end if;
    end if;
  end process;

end Behavioral;

