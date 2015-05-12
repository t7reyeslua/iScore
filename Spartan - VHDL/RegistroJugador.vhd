----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:55:59 03/16/2009 
-- Design Name: 
-- Module Name:    RegistroJugador - Behavioral 
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

entity RegistroJugador is
Port ( 	  CLK : in  STD_LOGIC;

			  njugador	: in integer range 0 to 15;
			  jugadorSel: in integer range 0 to 15;
			  nEquipo 	: in STD_LOGIC;
			  equipoSel : in STD_LOGIC;
			 
 			  algoPUSHED: in STD_LOGIC;
			  errorMode : in STD_LOGIC;
			  instruccionPanel: in integer range 0 to 15;
			  tecla1 : in  STD_LOGIC_VECTOR (3 downto 0);
			  tecla2 : in  STD_LOGIC_VECTOR (3 downto 0);
			  
			  setNewValueRx 	:in STD_LOGIC;
			  datoIDRxPC		:in  STD_LOGIC_VECTOR (7 downto 0);
			  datoC1RxPC		:in  STD_LOGIC_VECTOR (7 downto 0);
			  datoC2RxPC		:in  STD_LOGIC_VECTOR (7 downto 0);
			  datoC3RxPC		:in  STD_LOGIC_VECTOR (7 downto 0);
			  datoC4RxPC		:in  STD_LOGIC_VECTOR (7 downto 0);
			  
			  jnumero	:out  STD_LOGIC_VECTOR (7 downto 0):="00000000";
			  jlibres	:out  STD_LOGIC_VECTOR (7 downto 0):="00000000";
			  jdobles	:out  STD_LOGIC_VECTOR (7 downto 0):="00000000";
			  jtriples	:out  STD_LOGIC_VECTOR (7 downto 0):="00000000";
			  jasist		:out  STD_LOGIC_VECTOR (7 downto 0):="00000000";
			  jrebotes	:out  STD_LOGIC_VECTOR (7 downto 0):="00000000";
			  jfaltas	:out  STD_LOGIC_VECTOR (7 downto 0):="00000000");
end RegistroJugador;

architecture Behavioral of RegistroJugador is

begin

pSerial: process(setNewValueRxPC,datoIdRxPC,datoC1RxPC,datoC2RxPC,datoC3RxPC,datoC4RxPC)
begin
			if (setNewValueRxPC='1' and setNewValueRxPC'event) then --se recibió algo por serial de la PC
				if(njugador = datoC2RxPC(3 downto 0) and nEquipo=datoC1RxPC(3 downto 0)) then --si es el jugador a cambiar
						if (datoIdRxPC(7 downto 4) ="0000") then --comando pc quiere cambiar algo
									
									case datoC3RxPC is --QUÉ ACCIÓN
											when "00000010"=> jdobles <=datoC4RxPC;--Doble
											when "00000011"=> jtriples<=datoC4RxPC;--Triple
											when "00000100"=> jlibres <=datoC4RxPC;--Libre
											when "00000101"=> jfaltas <=datoC4RxPC;--Falta
											when "00000110"=> jasist  <=datoC4RxPC;--Asistencia
											when "00000111"=> jrebotes<=datoC4RxPC;--Rebote
											when "00001001"=> jnumero <=datoC4RxPC;--Playera
										when others => null;
									end case;				
							
						end if;--//del comando pc quiere cambiar valor;
				end if;--//si es el jugador correcto
			end if;--//del if setNewValueRxPC
end process;

pPanel:process(datoIdRxPC,datoC1RxPC,datoC2RxPC,datoC3RxPC,datoC4RxPC)
begin
		  if algoPUSHED='1' and algoPUSHED'event then
				if(njugador = jugadorSel and nEquipo=equipoSel) then --si es el jugador a cambiar
						if (errorMode ='0') then --modo sin Errores
									
									case instruccionPanel is --QUÉ ACCIÓN
											when 1=> jlibres <=jlibres  +'1';--Libre
											when 2 =>jdobles <=jdobles  +'1';--Doble
											when 3=> jtriples<=jtriples +'1';--Triple
											when 4=> jasist  <=jasist   +'1';--Asistencia
											when 5=> jrebotes<=jrebotes +'1';--Rebote
											when 6=> jfaltas <=jfaltas  +'1';--Falta
											--when 7=> jugadorEnCancha
											--when 8=> jugadorEnBanca
											when 15=>jnumero <=tecla1&tecla2;--Playera
										when others => null;
									end case;			
						
						else
						
									case instruccionPanel is --QUÉ ACCIÓN
											when 1=> jlibres <=jlibres  -'1';--Libre
											when 2 =>jdobles <=jdobles  -'1';--Doble
											when 3=> jtriples<=jtriples -'1';--Triple
											when 4=> jasist  <=jasist   -'1';--Asistencia
											when 5=> jrebotes<=jrebotes -'1';--Rebote
											when 6=> jfaltas <=jfaltas  -'1';--Falta
											--when 7=> jugadorEnCancha
											--when 8=> jugadorEnBanca
											when 15=>jnumero <=tecla1&tecla2;--Playera
										when others => null;
									end case;					
						
							
						end if;--//del comando panel quiere cambiar valor;
				end if;--//si es el jugador correcto
			end if;--//del if algoPUSHED
end process;

end Behavioral;

