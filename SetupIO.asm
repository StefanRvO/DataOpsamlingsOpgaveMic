ldi     R16,0xFF
;Port B is output
out     DDRB,R16
out	PORTB,R16
cbi     DDRA,0 ;Set PA0 to input


;Interupt on falling edge
ldi R16,(1<<ISC01)
out MCUCR,R16
;Enable external interrupt 0 (PD2)
SBI	PORTD,2
ldi	R16,(1<<INT0)
out	GICR,R16
