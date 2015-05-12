----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:12:06 03/16/2009 
-- Design Name: 
-- Module Name:    Evento - Behavioral 
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

entity Evento is
    Port ( CLK : in  STD_LOGIC;
           setNewValueRxPC : in  STD_LOGIC;
           algoPUSHED : in  STD_LOGIC;
           ultimoEvento : out  STD_LOGIC_VECTOR (1 downto 0);
           pulsoEventoZB : out  STD_LOGIC);
end Evento;

architecture Behavioral of Evento is
	signal ultimoEventoAux : STD_LOGIC_VECTOR (1 downto 0);
begin

process(CLK)
	begin
		if CLK'event and CLK='1' then
				if setNewValueRxPC='1' then
					pulsoEventoZB<='1';
					ultimoEventoAux<="01";
				elsif algoPUSHED = '1' then
					pulsoEventoZB<='1';
					ultimoEventoAux<="10";
				else
					pulsoEventoZB<='0';
				end if;
		end if;
end process;
	
ultimoEvento<=ultimoEventoAux;	

end Behavioral;

