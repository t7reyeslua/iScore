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

entity RegistroTeclasKB is
    Port ( CLK : in  STD_LOGIC;
		     ENE: in  STD_LOGIC;	 
           CTRL : in  STD_LOGIC;
           Pin : in  STD_LOGIC_VECTOR (3 downto 0);
			  teclasValidas: out STD_LOGIC:='0';
			  contTeclas: out std_logic_vector(3 downto 0):="0000";
			  tecla1 : out  STD_LOGIC_VECTOR (3 downto 0):="0000";
           tecla2 : out  STD_LOGIC_VECTOR (3 downto 0):="0000");
end RegistroTeclasKB;

architecture Behavioral of RegistroTeclasKB is
	signal R : STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal cont: std_logic_vector(3 downto 0):="0000";
	signal ultima:std_logic_vector(3 downto 0):="0000";
	signal flag:std_logic:='0';
begin
	p1:process(CLK,CTRL,ENE,Pin)
	begin
		if (CTRL = '1' and CTRL'event)then
			if (flag<='1' and Pin < "1111") then 				
				R<= R(3 downto 0)&Pin; --SHIFT to the left
				cont <= cont+1;	--llegó el primero				
				flag<='0';
			end if;
		end if;
	end process;
	tecla1 <= R(7 downto 4);
	tecla2 <= R(3 downto 0);
	contTeclas<= cont;
	
	process(CTRL)
	begin
		if CTRL'event and CTRL='1' then
				if (Pin="1111") then
					flag<='1';
					if (cont(1)='0')then
							teclasValidas<='1';
					else 
							teclasValidas <= '0';
					end if;
				else
					flag<='0';
					
				end if;
		end if;
	end process;
	

end Behavioral;


--process (clk25,kbready)
--begin
--  if clk25'EVENT and clk25 = '1' then
--		if (kbready = '1')then --si ya se leyó algo da un SHIFT a las teclas para que
--											--teclaKBb quede con la última tecla pulsada y 
--											--teclaKBa quede con la penúltima
--			teclaKBb<= teclaKB; 	  --tecla recién pulsada
--			teclaKBa<= teclaKBaux; --el valor que tenía teclaKBb en el ciclo anterior
--		else
--			teclaKBaux <= teclaKBb;
--		end if;
--  end if;
--end process;

