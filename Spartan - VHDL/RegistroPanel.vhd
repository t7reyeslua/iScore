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

entity RegistroPanel is
    Port ( CLK : in  STD_LOGIC;
		     ENE: in  STD_LOGIC;	 
           CTRL : in  STD_LOGIC;
           Pin : in  STD_LOGIC_VECTOR (10 downto 0):="00000000000";
			  teclasOK : in  STD_LOGIC:='0';
			  Pout1 : inout  STD_LOGIC_VECTOR (3 downto 0):="0000";
           Pout2 : inout  integer range 0 to 15);
end RegistroPanel;

architecture Behavioral of RegistroPanel is
	signal R : STD_LOGIC_VECTOR (10 downto 0);
begin
	p1:process(CLK,CTRL,ENE,Pin)begin
		if (CTRL = '1' and ENE='1') then R <="00000000000"; --RESET
		elsif (CLK = '1' and CLK'event and ENE='1')then
			if (CTRL = '0') then 
				R<= Pin;
				--E.Paralela
			end if;
		end if;
	end process;
	Pout1 <= --"0000" when R="00000000000" else
				"0001" when R="00000000001" else --libres
				"0010" when R="00000000010" else --dobles
				"0011" when R="00000000100" else --triples
				"0100" when R="00000001000" else --asistencia
				"0101" wheN R="00000010000" else --rebote
				"0110" when R="00000100000" else --falta
				"0111" when R="00001000000" else --cancha
				"1000" when R="00010000000" else --banca
				"1001" when R="00100000000" else --play/pausa
				"1010" when R="01000000000" else --reset
				"1100" when R="10000000000" else --reset
				--"1011" when R="10000000000" else --tiempoFuera
				--"1100" when teclasOK='1'	 else --playera
				"1111";
	Pout2 <= --0  when R="00000000000" else
				1  when R="00000000001" else
				2  when R="00000000010" else
				3  when R="00000000100" else
				4  when R="00000001000" else
				5  when R="00000010000" else
				6  when R="00000100000" else
				7  when R="00001000000" else
				8  when R="00010000000" else
				9  when R="00100000000" else
				10 when R="01000000000" else
				12 when R="10000000000" else
				--11 when R="10000000000" else
				--12 when teclasOK='1'		else 
				15;
end Behavioral;