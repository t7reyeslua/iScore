----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:24:13 02/08/2009 
-- Design Name: 
-- Module Name:    serialComm - Behavioral 
-- Project Name: 	 iScore
-- Target Devices: 
-- Tool versions: 
-- Description: 	  Cración de puertos de Comunicación Serial usando puertos RS232
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


entity serialComm is
Port ( 	CLK 		: in  STD_LOGIC; 

			--LEDS
			ledprueba1: out std_logic;
			ledprueba2: out std_logic;
			ledprueba3: out std_logic;
			
			--Serial PINS
			ioRx	: in  STD_LOGIC;
			ioTx	: out STD_LOGIC;
			
			--Serial SIGNALS
			datoIdTx :in std_logic_vector(7 downto 0);
			datoC1Tx	:in std_logic_vector(7 downto 0);
			datoC2Tx	:in std_logic_vector(7 downto 0);
			datoC3Tx	:in std_logic_vector(7 downto 0);
			datoC4Tx	:in std_logic_vector(7 downto 0);
			
			datoIdRx	:out std_logic_vector(7 downto 0);
			datoC1Rx	:out std_logic_vector(7 downto 0);--quién
			datoC2Rx	:out std_logic_vector(7 downto 0);--cuál
			datoC3Rx	:out std_logic_vector(7 downto 0);--cómo
			datoC4Rx	:out std_logic_vector(7 downto 0);
			
			setNewValueRx	:out std_logic;
			enviaSend 		:in  std_logic;
			elOtroDiceQueMandes : in std_logic;
			queElOtroMande:out std_logic);
end serialComm;
--***********************************************************************

architecture Behavioral of serialComm is
--**********COMPONENTES**************************************************
component uart_tx is
    Port (   data_in 			: in std_logic_vector(7 downto 0);
             write_buffer 		: in std_logic;
             reset_buffer 		: in std_logic;
             en_16_x_baud 		: in std_logic;
             serial_out 		: out std_logic;
             buffer_full 		: out std_logic;
             buffer_half_full : out std_logic;
             clk 					: in std_logic);
end component;

component uart_rx is
    Port (   serial_in 			: in std_logic;
             data_out 			: out std_logic_vector(7 downto 0);
             read_buffer 		: in std_logic;
             reset_buffer 		: in std_logic;
             en_16_x_baud 		: in std_logic;
             buffer_data_present : out std_logic;
             buffer_full 		: out std_logic;
             buffer_half_full : out std_logic;
             clk 					: in std_logic);
end component;

--FINAL DE COMPONENTES********************************************************

--************SEÑALES****************************************************
--//señales necesarias para los módulos UART del paquete de PICOBLAZE para trans. serial bajado de la página de Xilinix
signal baud_count: integer range 0 to 650:=0;
signal en_16_x_baud: std_logic;

--SERIAL 1
signal datoTx			: std_logic_vector(7 downto 0);
signal wbufferTx 		: std_logic;
signal resetbufferTx : std_logic;
signal bufferFTx		: std_logic;
signal bufferHFTx		: std_logic;

signal datoRx			: std_logic_vector(7 downto 0);
signal rbufferRx		: std_logic;
signal resetbufferRx : std_logic;
signal bufferReadyRx : std_logic;
signal bufferFRx		: std_logic;
signal bufferHFRx  	: std_logic;

signal dato55Rx		:std_logic_vector(7 downto 0);
signal datoAARx		:std_logic_vector(7 downto 0);
signal dato55Tx		:std_logic_vector(7 downto 0):="01010101";
signal datoAATx		:std_logic_vector(7 downto 0):="10101010";

--//señales de los Estados para la transmisión y recepción de datos
signal stateTx,nstateTx: integer range 0 to 15:=0;
signal stateRx,nstateRx: integer range 0 to 15:=0;

signal sendAlgo:std_logic; --señal para indicar que se ha cambiado un valor y es necesario transmitirlo serialmente al programa en C
signal sendAux:std_logic;
signal esperate:std_logic_vector(29 downto 0):="000000000000000000000000000000";
signal tiempoEspera:std_logic_vector(29 downto 0):="000000000000000000000000000000";
signal selectTiempo: std_logic_vector(2 downto 0):="000";
--FIN de SEÑALES*******************************************************************


begin
--SERIAL-==========================================================================

NextState: process(CLK, nstateTx,nstateRx,nstateRx)
begin
	if(CLK = '1' and CLK'event)then
			stateTx <= nstateTx;
			stateRx <= nstateRx;
	end if;
end process;

baud_Timer: process(CLK) --reloj para determinar los bits por segundo. En este caso se determinó utilizar 4800bps por lo que el contador
								 -- necesita llegar hasta 650. Para meyor información referirse al manual de usuario del PICOBLAZE
begin
	if CLK'event and CLK='1' then
		if baud_count=650 then 
			baud_count<=0;
			en_16_x_baud <='1';
		else
			baud_count<=baud_count + 1;
			en_16_x_baud <='0';
		end if;
	end if;
end process baud_timer;


txMod : uart_tx port map(datoTx,wbufferTx,resetbufferTx,en_16_x_baud,ioTx,bufferFTx,bufferHFTx,CLK);
rxMod : uart_rx port map(ioRx,datoRx,rbufferRx,resetbufferRx,en_16_x_baud,bufferReadyRx,bufferFRx,bufferHFRx,CLK);

--SERIAL con PC...............................

--//máquina de Edos para la recepción de datos
recibePC:process(stateRx,bufferReadyRx, datoRx)
begin
	case stateRx is
		when 0 => if bufferReadyRx='1' then
						nstateRx<=1;
						rbufferRx<='1';
						resetbufferRx<='0';
						dato55Rx<="00000000";
						datoAARx<="00000000";
						setNewValueRx<='0';
						queElOtroMande<='0';
					else
						nstateRx<=0;
						resetbufferRx<='0';
						rbufferRx<='0';	
						dato55Rx<="00000000";
						datoAARx<="00000000";
						setNewValueRx<='0';
						queElOtroMande<='0';
					end if;
					
		when 1 => rbufferRx<='0'; 					--recibe 1er octeto
					 dato55Rx<= datoRx;
					-- resetbufferRx <='1';
					 if datoRx = "01010101" then
						ledprueba1<='1';
					 else
						ledprueba1<='0';
					 end if;
					 nstateRx<=2;
					 
		----
		when 2 => if bufferReadyRx='1' then
						nstateRx<=3;
						rbufferRx<='1';
					else
						nstateRx<=2;
					end if;
					--resetbufferRx <='0';
		when 3 => rbufferRx<='0'; 					--recibe 2do octeto
					 datoIdRx<= datoRx;
					 if datoRx = "00000001" then
						ledprueba2<='1';
					 else
						ledprueba2<='0';
					 end if;
					 nstateRx<=4;
					 
		-----			 
		when 4 => if bufferReadyRx='1' then
						nstateRx<=5;
						rbufferRx<='1';
					else
						nstateRx<=4;
					end if;
		when 5 => rbufferRx<='0';					--recibe 3er octeto
					 datoC1Rx<= datoRx;
					 nstateRx<=6;
		---
		
		when 6 => if bufferReadyRx='1' then
						nstateRx<=7;
						rbufferRx<='1';
					else
						nstateRx<=6;
					end if;
		when 7 => rbufferRx<='0';					--recibe 4to octeto
					 datoC2Rx<= datoRx;
					 nstateRx<=8;
		---
		
		when 8 => if bufferReadyRx='1' then
						nstateRx<=9;
						rbufferRx<='1';	
					else
						nstateRx<=8;
					end if;
		when 9 => rbufferRx<='0';					--recibe 5to octeto
					 datoC3Rx<= datoRx;
					 nstateRx<=10;
		---
		
		when 10 => if bufferReadyRx='1' then
						nstateRx<=11;
						rbufferRx<='1';
					else
						nstateRx<=10;
					end if;
		when 11 => rbufferRx<='0'; 				--recibe 6to octeto
					  datoC4Rx<= datoRx;
					  nstateRx<=12;
		---
		
		when 12 => if bufferReadyRx='1' then
						nstateRx<=13;
						rbufferRx<='1';	
					else
						nstateRx<=12;
					end if;
		when 13 => rbufferRx<='0';					--recibe 7mo octeto
				    datoAARx<= datoRx;
					 if datoRx = "10101010" then
						ledprueba3<='1';
						setNewValueRx<='1';
					 else
						ledprueba3<='0';
					 end if;
					 nstateRx<=0;
					 queElOtroMande<='1';
		---		
		when others => null;
	end case;
end process;

selectTiempo<="000";
tiempoEspera<= "000000000000000000000000000000" when selectTiempo ="000" else
					"000000011111010111100001000000" when selectTiempo ="001" else
					"000001000011110100001001000000" when selectTiempo ="010" else
					"000000000000000000000000000000";


--//máquina de Edos para la transmisión de datos
transmitePC:process(sendAlgo,stateTx, dato55Tx, datoIdTx, datoC1Tx, datoC2Tx, datoC3Tx, datoC4Tx, datoAATx)
begin
	case stateTx is
		when 0=> if sendAlgo='1' then
							nstateTx<=15;
					else  nstateTx<=0;
					end if;
		when 15=> if sendAlgo='0' then
							nstateTx<=1;
					 else nstateTx<=15;
					end if;
					
		when 1=> datoTx<= dato55Tx;				--trasmite 1er octeto
					wbufferTx<='1';
					nstateTx<=2;
		when 2=> wbufferTx<='0';
					if (esperate = tiempoEspera) then
						esperate <="000000000000000000000000000000";
						nstateTx<=3;
					else
						esperate <= esperate +'1';
						nstateTx<=2;
					end if;
		when 3=> datoTx<= datoIdTx;				--trasmite 2do octeto
					wbufferTx<='1';
					nstateTx<=4;
		when 4=> wbufferTx<='0';
					if (esperate = tiempoEspera) then
						esperate <="000000000000000000000000000000";
						nstateTx<=5;
					else
						esperate <= esperate+'1';
						nstateTx<=4;
					end if;
		when 5=> datoTx<= datoC1Tx;				--trasmite 3er octeto
					wbufferTx<='1';
					nstateTx<=6;
		when 6=> wbufferTx<='0';
					if (esperate = tiempoEspera) then
						esperate <="000000000000000000000000000000";
						nstateTx<=7;
					else
						esperate <= esperate+'1';
						nstateTx<=6;
					end if;
		when 7=> datoTx<= datoC2Tx;				--trasmite 4to octeto
					wbufferTx<='1';
					nstateTx<=8;
		when 8=> wbufferTx<='0';
					if (esperate = tiempoEspera) then
						esperate <="000000000000000000000000000000";
						nstateTx<=9;
					else
						esperate <= esperate+'1';
						nstateTx<=8;
					end if;
		when 9=> datoTx<= datoC3Tx;				--trasmite 5to octeto
					wbufferTx<='1';
					nstateTx<=10;
		when 10=> wbufferTx<='0';
					if (esperate = tiempoEspera) then
						esperate <="000000000000000000000000000000";
						nstateTx<=11;
					else
						esperate <= esperate+'1';
						nstateTx<=10;
					end if;
		when 11=> datoTx<= datoC4Tx;				--trasmite 6to octeto
					wbufferTx<='1';
					nstateTx<=12;
		when 12=> wbufferTx<='0';
					if (esperate = tiempoEspera) then
						esperate <="000000000000000000000000000000";
						nstateTx<=13;
					else
						esperate <= esperate+'1';
						nstateTx<=12;
					end if;
		when 13=> datoTx<= datoAATx;				--trasmite 7mo octeto
					wbufferTx<='1';
					nstateTx<=14;
		when 14=> wbufferTx<='0';nstateTx<=0;
		when others => null;
	end case;
end process;
--=====================================================================================	


--GENERA PULSOS QUE INDIQUEN CUANDO ENVIAR ALGO========================================

sendAlgo <= '1' when (enviaSend = '1' or elOtroDiceQueMandes = '1') else '0';

end Behavioral;