#include "P18F4550.inc"

	UDATA_ACS
tecla res 1
contKEYS res 1
vel	res 1
PORTBTEMP res 1
variable1 res 1		; etiqueta un byte de memoria RAM con el nombre "variable1"
variable2 res 2
variable3 res 3
temp	  res 1
uni  	  res 1
dec		  res 1
cent	  res 1
wtmp	  res 1
contFF	res 1
cont78	res 1


org 0
	goto Inicio

org 8h
salirISR:
	retfie 1
   
salir
	retfie 1

org 0x50

txtWELCOME	db "   iScore v1.0  ",0x00 
txtSETplayera	db "PLAYERA: ",0x00 

org 100
Inicio

;----------------INICIALIZACION DEL LCD--------------------------------------


inicializa:
	call INITLCD

	movlw CLR_DISP			;limpia el LCD
	call LCD_CMD

	movlw LINE1
	call LCD_CMD

	MOVLW UPPER txtWELCOME	;escribe "iScore v1.0"
	MOVWF TBLPTRU 			
	MOVLW HIGH  txtWELCOME
	MOVWF TBLPTRH
	MOVLW LOW	txtWELCOME
	MOVWF TBLPTRL 
	call WRITE_LCD
	

;escribe en 2da linea: "Playera: "	
	movlw LINE2
	call LCD_CMD
	MOVLW UPPER txtSETplayera
	MOVWF TBLPTRU 			
	MOVLW HIGH txtSETplayera
	MOVWF TBLPTRH
	MOVLW LOW  txtSETplayera
	MOVWF TBLPTRL 
	call WRITE_LCD

;----------------------------------------------------------------------------

;----------------INICIALIZACION DEL TECLADO--------------------------------------
; Se utilizan:
; PUERTO A:---> 0,1,2     SALIDAS   (COLUMNAS)
; PUERTO B:---> 4,5,6,7   ENTRADAS (RENGLONES)

	bsf TRISB,4		 ; PORTB (5,4,3) Salidas, (2,1,0) Entradas
	bsf TRISB,5
	bsf TRISB,6
	bsf TRISB,7
	
	movlw b'00000000'
	bcf	INTCON2,RBPU	;Turn on the PORT B pullups.
	bcf	TRISA,0
	bcf TRISA,1
	bcf TRISA,2
	call delaytcl
	movlw b'00001111'
	movwf ADCON1
	movlw 0xFF
	movwf tecla
	movlw d'1'
	movwf contKEYS ;Contador para que solo se tome el valor de 3 teclas
	setf vel
;------------------------------------------------------------------------------


main
	goto CHECAR_KEYS

;********************************************************************************
;---------------- INICIO DE CODIGO DEL TECLADO------------------------------------
;*********************************************************************************
;Rutina que detecta las pulsaciones en teclado matricial, y despues de oprimidas
; 2 teclas guarda el resultado en la variable "vel"


CHECAR_KEYS
	
;Aqui se queda hasta que se presione una tecla
	movlw d'1'
	movwf contKEYS
CHECAR_KEYS2
    
	;escribe en 2da linea: "Playera: "	
	movlw LINE2
	call LCD_CMD
	MOVLW UPPER txtSETplayera
	MOVWF TBLPTRU 			
	MOVLW HIGH txtSETplayera
	MOVWF TBLPTRH
	MOVLW LOW  txtSETplayera
	MOVWF TBLPTRL 
	call WRITE_LCD

    
	movlw b'00000000' ; columnas en 0
	movwf PORTA
	call delaytcl 		;wait 20us
	movf PORTB,W,0 ; 	read PORTB
	andlw b'11110000' ; mask out unused bits
	xorlw b'11110000' ; are bits 2,1,0 all 1?
	bz CHECAR_KEYS2 ; 		if yes branch to KEYPRESS
	nop ; 				if not execute jump
	
	
;Una vez presionada la tecla va barriendo columna x columna cada renglon
CHECK_COL3 
	movlw b'00000011' ; Output a zero for column 3
	movwf PORTA,0 ; writing values to the PORT
	call delaytcl ; wait 20us
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'01110000' ; mask out unused bits
CHECK_9 
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'01110000' ; mask out unused bits
	xorlw b'01100000' ; was the 9 button pressed
	bnz CHECK_6 ; if it was not 9 then check if it is 6
	movlw 0x09 ; if it was 9 load WREG = 9 and DONE!!
	movwf tecla
	goto FINteclado ; jump to FINteclado
CHECK_6 
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'01110000' ; mask out unused bits
	xorlw b'01010000' ; was the 6 button pressed?
	bnz CHECK_3 ; if it was not 6 then check if it is 3
	movlw 0x06 ; if it was 6 load WREG = 6 and DONE!!
	movwf tecla
	goto FINteclado
CHECK_3 
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'01110000' ; mask out unused bits
	xorlw b'00110000' ; was the 3 button pressed?
	bnz CHECK_COL2 ; if it was not 3 then check the next COLUMN
	movlw 0x03 ; if it was 3 load WREG = 3 and DONE!!
	movwf tecla
	goto FINteclado
					
CHECK_COL2 
	movlw b'00000101' ; Output a zero for column 2
	movwf PORTA,0 ; writing values to the PORT
	call delaytcl ; wait 20us
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'11110000' ; mask out unused bits
CHECK_8 
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'11110000' ; mask out unused bits
	xorlw b'11100000' ; was the 8 button pressed
	bnz CHECK_5 ; if it was not 8 then check if it is 5
	movlw 0x08 ; if it was 8 load WREG = 8 and DONE!!
	movwf tecla
	goto FINteclado ; jump to FINteclado
CHECK_5 
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'11110000' ; mask out unused bits
	xorlw b'11010000' ; was the 5 button pressed?
	bnz CHECK_2 ; if it was not 5 then check if it is 2
	movlw 0x05 ; if it was 5 load WREG = 5 and DONE!!
	movwf tecla
	goto FINteclado
CHECK_2 
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'11110000' ; mask out unused bits
	xorlw b'10110000' ; was the 2 button pressed?
	bnz CHECK_0 ; if it was not 2 then check the next COLUMN
	movlw 0x02 ; if it was 2 load WREG = 2 and DONE!!
	movwf tecla
	goto FINteclado

CHECK_0 
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'11110000' ; mask out unused bits
	xorlw b'01110000' ; was the 2 button pressed?
	bnz CHECK_COL1 ; if it was not 2 then check the next COLUMN
	movlw 0x00 ; if it was 2 load WREG = 2 and DONE!!
	movwf tecla
	goto FINteclado

CHECK_COL1 
	movlw b'00000110' ; Output a zero for column 
	movwf PORTA,0 ; writing values to the PORT
	call delaytcl ; wait 20us
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'01110000' ; mask out unused bits
CHECK_7 
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'01110000' ; mask out unused bits
	xorlw b'01100000' ; was the 8 button pressed
	bnz CHECK_4 ; if it was not 8 then check if it is 5
	movlw 0x07 ; if it was 8 load WREG = 8 and DONE!!
	movwf tecla
	goto FINteclado ; jump to FINteclado
CHECK_4 
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'01110000' ; mask out unused bits
	xorlw b'01010000' ; was the 5 button pressed?
	bnz CHECK_1 ; if it was not 5 then check if it is 2
	movlw 0x04 ; if it was 5 load WREG = 5 and DONE!!
	movwf tecla
	goto FINteclado
CHECK_1 
	movf PORTB,0,0 ; read PC -> WREG
	andlw b'01110000' ; mask out unused bits
	xorlw b'00110000' ; was the 2 button pressed?
	bnz FINteclado ; if it was not 2 then check the next COLUMN
	movlw 0x01 ; if it was 2 load WREG = 2 and DONE!!
	movwf tecla
	goto FINteclado

FINteclado
;En las siguientes rutinas se convierten las 2 teclas por medio de multiplicaciones, en el valor
;de 2 digitos que se desea:

	movlw 0x01
	cpfseq contKEYS
	bra tstcont0
	movff tecla,vel
	
tstcont1
	movf vel,w
	mullw d'10'
	movff PRODL,vel
	bra contFINteclado
tstcont0
	movf tecla,w
	addwf vel,f
centOK

;------	Aqui se envian los DATOS AL LCD-----
	movf vel,w
	call dispwdec

	movf vel,w
	mullw d'4'

;---- Aquí vel se multiplica x 4, y se envían los 10 bits a CCPR2L y los 2 LSB, que hacen el Duty Cycle --------;	
	btfss PRODL,0
	btfsc PRODL,0
	bsf CCP1CON,4
	btfss PRODL,0
	bcf CCP1CON,4

	btfss PRODL,1
	btfsc PRODL,1
	bsf CCP1CON,5
	btfss PRODL,1
	bcf CCP1CON,5
	
	rrncf PRODL,F
	rrncf PRODL,F

	btfss PRODH,0
	btfsc PRODH,0
	bsf PRODL,6
	btfss PRODH,0
	bcf PRODL,6

	btfss PRODH,1
	btfsc PRODH,1
	bsf PRODL,7
	btfss PRODH,7
	bcf PRODL,1
	
	movff PRODL,CCPR1L
	
;-------------------------------------------
	
	movlw d'2'
	movwf contKEYS


contFINteclado
	decf contKEYS

looploop ;Esta rutina se hace para eliminar los rebotes que ocurren al dejar una tecla presionada por mucho tiempo,
		 ; No sale de esta rutina hasta que se desoprime
	movf PORTB,w
	andlw b'11110000'
	movwf PORTBTEMP
	movlw b'11110000' ;Ninguna oprimida
	cpfseq PORTBTEMP
	bra looploop 
	
	call delay_rebote
	call delay_rebote
	call delay_rebote
	call delay_rebote
	call delay_rebote
	bra CHECAR_KEYS2



;------------------- desplegar en decimal--------------
dispwdec
	movwf wtmp
	call hex2dec	
	movf dec,w
	addlw 0x30
	call LCD_CHAR
	movf uni,w
	addlw 0x30
	call LCD_CHAR
	movf wtmp,w	

	;saca DEC y UNI a los PUERTOS (E0-E2)(C0-C1)(B0-B2)
;bit7--
bit7on	btfss dec,3			;si es 1 entonces se tiene que salir un '1' por el pin
		bra bit7off
		bsf PORTE,0					;saca un '1'
		bra bit6on
bit7off
		bcf PORTE,0					;saca un '0'

;bit6--
bit6on	btfss dec,2			;si es 1 entonces se tiene que salir un '1' por el pin
		bra bit6off
		bsf PORTE,1					;saca un '1'
		bra bit5on
bit6off
		bcf PORTE,1					;saca un '0'

;bit5--
bit5on	btfss dec,1			;si es 1 entonces se tiene que salir un '1' por el pin
		bra bit5off
		bsf PORTE,2					;saca un '1'
		bra bit4on
bit5off
		bcf PORTE,2					;saca un '0'

;bit4--
bit4on	btfss dec,0			;si es 1 entonces se tiene que salir un '1' por el pin
		bra bit4off
		bsf PORTC,0					;saca un '1'
		bra bit3on
bit4off
		bcf PORTC,0					;saca un '0'

;bit3--
bit3on	btfss uni,3			;si es 1 entonces se tiene que salir un '1' por el pin
		bra bit3off
		bsf PORTC,1					;saca un '1'
		bra bit2on
bit3off
		bcf PORTC,1					;saca un '0'

;bit2--
bit2on	btfss uni,2			;si es 1 entonces se tiene que salir un '1' por el pin
		bra bit2off
		bsf PORTB,2					;saca un '1'
		bra bit1on
bit2off
		bcf PORTB,2					;saca un '0'

;bit1--
bit1on	btfss uni,1			;si es 1 entonces se tiene que salir un '1' por el pin
		bra bit1off
		bsf PORTB,1					;saca un '1'
		bra bit0on
bit1off
		bcf PORTB,1					;saca un '0'

;bit0--
bit0on	btfss uni,0			;si es 1 entonces se tiene que salir un '1' por el pin
		bra bit0off
		bsf PORTB,0					;saca un '1'
		bra salESCRIBEspartan
bit0off
		bcf PORTB,0					;saca un '0'

salESCRIBEspartan
	return

;----------------- hex2dec routine----------------------
hex2dec
	movwf temp
	clrf uni
	clrf dec
	clrf cent
sup100
	movlw d'99'
	cpfsgt temp
	bra sup10
	movlw d'100'
	subwf temp,f
	incf cent
	bra sup100
sup10 movlw d'9'
	cpfsgt temp
	bra inf10
	movlw d'10'
	subwf temp,f
	incf dec
	bra sup10
inf10 tstfsz temp
	bra process
	bra salida
process decf temp
	incf uni
	bra inf10
salida return	


;----DELAY PARA ELIMINAR REBOTES DEL 4x3 KEYPAD------------
delay_rebote	
denuevo
	movlw 0xFF
	movwf contFF
decrementa
	dcfsnz contFF,f
	bra dec_78
	bra decrementa
dec_78
	dcfsnz cont78,f
	bra salida1
	bra denuevo
salida1
	movlw 0x4E
	movwf cont78
	return
;------------------------------------------------------------


;--------- DELAY 20microsegundos------------------------------
delaytcl
	nop

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	return 
;****************************************************************
;---------------- FIN DE CODIGO DEL TECLADO----------------------
;*****************************************************************


;INCLUDES OTROS**************************************************
	#include "rutinasLCD.inc"

	end
