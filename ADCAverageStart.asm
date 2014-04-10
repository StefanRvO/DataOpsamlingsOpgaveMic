ldi     ZL,LOW(Readings)
ldi     ZH,HIGH(Readings)
ldi     R18,0x00
InitADCLoop:
    cpi     R18,16
    breq    ENDINITADC
    in      R16,ADCH
    lsr     R16
    lsr     R16
    lsr     R16
    lsr     R16
    st      Z+,R16
    inc     R18
rjmp InitADCLoop

ENDINITADC:
sts LastReading,R16
