    #include <p16f877a.inc>
    ; Configuración básica: Oscilador XT, sin perro guardián y protección apagada
    __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
    
    ; --- DEFINICIÓN DE VARIABLES ---
    ; Asignamos nombres a direcciones de memoria RAM para nuestras banderas
    IS_ON       EQU 20h     ; Bandera para estado Encendido
    IS_OFF      EQU 21h     ; Bandera para estado Apagado
    IS_BLINKING EQU 22h     ; Bandera para estado Parpadeo
    IS_PULSED   EQU 23h     ; Bandera "chismosa": avisa si se presionó algo
    TIEMPO_A    EQU 24h     ; Variables para manejar el retardo
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
    MOVWF ADCON1    ; IMPORTANTE: Ponemos el Puerto A y B como Digitales (no análogos)

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
    BSF IS_PULSED, 0
    RETURN

; --- ACCIONES DEL LED ---
TURN_ON:
    CLRF IS_PULSED      ; Ya atendimos el pulso, limpiamos la bandera
    CLRF IS_ON          ; Limpiamos la solicitud
    BSF PORTB, 3        ; Encendemos el LED físicamente
    RETURN

TURN_OFF:
    CLRF IS_PULSED
    CLRF IS_OFF
    BCF PORTB, 3        ; Apagamos el LED físicamente
    RETURN

; --- RUTINA DE PARPADEO ---
BLINK:
    CLRF IS_PULSED
    CLRF IS_BLINKING

    ; 1. Encendemos
    CALL TURN_ON

    ; 2. Esperamos tiempo (Revisando botones mientras tanto)
    CALL RETARDO

    ; 3. Seguridad: Si alguien presionó un botón durante la espera, salimos YA
    BTFSC IS_PULSED, 0
    RETURN

    ; 4. Apagamos
    CALL TURN_OFF

    ; 5. Esperamos otra vez
    CALL RETARDO
    
    ; 6. Seguridad de nuevo (para respuesta rápida)
    BTFSC IS_PULSED, 0
    RETURN

    GOTO BLINK          ; Si nadie tocó nada, repite el ciclo

; --- RUTINA DE RETARDO INTELIGENTE ---
; Dura aprox 0.5s, pero revisa los botones DENTRO del bucle
RETARDO:
    MOVLW d'45'         ; Cargamos contadores calculados para 0.5s
    MOVWF TIEMPO_A

LAZO_A:
    MOVLW d'100'
    MOVWF TIEMPO_B

LAZO_B:
    MOVLW d'10'
    MOVWF TIEMPO_C

LAZO_C:
    ; --- TRUCO CLAVE ---
    ; En lugar de solo perder tiempo, aprovechamos para mirar los botones
    CALL REVISAR_BOTONES
    
    ; Si se detectó un botón, rompemos el retardo y regresamos inmediatamente
    BTFSC IS_PULSED, 0
    RETURN
    
    ; Decrementamos los contadores de tiempo
    DECFSZ TIEMPO_C, 1
    GOTO LAZO_C

    DECFSZ TIEMPO_B, 1
    GOTO LAZO_B

    DECFSZ TIEMPO_A, 1
    GOTO LAZO_A

    RETURN

    END
