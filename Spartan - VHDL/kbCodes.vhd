----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:52:44 03/15/2009 
-- Design Name: 
-- Module Name:    kbCodes - Behavioral 
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

entity kbCodes is
port(		clk25				: IN	STD_LOGIC;
			reset				: OUT	STD_LOGIC;
			read_kb			: OUT	STD_LOGIC;
			teclaKB			: OUT	STD_LOGIC_VECTOR(3 DOWNTO 0);
			scan_code		: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
			scan_ready		: IN	STD_LOGIC);
end kbCodes;

architecture Behavioral of kbCodes is
signal teclaKBaux	: STD_LOGIC_VECTOR(3 DOWNTO 0);

begin

--proceso para establecer el read y reset del teclado
process (clk25,scan_ready)
begin
  if clk25'EVENT and clk25 = '1' then
		if (scan_ready = '1')then --si ya se leyó algo es necesario darle reset y prepararse para una nueva lectura
			reset    <= '1';
			read_kb  <= '1';
			
		else
			reset <= '0';
			read_kb  <= '0';
		end if;
  end if;
end process;


process(clk25, scan_ready,scan_code)
begin
	if clk25'EVENT and clk25 = '1' then
		if (scan_ready = '1')then --si hay un dato listo del teclado
				case scan_code is
					when "00010110" => teclaKBaux<="0001"; --0x16 1
					when "00011110" => teclaKBaux<="0010"; --0x1E 2
					when "00100110" => teclaKBaux<="0011"; --0x26 3
					when "00100101" => teclaKBaux<="0100"; --0x25 4
					when "00101110" => teclaKBaux<="0101"; --0x2E 5
					when "00110110" => teclaKBaux<="0110"; --0x36 6
					when "00111101" => teclaKBaux<="0111"; --0x3D 7
					when "00111110" => teclaKBaux<="1000"; --0x3E 8
					when "01000110" => teclaKBaux<="1001"; --0x46 9	
					when "11110000" => teclaKBaux<="1111"; --0xF0 F	
					when others 	 => teclaKBaux<=teclaKBaux;
				end case;
		end if;
  end if;
end process;
teclaKB<=teclaKBaux;

end Behavioral;

