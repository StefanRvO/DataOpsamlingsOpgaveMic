ldi R16,0
out TCCR1A,R16
ldi R16,0
out TCCR1A,R16
ldi R16, (1<<CS12) 
out TCCR1B,R16 ;Timer 1, normal mode, no prescale
ldi R16,(1<<TOIE1) ;Enable timer 1 interrupt
out TIMSK,R16
ldi R19,HIGH(65536-ADCInterval)
out TCNT1H,R19
ldi R19,LOW(65536-ADCInterval)
out TCNT1L,R19
