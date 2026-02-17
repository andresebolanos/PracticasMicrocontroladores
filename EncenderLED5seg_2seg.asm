;==================================================================
;Código en Assembler para PIC18F4550
;Usa retardos sin interrupciones ni Timer0
;Frecuencia: 8MHz
;==================================================================
    #include <xc.inc>  
    ; Incluir definiciones del ensamblador para PIC184550
    
    ; Configuración de bits de confiuración
    config FOSC = INTOSCIO_EC ; Usa el oscilador interno a 8MHz
    config WDT = OFF	      ; Desactiva el Watchdog Timer
    config LVP = OFF	      ; Deshabilita la programación en bajo voltaje
    config PBADEN = OFF	      ; Configurar los pines de PORTB como digitales
    
    ;=== Vectores de Inicio ===
    
    PSECT resetVec, class=CODE, reloc=2 ; Sección para el vector de reinicio
resetVec:
    ORG 0x00				; Dirección de inicio
    GOTO Inicio				; Saltar a la rutina de inicio
    
    ;=== Codigo Principal ===
    
    PSECT main_code, class=CODE, reloc=2  ; Sección de código principal
    
Inicio:
    CLRF TRISB, A	    ; Configuramos PORTB como salida
    CLRF LATB, A	    ; Apagar todos los pines de PORTB
    
Loop:
    ; === Encender LED por 5 seg ===
    BSF  LATB, 0, A	    ; Poner en 1 el estado del LED en RB0
    MOVLW 5
    MOVWF Contador, A
    
Encendido:
    Call   Retardo_1s
    DECFSZ Contador, F, A
    GOTO   Encendido
    
    ; === Apagar LED por 2 seg ===
    BCF   LATB, 0, A       ; Poner en 0 el estado del LED en RB0
    MOVLW 2
    MOVWF Contador, A
    
Apagado:
    Call   Retardo_1s
    DECFSZ Contador, F, A
    Goto   Apagado
    
    Goto   Loop		   ; Repetimos el ciclo
    ;=== Aprox. 1 segundo ===

Retardo_1s:
    MOVLW 25                  ; Cargar el valor 25 en el registro W (contador externo)
    MOVWF ContadorExterno, A  ; Guardar el valor en la variable ContadorExterno
    
LoopExterno:
    MOVLW 250		       ; Cargar el valor 250 en el registro W (contador interno)
    MOVWF ContadorInterno, A   ; Guardar el valor en la variable ContadorInterno
    
LoopInterno:
    NOP
    NOP
    NOP
    
    DECFSZ ContadorInterno, F, A ; Decrementear ContadorInterno, si es cero, salta la siguiente instrucción
    GOTO   LoopInterno           ; Si no es cero, repetir bucle interno
    
    DECFSZ ContadorExterno, F, A ; Decrementar ContadorExterno, si es cero, salta la siguiente instrucción
    GOTO   LoopExterno           ; Si noes cero, repertir bucle externo
    
    RETURN                       ; Retomar el programa principal luego del retorno
    
    ;=== Definición de Variables ===
    
    PSECT udata  ; Sección de datos sin inicializar (Variables en RAM)
ContadorExterno: DS 1 ; Reserva 1 byte de memoria para el contador externo
ContadorInterno: DS 1 ; Resetva 1 byte de memoria para el contador interno
Contador:        DS 1 ; Reserva 1 byte de memoria para el contador
    END