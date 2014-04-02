ldi     R16,0xFF
;Port B is output
out     DDRB,R16
ldi	R16,0xff
out	PORTB,R16
cbi     DDRA,0 ;Set PA0 to input
;Enable external interrupt 1 (PD2)
SBI	PORTD,2
ldi	R16,(1<<INT0)
out	GICR,R16
