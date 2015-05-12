----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:31:19 02/29/2008 
-- Design Name: 
-- Module Name:    OneShot - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity OneShot is
Port ( Clk_in : in  STD_LOGIC;
       D : in  STD_LOGIC;
           Q : out  STD_LOGIC);
end OneShot;

architecture Behavioral of OneShot is
signal Q1, Q2, Q3: std_logic;

begin
process(Clk_in)
begin
   if (Clk_in'event and Clk_in = '1') then
         Q1 <= D;
         Q2 <= Q1;
         Q3 <= Q2;
   end if;
end process;
 
Q <= Q1 and Q2 and (not Q3);

end Behavioral;

