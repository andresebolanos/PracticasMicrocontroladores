# Explicación del programa: 4 secuencias con LEDs (PIC18)

Este documento describe paso a paso el flujo del código ensamblador que controla 4 LEDs en `RD4-RD7`, con dos botones:

- `RB0/INT0`: cambia la secuencia.
- `RB1/INT1`: cambia la velocidad.

## 1) Objetivo general

El programa mantiene un **bucle principal** que reproduce una de cuatro animaciones de LEDs. La animación activa se guarda en `SecAct` (1 a 4). La velocidad se guarda en `VelAct`:

- `VelAct = 0` → retardo de ~250 ms
- `VelAct = 1` → retardo de ~500 ms

Cuando se presionan botones, se atienden por interrupción, aplicando antirrebote por software.

## 2) Configuración inicial del micro

En `Inicio` se hace:

1. Configuración de oscilador interno a 8 MHz (`OSCCON = 0b01110010`).
2. Espera activa hasta que el oscilador esté estable (`IOFS = 1`).
3. Configuración de puertos:
   - `TRISD = 0x00` (RD como salida).
   - `LATD = 0x00` (LEDs apagados).
   - `TRISB = 0xFF` (RB como entrada).
4. Configuración de interrupciones externas:
   - INT0 e INT1 por **flanco de bajada**.
   - Limpieza de banderas (`INT0IF`, `INT1IF`).
   - Habilitación de INT0/INT1 y `GIE`.
5. Configuración de Timer0 en 16 bits con prescaler 1:256 (`T0CON = 0b00000111`, apagado inicialmente).
6. Variables iniciales:
   - `VelAct = 0` (rápido, 250 ms).
   - `SecAct = 1` (primera secuencia).

## 3) Cómo se atienden las interrupciones

La rutina `ISR` revisa primero si el evento fue INT0 o INT1:

- Si `INT0IF=1` → `ManejoINT0`.
- Si `INT1IF=1` → `ManejoINT1`.
- Si no, `RETFIE`.

### 3.1 INT0 (RB0): cambiar secuencia

`ManejoINT0` hace:

1. Limpia `INT0IF`.
2. Llama a `Antirebote` (~65 ms).
3. Relee `PORTB,0`:
   - Si volvió a `1`, se considera rebote y sale.
   - Si sigue en estado de pulsación válida, incrementa `SecAct`.
4. Si `SecAct` llega a 5, la reinicia a 1 (ciclo 1→2→3→4→1...).

### 3.2 INT1 (RB1): cambiar velocidad

`ManejoINT1` hace:

1. Limpia `INT1IF`.
2. Llama a `Antirebote`.
3. Relee `PORTB,1` para descartar rebote.
4. Alterna bit 0 de `VelAct` con `BTG`, quedando entre 0 y 1.

## 4) Antirebote por software

`Antirebote` carga dos contadores de 8 bits (`RetrasoExt`, `RetrasoInt`) en `0xFF` y llama a `BucleRetraso`.

`BucleRetraso` usa doble decremento con `DECFSZ`, aproximando `255 × 255 = 65025` iteraciones. Con ciclo de instrucción de 0.5 µs (Fosc 8 MHz), el retardo ronda ~60–65 ms según overhead.

## 5) Retardo principal de animaciones (Timer0)

Cada paso de animación llama `Retardo`:

- Si `VelAct=0` → `Velocidad250ms` (precarga `TMR0 = 0xF85F`).
- Si `VelAct=1` → `Velocidad500ms` (precarga `TMR0 = 0xF0BE`).

En ambos casos se:

1. Detiene Timer0.
2. Carga `TMR0H:TMR0L`.
3. Limpia `TMR0IF`.
4. Arranca Timer0.
5. Espera en `EsperaLoop` hasta desbordamiento (`TMR0IF=1`), limpia bandera y retorna.

## 6) Selector de secuencias en el bucle principal

El bloque `Loop` compara `SecAct` y llama a la secuencia correspondiente:

- `SecAct=1` → `Seq1`
- `SecAct=2` → `Seq2`
- `SecAct=3` → `Seq3`
- `SecAct=4` → `Seq4`

Después de cada llamada vuelve a evaluar `SecAct`, permitiendo cambiar de secuencia casi inmediatamente tras una interrupción.

## 7) Qué hace cada secuencia

### Seq1: barrido con acumulación

Enciende patrones desde `RD7` hacia `RD4` y va “acumulando” bits hasta terminar con todos ON (`11110000`) y luego limpia `LATD`.

### Seq2: rebote

Patrón tipo ping-pong: `RD7 → RD6 → RD5 → RD4 → RD5 → RD6 → RD7`.

### Seq3: parpadeo simultáneo

Todos ON (`11110000`) y luego todos OFF, repitiendo.

### Seq4: alternado

Alterna dos pares:

- `RD6 + RD4` (`01010000`)
- `RD7 + RD5` (`10100000`)

## 8) Variables usadas

En `udata_acs`:

- `SecAct` (1 byte): secuencia actual (1..4).
- `VelAct` (1 byte): velocidad actual (0 o 1).
- `RetrasoExt` y `RetrasoInt` (1 byte cada una): contadores de antirebote.

## 9) Resumen mental rápido del flujo

1. Inicializa reloj, puertos, interrupciones y Timer0.
2. Entra en bucle principal ejecutando secuencia actual.
3. Cada paso de secuencia espera 250 o 500 ms con Timer0.
4. Si presionas RB0, ISR cambia `SecAct`.
5. Si presionas RB1, ISR conmuta `VelAct`.
6. Antirebote evita múltiples cambios por una sola pulsación.

