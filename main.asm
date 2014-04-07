.include "m32def.inc"

.equ    ADCInterval=31250
.equ    Readings=0x500 ; Here we put in our ADC readings
.equ    CurReading=0x498
.equ    LastReading=0x499
.org    0x0000
.equ    ShowState=0x497 ;This Loaction holds our current state
jmp     Reset

.org    0x000E
jmp     T1_CTC

.org    0x0002
jmp     INT0_ISR
.org    0x60
Reset:

.include "SetupIO.asm"
.include "SetupStack.asm"
.include "SetupTime.asm"
.include "SetupADC.asm"

sei
ldi     R16,0x00
sts     CurReading,R16
sts     ShowState,R16
jmp     Main


INT0_ISR: ;Flip the last bit in ShowState
    push    R16
    in      R16,SREG
    push    R16
    ;CALL    ShowAverage
    lds     R16,ShowState
    ;Flip The last Bit of state
    cpi     R16,0x00
    breq    SetState2
    ldi     R16,0x00
    rjmp    INT0_END
    SetState2:
    ldi     R16,0x01
    INT0_END:
    sts     ShowState,R16
    pop     R16
    in      R16,SREG
    pop     R16
reti


T1_CTC: ;Read in an ADC value and save it to the Readings array
    push    R19
    in      R19,SREG
    push    R19
    push    R18
    push    R17

    ;Read In ADC
    SBI     ADCSRA,ADSC ;start conversion
    WAITADC:
        SBIS    ADCSRA,ADIF ;is adc done?
        rjmp    WAITADC
    in      R19,ADCH
    ;out    PORTB,R19 ;Debug
    lsr     R19
    lsr     R19
    lsr     R19
    lsr     R19
    ;ANDI   R19,0b00001111
    ;out    PORTB,R19 ;Debug
    ldi	    ZH,high(Readings)	; make high byte of Z point at the Readings list
    ldi     ZL,low(Readings)

    ldi     R18,0x00
    lds     R17,CurReading
    sub     R18,R17

    Loop:
        cpi     R18,0x00
        breq    STOPINC
        inc     R18
        ADIW    ZL,1
        rjmp    Loop

    STOPINC:
    st      Z,R19
    inc     R17
    cpi     R17,0x10
    brne    ENDT1
    ldi     R17,0x00
    ENDT1:
    sts     CurReading,R17
    sts     LastReading,R19
    pop     R17
    pop     R18
    pop     R19
    out     SREG,R19
    pop     R19
reti


Main:
    lds     R16,ShowState
    cpi     R16,0x00
    brne    State2
    State1:
    CALL    ShowLastReading
    rjmp Main
    State2:
    CALL    ShowAverage
    rjmp     Main


MakeAverage:  ;Grabs the values in ram and returns the average in R16
              ;Be carefull, changes R16

    push    R18
    push    R23
    ldi     R16,0x00 ;Here we hold the sum
    ldi	    ZH,high(Readings)	; make high byte of Z point at the Readings list
    ldi     ZL,low(Readings)
    ldi     R18,0x00
    AverageLoop:
    inc     R18
    LD	    R23,Z+
    add     R16,R23
    ;out    PORTB,R16
    cpi     R18,0x10
    brne    AverageLoop
    lsr     R16
    lsr     R16
    lsr     R16
    lsr     R16
    pop     R23
    pop     R18
ret


ShowAverage:
    push    R16
    Call    MakeAverage
    CALL    To7Seg
    out     PORTB,R16
    pop     R16
ret

ShowLastReading:
    push    R16
    lds     R16,LastReading
    CALL    To7Seg
    OUT     PORTB,R16
    pop     R16
ret

To7Seg: ;Converts the 4-bit value in R16 to a value which coresponds
        ;on the 7 Segment display
    cpi     R16,0
    brne    PC+2
    ldi     R16,0b10100000
    cpi     R16,1
    brne    PC+2
    ldi     R16,0b11110011
    cpi     R16,2
    brne    PC+2
    ldi     R16,0b10010100
    cpi     R16,3
    brne    PC+2
    ldi     R16,0b10010001
    cpi     R16,4
    brne    PC+2
    ldi     R16,0b11000011
    cpi     R16,5
    brne    PC+2
    ldi     R16,0b10001001
    cpi     R16,6
    brne    PC+2
    ldi     R16,0b10001000
    cpi     R16,0
    brne    PC+2
    ldi     R16,0b10100000
    cpi     R16,7
    brne    PC+2
    ldi     R16,0b10110011
    cpi     R16,8
    brne    PC+2
    ldi     R16,0b10000000
    cpi     R16,9
    brne    PC+2
    ldi     R16,0b10000001
    cpi     R16,0x0a
    brne    PC+2
    ldi     R16,0b10000010
    cpi     R16,0x0b
    brne    PC+2
    ldi     R16,0b11001000
    cpi     R16,0x0c
    brne    PC+2
    ldi     R16,0b10101100
    cpi     R16,0x0d
    brne    PC+2
    ldi     R16,0b11010000
    cpi     R16,0x0e
    brne    PC+2
    ldi     R16,0b10001100
    cpi     R16,0x0f
    brne    PC+2
    ldi     R16,0b10001110
ret

