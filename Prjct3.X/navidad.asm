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
 
;####RESET VECTOR####
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    SETUP                   ; go to beginning of program

;####INTERRUPT####

;####TABLAS####
;Tabla para decodificar valores binarios hacia el display de 7 seg
TABLA_7SEG
    ANDLW B'00001111'
    ADDWF PCL
    RETLW   B'000111111' ;O
    RETLW   B'000000110' ;1
    RETLW   B'001011011' ;2
    RETLW   B'001001111' ;3
    RETLW   B'01100110' ;4
    RETLW   B'01101101' ;5
    RETLW   B'01111101' ;6
    RETLW   B'00000111' ;7
    RETLW   B'01111111' ;8
    RETLW   B'01100111' ;9
    RETLW   B'01110111' ;A
    RETLW   B'01111100' ;b
    RETLW   B'00111001' ;C
    RETLW   B'01011110' ;d
    RETLW   B'01111001' ;E
    RETLW   B'01110001' ;F
    
    
MAIN_PROG CODE                      ; let linker place main program
SETUP:
    ;BSF	 STATUS, RP0
    ;MOVLW B'00001011'
    CALL CONFIG_IO
    CALL CONFIG_ADC
    CALL CONFIG_TXRX
    CALL CONFIG_T2CON_CCP1CON
    
    CLRF BAND
    CLRF BAND2
    CLRF XCOR
    CLRF YCOR
    CLRF VIENE
    CLRF BANDERAS
    ;MOVLW .150
    ;MOVWF CCPR2L
    BSF	 BAND, 0
    
;####EMPIEZA MAINLOOP####     
LOOP:
    CALL    LEC_POTX
    CALL    DELAY_AQ
    CALL    LEC_POTY
    CALL    ENVIO1
    CALL    DELAY_MULTPLX
    CALL    RECIBIR2
    CALL    LEC_EEPROM
    
    CALL    LEDS

    CALL    MOTORDC
    

    MOVFW   ADC_VAL
    SUBLW   .1
    MOVWF   MOT
    BTFSC   STATUS, C
    GOTO    SIGN
    GOTO    NO_SIGN
    GOTO    LOOP                         ; loop forever
   
;####SETUPS####
CONFIG_IO:
    BANKSEL ANSEL
    CLRF    ANSEL
    COMF    ANSEL
    BANKSEL TRISA
    CLRF    TRISA
    COMF    TRISA
    CLRF    TRISD
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
    
SEL_ENVIO: ;Toggle de envíos
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
    MOVFW   ADC_VAL
    MOVWF   TXREG
    RETURN
ENVIO1: ;Envío segundo Byte
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
    MOVFW PORTB
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
    BSF INTCON, GIE 
    
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
    BANKSEL PORTD
    MOVWF   PORTD
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
    
SIGN:
    CALL ESC_EEPROM
    GOTO LOOP
NO_SIGN:
    GOTO LOOP
    

    END