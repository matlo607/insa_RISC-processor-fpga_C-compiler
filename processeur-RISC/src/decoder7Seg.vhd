----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:27:41 02/11/2013 
-- Design Name: 
-- Module Name:    decoder7Seg - Behavioral 
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

entity decoder7Seg is
  Port (
    CLOCK : in STD_LOGIC;
    Din : in  STD_LOGIC_VECTOR (3 downto 0);
    Dout : out  STD_LOGIC_VECTOR (7 downto 0)
    );
end decoder7Seg;

architecture Behavioral of decoder7Seg is
  signal val : unsigned(3 downto 0);
begin
  val <= unsigned(Din);
  
  process(val, CLOCK)
  begin
    if rising_edge(CLOCK) then
      if(val = 0) then
        Dout <= "00000011";
      elsif(val = 1) then
        Dout <= "10011111";
      elsif(val = 2) then
        Dout <= "00100101";
      elsif(val = 3) then
        Dout <= "00001101";
      elsif(val = 4) then
        Dout <= "10011001";
      elsif(val = 5) then
        Dout <= "01001001";
      elsif(val = 6) then
        Dout <= "01000001";
      elsif(val = 7) then
        Dout <= "00011111";
      elsif(val = 8) then
        Dout <= "00000001";
      elsif(val = 9) then
        Dout <= "00001001";
      elsif(val = 10) then
        Dout <= "00010001";
      elsif(val = 11) then
        Dout <= "11000001";
      elsif(val = 12) then
        Dout <= "01100011";
      elsif(val = 13) then
        Dout <= "10000101";
      elsif(val = 14) then
        Dout <= "00100001";
      elsif(val = 15) then
        Dout <= "01110001";
      end if;
    end if;
  end process;

end Behavioral;

