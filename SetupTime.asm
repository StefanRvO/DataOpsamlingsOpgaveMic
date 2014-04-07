.equ WGM12=3 ;Not defined in m32def.inc...?
ldi R16,0
out TCCR1A,R16
ldi R16, (1<<CS12) | (1<<WGM12)
out TCCR1B,R16 ;Timer 1, 256x prescale;CTC mode
ldi R16,HIGH(ADCInterval)
out OCR1AH,R16      
ldi R16,LOW(ADCInterval)
out OCR1AL,R16
ldi R16,(1<<OCIE1A) ;Enable timer 1 interrupt
out TIMSK,R16
