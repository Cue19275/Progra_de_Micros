;*******************************************************************************                                                                                                                                      *
;*******************************************************************************
;                                                                              
;    Filename: Laboratorio 10                                                               
;    Date: Nov 2020                                                                                                                          
;    Author: Cuellar                                                           
;    Company: UVG                                                              
;    Description: LAB10                                                                                                                                 
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
DECODE	RES 1
DECODE2	RES 1
CONT1	RES 1
CONT2	RES 1
DIR	RES 1
 
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
    
;####EMPIEZA MAINLOOP####     
LOOP:
    CALL    DELAY_AQ
    BSF	    ADCON0, GO
    BTFSC   ADCON0, GO
    GOTO    $-1
    MOVF    ADRESH, W
    MOVWF   ADC_VAL
    MOVWF   PORTC
    MOVWF   DECODE
    MOVWF   DECODE2
    
    CALL    LEC_EEPROM
    
CHCK_B11:
    
    BTFSS PORTD, RD1
    GOTO LOOP
    
EXE_B11:
;Ejecución del cambio de modo   
    BTFSC PORTD, RD1
    GOTO EXE_B11
    CALL ESC_EEPROM
   
    
    GOTO    LOOP                         ; loop forever
 
ESC_EEPROM:
    BANKSEL EEADR
    MOVLW .0
    MOVWF EEADR
    BANKSEL PORTA
    MOVFW PORTC
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
    MOVWF   PORTB
    BANKSEL PORTA
    RETURN
    

    
    
;####SETUPS####
CONFIG_IO:
    BANKSEL ANSEL
    CLRF    ANSEL
    COMF    ANSEL
    BANKSEL TRISA
    CLRF    TRISA
    COMF    TRISA
    BSF	    TRISD,  1
    CLRF    TRISB
    CLRF    TRISC
    BANKSEL PORTD
    CLRF    PORTA
    ;CLRF    PORTD
    CLRF    PORTB
    CLRF    PORTC
    MOVLW   0xA
    MOVWF   DIR
    RETURN
    
CONFIG_ADC:
    BANKSEL ADCON1
    MOVLW   B'00000000'
    MOVWF   ADCON1
    BANKSEL ADCON0
    MOVLW   B'01000001'
    MOVWF   ADCON0
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