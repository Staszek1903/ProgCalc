
/*
 * LCD.s
 *
 * Created: 2016-09-28 13:14:32
 *  Author: Patryk
 */ 

 #include <avr/io.h>

 ; PB. 0,1,2,3 = LCD data (D4,D5,D6,D7)
 ; PD. 5,6,7 = E, RW, RS

 port_D = _SFR_IO_ADDR(PORTD)
 port_B = _SFR_IO_ADDR(PORTB)
 ddr_D = _SFR_IO_ADDR(DDRD)
 ddr_B = _SFR_IO_ADDR(DDRB)
 pin_B = _SFR_IO_ADDR(PINB)

 LCD_E = 5
 LCD_RW = 6
 LCD_RS = 7

 LCD_delay:
	clr r24
	clr r25
	LCD_delay_loop:
	inc r24
	brne LCD_delay_loop
	inc r25
	brne LCD_delay_loop
	ret

LCD_wait:

	rcall LCD_getaddr
	andi r24, 0x80
	brne LCD_wait

	ret

.global LCD_init
LCD_init:
	in r24, ddr_B
	sbr r24, 0x0f
	out ddr_B,r24	;ustawiam magistrale jako wyjscie

	in r24, ddr_D
	sbr r24, 0b11100000
	out ddr_D,r24	; ustwawiam sterowanie jako wyjscie

	in r24, port_B
	cbr r24, 0x0f
	out port_B,r24	;czyszcze magistrale

	in r24, port_D
	cbr r24, 0b11100000
	out port_D,r24  ;czyszcze sterowanie

	rcall LCD_delay
	
	in r24, port_B
	andi r24, 0xf0
	ori r24, 0x2
	out port_B, r24
	sbi port_D, LCD_E
	nop
	nop
	nop
	cbi port_D,LCD_E
	
	rcall LCD_wait
	ldi r24, 0b0101000
	rcall LCD_command

	rcall LCD_wait
	ldi r24, 0b01100
	rcall LCD_command
	ret


.global LCD_command
LCD_command:
	push r24
	rcall LCD_wait
	pop r24

	in r25, ddr_B
	sbr r25, 0x0f
	out ddr_B, r25

	cbi port_D, LCD_RW
	cbi port_D, LCD_RS
	rjmp LCD_send

.global LCD_data
LCD_data:
	push r24
	rcall LCD_wait
	pop r24

	in r25, ddr_B
	sbr r25, 0x0f
	out ddr_B, r25

	cbi port_D, LCD_RW
	sbi port_D, LCD_RS

LCD_send:
	push r24
	swap r24
	cbr r24, 0xf0

	in r25, port_B
	cbr r25, 0x0f
	or r24,r25
	out port_B, r24
	sbi port_D, LCD_E
	nop
	nop
	nop
	cbi port_D,LCD_E

	pop r24
	or r24,r25
	out port_B, r24
	sbi port_D,LCD_E
	nop
	nop
	nop
	cbi port_D,LCD_E

	ret

.global LCD_getaddr
LCD_getaddr:
	in r24, ddr_B
	cbr r24, 0x0f
	out ddr_B,r24

	sbi port_D, LCD_RW
	cbi port_D, LCD_RS
	rjmp LCD_recieve

.global LCD_getchar
LCD_getchar:
	in r24, ddr_B
	cbr r24, 0x0f
	out ddr_B,r24

	sbi port_D, LCD_RW
	sbi port_D, LCD_RS
	
LCD_recieve:
	sbi port_D, LCD_E
	nop
	nop
	nop
	in r24, pin_B
	cbi port_D,LCD_E
	cbr r24, 0xf0
	swap r24
	nop
	nop

	sbi port_D,LCD_E
	nop
	nop
	in r25, pin_B
	cbi port_D,LCD_E
	cbr r25, 0xf0
	or r24, r25
	
	ret


.global LCD_print
LCD_print:
	movw XL, r24
	
	LCD_print_loop:
		ld r24, x+
		tst r24
		breq LCD_print_end
		rcall LCD_data
		rjmp LCD_print_loop

	LCD_print_end:
	ret


.global	LCD_clear
LCD_clear:
	ldi r24, 1
	rcall LCD_command
	ret

.global LCD_setDDaddr
LCD_setDDaddr:
	ori r24, 0x80
	rcall LCD_command
	ret

.global LCD_setCGaddr
LCD_setCGaddr:
	ori r24, 0x40
	rcall LCD_command
	ret

.global LCD_EntryMode
LCD_EntryMode:
	andi r24, 0x02
	andi r22, 1
	or r24,r22
	ori r24, 0x04
	rcall LCD_command
	ret

.global LCD_DisplayControl
LCD_DisplayControl:
	andi r24, 0x04
	andi r22, 0x02
	andi r20, 0x01
	or r24,r22
	or r24,r20
	ori r24, 0x08
	rcall LCD_command
	ret


