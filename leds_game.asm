    #include <p16f877a.inc>
    __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
    
    ; variables
    CONTADOR EQU 20h ; creo una variable para manejar mas facil el contador
    
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

    GOTO PRINCIPAL ; vamos al bloque principal

; creo la etiqueta principal, donde correrá mi programa
PRINCIPAL:
    BTFSC PORTB, 0 ; "saltar la siguiente línea si botón 0 no se presionó"
    CALL TURN_ON

    BTFSC PORTB, 1 ; "saltar la siguiente línea si botón 1 no se presionó"
    CALL TURN_OFF

    BTFSC PORTB, 2 ; "saltar la siguiente línea si botón 2 no se presionó"
    CALL BLINK

    GOTO PRINCIPAL ; repetimos nuevamente el bloque principal

; subrutina para encender el led (Botón 0)
TURN_ON:
    BSF PORTB, 3
    RETURN

; subrutina para apagar el led (Botón 1)
TURN_OFF:
    BCF PORTB, 3
    RETURN

; subrutina para activar el parpadeo del led (Botón 2)
BLINK:
    CALL TURN_ON ; llamamos a la subrutina de encendido

    CALL RETARDO ; causamos un retardo para que se aprecie el cambio al ojo humano

    BTFSC PORTB, 0 ; "saltar la siguiente línea si botón 0 no se presionó"
    GOTO TURN_ON_EXIT ; si se presiona el botón vamos al bloque de salida con encendido de led

    BTFSC PORTB, 1 ; "saltar la siguiente línea si botón 1 no se presionó"
    GOTO TURN_OFF_EXIT ; si se presiona el botón vamos al bloque de salida con apagado de led

    CALL TURN_OFF ; llamamos la subrutina de apagado de led

    CALL RETARDO ; causamos un retardo para que se aprecie el cambio al ojo humano

    BTFSC PORTB, 0 ; "saltar la siguiente línea si botón 0 no se presionó"
    GOTO TURN_ON_EXIT ; si se presiona el botón vamos al bloque de salida con encendido de led

    BTFSC PORTB, 1  ; "saltar la siguiente línea si botón 1 no se presionó"
    GOTO TURN_OFF_EXIT ; si se presiona el botón vamos al bloque de salida con apagado de led

    GOTO BLINK ; volvemos a empezar todo el ciclo

; subrutina de retardo
RETARDO:
    MOVLW d'255' ; se mueve 255 a la estación de trabajo
    MOVWF CONTADOR ; se le carga 255 al contador

BUCLE:
    DECFSZ CONTADOR, 1 ; disminuye en 1 el contador, cuando llega a 0 salta la línea siguiente
    GOTO BUCLE
    RETURN

; bloque de salida de BLINK con encendido de led
TURN_ON_EXIT:
    CALL TURN_ON ; llama a la subrutina de encendido
    GOTO PRINCIPAL ; vuelve al bloque principal

; bloque de salida de BLINK con apagado de led
TURN_OFF_EXIT:
    CALL TURN_OFF ; llama a la subrutina de apagado
    GOTO PRINCIPAL ; vuelve al bloque principal

    END

