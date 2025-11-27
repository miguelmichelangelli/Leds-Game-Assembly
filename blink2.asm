    #include <p16f877a.inc>
    __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
    
    ; variables
    IS_ON EQU 20h
    IS_OFF EQU 21h
    IS_BLINKING EQU 22h
    IS_PULSED EQU 23h
    TIEMPO_A EQU 24h
    TIEMPO_B EQU 25h
    TIEMPO_C EQU 26h
    
    ORG 0x00 
    GOTO INICIO

INICIO:
    ; limpio el banco de memoria
    BCF STATUS, RP0
    BCF STATUS, RP1

    ; me muevo al banco 1
    BSF STATUS, RP0

    ; activo los puertos 0, 1 y 2 como entradas (aquí irán lo botones)
    BSF TRISB, 0
    BSF TRISB, 1
    BSF TRISB, 2

    ; activo el puerto 3 como salida (aquí irá el led)
    BCF TRISB, 3

    ; vuelvo al banco 0
    BCF STATUS, RP0

    ; para iniciar con el led apagado, llamo a mi subrutina de TURN_OFF
    CALL TURN_OFF

    GOTO PRINCIPAL

PRINCIPAL:
    CALL REVISAR_BOTONES
    CALL MENU
    GOTO PRINCIPAL

MENU:
    BTFSC IS_ON, 0
    CALL TURN_ON

    BTFSC IS_OFF, 0
    CALL TURN_OFF

    BTFSC IS_BLINKING, 0
    CALL BLINK

    RETURN


REVISAR_BOTONES:
    BTFSC PORTB, 0 ; "saltar la siguiente línea si botón 0 no se presionó"
    CALL BUTTON_0

    BTFSC PORTB, 1 ; "saltar la siguiente línea si botón 1 no se presionó"
    CALL BUTTON_1

    BTFSC PORTB, 2 ; "saltar la siguiente línea si botón 2 no se presionó"
    CALL BUTTON_2

    RETURN

BUTTON_0:
    BSF IS_ON, 0
    BSF IS_PULSED, 0
    RETURN

BUTTON_1:
    BSF IS_OFF, 0
    BSF IS_PULSED, 0
    RETURN

BUTTON_2:
    BSF IS_BLINKING, 0
    BSF IS_PULSED, 0
    RETURN

; subrutina para encender el led (Botón 0)
TURN_ON:
    CLRF IS_PULSED
    CLRF IS_ON
    BSF PORTB, 3
    RETURN

; subrutina para apagar el led (Botón 1)
TURN_OFF:
    CLRF IS_PULSED
    CLRF IS_OFF
    BCF PORTB, 3
    RETURN

BLINK:
    CLRF IS_PULSED
    CLRF IS_BLINKING

    CALL TURN_ON

    CALL RETARDO

    BTFSC IS_PULSED, 0
    RETURN

    CALL TURN_OFF

    CALL RETARDO
    
    BTFSC IS_PULSED, 0
    RETURN

    GOTO BLINK

RETARDO:
    MOVLW d'45'
    MOVWF TIEMPO_A

LAZO_A:
    MOVLW d'100'
    MOVWF TIEMPO_B

LAZO_B:
    MOVLW d'10'
    MOVWF TIEMPO_C

LAZO_C:
    CALL REVISAR_BOTONES
    BTFSC IS_PULSED, 0
    RETURN

    DECFSZ TIEMPO_C, 1
    GOTO LAZO_C

    DECFSZ TIEMPO_B, 1
    GOTO LAZO_B

    DECFSZ LAZO_A, 1
    GOTO LAZO_A

    RETURN

    END