;*******************************************************************************                                                                                                                                      *
;*******************************************************************************
;                                                                              
;    Filename: Laboratorio 7                                                               
;    Date: Oct 2020                                                                                                                          
;    Author: Cuellar                                                           
;    Company: UVG                                                              
;    Description: LAB7                                                                                                                                 
#include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_ON & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
;#####VARIABLES####
 CBLOCK
 CUENTA ;Variable para los ciclos del timer1
 CUENTA2
 AUMENTO ;Variable para los ciclos del timer 1
 ENDC
 ;NUMERO EQU .10 ;Cuantas veces quiero que cuente el timer1
 NUMERO2 EQU .2
 
GPR UDATA
ADC_VAL RES 1
ADC_VAL2 RES 1
DECODE	RES 1
DECODE2	RES 1
DECODE3 RES 1
DECODE4 RES 1
CONT1	RES 1
CONT2	RES 1
XCOR	RES 1
YCOR	RES 1
BAND	RES 1
BAND2	RES 1
VIENE  RES 1
YVIENE  RES 1
BANDERAS RES 1
MOT	RES 1
BARRIDOS    RES 1
NUMERO	    RES 1
CNT	RES 1
CAMBIO RES 1
MOD RES 1
 
 
;####RESET VECTOR####
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    SETUP                   ; go to beginning of program

;####INTERRUPT####

;####TABLAS####
;Tabla para decodificar valores binarios hacia el display de 7 seg

    
    
MAIN_PROG CODE                      ; let linker place main program
SETUP:
    ;BSF	 STATUS, RP0
    ;MOVLW B'00001011'
    CALL CONFIG_IO
    CALL CONFIG_ADC
    CALL CONFIG_TXRX
    CALL CONFIG_T2CON_CCP1CON
    CALL    LEC_EEPROM
    
    CLRF BAND
    CLRF BAND2
    CLRF XCOR
    CLRF YCOR
    CLRF VIENE
    CLRF BANDERAS
    CLRF CAMBIO
    MOVLW .10
    MOVWF NUMERO
    MOVLW .10
    MOVWF CNT
    MOVWF MOD
    BSF	 BAND, 0
    
;####EMPIEZA MAINLOOP####     
LOOP:
    CALL    LEC_POTX
    CALL    DELAY_AQ
    CALL    LEC_POTY
    CALL    ENVIO1
    CALL    DELAY_MULTPLX
    CALL    RECIBIR2
    
    
    CALL    LEDS

    CALL    MOTORDC
    BTFSC   PORTD, 7
    GOTO    TEMPO_1
    BTFSC   PORTD, 3
    GOTO    TEMPO_2
    BTFSC   PORTD, 6
    GOTO    TEMPO_3
    
SIGUE:
    
    CALL    DELAY_AQ2
    DECFSZ  CNT, 1
    GOTO    LOOP
;    BTFSS   CAMBIO, 0
;    GOTO    TOGGLE_2
    CALL    TOGGLE
    
    
    
    

;    MOVFW   ADC_VAL
;    SUBLW   .1
;    MOVWF   MOT
;    BTFSC   STATUS, C
;    GOTO    SIGN
;    GOTO    NO_SIGN
    GOTO    LOOP                         ; loop forever
   
;####SETUPS####
CONFIG_IO:
    BANKSEL ANSEL
    CLRF    ANSEL
    COMF    ANSEL
    BANKSEL TRISA
    CLRF    TRISA
    COMF    TRISA
    BCF     TRISD, 2
    BSF	    TRISD, 3
    BSF	    TRISD, 6
    BSF	    TRISD, 7
    CLRF    TRISB
    CLRF    TRISC
    CLRF    TRISE
    BANKSEL PORTD
    CLRF    PORTA
    CLRF    PORTD
    CLRF    PORTB
    CLRF    PORTC
    RETURN
    
CONFIG_ADC:
    BANKSEL ADCON1
    MOVLW   B'00000000'
    MOVWF   ADCON1
    BANKSEL ADCON0
    MOVLW   B'01000001'
    MOVWF   ADCON0
    RETURN
    
CONFIG_ADC2:
    BANKSEL ADCON1
    MOVLW   B'00000000'
    MOVWF   ADCON1
    BANKSEL ADCON0
    MOVLW   B'01001001'
    MOVWF   ADCON0
    RETURN
    
CONFIG_TXRX:
    BANKSEL TXSTA
    BCF     TXSTA, SYNC
    BSF     TXSTA, BRGH
    BANKSEL BAUDCTL
    BCF     BAUDCTL, BRG16
    BANKSEL SPBRG
    MOVLW   .25
    MOVWF   SPBRG
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF     RCSTA, SPEN
    BCF     RCSTA, RX9
    BSF     RCSTA, CREN
    BANKSEL TXSTA
    BSF     TXSTA, TXEN
    BANKSEL PORTA
    RETURN
    
DELAY_AQ:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    RETURN
    
DELAY_SMALL
    MOVLW .10
    MOVFW CONT1
    DECFSZ CONT1, F
               GOTO $-1 ;IR A PC - 1, REGRESAR A DECFSZ
 RETURN
 
DELAY_MULTPLX ;Delay para multiplexar
    MOVLW .10
    MOVWF CONT2
CONFIG1:    
    CALL DELAY_SMALL
    DECFSZ CONT2, F
    GOTO CONFIG1
    RETURN
    
SEL_RECIBIR:
    BTFSC   BAND2, 0
    GOTO    RECIBIR2
;    BTFSC   BAND2, 1
;    GOTO    RECIBIR2
    
    

    
RECIBIR2: ;Recibir info de Y
    BCF	    BAND2, 0
    ;BCF	    BAND2, 1
    BTFSS   PIR1, RCIF
    RETURN
    MOVF    RCREG, W
    MOVWF   VIENE
    MOVWF   BANDERAS
    RETURN
    
CONFIG_T2CON_CCP1CON:
    BANKSEL PR2
    MOVLW   .156
    MOVWF   PR2
    BANKSEL CCP2CON
    BSF	    CCP2CON, 3
    BSF	    CCP2CON, 2
    BANKSEL PORTA
    MOVLW   B'00000111'
    MOVWF   T2CON
    BSF	    CCP1CON, 3
    BSF	    CCP1CON, 2
    BCF	    CCP1CON, 1
    BCF	    CCP1CON, 0
    RETURN
    
    
    
LEC_POTX: ;Lecutra del pot de X
    CALL    CONFIG_ADC
    BANKSEL PORTA
    CALL    DELAY_AQ
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, W
    MOVWF   ADC_VAL
    MOVWF   CCPR1L
    RETURN
    
LEC_POTY: ;lECTURA DEL POT DE Y
    CALL    CONFIG_ADC2
    BANKSEL PORTA
    CALL    DELAY_AQ
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, W
    MOVWF   ADC_VAL2
    ;MOVWF   CCPR2L
    RETURN
    
SEL_ENVIO: ;Toggle de env�os
    BTFSC   BAND, 0
    GOTO    ENVIO1
    BTFSC   BAND, 1
    GOTO    ENVIO3
    RETURN ;Envio primer Byte
ENVIO3:
    BCF     BAND, 1
    BSF     BAND, 0
    BTFSS   PIR1, TXIF
    RETURN
    MOVFW   BARRIDOS
    MOVWF   TXREG
    RETURN
ENVIO1: ;Env�o segundo Byte
    BCF     BAND, 0
    BSF     BAND, 1
    BTFSS   PIR1, TXIF
    RETURN
    MOVFW   ADC_VAL2
    MOVWF   TXREG
    RETURN
    
ESC_EEPROM:
    BANKSEL EEADR
    MOVLW .0
    MOVWF EEADR
    BANKSEL PORTA
    MOVFW PORTE
    BANKSEL EEDAT
    MOVWF   EEDAT
    BANKSEL EECON1
    BCF EECON1,EEPGD
    BSF EECON1,WREN
    BCF INTCON, GIE
    MOVLW 0x55 
    MOVWF EECON2 ;Write 55h
    MOVLW 0XAA  
    MOVWF EECON2 
    BSF EECON1, WR
    
    BCF EECON1, WREN 
    BANKSEL PORTA  
    RETURN
    
LEC_EEPROM:
    MOVLW   .0
    BANKSEL EEADR
    MOVWF   EEADR
    BANKSEL EECON1
    BCF     EECON1, EEPGD
    BSF	    EECON1, RD
    BANKSEL EEDATA
    MOVF    EEDATA, W
    MOVWF   PORTE
    BANKSEL PORTA
    RETURN   
    
LEDS:
   BANKSEL  PORTB
   MOVFW    BANDERAS
   MOVWF    PORTB
   RETURN
MOTORDC:
    BANKSEL PORTB
    MOVFW   VIENE
    ANDLW B'00110000'
    MOVWF   VIENE
    BTFSC   VIENE, 4
    GOTO    LENTO
    BTFSC   VIENE, 5
    GOTO    RAPIDO
    MOVLW   .15
    MOVWF   CCPR2L
    RETURN
LENTO:
    MOVLW   .70
    MOVWF   CCPR2L
    RETURN
RAPIDO:
    MOVLW   .252
    MOVWF   CCPR2L
    RETURN
    
 
TEMPO_1:
    BSF	    PORTE, 2
    CALL    ESC_EEPROM
    GOTO    SIGUE
    
TEMPO_2:
    BCF	    PORTE, 2
    CALL    ESC_EEPROM
    GOTO    SIGUE
    
TEMPO_3:
    MOVLW   .50
    MOVWF   MOD
    GOTO    SIGUE 
    
  
	
DELAY_AQ2:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    RETURN
    
TOGGLE:
    MOVFW MOD
    MOVWF CNT
    BTFSC PORTD, 2
    GOTO  OFF_D
    BSF   PORTD, 2
    RETURN
    
OFF_D:
    BCF   PORTD, 2
    RETURN
TOGGLE_2:
    MOVLW .10
    MOVWF CNT
    BTFSC PORTD, 2
    GOTO  OFF_D
    BSF   PORTD, 2
    GOTO  LOOP
    
    END