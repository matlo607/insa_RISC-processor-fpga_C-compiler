----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:06:47 02/11/2013 
-- Design Name: 
-- Module Name:    sevenSegments - Behavioral 
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

entity sevenSegments is
  Port ( 
    CLOCK : in STD_LOGIC;
    Din : in  STD_LOGIC_VECTOR (15 downto 0);
    Dout : out  STD_LOGIC_VECTOR (7 downto 0);
    Ctrl : out  STD_LOGIC_VECTOR (3 downto 0)
    );
end sevenSegments;

architecture Behavioral of sevenSegments is
  component decoder7Seg
    Port (
      CLOCK : in STD_LOGIC;
      Din : in  STD_LOGIC_VECTOR (3 downto 0);
      Dout : out  STD_LOGIC_VECTOR (7 downto 0)
      );
  end component;
  
  type REG is array (3 downto 0) of STD_LOGIC_VECTOR(3 downto 0);
  
  signal CLOCK_count : integer range 0 to 3;
  signal digit : REG;
  signal a : STD_LOGIC_VECTOR(3 downto 0);
begin	
  process(CLOCK)
  begin
    if rising_edge(CLOCK) then
      if CLOCK_count = 3 then
        CLOCK_count <= 0;
      else
        CLOCK_count <= CLOCK_count + 1;
      end if;
    end if;
  end process;
  
  digit(3) <= Din(15 downto 12);
  digit(2) <= Din(11 downto 8);
  digit(1) <= Din(7 downto 4);
  digit(0) <= Din(3 downto 0);
  
  process(CLOCK_count, digit)
  begin
    if(CLOCK_count = 0) then
      Ctrl <= "1110";
      a <= digit(0);
    elsif(CLOCK_count = 1) then
      Ctrl <= "1101";
      a <= digit(1);
    elsif(CLOCK_count = 2) then
      Ctrl <= "1011";
      a <= digit(2);
    else
      Ctrl <= "0111";
      a <= digit(3);
    end if;
  end process;
  
  DEC : decoder7Seg port map(CLOCK, a, Dout);
end Behavioral;
