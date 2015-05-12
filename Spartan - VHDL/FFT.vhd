----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity FFT is
    Port ( Clk_in : in  STD_LOGIC;
			  ENE: in STD_LOGIC;
           Q : out  STD_LOGIC);
end FFT;

architecture Behavioral of FFT is
	signal t :std_logic;
begin
	process (Clk_in, ENE)
		begin
			if (Clk_in='1') and (Clk_in'event) then 
				if (ENE = '1') then
					t<= not t;
				end if;
		end if;
	end process;
	Q <= t;
end Behavioral;

