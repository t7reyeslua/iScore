----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:38:41 02/21/2009 
-- Design Name: 
-- Module Name:    mainSerial - Behavioral 
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

entity mainMaster is
Port ( 	CLK 		: in  STD_LOGIC; 
			
			--Serial
			ioRxPC	: in  STD_LOGIC;
			ioTxPC	: out STD_LOGIC;
			ioRxZB	: in  STD_LOGIC;
			ioTxZB	: out STD_LOGIC;
			
			--Display
			salBCD	: out STD_LOGIC_VECTOR (7 downto 0);
			ENE		: out STD_LOGIC_VECTOR (3 downto 0);
			
			--Teclado
			tecladoPIC: in STD_LOGIC_VECTOR (7 downto 0);
			--tecladoOK : in  STD_LOGIC;
			
			--Interruptores Panel
			bError	: in std_logic;
			bEquipo 	: in std_logic;	--0=LOCAL 1=VISITANTE
			bReloj   : in std_logic;  --0=PERIODO 1=24s
						
			--Botones Panel
			--btPlayPausa : in std_logic;  --0=FORWARD 1=BACKWARD
			--btResetReloj: in std_logic; 
			
			bJugadoresIn   : in std_logic_vector (11 downto 0);
			bEstadisticasIn: in std_logic_vector (7 downto 0);
			
			--ledJugadores   : out std_logic_vector (11 downto 0);
			--ledEstadisticas: out std_logic_vector (7 downto 0);
						
			--Interruptores Prueba
			iModo	: in  STD_LOGIC;
			iName	: in  STD_LOGIC;
			iKB	: in  STD_LOGIC;
					
			i1		: in  STD_LOGIC;
			i2		: in  STD_LOGIC;
			i3		: in  STD_LOGIC;
			
			--LEDs Prueba
			led1: out std_logic;
			led2: out std_logic;
			led3: out std_logic;
			
			led4: out std_logic;
			led5: out std_logic;
			led6: out std_logic;
			
			led7: out std_logic;
			led8: out std_logic;
			
			--Botones Prueba
			boton1	: in std_logic;
			boton2	: in std_logic;
			boton3	: in std_logic;
			boton4	: in std_logic);
end mainMaster;

architecture Behavioral of mainMaster is


--COMPONENTES**************************
component CLKs is
	Port (  Clk_in : in  STD_LOGIC;
           CLK_out: out STD_LOGIC);
end component;

component Registro is
    Port ( CLK : in  STD_LOGIC;
		     ENE: in  STD_LOGIC;	 
           CTRL : in  STD_LOGIC;
           Pin : in  STD_LOGIC_VECTOR (11 downto 0):="000000000000";
			  Pout1 : out  STD_LOGIC_VECTOR (3 downto 0):="0000";
           Pout2 : out  integer range 0 to 15);
end component;

component RegistroPanel is
    Port ( CLK : in  STD_LOGIC;
		     ENE: in  STD_LOGIC;	 
           CTRL : in  STD_LOGIC;
           Pin : in  STD_LOGIC_VECTOR (10 downto 0):="00000000000";
			  teclasOK : in  STD_LOGIC:='0';
			  Pout1 : inout  STD_LOGIC_VECTOR (3 downto 0):="0000";
           Pout2 : inout  integer range 0 to 15);
end component;

component Display is
Port (
	-- Input
	Clk_in	: in  STD_LOGIC;		-- Clock
	-- Data
	D0: in  STD_LOGIC_VECTOR (3 downto 0);
	D1: in  STD_LOGIC_VECTOR (3 downto 0);
	D2: in  STD_LOGIC_VECTOR (3 downto 0);
	D3: in  STD_LOGIC_VECTOR (3 downto 0);
		
	-- Output
	D7: out  STD_LOGIC_VECTOR (7 downto 0);	-- Data
	En: out  STD_LOGIC_VECTOR (3 downto 0)	-- Enable
		);
end component;

component OneShot is
Port ( Clk_in : in  STD_LOGIC;
       D : in  STD_LOGIC;
       Q : out  STD_LOGIC);
end component;

component FFT is
    Port ( Clk_in : in  STD_LOGIC;
			  ENE: in STD_LOGIC;
           Q : out  STD_LOGIC);
end component;

component serialComm is
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
			
			setNewValueRx			:out std_logic;
			enviaSend 				:in std_logic;
			elOtroDiceQueMandes 	:in std_logic;
			queElOtroMande			:out std_logic);
end component;

component eDobles IS
	port (
	addr: IN std_logic_VECTOR(4 downto 0);
	clk: IN std_logic;
	din: IN std_logic_VECTOR(7 downto 0);
	dout: OUT std_logic_VECTOR(7 downto 0);
	we: IN std_logic);
END component;

component eLibres IS
	port (
	addr: IN std_logic_VECTOR(4 downto 0);
	clk: IN std_logic;
	din: IN std_logic_VECTOR(7 downto 0);
	dout: OUT std_logic_VECTOR(7 downto 0);
	we: IN std_logic);
END component;

component eTriples IS
	port (
	addr: IN std_logic_VECTOR(4 downto 0);
	clk: IN std_logic;
	din: IN std_logic_VECTOR(7 downto 0);
	dout: OUT std_logic_VECTOR(7 downto 0);
	we: IN std_logic);
END component;

component eFaltas IS
	port (
	addr: IN std_logic_VECTOR(4 downto 0);
	clk: IN std_logic;
	din: IN std_logic_VECTOR(7 downto 0);
	dout: OUT std_logic_VECTOR(7 downto 0);
	we: IN std_logic);
END component;

component eAsistencias IS
	port (
	addr: IN std_logic_VECTOR(4 downto 0);
	clk: IN std_logic;
	din: IN std_logic_VECTOR(7 downto 0);
	dout: OUT std_logic_VECTOR(7 downto 0);
	we: IN std_logic);
END component;

component eRebotes IS
	port (
	addr: IN std_logic_VECTOR(4 downto 0);
	clk: IN std_logic;
	din: IN std_logic_VECTOR(7 downto 0);
	dout: OUT std_logic_VECTOR(7 downto 0);
	we: IN std_logic);
END component;

component ePlayeras IS
	port (
	addr: IN std_logic_VECTOR(4 downto 0);
	clk: IN std_logic;
	din: IN std_logic_VECTOR(7 downto 0);
	dout: OUT std_logic_VECTOR(7 downto 0);
	we: IN std_logic);
END component;

--*************************************


--************SEÑALES****************************************************
--Botones===================================================
signal sendAlgoPC:std_logic; --señal para indicar que se ha cambiado un valor y es necesario transmitirlo serialmente al programa en C
signal sendAlgoZB:std_logic; --señal para indicar que se ha cambiado un valor y es necesario transmitirlo serialmente al XBee

signal contador: std_logic_vector(25 downto 0);

--TECLADO================================================
signal teclasValidas		: std_logic:='0';
signal teclasOK			: std_logic:='0';
signal tecla1,tecla2    :  std_logic_vector(3 downto 0):="1010";

--CLKs===================================================
signal clk25,CLKBoton : std_logic; --25MHZ
--Display================================================
signal disp1,disp2,disp3,disp4: std_logic_vector(3 downto 0):="1010";
--Serial=================================================

--//paquetes Tx y Rx utilizados (55:id:C1:C2:C3:C4:AA)
signal datoIdTxPC		:std_logic_vector(7 downto 0);
signal datoC1TxPC		:std_logic_vector(7 downto 0); --Dato1 8
signal datoC2TxPC		:std_logic_vector(7 downto 0); --Dato2 4
signal datoC3TxPC		:std_logic_vector(7 downto 0); --Dato3 2
signal datoC4TxPC		:std_logic_vector(7 downto 0); --Dato4 1

signal datoIdRxPC		:std_logic_vector(7 downto 0);
signal datoC1RxPC		:std_logic_vector(7 downto 0);--quién
signal datoC2RxPC		:std_logic_vector(7 downto 0);--cuál
signal datoC3RxPC		:std_logic_vector(7 downto 0);--cómo
signal datoC4RxPC		:std_logic_vector(7 downto 0);

signal datoIdTxZB		:std_logic_vector(7 downto 0):="00000000";
signal datoC1TxZB		:std_logic_vector(7 downto 0):="00000000"; --Dato1 1
signal datoC2TxZB		:std_logic_vector(7 downto 0):="00000000"; --Dato2 2
signal datoC3TxZB		:std_logic_vector(7 downto 0):="00000000"; --Dato3 4
signal datoC4TxZB		:std_logic_vector(7 downto 0):="00000000"; --Dato4 8

signal datoIdRxZB		:std_logic_vector(7 downto 0);
signal datoC1RxZB		:std_logic_vector(7 downto 0);--quién
signal datoC2RxZB		:std_logic_vector(7 downto 0);--cuál
signal datoC3RxZB		:std_logic_vector(7 downto 0);--cómo
signal datoC4RxZB		:std_logic_vector(7 downto 0);

signal setNewValueRxPC	:std_logic:='0';
signal setNewValueRxZB  :std_logic:='0';
signal queZBMande			:std_logic;
signal quePCMande			:std_logic;
signal enviaSendPC		:std_logic;
signal enviaSendZB		:std_logic;

signal contestaPC		:std_logic_vector(24 downto 0):="0000000000000000000000000";
signal contestaZB		:std_logic:='0';

--ESTADISTICAS=================================================
signal algunBoton		   : std_logic:='0';
signal algunBotonPanel  : std_logic:='0';
signal algunBotonJugadores  : std_logic:='0';
signal instruccionPanel	: integer range 0 to 15;
signal instruccionPanelBINARIO: std_logic_vector(3 downto 0);
signal bpanelAux		   : std_logic_vector(11 downto 0);
signal errorMode  		: std_logic:='0';
signal relojPLAY			: std_logic:='0';
signal algoPUSHED			: std_logic:='0';
signal algoPUSHED2		: std_logic:='0';
signal algoPUSHED3		: std_logic:='0';
signal algoPUSHEDb		: std_logic:='0';
signal aux1					: std_logic:='0';
signal aux2					: std_logic:='0';
signal OS_error			: std_logic:='0';
signal OS_play				: std_logic:='0';

signal anuncio: std_logic_vector(1 downto 0):="00";

--//jugadores
signal jugador			:integer range 0 to 15;
signal jugadorBINARIO: std_logic_vector(3 downto 0);
signal ENEjugador		:std_logic:='0';

--//dobles
signal addrDobles: std_logic_VECTOR(4 downto 0);
signal dinDobles : std_logic_VECTOR(7 downto 0);
signal doutDobles: std_logic_VECTOR(7 downto 0);
signal weDobles  : std_logic;

--//libres
signal addrLibres: std_logic_VECTOR(4 downto 0);
signal dinLibres : std_logic_VECTOR(7 downto 0);
signal doutLibres: std_logic_VECTOR(7 downto 0);
signal weLibres  : std_logic;

--//triples
signal addrTriples: std_logic_VECTOR(4 downto 0);
signal dinTriples : std_logic_VECTOR(7 downto 0);
signal doutTriples: std_logic_VECTOR(7 downto 0);
signal weTriples  : std_logic;

--//faltas
signal addrFaltas: std_logic_VECTOR(4 downto 0);
signal dinFaltas : std_logic_VECTOR(7 downto 0);
signal doutFaltas: std_logic_VECTOR(7 downto 0);
signal weFaltas  : std_logic;

--//asistencias
signal addrAsist: std_logic_VECTOR(4 downto 0);
signal dinAsist : std_logic_VECTOR(7 downto 0);
signal doutAsist: std_logic_VECTOR(7 downto 0);
signal weAsist  : std_logic;

--//rebotes
signal addrRebotes: std_logic_VECTOR(4 downto 0);
signal dinRebotes : std_logic_VECTOR(7 downto 0);
signal doutRebotes: std_logic_VECTOR(7 downto 0);
signal weRebotes  : std_logic;

--//playeras
signal addrPlayeras: std_logic_VECTOR(4 downto 0);
signal dinPlayeras : std_logic_VECTOR(7 downto 0);
signal doutPlayeras: std_logic_VECTOR(7 downto 0);
signal wePlayeras  : std_logic;

--//otras miscellaneous
signal atiempofuera	:std_logic_vector(7 downto 0);
signal btiempofuera	:std_logic_vector(7 downto 0);

signal rNumCuarto		:std_logic_vector(7 downto 0);
signal rCuartoMin		:std_logic_vector(7 downto 0);
signal rCuartoSeg		:std_logic_vector(7 downto 0);
signal rCuartoCen		:std_logic_vector(7 downto 0);
signal rCuartoSTATUS	:std_logic_vector(7 downto 0);

signal r24Seg			:std_logic_vector(7 downto 0);
signal r24SegSTATUS	:std_logic_vector(7 downto 0);

signal bpanel		:  STD_LOGIC_VECTOR (10 downto 0):="00000000000";
signal bjugadores : STD_LOGIC_VECTOR (11 downto 0) :="000000000000";

signal tecladoOK   : std_logic;
signal btResetReloj: std_logic;
signal btPlayPausa : std_logic;

--FIN de SEÑALES*******************************************************************

begin

--RELOJES-==========================================================================
clk25MHz: Clks port map(CLK,clk25); --reloj de 25MHz
CLKBoton<= contador(13);

process(CLK)
	begin
		if CLK'event and CLK='1' then
				contador <= contador+1;
		end if;
end process;
--==================================================================================

--DISPLAY del SPARTAN================================================================

disp: Display port map(clk25,disp1,disp2,disp3,disp4,salBCD,ENE);

disp4<= datoC1RxPC(3 downto 0)  when (iModo ='1' and iName= '0' and iKB='0') else 
		  datoC1TxPC(3 downto 0)  when (iModo ='0' and iName= '0' and iKB='0') else
		  datoC1TxZB(3 downto 0)  when (iModo='0'  and iName ='1' and iKB='0') else 
		  jugadorBINARIO; --nada
disp3<= datoC2RxPC(3 downto 0)  when (iModo ='1' and iName= '0' and iKB='0') else 
		  datoC2TxPC(3 downto 0)  when (iModo ='0' and iName= '0' and iKB='0') else
		  datoC2TxZB(3 downto 0)  when (iName ='1' and iModo='0'  and iKB='0') else
		  "1010"; --nada
disp2<= datoC3RxPC(3 downto 0)  when (iModo ='1' and iName= '0' and iKB='0') else 
		  datoC3TxPC(3 downto 0)  when (iModo ='0' and iName= '0' and iKB='0') else
		  datoC3TxZB(3 downto 0)  when (iName ='1' and iModo= '0' and iKB='0') else  
		  tecla1 when (iKB='1' and i2='1') else
		  "1010"; --nada
disp1<= datoC4RxPC(3 downto 0)  when (iModo ='1' and iName= '0' and iKB='0') else 
		  datoC4TxPC(3 downto 0)  when (iModo ='0' and iName= '0' and iKB='0') else
		  datoC4TxZB(3 downto 0)  when (iName ='1' and iModo= '0' and iKB='0') else 
		  tecla2 when (iKB='1' and i2='1') else
		  instruccionPanelBINARIO; --nada

--====================================================================================


--ACTUALIZA ESTADÍSTICAS==============================================================

--//botones

process(CLKBoton)
	begin
		if CLKBoton'event and CLKBoton='1' then
					aux2<= aux1;
					aux1<= bEquipo;
					if (aux2=aux1)then
						algoPUSHED3<='0';
					else
						algoPUSHED3<='1';
					end if;
		end if;
end process;

algoPUSHEDb<= algoPUSHED2 or algoPUSHED3;

led8<=errormode;
led7<=relojPlay;

tecla2 <= tecladoPIC(3 downto 0);
tecla1 <= tecladoPIC(7 downto 4);

--bjugadores<= bJugadoresIn(11 downto 1) & boton1;
--bpanel<= "0"& btResetReloj & btPlayPausa & bEstadisticasIn;
--bpanel<= tecladoOK & btResetReloj & btPlayPausa & bEstadisticasIn;
--bpanel<= tecladoOK & btResetReloj & btPlayPausa & "0000000"& boton1;
--bjugadores<= bJugadoresIn;

tecladoOK   <= boton2 when (i2='1' and i3='1' ) else '0';
btResetReloj<= boton3 when (i2='1' and i3='1' ) else '0';
btPlayPausa <= boton4 when (i2='1' and i3='1' ) else '0';

--bjugadores<= "000000000010";

bjugadores(0)<= boton1 when (i2='0' and i3='1')else '0';-- and bReloj='0') else '0';
bjugadores(1)<= boton2 when (i2='0' and i3='1')else '0';-- and bReloj='0') else '0';
bjugadores(2)<= boton3 when (i2='0' and i3='1')else '0';-- and bReloj='0') else '0';
bjugadores(3)<= boton4 when (i2='0' and i3='1')else '0';-- and bReloj='0') else '0';
bjugadores(4)<= boton1 when (i2='1' and i3='0' and bReloj='0')else '0';-- and bReloj='1') else '0';
bjugadores(5)<= boton2 when (i2='1' and i3='0' and bReloj='0')else '0';-- and bReloj='1') else '0';
bjugadores(6)<= boton3 when (i2='1' and i3='0' and bReloj='0')else '0';-- and bReloj='1') else '0';
bjugadores(7)<= boton4 when (i2='1' and i3='0' and bReloj='0')else '0';-- and bReloj='1') else '0';
bjugadores(8)<= boton1 when (i2='1' and i3='0' and bReloj='1') else '0';
bjugadores(9)<= boton2 when (i2='1' and i3='0' and bReloj='1') else '0';
bjugadores(10)<=boton3 when (i2='1' and i3='0' and bReloj='1') else '0';
bjugadores(11)<=boton4 when (i2='1' and i3='0' and bReloj='1') else '0';

bpanel(0)<= boton1 when (i2='0' and i3='0' and bReloj='0') else '0';--libres
bpanel(1)<= boton2 when (i2='0' and i3='0' and bReloj='0') else '0';--dobles
bpanel(2)<= boton3 when (i2='0' and i3='0' and bReloj='0') else '0';--triples
bpanel(3)<= boton4 when (i2='0' and i3='0' and bReloj='0') else '0';--asist
bpanel(4)<= boton1 when (i2='0' and i3='0' and bReloj='1') else '0';--rebotes
bpanel(5)<= boton2 when (i2='0' and i3='0' and bReloj='1') else '0';--faltas
bpanel(6)<= boton3 when (i2='0' and i3='0' and bReloj='1') else '0';--cancha
bpanel(7)<= boton4 when (i2='0' and i3='0' and bReloj='1') else '0';--banca

bpanel(8) <=btPlayPausa;
bpanel(9) <=btResetReloj;
bpanel(10)<=tecladoOK;

algunBotonPanel     <= '1' when (bpanel > 0) or (teclasOK='1')else '0';
algunBotonJugadores <= '1' when (bjugadores > 0) else '0';
algunBoton          <= algunBotonPanel or algunBotonJugadores ;

tecladoPRESSED	  : OneShot  port map(CLKBoton,tecladoOK,teclasOK);
cualquieraJugador: OneShot  port map(CLKBoton,algunBotonJugadores,algoPUSHED2);
cualquieraPanel  : OneShot  port map(CLKBoton,algunBotonPanel,algoPUSHED);
oneShotPlay		  : OneShot  port map(CLKBoton,bpanel(8),OS_play);

--oneShotError	  : OneShot  port map(CLKBoton,bError,OS_error);
modoError		  : FFT  port map(teclasOK,'1',errorMode); --FFT
playPause		  : FFT  port map(OS_play ,'1',relojPLAY);--FFT

estadisticaPanel : RegistroPanel port map(CLK,algunBotonPanel,'0',bpanel,teclasOK,instruccionPanelBINARIO,instruccionPanel);

--//numero de jugador
ENEjugador <= '0' when bjugadores = 0 else '1'; 
numJugador : Registro port map(CLK,ENEjugador,'0',bjugadores,jugadorBINARIO,jugador);


process(CLK,setNewValueRxPC,datoIdRxPC,datoC1RxPC,datoC2RxPC,datoC3RxPC,datoC4RxPC)
begin
if (CLK='1' and CLK'event)then
	if (contestaPC>"0000000000000000000000000") then
		if (contestaPC = "1000011110100001001000000") then --1millon 40ms
			contestaPC <="0000000000000000000000000";
		else
			contestaPC <= contestaPC+'1';
		end if;
	end if;
	
	contestaZB<='0';
	weDobles  <='0';
	weLibres  <='0';
	weTriples <='0';
	weFaltas  <='0';
	weAsist   <='0';
	weRebotes <='0';
	wePlayeras<='0';
	
	if (setNewValueRxPC='1') then --se recibió algo por serial de la PC
		
		if (datoIdRxPC(7 downto 4) ="0000") then --no es refresh..es NORMAL
				--//mandar al Esclavo lo mismo que se ha recibido de la PC
				datoIdTxZB <=datoIdRxPC;
				datoC1TxZB <=datoC1RxPC;
				datoC2TxZB <=datoC2RxPC;
				datoC3TxZB <=datoC3RxPC;
				datoC4TxZB <=datoC4RxPC;
				
				--//actualizar valores internos con respecto a los recibidos de la PC
				if    (datoIdRxPC(3 downto 0) ="0001") then		--COMANDO NORMAL
						--===========================================
						if    (datoC3RxPC ="00000001") then  --DOBLES
								weDobles <='1';
								dinDobles<=datoC4RxPC;
								if    (datoC1RxPC ="00000001") then --LOCAL
									addrDobles<= datoC2RxPC(4 downto 0);
								elsif (datoC1RxPC ="00000010") then --VISITANTE
									addrDobles<= datoC2RxPC(4 downto 0) + "01100";
								end if;
						--===========================================
						elsif (datoC3RxPC ="00000010") then  --TRIPLES
								weTriples <='1';
								dinTriples<=datoC4RxPC;
								if    (datoC1RxPC ="00000001") then --LOCAL
									addrTriples<= datoC2RxPC(4 downto 0);
								elsif (datoC1RxPC ="00000010") then --VISITANTE
									addrTriples<= datoC2RxPC(4 downto 0) + "01100";
								end if;
						--===========================================
						elsif (datoC3RxPC ="00000011") then  --LIBRES
								weLibres <='1';
								dinLibres<=datoC4RxPC;
								if    (datoC1RxPC ="00000001") then --LOCAL
									addrLibres<= datoC2RxPC(4 downto 0);
								elsif (datoC1RxPC ="00000010") then --VISITANTE
									addrLibres<= datoC2RxPC(4 downto 0) + "01100";
								end if;				
						--===========================================
						
						elsif (datoC3RxPC ="00000100") then  --FALTAS
								weFaltas <='1';
								dinFaltas<=datoC4RxPC;
								if    (datoC1RxPC ="00000001") then --LOCAL
									addrFaltas<= datoC2RxPC(4 downto 0);
								elsif (datoC1RxPC ="00000010") then --VISITANTE
									addrFaltas<= datoC2RxPC(4 downto 0) + "01100";
								end if;
						--===========================================
						elsif (datoC3RxPC ="00000101") then  --ASISTENCIAS
								weAsist <='1';
								dinAsist<=datoC4RxPC;
								if    (datoC1RxPC ="00000001") then --LOCAL
									addrAsist<= datoC2RxPC(4 downto 0);
								elsif (datoC1RxPC ="00000010") then --VISITANTE
									addrAsist<= datoC2RxPC(4 downto 0) + "01100";
								end if;
						--===========================================
						elsif (datoC3RxPC ="00000110") then  --REBOTES
								weRebotes <='1';
								dinRebotes<=datoC4RxPC;
								if    (datoC1RxPC ="00000001") then --LOCAL
									addrRebotes<= datoC2RxPC(4 downto 0);
								elsif (datoC1RxPC ="00000010") then --VISITANTE
									addrRebotes<= datoC2RxPC(4 downto 0) + "01100";
								end if;
						--===========================================
						elsif (datoC3RxPC ="00000111") then  --PLAYERA	
								wePlayeras <='1';
								dinPlayeras<=datoC4RxPC;
								if    (datoC1RxPC ="00000001") then --LOCAL
									addrPlayeras<= datoC2RxPC(4 downto 0);
								elsif (datoC1RxPC ="00000010") then --VISITANTE
									addrPlayeras<= datoC2RxPC(4 downto 0) + "01100";
								end if;
						--===========================================
						end if; --//end QUE EQUIPO de COMANDO NORMAL (datoC1Rx)
				
									
				elsif (datoIdRxPC(3 downto 0) ="0011") then	 --CONFIG2 CRONOMETRO //establecer hora manualmente
					if    (datoC1RxPC ="00000001") then --RELOJ del PERIODO
							 rCuartoMin <=	datoC2RxPC;
							 rCuartoSeg	<= datoC3RxPC;
							 rCuartoCen	<= datoC4RxPC;
					elsif (datoC1RxPC ="00000010") then --RELOJ de 24s
							r24Seg      <= datoC3RxPC;
					elsif (datoC1RxPC ="00000011") then --Número de PERIODO
							rNumCuarto  <= datoC4RxPC;
					end if; --//end QUE TIPO DE RELOJ de CONFIG2 CRONOMETRO		
								
							
				end if; --//end de QUE COMANDO (datoIDRx)
				contestaZB<='1';
		--==============================================================================
		else --//es refresh
			contestaZB<='0';
			weDobles  <='0';
			weLibres  <='0';
			weTriples <='0';
			weFaltas  <='0';
			weAsist   <='0';
			weRebotes <='0';
			wePlayeras<='0';
			
			datoIdTxPC <=datoIdRxPC;
			datoC1TxPC <=datoC1RxPC;
			datoC2TxPC <=datoC2RxPC;
			datoC3TxPC <=datoC3RxPC;
			
			--===========================================
			if    (datoC3RxPC ="00000001") then  --DOBLES
				weDobles <='0';
				if    (datoC1RxPC ="00000001") then --LOCAL
					addrDobles<= datoC2RxPC(4 downto 0);
				elsif (datoC1RxPC ="00000010") then --VISITANTE
					addrDobles<= datoC2RxPC(4 downto 0) + "01100";
				end if;
			--===========================================			
			elsif (datoC3RxPC ="00000010") then  --TRIPLES
				weTriples <='0';
				if    (datoC1RxPC ="00000001") then --LOCAL
					addrTriples<= datoC2RxPC(4 downto 0);
				elsif (datoC1RxPC ="00000010") then --VISITANTE
					addrTriples<= datoC2RxPC(4 downto 0) + "01100";
				end if;
			--===========================================
			elsif (datoC3RxPC ="00000011") then  --LIBRES
				weLibres <='0';
				if    (datoC1RxPC ="00000001") then --LOCAL
					addrLibres<= datoC2RxPC(4 downto 0);
				elsif (datoC1RxPC ="00000010") then --VISITANTE
					addrLibres<= datoC2RxPC(4 downto 0) + "01100";
				end if;
			--===========================================
			elsif (datoC3RxPC ="00000100") then  --FALTAS
				weFaltas <='0';
				if    (datoC1RxPC ="00000001") then --LOCAL
					addrFaltas<= datoC2RxPC(4 downto 0);
				elsif (datoC1RxPC ="00000010") then --VISITANTE
					addrFaltas<= datoC2RxPC(4 downto 0) + "01100";
				end if;
			--===========================================
			elsif (datoC3RxPC ="00000101") then  --ASISTENCIAS
				weAsist <='0';
				if    (datoC1RxPC ="00000001") then --LOCAL
					addrAsist<= datoC2RxPC(4 downto 0);
				elsif (datoC1RxPC ="00000010") then --VISITANTE
					addrAsist<= datoC2RxPC(4 downto 0) + "01100";
				end if;
			--===========================================
			elsif (datoC3RxPC ="00000110") then  --REBOTES
				weRebotes <='0';
				if    (datoC1RxPC ="00000001") then --LOCAL
					addrRebotes<= datoC2RxPC(4 downto 0);
				elsif (datoC1RxPC ="00000010") then --VISITANTE
					addrRebotes<= datoC2RxPC(4 downto 0) + "01100";
				end if;
			--===========================================
			elsif (datoC3RxPC ="00000111") then  --PLAYERA	
				wePlayeras <='0';
				if    (datoC1RxPC ="00000001") then --LOCAL
					addrPlayeras<= datoC2RxPC(4 downto 0);
				elsif (datoC1RxPC ="00000010") then --VISITANTE
					addrPlayeras<= datoC2RxPC(4 downto 0) + "01100";
				end if;
			--===========================================
			end if; --//end QUE EQUIPO de COMANDO NORMAL (datoC1Rx)
			contestaPC<="0000000000000000000000001";			
		--=============================================================================
		end if;--//del si es refresh o normal;
	elsif algoPUSHED='1' then  --==PANEL==
		case instruccionPanel is
				--===========================================
				when 1=> --LIBRES
					datoIdTxZB <="0000"&"0001"; --01 CONFIG NORMAL
					datoC2TxZB <="0000" & jugadorBINARIO;	 
					datoC3TxZB <="00000011";	   --03 Libres
					if(bEquipo='0')then --LOCAL
							datoC1TxZB <="00000001";    --LOCAL
							addrLibres <= '0'& jugadorBINARIO;
					else
							datoC1TxZB <="00000010";    --VISITANTE
							addrLibres <= '0'& jugadorBINARIO + "01100";
					end if;
					
					if (bError = '0')then
						dinLibres <= doutLibres +'1';
						if (dinLibres(3 downto 0) > "1001") then
							dinLibres(3 downto 0)<= "0000";
							dinLibres(7 downto 4)<= dinLibres(7 downto 4)+'1';
						end if;
						weLibres <='1';
						if (dinLibres(3 downto 0)= "1010") then
							datoC4TxZB(7 downto 4)<= dinLibres(7 downto 4)+'1';
							datoC4TxZB(3 downto 0)<="0000";
						else
							datoC4TxZB<= dinLibres;
						end if;
					else --MODO ERROR
						if (doutLibres > "00000000" and doutLibres < "10011001" ) then
							dinLibres <= doutLibres -'1';
							if (dinLibres(3 downto 0) = "1111") then
								dinLibres(3 downto 0)<= "1001";
							end if;
							weLibres <='1';
							
							if (dinLibres(3 downto 0)= "1111") then
								datoC4TxZB(3 downto 0)<="1001";
							else
								datoC4TxZB<= dinLibres;
							end if;
						end if;
					end if; --¿errorMode?
				--===========================================
				when 2=> --DOBLES
					datoIdTxZB <="0000"&"0001"; --01 CONFIG NORMAL
					datoC2TxZB <="0000" & jugadorBINARIO;	 
					datoC3TxZB <="00000001";	   --01 Dobles
					if(bEquipo='0')then --LOCAL
							datoC1TxZB <="00000001";    --LOCAL
							addrDobles <= '0'& jugadorBINARIO;
					else
							datoC1TxZB <="00000010";    --VISITANTE
							addrDobles <= '0'& jugadorBINARIO + "01100";
					end if;
					
					if (bError = '0')then
						dinDobles <= doutDobles +'1';
						if (dinDobles(3 downto 0) > "1001") then
							dinDobles(3 downto 0)<= "0000";
							dinDobles(7 downto 4)<= dinDobles(7 downto 4)+'1';
						end if;
						weDobles <='1';
						if (dinDobles(3 downto 0)= "1010") then
							datoC4TxZB(7 downto 4)<= dinDobles(7 downto 4)+'1';
							datoC4TxZB(3 downto 0)<="0000";
						else
							datoC4TxZB<= dinDobles;
						end if;
					else --MODO ERROR
						if (doutDobles > "00000000" and doutDobles < "10011001" ) then
							dinDobles <= doutDobles -'1';
							if (dinDobles(3 downto 0) = "1111") then
								dinDobles(3 downto 0)<= "1001";
							end if;
							weDobles <='1';
							
							if (dinDobles(3 downto 0)= "1111") then
								datoC4TxZB(3 downto 0)<="1001";
							else
								datoC4TxZB<= dinDobles;
							end if;
						end if;
					end if; --¿errorMode?
				--===========================================
				when 3=> --TRIPLES
					datoIdTxZB <="0000"&"0001"; --01 CONFIG NORMAL
					datoC2TxZB <="0000" & jugadorBINARIO;	 
					datoC3TxZB <="00000010";	   --02 Triples
					if(bEquipo='0')then --LOCAL
							datoC1TxZB <="00000001";    --LOCAL
							addrTriples <= '0'& jugadorBINARIO;
					else
							datoC1TxZB <="00000010";    --VISITANTE
							addrTriples <= '0'& jugadorBINARIO + "01100";
					end if;
					
					if (bError = '0')then
						dinTriples <= doutTriples +'1';
						if (dinTriples(3 downto 0) > "1001") then
							dinTriples(3 downto 0)<= "0000";
							dinTriples(7 downto 4)<= dinTriples(7 downto 4)+'1';
						end if;
						weTriples <='1';
						if (dinTriples(3 downto 0)= "1010") then
							datoC4TxZB(7 downto 4)<= dinTriples(7 downto 4)+'1';
							datoC4TxZB(3 downto 0)<="0000";
						else
							datoC4TxZB<= dinTriples;
						end if;
					else --MODO ERROR
						if (doutTriples > "00000000" and doutTriples < "10011001" ) then
							dinTriples <= doutTriples -'1';
							if (dinTriples(3 downto 0) = "1111") then
								dinTriples(3 downto 0)<= "1001";
							end if;
							weTriples <='1';
							
							if (dinTriples(3 downto 0)= "1111") then
								datoC4TxZB(3 downto 0)<="1001";
							else
								datoC4TxZB<= dinTriples;
							end if;
						end if;
					end if; --¿errorMode?
				--===========================================
				when 4=> --ASISTENCIAS
					datoIdTxZB <="0000"&"0001"; --01 CONFIG NORMAL
					datoC2TxZB <="0000" & jugadorBINARIO;	 
					datoC3TxZB <="00000101";	   --05 Asistencias
					if(bEquipo='0')then --LOCAL
							datoC1TxZB <="00000001";    --LOCAL
							addrAsist  <= '0'& jugadorBINARIO;
					else
							datoC1TxZB <="00000010";    --VISITANTE
							addrAsist  <= '0'& jugadorBINARIO + "01100";
					end if;
					
					if (bError = '0')then
						dinAsist  <= doutAsist +'1';
						if (dinAsist(3 downto 0) > "1001") then
							dinAsist(3 downto 0)<= "0000";
							dinAsist(7 downto 4)<= dinAsist(7 downto 4)+'1';
						end if;
						weAsist <='1';
						if (dinAsist(3 downto 0)= "1010") then
							datoC4TxZB(7 downto 4)<= dinAsist(7 downto 4)+'1';
							datoC4TxZB(3 downto 0)<="0000";
						else
							datoC4TxZB<= dinAsist;
						end if;
					else --MODO ERROR
						if (doutAsist > "00000000" and doutAsist < "10011001" ) then
							dinAsist <= doutAsist -'1';
							if (dinAsist(3 downto 0) = "1111") then
								dinAsist(3 downto 0)<= "1001";
							end if;
							weAsist <='1';
							
							if (dinAsist(3 downto 0)= "1111") then
								datoC4TxZB(3 downto 0)<="1001";
							else
								datoC4TxZB<= dinAsist;
							end if;
						end if;
					end if; --¿errorMode?
				--===========================================
				when 5=> --REBOTES
					datoIdTxZB <="0000"&"0001"; --01 CONFIG NORMAL
					datoC2TxZB <="0000" & jugadorBINARIO;	 
					datoC3TxZB <="00000110";	   --06 Rebotes
					if(bEquipo='0')then --LOCAL
							datoC1TxZB <="00000001";    --LOCAL
							addrRebotes<= '0'& jugadorBINARIO;
					else
							datoC1TxZB <="00000010";    --VISITANTE
							addrRebotes<= '0'& jugadorBINARIO + "01100";
					end if;
					
					if (bError = '0')then
						dinRebotes<= doutRebotes +'1';
						if (dinRebotes(3 downto 0) > "1001") then
							dinRebotes(3 downto 0)<= "0000";
							dinRebotes(7 downto 4)<= dinRebotes(7 downto 4)+'1';
						end if;
						weRebotes <='1';
						if (dinRebotes(3 downto 0)= "1010") then
							datoC4TxZB(7 downto 4)<= dinRebotes(7 downto 4)+'1';
							datoC4TxZB(3 downto 0)<="0000";
						else
							datoC4TxZB<= dinRebotes;
						end if;
					else --MODO ERROR
						if (doutRebotes > "00000000" and doutRebotes < "10011001" ) then
							dinRebotes <= doutRebotes -'1';
							if (dinRebotes(3 downto 0) = "1111") then
								dinRebotes(3 downto 0)<= "1001";
							end if;
							weRebotes <='1';
							
							if (dinRebotes(3 downto 0)= "1111") then
								datoC4TxZB(3 downto 0)<="1001";
							else
								datoC4TxZB<= dinRebotes;
							end if;
						end if;
					end if; --¿errorMode?
				--===========================================
				when 6=> --FALTAS
					datoIdTxZB <="0000"&"0001"; --01 CONFIG NORMAL
					datoC2TxZB <="0000" & jugadorBINARIO;	 
					datoC3TxZB <="00000100";	   --04 Faltas
					if(bEquipo='0')then --LOCAL
							datoC1TxZB <="00000001";    --LOCAL
							addrFaltas <= '0'& jugadorBINARIO;
					else
							datoC1TxZB <="00000010";    --VISITANTE
							addrFaltas <= '0'& jugadorBINARIO + "01100";
					end if;
					
					if (bError = '0')then
						dinFaltas <= doutFaltas +'1';
						if (dinFaltas(3 downto 0) > "1001") then
							dinFaltas(3 downto 0)<= "0000";
							dinFaltas(7 downto 4)<= dinFaltas(7 downto 4)+'1';
						end if;
						weFaltas <='1';
						if (dinFaltas(3 downto 0)= "1010") then
							datoC4TxZB(7 downto 4)<= dinFaltas(7 downto 4)+'1';
							datoC4TxZB(3 downto 0)<="0000";
						else
							datoC4TxZB<= dinFaltas;
						end if;
					else --MODO ERROR
						if (doutFaltas > "00000000" and doutFaltas < "10011001" ) then
							dinFaltas <= doutFaltas -'1';
							if (dinFaltas(3 downto 0) = "1111") then
								dinFaltas(3 downto 0)<= "1001";
							end if;
							weFaltas <='1';
							
							if (dinFaltas(3 downto 0)= "1111") then
								datoC4TxZB(3 downto 0)<="1001";
							else
								datoC4TxZB<= dinFaltas;
							end if;
						end if;
					end if; --¿errorMode?
				--===========================================
				when 7=> --jugador en CANCHA
					datoIdTxZB <="0000"&"0001";--01 CONFIG NORMAL
					if (bEquipo = '0') then
							datoC1TxZB <="00000001"; --LOCAL 
					else  
							datoC1TxZB <="00000010"; --VISITANTE
					end if;
					datoC2TXZB <= "0000" & jugadorBINARIO;
					datoC3TxZB <="00001001";	--09 JUGANDO/BANCA
					datoC4TxZB <="00000001";   --01 jugador entró a jugar
				--===========================================
				when 8=> --jugador en BANCA
					datoIdTxZB <="0000"&"0001";--01 CONFIG NORMAL
					if (bEquipo = '0') then
							datoC1TxZB <="00000001"; --LOCAL 
					else  
							datoC1TxZB <="00000010"; --VISITANTE
					end if;
					datoC2TXZB <= "0000" & jugadorBINARIO;
					datoC3TxZB <="00001001";	--09 JUGANDO/BANCA
					datoC4TxZB <="00000000";   --00 jugador salió a banca
				--===========================================
				when 9=> --PLAY/PAUSE
					
					if(bReloj='0')then 			 --Reloj del PERIODO
							datoIdTxZB <="0000"&"0010"; --02 CONFIG1 CRONOM
							datoC1TxZB <="00000001";    --01 RELOJ PERIODO
							if (relojPLAY='1') then
								datoC4TxZB <="0000"&"0001"; --01 PLAY
							else
								datoC4TxZB <="0000"&"0010"; --02 PAUSA
							end if;
					else --Reloj 24s
							datoIdTxZB <="0000"&"0100"; --04 CONFIG PUBLICIDAD
							datoC1TxZB <="00000000";    --01 RELOJ 24s
							if anuncio="00" then
								datoC4TxZB <="0000"&"0010";--2
								anuncio<="01";
							elsif anuncio="01" then
								datoC4TxZB <="0000"&"0011";--3
								anuncio<="10";
							elsif anuncio="10" then
								datoC4TxZB <="0000"&"0001";--1
								anuncio<="00";
							end if;
					end if;
					datoC2TxZB <="00000000";    --xx
					datoC3TxZB <="00000000";	 --xx
					
				--===========================================
				when 10=> --RESET
					datoIdTxZB <="0000"&"0010"; --02 CONFIG1 CRONOM
					if(bReloj='0')then 			 --Reloj del PERIODO
							datoC1TxZB <="00000001";    --01 RELOJ PERIODO
					else --Reloj 24s
							datoC1TxZB <="00000010";    --01 RELOJ 24s
					end if;
					datoC2TxZB <="00000000";    --xx
					datoC3TxZB <="00000000";	 --xx
					datoC4TxZB <="0000"&"0011"; --03 RESET
				--===========================================
				when 11=> --TIEMPO FUERA
					datoIdTxZB <="0000"&"0001"; --01 CONFIG NORMAL
					datoC2TxZB <="00000000";    --xx
					datoC3TxZB <="00001000";	 --08 TIEMPO FUERA
					if(bEquipo='0')then --LOCAL
						datoC1TxZB <="00000001";    --01 LOCAL
						datoC4TxZB <= atiempofuera +'1';   --enésimo tfuera
						atiempofuera <= atiempofuera + '1';
					else --VISITANTE
						datoC1TxZB <="00000010";	 --02 VISITA
						datoC4TxZB <= btiempofuera +'1';   --enésimo tfuera
						btiempofuera <= btiempofuera + '1';
					end if;
				--===========================================
				when 12=> --PLAYERAS
					datoIdTxZB <="0000"&"0001"; --01 CONFIG NORMAL
					datoC2TxZB <="0000" & jugadorBINARIO;	 
					datoC3TxZB <="00000111";	   --07 Playeras
					datoC4TxZB<= tecla1&tecla2;
					if(bEquipo='0')then --LOCAL
							datoC1TxZB <="00000001";    --LOCAL
							addrPlayeras<= '0'& jugadorBINARIO;
					else
							datoC1TxZB <="00000010";    --VISITANTE
							addrPlayeras<= '0'& jugadorBINARIO + "01100";
					end if;
					
					dinPlayeras<= tecla1&tecla2;
					wePlayeras <='1';					
				--===========================================
				when others=> null;
		end case;
		contestaZB<='1';
		

		elsif algoPUSHEDb='1' then  --==PANEL==
		contestaZB<='0';
		contestaPC<="0000000000000000000000000";
		
				--===========================================
				
					if(bEquipo='0')then --LOCAL
							addrLibres  <= '0'& jugadorBINARIO;
							addrDobles  <= '0'& jugadorBINARIO;
							addrTriples <= '0'& jugadorBINARIO;
							addrAsist   <= '0'& jugadorBINARIO;
							addrRebotes <= '0'& jugadorBINARIO;
							addrFaltas  <= '0'& jugadorBINARIO;
							addrPlayeras<= '0'& jugadorBINARIO;
					else					 --VISITANTE
							addrLibres  <= '0'& jugadorBINARIO + "01100";
							addrDobles  <= '0'& jugadorBINARIO + "01100";
							addrTriples <= '0'& jugadorBINARIO + "01100";
							addrAsist   <= '0'& jugadorBINARIO + "01100";
							addrRebotes <= '0'& jugadorBINARIO + "01100";
							addrFaltas  <= '0'& jugadorBINARIO + "01100";
							addrPlayeras<= '0'& jugadorBINARIO + "01100";
					end if;
					
				--===========================================
		
  end if;
end if;
end process;

datoC4TxPC<=doutDobles   when (weDobles  = '0' and datoC3RxPC ="00000001") else 
				doutTriples  when (weTriples = '0' and datoC3RxPC ="00000010") else
				doutLibres   when (weLibres  = '0' and datoC3RxPC ="00000011") else
				doutFaltas   when (weFaltas  = '0' and datoC3RxPC ="00000100") else 
				doutAsist    when (weAsist   = '0' and datoC3RxPC ="00000101") else
				doutRebotes  when (weRebotes = '0' and datoC3RxPC ="00000110") else
				doutPlayeras when (wePlayeras= '0' and datoC3RxPC ="00000111") else "00000000";
--===================================================================================


--MEMORIAS de BLOQUE=================================================================

estadDobles : eDobles       port map(addrDobles,CLK,dinDobles,doutDobles,weDobles);
estadLibres : eLibres       port map(addrLibres,CLK,dinLibres,doutLibres,weLibres);	
estadFaltas : eFaltas       port map(addrFaltas,CLK,dinFaltas,doutFaltas,weFaltas);
estadTriples: eTriples      port map(addrTriples,CLK,dinTriples,doutTriples,weTriples);	
estadRebotes: eRebotes      port map(addrRebotes,CLK,dinRebotes,doutRebotes,weRebotes);
estadPlayers: ePlayeras     port map(addrPlayeras,CLK,dinPlayeras,doutPlayeras,wePlayeras);
estadAsist  : eAsistencias  port map(addrAsist,CLK,dinAsist,doutAsist,weAsist);

--====================================================================================

--PUERTOS SERIAL======================================================================
puertoPC: serialComm port map (	CLK,led1,led2,led3,ioRxPC,ioTxPC,
											datoIdTxPC,datoC1TxPC,datoC2TxPC,datoC3TxPC,datoC4TxPC,
											datoIdRxPC,datoC1RxPC,datoC2RxPC,datoC3RxPC,datoC4RxPC,
											setNewValueRxPC,enviaSendPC,quePCMande,queZBMande);
											
puertoZB: serialComm port map (	CLK,led4,led5,led6,ioRxZB,ioTxZB,
											datoIdTxZB,datoC1TxZB,datoC2TxZB,datoC3TxZB,datoC4TxZB,
											datoIdRxZB,datoC1RxZB,datoC2RxZB,datoC3RxZB,datoC4RxZB,
											setNewValueRxZB,enviaSendZB,queZBMande,quePCMande);
											
enviaSendZB <= '1' when (sendAlgoZB ='1') or (contestaZB='1') else '0';
enviaSendPC <= '1' when (sendAlgoPC ='1') or (contestaPC="1000011110100001001000000")else '0';

--====================================================================================

end Behavioral;


--play/pausa --9