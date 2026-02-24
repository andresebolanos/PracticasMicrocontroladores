;==================================================================
;Codigo en Assembler para PIC18F4550
;Usa retardos
;Frecuencia: 8MHz
;==================================================================
    #include <xc.inc>  
    ; Incluir definiciones del ensamblador para PIC184550
    
    ; Configuraci?n de bits de confiuraci?n
    config FOSC = INTOSCIO_EC ; Usa el oscilador interno a 8MHz
    config WDT = OFF	      ; Desactiva el Watchdog Timer
    config LVP = OFF	      ; Deshabilita la programaci?n en bajo voltaje
    config PBADEN = OFF	      ; Configurar los pines de PORTB como digitales
    
    ;=== Vectores de Inicio ===
    
    PSECT resetVec, class=CODE, reloc=2 ; Secci?n para el vector de reinicio
resetVec:
    ORG 0x00				; Direcci?n de inicio
    GOTO Inicio				; Saltar a la rutina de inicio
    
    
    
    ;=== Codigo Principal ===
    
    PSECT main_code, class=CODE, reloc=2  ; Secci?n de c?digo principal
    
Inicio:
    MOVLW 0x72
    MOVWF OSCCON, A
    CLRF TRISB, A	    ; Configuramos PORTB como salida
    CLRF LATB, A	    ; Apagar todos los pines de PORTB
    
    banksel T0CON
    MOVLW   b'10000111',A   ; 16 bits, preescaler 1:256, osc. interno, encendido
    MOVWF   T0CON, A

    MOVLW   0xE1
    MOVWF   TMR0H, A
    MOVLW   0x7C
    MOVWF   TMR0L, A

    banksel INTCON
    BCF     INTCON, TMR0IF, A
    BSF     T0CON, TMR0ON, A
    
Loop:
    ; === Encender LED por 1 seg ===
    BSF  LATB, 0, A    ; Poner en 1 el estado del LED en RB0
    
Encendido:
    Call   Espera
    
    ; === Apagar LED por 2 seg ===
    BCF   LATB, 0, A    ; Poner en 0 el estado del LED en RB0
    MOVLW 2
    MOVWF Contador, A
    
Apagado:
    Call   Espera
    DECFSZ Contador, F, A
    Goto   Apagado
    
    Goto   Loop		   ; Repetimos el ciclo

Espera:
    btfss   INTCON, TMR0IF, A
    goto    Espera, A
    bcf     INTCON, TMR0IF, A
    bcf     T0CON, TMR0ON, A
    
    Return
    ;=== Definicion de Variables ===
    
    PSECT udata  ; Seccion de datos sin inicializar (Variables en RAM)
Contador:         DS 1 ; Reserva 1 byte de memoria para el contador
    END

