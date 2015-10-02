--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:48:57 03/07/2013
-- Design Name:   
-- Module Name:   /home/matt/Documents/Studies/4IRT/ComputerArchitecture/projet/microprocessor/registers/testRegisters.vhd
-- Project Name:  registers
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: registres
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
 
ENTITY testRegisters IS
END testRegisters;
 
ARCHITECTURE behavior OF testRegisters IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT registres
    PORT(
         AddrA : IN  std_logic_vector(3 downto 0);
         AddrB : IN  std_logic_vector(3 downto 0);
         AddrW : IN  std_logic_vector(3 downto 0);
         W : IN  std_logic;
         DATA : IN  std_logic_vector(7 downto 0);
         RST : IN  std_logic;
         CLK : IN  std_logic;
         QA : OUT  std_logic_vector(7 downto 0);
         QB : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal AddrA : std_logic_vector(3 downto 0) := (others => '0');
   signal AddrB : std_logic_vector(3 downto 0) := (others => '0');
   signal AddrW : std_logic_vector(3 downto 0) := (others => '0');
   signal W : std_logic := '0';
   signal DATA : std_logic_vector(7 downto 0) := (others => '0');
   signal RST : std_logic := '0';
   signal CLK : std_logic := '0';

 	--Outputs
   signal QA : std_logic_vector(7 downto 0);
   signal QB : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: registres PORT MAP (
          AddrA => AddrA,
          AddrB => AddrB,
          AddrW => AddrW,
          W => W,
          DATA => DATA,
          RST => RST,
          CLK => CLK,
          QA => QA,
          QB => QB
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
	
	W <= '1', '0' after 20ns;
	AddrW <= X"2";
	DATA <= X"AA";
	RST <= '1', '0' after 40ns;
	AddrA <= X"2" after 20ns;

END;
