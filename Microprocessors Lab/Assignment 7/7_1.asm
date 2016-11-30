;
; AssemblerApplication1.asm
;
; Created: 11/29/2016 3:10:43 PM
; Author : Gbax
;
.include "m16def.inc"
.def temp = r17
.org 0x0 
rjmp main
.org 0x2
rjmp ISR0


main:
ldi temp,high(RAMEND)					;Initialize stack
out SPH, temp
ldi temp,low(RAMEND)
out SPL, temp

ser r26 ; a?????p???s? t?? PORTA
out DDRA, r26 ;??a ???d?
out DDRB, r26
clr r26; a?????p???s? t?? µet??t?
clr r23; init num of interrupts
loop:
ldi r24 ,( 1 << ISC01) | ( 1 << ISC00)
out MCUCR, r24
ldi r24 ,( 1 << INT0)
out GICR, r24
sei
out PORTA, r26 ;?e??e t?? t?µ? t?? µet??t? st? ???a e??d?? t?? LED
ldi r24, low(100) ;load r25:r24 with 100
ldi r25, high(100) ;delay 100 ms
rcall wait_msec
inc r26 
; ????se t?? µet??t?
rjmp loop
; ?pa???aße

wait_usec:
	sbiw r24 ,1 	; 2 ?????? (0.250 µsec)
	nop 		; 1 ?????? (0.125 µsec)
	nop 		; 1 ?????? (0.125 µsec)
	nop 		; 1 ?????? (0.125 µsec)
	nop 		; 1 ?????? (0.125 µsec)
	brne wait_usec 	; 1 ? 2 ?????? (0.125 ? 0.250 µsec)
	ret 		; 4 ?????? (0.500 µsec)

wait_msec:
	push r24 	; 2 ?????? (0.250 µsec)
	push r25 	; 2 ??????
	ldi r24 , 0xe6	; f??t?se t?? ?ata?. r25:r24 µe 998 (1 ?????? - 0.125 µsec)
	ldi r25 , 0x03	; 1 ?????? (0.125 µsec)
	rcall wait_usec ; 3 ?????? (0.375 µsec), p???a?e? s??????? ?a??st???s? 998.375 µsec
	pop r25 	; 2 ?????? (0.250 µsec)
	pop r24	 	; 2 ??????
	sbiw r24 , 1 	; 2 ??????
	brne wait_msec 	; 1 ? 2 ?????? (0.125 ? 0.250 µsec)
	ret 		; 4 ?????? (0.500 µsec)

ISR0:
	; r23 = num of interrupts
	rcall protect
	push r26
	in r26, SREG
	push r26
	in temp,PIND				
	sbrc temp,0		;If (PD0==1) return
	rjmp ISR0_exit
	inc r23
	out PORTB, r23 ; show num of interrupts 
	ldi r24, low(998)
	ldi r25, high(998)
	;rcall wait_msec ; and wait a sec
ISR0_exit:
	pop r26
	out SREG, r26
	pop r26
	sei ;just in case
	reti

protect:
	ldi temp,0x40		;0100 0000
	out GIFR,temp		;INTF0 -> 0
	ldi r24,0x05		;5ms
	ldi r25,0x00
	rcall wait_msec		;wait r24r25 -> 5ms
	in temp,GIFR		;Check if INTF0==1
	sbrc temp,6			;check bit 6 (intf0)
	rjmp protect		;INTF0==1 then loop
	ret					;INTF0==0 then return
