----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:32:16 02/23/2008 
-- Design Name: 
-- Module Name:    Registro - Behavioral 
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

entity Registro is
    Port ( CLK : in  STD_LOGIC;
		     ENE: in  STD_LOGIC;	 
           CTRL : in  STD_LOGIC;
           Pin : in  STD_LOGIC_VECTOR (11 downto 0):="000000000000";
			  Pout1 : out  STD_LOGIC_VECTOR (3 downto 0):="0000";
           Pout2 : out  integer range 0 to 15);
end Registro;

architecture Behavioral of Registro is
	signal R : STD_LOGIC_VECTOR (11 downto 0);
begin
	p1:process(CLK,CTRL,ENE,Pin)begin
		if (CTRL = '1' and ENE='1') then R <="000000000000"; --RESET
		elsif (CLK = '1' and CLK'event and ENE='1')then
			if (CTRL = '0') then 
				R<= Pin;
				--E.Paralela
			end if;
		end if;
	end process;
	Pout1 <= "0001" when R="000000000001" else
				"0010" when R="000000000010" else
				"0011" when R="000000000100" else
				"0100" when R="000000001000" else
				"0101" wheN R="000000010000" else
				"0110" when R="000000100000" else
				"0111" when R="000001000000" else
				"1000" when R="000010000000" else
				"1001" when R="000100000000" else
				"1010" when R="001000000000" else
				"1011" when R="010000000000" else
				"1100" when R="100000000000" else
				"1111";
	Pout2 <= 0 when R="000000000000" else
				1 when R="000000000001" else
				2 when R="000000000010" else
				3 when R="000000000100" else
				4 when R="000000001000" else
				5 wheN R="000000010000" else
				6 when R="000000100000" else
				7 when R="000001000000" else
				8 when R="000010000000" else
				9 when R="000100000000" else
				10 when R="001000000000" else
				11 when R="010000000000" else
				12 when R="100000000000" else
				15;
end Behavioral;