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
    
    ;===========================================
    ; Vectores de Inicio
    ;===========================================
    
    PSECT resetVec, class=CODE, reloc=2 ; Sección para el vector de reinicio
resetVec:
    ORG 0x00				; Dirección de inicio
    GOTO Inicio				; Saltar a la rutina de inicio
    
    ;==========================================
    ; Código Principio
    ;==========================================
    
    PSECT main_code, class=CODE, reloc=2  ; Sección de código principal
    
Inicio:
    CLRF TRISB, A	    ; Configuramos PORTB como salida
    CLRF LATB, A	    ; Apagar todos los pines de PORTB
    
Loop:
    BTG	 LATB, 0, A    ; Alternar el estado del LED en RB0
    Call Retardo_ls    ; Llamar a la rutina de retardo de 1 segundo
    GOTO Loop          ; Repetir el proceso de parpadeo en bucle infinito
    
    ;=============================================
    ; Subrutina de Retardo de 1 Segundo (Aprox.)
    ;=============================================
    
Retardo_ls:
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
    
    ;==============================================
    ; Definición de Variables
    ;==============================================
    
    PSECT udata  ; Sección de datos sin inicializar (Variables en RAM)
ContadorExterno: DS 1 ; Reserva 1 byte de memoria para el contador externo
ContadorInterno: DS 1 ; Resetva 1 byte de memoria para el contador interno
    
    END
    
    
    


