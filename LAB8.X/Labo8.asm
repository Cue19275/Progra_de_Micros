;*******************************************************************************                                                                                                                                      *
;*******************************************************************************
;                                                                              
;    Filename: Laboratorio 8                                                               
;    Date: Nov 2020                                                                                                                          
;    Author: Cuellar                                                           
;    Company: UVG                                                              
;    Description: LAB8                                                                                                                                 
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
CONT1	RES 1
CONT2	RES 1
 
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
    CALL CONFIG_T2CON_CCP1CON
    
;####EMPIEZA MAINLOOP####     
LOOP:
    CALL    CONFIG_ADC
    CALL    DELAY_AQ
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, W
    MOVWF   ADC_VAL
    MOVWF   CCPR1L
    
    CALL    CONFIG_ADC2
    CALL    DELAY_AQ
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, W
    MOVWF   ADC_VAL2
    MOVWF   CCPR2L
    
;    CLRF PORTC
;    BSF PORTD, 1
;    BCF PORTD, 2
;    MOVF DECODE, W
;    CALL TABLA_7SEG
;    MOVWF PORTC
;    CALL DELAY_MULTPLX
;    
;    CLRF PORTC
;    BCF PORTD, 1
;    BSF PORTD, 2
;    SWAPF DECODE2, W
;    MOVWF DECODE2
;    CALL TABLA_7SEG
;    MOVWF PORTC
;    CALL DELAY_MULTPLX
    
    GOTO    LOOP                         ; loop forever
    
;####SETUPS####
CONFIG_IO:
    BANKSEL ANSEL
    CLRF    ANSEL
    COMF    ANSEL
    BANKSEL TRISA
    CLRF    TRISA
    COMF    TRISA
    CLRF    TRISC
    
    
;    CLRF    TRISD
;    CLRF    TRISB
;    CLRF    TRISC
;    BANKSEL PORTD
;    CLRF    PORTA
;    CLRF    PORTD
;    CLRF    PORTB
;    CLRF    PORTC
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
    MOVLW .40
    MOVFW CONT1
    DECFSZ CONT1, F
               GOTO $-1 ;IR A PC - 1, REGRESAR A DECFSZ
 RETURN
 
DELAY_MULTPLX
    MOVLW .40
    MOVWF CONT2
CONFIG1:    
    CALL DELAY_SMALL
    DECFSZ CONT2, F
    GOTO CONFIG1
    RETURN

    END