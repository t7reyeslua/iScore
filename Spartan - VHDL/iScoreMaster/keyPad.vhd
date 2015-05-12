----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:38:13 04/18/2009 
-- Design Name: 
-- Module Name:    keyPad - Behavioral 
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

entity keyPad is
    Port ( CLK 		: in  STD_LOGIC;
			  columns 	: in   STD_LOGIC_VECTOR (2 downto 0);
           rows 		: out  STD_LOGIC_VECTOR (3 downto 0);
           teclasOut : out  STD_LOGIC_VECTOR (7 downto 0);
           eneTeclas : out  STD_LOGIC);
end keyPad;

architecture Behavioral of keyPad is

--SEÑALES==============================
signal cont1, sDelay,contador : std_logic_vector(25 downto 0);
signal clkKPren : std_logic;

signal checaRen : std_logic_vector(1 downto 0);
signal parTeclas: std_logic_vector(7 downto 0);
--=====================================

begin

--GENERA CLOCKS========================
sDelay <="01011111010111100000111111";

process(CLK)
begin
	if CLK'event and CLK='1' then
		if cont1 = sDelay then
			clkKPren <= not clkKPren;
			cont1 <=(others =>'0');
			contador <= contador+1;
		else
			cont1 <= cont1+1;
			contador <= contador+1;
		end if;
	end if;
end process;

CLKBoton<= contador(13);
--=====================================

--SELECTOR de COLUMNA a CHECAR=========
process (clkKPren)
begin
	if clkKPren'event and clkKPren='1' then
		checaRen <= checaRen +'1';
	end if;
end process;

rows<="1000" when checaRen="00" else --checaRen1
		"0100" when checaRen="01" else --checaRen2
		"0010" when checaRen="10" else --checaRen3
		"0001"; 								 --checaRen4
		
--=====================================

--=CHECA TECLA OPRIMIDA================
process (CLK)
begin
	if CLK'event and CLK='1' then
		eneTeclas <= '0';
		case checaRen is
				when "00" =>
						if    (columns="100") then --1
							parTeclas <= parTeclas(3 downto 0)&"0001";
						elsif (columns="010") then --2
							parTeclas <= parTeclas(3 downto 0)&"0010";
						elsif (columns="001") then --3
							parTeclas <= parTeclas(3 downto 0)&"0011";
						end if;
				when "01" =>
						if    (columns="100") then --4
							parTeclas <= parTeclas(3 downto 0)&"0100";
						elsif (columns="010") then --5
							parTeclas <= parTeclas(3 downto 0)&"0101";
						elsif (columns="001") then --6
							parTeclas <= parTeclas(3 downto 0)&"0110";
						end if;
				when "10" =>
						if    (columns="100") then --7
							parTeclas <= parTeclas(3 downto 0)&"0111";
						elsif (columns="010") then --8
							parTeclas <= parTeclas(3 downto 0)&"1000";
						elsif (columns="001") then --9
							parTeclas <= parTeclas(3 downto 0)&"1001";
						end if;
				when "11" =>
						if    (columns="010") then --0
							parTeclas <= parTeclas(3 downto 0)&"0000";
						elsif (columns="001") then --#
							eneTeclas<='1';
						end if;
				when others=> null;
		end case;
	end if;
end process;

teclasOut<= parTeclas;
--=====================================


end Behavioral;

