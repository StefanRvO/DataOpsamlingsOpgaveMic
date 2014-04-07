.include "m32def.inc"

.equ ADCInterval=31250
.equ Readings=0x500 ; Here we put in our ADC readings
.equ CurReading=0x498
;.def CurReading=R24
.def LastReading=R21
.org 0x0000
jmp Reset

.org 0x0012
jmp T1_OVFLW

.org 0x0002
jmp INT0_ISR
.org 0x60
Reset:
.include "SetupIO.asm"
.include "SetupStack.asm"
.include "SetupTime.asm"
.include "SetupADC.asm"
sei
ldi R16,0x00
sts CurReading,R16
jmp Main


INT0_ISR:
CALL ShowAverage
reti

T1_OVFLW:
ldi R19,HIGH(65536-ADCInterval)
out TCNT1H,R19
ldi R19,LOW(65536-ADCInterval)
out TCNT1L,R19
;Read In ADC
SBI ADCSRA,ADSC ;start conversion
WAITADC:
SBIS ADCSRA,ADIF ;is adc done?
rjmp    WAITADC
in LastReading,ADCH
;out PORTB,LastReading ;Debug
lsr LastReading
lsr LastReading
lsr LastReading
lsr LastReading
;ANDI LastReading,0b00001111
;out PORTB,LastReading ;Debug
ldi	ZH,high(Readings)	; make high byte of Z point at the Readings list
ldi ZL,low(Readings)

ldi R18,0x00
lds R17,CurReading
sub R18,R17
Loop:
cpi R18,0x00
breq STOPINC
inc R18
ADIW ZL,1
rjmp Loop
STOPINC:
st Z,LastReading
inc R17
cpi R17,0x10
brne ENDT1
ldi R17,0x00
ENDT1:
sts CurReading,R17
COM LastReading
reti


Main:
CALL ShowLastReading
CALL Delay
jmp Main


MakeAverage:
push R18
push R23
ldi R22,0x00 ;Here we hold the sum
ldi	ZH,high(Readings)	; make high byte of Z point at the Readings list
ldi ZL,low(Readings)
ldi R18,0x00
AverageLoop:
inc R18
LD	R23,Z+
add R22,R23
;out PORTB,R22
cpi R18,0x10
brne AverageLoop
lsr R22
lsr R22
lsr R22
lsr R22
pop R23
pop R18
ret


ShowAverage:
push R22
Call MakeAverage
COM R22
out PORTB,R22
pop R22
ret

ShowLastReading:
OUT PORTB,LastReading
ret

Delay:
push R17
ldi R17,0x00
DelayLoop:
inc R17
brne DelayLoop
pop R17
ret

