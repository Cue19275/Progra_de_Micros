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
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
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
W_TEMP	RES 1
STATUS_TEMP RES 1
XCOR	RES 1
XCOR2	RES 1
YCOR	RES 1
BAND	RES 1
 
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
    CALL CONFIG_IO
    CALL CONFIG_ADC
    CALL CONFIG_TXRX
    CLRF BAND
    CLRF XCOR
    CLRF YCOR
    BSF	 BAND, 0
    
;####EMPIEZA MAINLOOP####     
LOOP:
    CALL    LEC_POTX
    ;CALL    CALC_X
    CALL    DELAY_AQ
    CALL    LEC_POTY
    ;CALL    CALC_Y
    CALL    SEL_ENVIO
    ;CALL    ENVIO
    ;CALL    RECIBIR

;###########################################
    
    
    ;CALL    ENVIO2
    ;CALL    RECIBIR2 
;########################################    
    MOVFW   ADC_VAL
    MOVWF   DECODE
    MOVWF   DECODE2
    MOVFW   ADC_VAL2
    MOVWF   DECODE3
    MOVWF   DECODE4
    
    CALL SEG7
    
    
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
 
DELAY_MULTPLX
    MOVLW .10
    MOVWF CONT2
CONFIG1:    
    CALL DELAY_SMALL
    DECFSZ CONT2, F
    GOTO CONFIG1
    RETURN
    

RECIBIR:
    BTFSS   PIR1, RCIF
    RETURN
    MOVF    RCREG, W
    MOVWF   DECODE
    MOVWF   DECODE2
    RETURN
    
ENVIO:
    BTFSS   PIR1, TXIF
    RETURN
    MOVFW   ADC_VAL
    MOVWF   TXREG
    RETURN
    
RECIBIR2:
    BTFSS   PIR1, RCIF
    RETURN
    MOVF    RCREG, W
    MOVWF   DECODE3
    MOVWF   DECODE4
    RETURN
    
ENVIO2:
    BTFSS   PIR1, TXIF
    RETURN
    MOVFW   ADC_VAL2
    MOVWF   TXREG
    RETURN
    
SEG7:
    CLRF PORTB
    BSF PORTD, 1
    BCF PORTD, 2
    BCF PORTD, 3
    BCF PORTD, 4
    MOVF DECODE, W
    CALL TABLA_7SEG
    MOVWF PORTB
    CALL DELAY_MULTPLX
    
    CLRF PORTB
    BCF PORTD, 1
    BSF PORTD, 2
    BCF PORTD, 3
    BCF PORTD, 4
    SWAPF DECODE2, W
    MOVWF DECODE2
    CALL TABLA_7SEG
    MOVWF PORTB
    CALL DELAY_MULTPLX
    
    CLRF PORTB
    BCF PORTD, 1
    BCF PORTD, 2
    BSF PORTD, 3
    BCF PORTD, 4
    MOVF DECODE3, W
    CALL TABLA_7SEG
    MOVWF PORTB
    CALL DELAY_MULTPLX
    
    CLRF PORTB
    BCF PORTD, 1
    BCF PORTD, 2
    BCF PORTD, 3
    BSF PORTD, 4
    SWAPF DECODE4, W
    MOVWF DECODE4
    CALL TABLA_7SEG
    MOVWF PORTB
    CALL DELAY_MULTPLX
    
    RETURN
    
CALC_X:
    MOVLW   .191
    SUBWF   ADC_VAL, W
    BTFSS   STATUS, C
    GOTO    CALC2_X
    MOVLW   0X34
    MOVWF   XCOR
    RETURN
CALC2_X:
    MOVLW   .143
    SUBWF   ADC_VAL, W
    BTFSS   STATUS, C
    GOTO    CALC3_X
    MOVLW   0X33
    MOVWF   XCOR
    RETURN
CALC3_X:
    MOVLW   .111
    SUBWF   ADC_VAL, W
    BTFSS   STATUS, C
    GOTO    CALC4_X
    MOVLW   0X32
    MOVWF   XCOR
    RETURN
CALC4_X:
    MOVLW   .63
    SUBWF   ADC_VAL, W
    BTFSS   STATUS, C
    GOTO    CALC5_X
    MOVLW   0X31
    MOVWF   XCOR
    RETURN
CALC5_X:
    MOVLW   0X30
    MOVWF   XCOR
    RETURN
    
CALC_Y:
    MOVLW   .191
    SUBWF   ADC_VAL2, W
    BTFSS   STATUS, C
    GOTO    CALC2_Y
    MOVLW   0X34
    MOVWF   YCOR
    RETURN
CALC2_Y:
    MOVLW   .143
    SUBWF   ADC_VAL2, W
    BTFSS   STATUS, C
    GOTO    CALC3_Y
    MOVLW   0X33
    MOVWF   YCOR
    RETURN
CALC3_Y:
    MOVLW   .111
    SUBWF   ADC_VAL2, W
    BTFSS   STATUS, C
    GOTO    CALC4_Y
    MOVLW   0X32
    MOVWF   YCOR
    RETURN
CALC4_Y:
    MOVLW   .63
    SUBWF   ADC_VAL2, W
    BTFSS   STATUS, C
    GOTO    CALC5_Y
    MOVLW   0X31
    MOVWF   YCOR
    RETURN
CALC5_Y:
    MOVLW   0X30
    MOVWF   YCOR
    RETURN
    
LEC_POTX:
    CALL    CONFIG_ADC
    BANKSEL PORTA
    CALL    DELAY_AQ
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, W
    MOVWF   ADC_VAL
    ;MOVWF   DECODE
    ;MOVWF   DECODE2
    RETURN
    
LEC_POTY:
    CALL    CONFIG_ADC2
    BANKSEL PORTA
    CALL    DELAY_AQ
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, W
    MOVWF   ADC_VAL2
    ;MOVWF   DECODE
    ;MOVWF   DECODE2
    RETURN
    
SEL_ENVIO:
    BTFSC   BAND, 0
    GOTO    ENVIO1
    BTFSC   BAND, 1
    GOTO    ENVIO3
    ;BTFSC   BAND, 2
    ;GOTO    ENVIO4
    RETURN
ENVIO4:
    BCF     BAND, 2
    BSF     BAND, 0
    BTFSS   PIR1, TXIF
    RETURN
    ;MOVFW   ADC_VAL
    MOVLW   0xA
    MOVWF   TXREG
    RETURN
ENVIO3:
    BCF     BAND, 1
    BSF     BAND, 0
    BTFSS   PIR1, TXIF
    RETURN
    MOVFW   ADC_VAL
    MOVWF   TXREG
    RETURN
ENVIO1:
    BCF     BAND, 0
    BSF     BAND, 1
    BTFSS   PIR1, TXIF
    RETURN
    MOVFW   ADC_VAL2
    MOVWF   TXREG
    RETURN
    
    END