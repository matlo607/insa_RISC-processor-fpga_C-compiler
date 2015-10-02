--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:21:10 03/05/2013
-- Design Name:   
-- Module Name:   /home/bgayraud/4a/archiMat/processeur/ALU/testALU.vhd
-- Project Name:  ALU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ALU
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testALU IS
END testALU;
 
ARCHITECTURE behavior OF testALU IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         A : IN  std_logic_vector(7 downto 0);
         B : IN  std_logic_vector(7 downto 0);
         S : OUT  std_logic_vector(7 downto 0);
         N : OUT  std_logic;
         O : OUT  std_logic;
         Z : OUT  std_logic;
         C : OUT  std_logic;
         Ctrl_Alu : IN  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(7 downto 0) := (others => '0');
   signal B : std_logic_vector(7 downto 0) := (others => '0');
   signal Ctrl_Alu : std_logic_vector(2 downto 0) := (others => '0');

 	--Outputs
   signal S : std_logic_vector(7 downto 0);
   signal N : std_logic;
   signal O : std_logic;
   signal Z : std_logic;
   signal C : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          A => A,
          B => B,
          S => S,
          N => N,
          O => O,
          Z => Z,
          C => C,
          Ctrl_Alu => Ctrl_Alu
        );

	-- test addition
	--Ctrl_Alu <= "001";
	--A <= X"01", X"FF" after 30ns, X"FF" after 60ns, X"00" after 90ns, X"7F" after 120ns;
	--B <= X"01", X"01" after 30ns, X"0F" after 60ns, X"00" after 90ns, X"01" after 120ns;
	
	--test multiplication
	--Ctrl_Alu <= "010";
	--A <= X"02", X"00" after 30ns, X"FF" after 60ns;--, X"00" after 90ns, X"7F" after 120ns;
	--B <= X"02", X"02" after 30ns, X"0F" after 60ns;--, X"00" after 90ns, X"01" after 120ns;
	
	--test soustraction
	Ctrl_Alu <= "011";
	A <= X"02", X"00" after 30ns, X"FF" after 60ns;--, X"00" after 90ns, X"7F" after 120ns;
	B <= X"02", X"02" after 30ns, X"01" after 60ns;--, X"00" after 90ns, X"01" after 120ns;
	
END;
