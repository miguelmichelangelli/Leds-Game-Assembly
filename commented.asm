#include <p16f877a.inc>
    ; Configuración básica: Oscilador XT, sin perro guardián y protección apagada
    __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
    
    ; --- DEFINICIÓN DE VARIABLES ---
    ; Asignamos nombres a direcciones de memoria RAM para nuestras banderas
    IS_ON       EQU 20h     ; Bandera para estado Encendido
    IS_OFF      EQU 21h     ; Bandera para estado Apagado
    IS_BLINKING EQU 22h     ; Bandera para estado Parpadeo
    IS_PULSED   EQU 23h     ; Bandera "chismosa": avisa si se presionó algo
    TIEMPO_A    EQU 24h     ; Variables para contar el tiempo (Retardo)
    TIEMPO_B    EQU 25h
    TIEMPO_C    EQU 26h
    
    ORG 0x00        ; Vector de Reset: Aquí arranca el PIC al encenderse
    GOTO INICIO

INICIO:
    ; --- CONFIGURACIÓN DE PUERTOS ---
    BCF STATUS, RP0
    BCF STATUS, RP1 ; Aseguramos estar en Banco 0
    
    BSF STATUS, RP0 ; Pasamos al Banco 1 para configurar entradas/salidas

    MOVLW 0x06
    MOVWF ADCON1    ; Importante: Ponemos el Puerto A y B como Digitales (no análogos)

    ; Configuramos RB0, RB1 y RB2 como ENTRADAS (Botones)
    BSF TRISB, 0
    BSF TRISB, 1
    BSF TRISB, 2

    ; Configuramos RB3 como SALIDA (LED)
    BCF TRISB, 3

    BCF STATUS, RP0 ; Volvemos al Banco 0 para trabajar

    ; --- ESTADO INICIAL ---
    ; Limpiamos todas las banderas por seguridad al iniciar
    CLRF IS_ON
    CLRF IS_OFF
    CLRF IS_BLINKING
    CLRF IS_PULSED

    CALL TURN_OFF   ; Nos aseguramos de que el LED empiece apagado

    GOTO PRINCIPAL

; --- BUCLE PRINCIPAL ---
; El cerebro del programa: revisa botones y ejecuta acciones todo el tiempo
PRINCIPAL:
    CALL REVISAR_BOTONES
    CALL MENU
    GOTO PRINCIPAL

; --- GESTOR DE ESTADOS ---
; Decide qué hacer según qué bandera esté activa
MENU:
    BTFSC IS_ON, 0          ; ¿Está activa la bandera de encendido?
    CALL TURN_ON

    BTFSC IS_OFF, 0         ; ¿Está activa la de apagado?
    CALL TURN_OFF

    BTFSC IS_BLINKING, 0    ; ¿Está activa la de parpadeo?
    CALL BLINK

    RETURN

; --- LECTURA DE HARDWARE ---
; Mira los pines físicos del PIC. Si hay un botón presionado, llama a su rutina.
REVISAR_BOTONES:
    BTFSC PORTB, 0          ; Si RB0 es 0 (no presionado), salta la llamada
    CALL BUTTON_0

    BTFSC PORTB, 1          ; Si RB1 es 0, salta
    CALL BUTTON_1

    BTFSC PORTB, 2          ; Si RB2 es 0, salta
    CALL BUTTON_2

    RETURN

; --- RUTINAS DE BOTONES ---
; Activan la bandera correspondiente y avisan que hubo un pulso
BUTTON_0:
    BSF IS_ON, 0        ; Pide encender
    BSF IS_PULSED, 0    ; Avisa que se tocó un botón
    RETURN

BUTTON_1:
    BSF IS_OFF, 0       ; Pide apagar
    BSF IS_PULSED, 0
    RETURN

BUTTON_2:
    BSF IS_BLINKING, 0  ; Pide parpadear
    BS
