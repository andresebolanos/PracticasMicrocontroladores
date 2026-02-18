;==================================================================
;Codigo en Assembler para PIC18F4550
;Usa retardos sin interrupciones ni Timer0
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
    MOVWF OSCCON
    CLRF TRISB	    ; Configuramos PORTB como salida
    CLRF LATB	    ; Apagar todos los pines de PORTB
    
Loop:
    ; === Encender LED por 5 seg ===
    BSF  LATB, 0    ; Poner en 1 el estado del LED en RB0
    MOVLW 4
    MOVWF Contador
    
Encendido:
    Call   Retardo_1s
    DECFSZ Contador, F
    GOTO   Encendido
    
    ; === Apagar LED por 2 seg ===
    BCF   LATB, 0    ; Poner en 0 el estado del LED en RB0
    MOVLW 1
    MOVWF Contador
    
Apagado:
    Call   Retardo_1s
    DECFSZ Contador, F
    Goto   Apagado
    
    Goto   Loop		   ; Repetimos el ciclo
    ;=== Aprox. 1 segundo ===

Retardo_1s:
    MOVLW 5                  ; Cargar el valor 50 en el registro W (contador externo)
    MOVWF ContadorExterno1     ; Guardar el valor en la variable ContadorExterno
    
LoopExterno1:
    MOVLW 250		       ; Cargar el valor 250 en el registro W (contador interno)
    MOVWF ContadorExterno2      ; Guardar el valor en la variable ContadorInterno
    
LoopExterno2:
    MOVLW 250
    MOVWF ContadorInterno
    
LoopInterno:
    NOP
    NOP
    NOP
    NOP
    
    DECFSZ ContadorInterno, F    ; Decrementear ContadorInterno, si es cero, salta la siguiente instrucci?n
    GOTO   LoopInterno           ; Si no es cero, repetir bucle interno
    
    DECFSZ ContadorExterno2, F    ; Decrementar ContadorExterno, si es cero, salta la siguiente instrucci?n
    GOTO   LoopExterno2           ; Si noes cero, repertir bucle externo
    
    DECFSZ ContadorExterno1, F
    GOTO   LoopExterno1
    
    RETURN                       ; Retomar el programa principal luego del retorno
    
    ;=== Definici?n de Variables ===
    
    PSECT udata  ; Secci?n de datos sin inicializar (Variables en RAM)
ContadorExterno1: DS 1 ; Reserva 1 byte de memoria para el contador externo1
ContadorExterno2: DS 1 ; Reserva 1 byte de memoria para el contador externo2
ContadorInterno:  DS 1 ; Resetva 1 byte de memoria para el contador interno
Contador:         DS 1 ; Reserva 1 byte de memoria para el contador
    END


