;========================================================================
; PIC18F4550 - LED con botón usando INT0 (interrupción)
; 
; Requisitos:
;  - PIC18F4550
;  - Oscilador interno a 4 MHz
;  - Botón cableado a VDD (RB0/INT0) -> interrupción por flanco de SUBIDA
;========================================================================
        #include <xc.inc>

; CONFIG
        CONFIG  FOSC   = INTOSCIO_EC
        CONFIG  WDT    = OFF
        CONFIG  LVP    = OFF         ; Evitar voltajes bajos
        CONFIG  PBADEN = OFF	     ; Define si RB0-RB4 son: OFF: Entradas digitales, ON: Entredas analogicas
        CONFIG  MCLRE  = OFF	     ; Contrala si el pin MCLR es: ON: Pin de Reset, OFF: Se convierte en entrada digital
        CONFIG  XINST  = OFF	     ; ON: Habilita instrucciones extendidas, OFF: Usa modo normal
        CONFIG  PWRT   = ON	     ; Es el Power-ip Timer: ON:Agrega un pequeño retardo cuando el PIC enciende, OFF: Arranca inmediatamente
        CONFIG  DEBUG  = OFF	     ; Habilita el modo depuración: ON:Permite usar el debugger, OFF:Modo normal

; Vectores de Inicio e Interrupción
	PSECT resetVec, class=CODE, reloc=2
resetVec:
        ORG     0b00000000          ; 0x00 Reset
        GOTO    INIT
	
        ORG     0b00001000          ; 0x08 Vector de interrupción, le prepara un espacio de memoria a la interrupcion
        GOTO    ISR

; Inicio
	PSECT main_code, class=CODE, reloc=2
	
INIT:
        ; OSCCON:
        ; IRCF2:IRCF0 = 110 -> 4 MHz
        ; SCS1:SCS0   = 10  -> reloj interno
        ; Valor: 0b01100010
        MOVLW   0b01100010
        MOVWF   OSCCON, a
	
	; LED RD0 salida, encendido
	BCF     TRISD, 0, a
        BSF     LATD,  0, a

	; Botón RB0/INT0 como entrada
        BSF     TRISB, 0, a
	
	; Pull-ups internos PORTB deshabilitados (RBPU=1)
        ; (Con botón a VDD + pull-down externo NO se usan pull-ups)
        BSF     INTCON2, 7, a

	; IINT0 por flanco de BAJADA (INTEDG0=0) porque botón va a GND (1->0)
        BCF     INTCON2, 6, a

        ; Habilitar INT0 + GIE
        BCF     INTCON, 1, a	; INT0IF = 0
        BSF     INTCON, 4, a	; INT0IE = 1
        BSF     INTCON, 7, a	; GIE   = 1

; Codigo principal
MAIN_LOOP:
        SLEEP
        NOP
        GOTO    MAIN_LOOP

; ISR INT0
ISR:
        BTFSS   INTCON, 1, a
        RETFIE

        BCF     INTCON, 1, a
        BTG     LATD, 0, a

        RETFIE

        END


