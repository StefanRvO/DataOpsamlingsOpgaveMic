.include "m32def.inc"

.equ ADCInterval=31250
.equ Readings=0x500 ; Here we put in our ADC readings 
.def CurReading=R24
.org 0x0000
jmp Reset

.org 0x0012
jmp T1_OVFLW

.org 0x60
Reset:
.include "SetupIO.asm"
.include "SetupStack.asm"
.include "SetupTime.asm"
.include "SetupADC.asm"
sei
ldi R16,0x00
ldi CurReading,0x00
jmp Main




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
in R21,ADCH
;NEG R21
;out PORTB,R21 ;Debug
lsr R21
lsr R21
lsr R21
lsr R21
;ANDI R21,0b00001111
;out PORTB,R21 ;Debug
ldi	ZH,high(Readings)	; make high byte of Z point at the Readings list
ldi ZL,low(Readings)

ldi R18,0x00
sub R18,CurReading
Loop:
cpi R18,0x00
breq STOPINC
inc R18
ADIW ZL,1
rjmp Loop
STOPINC:
st Z,R21
inc CurReading
cpi CurReading,0x10
brne ENDT1
ldi CurReading,0x00
ENDT1:
reti


Main:
CALL MakeAverage
out PORTB,R22
jmp Main


MakeAverage:
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
ret





ADIW ZL,1;Increase Z pointer

