
/*
 * keypad.s
 *
 * Created: 2017-12-26 17:56:32
 *  Author: Patryk
 */ 

  #include <avr/io.h>
 
//keypad 1  2  3  4  5  6  7  8  (left to right)  9-additional row
//proc   c0 c1 c2 c3 b4 b5 b6 b7					d4
//       ustawianie  pobieranie

port_C = _SFR_IO_ADDR(PORTC) //<= adressing
port_B = _SFR_IO_ADDR(PORTB) //<= row value
port_D = _SFR_IO_ADDR(PORTD) //<= additional row
ddr_C = _SFR_IO_ADDR(DDRC)
ddr_B = _SFR_IO_ADDR(DDRB)
ddr_D = _SFR_IO_ADDR(DDRD)
pin_B = _SFR_IO_ADDR(PINB)

.global kp_init
kp_init:
	push r24

	in r24, ddr_C	//setting c0..c3 for output
	ori r24, 0xf
	out ddr_C, r24

	in r24, port_C
	ori r24, 0xf
	out port_C, r24

	in r24, ddr_B	//clearing b4..b7 for input
	andi r24, 0x0f
	out ddr_B, r24

	in r24, port_B	//b4..b7 pull_ups
	ori r24, 0xf0
	out port_B, r24

	sbi ddr_D, 4	//setting d4 for output
	sbi port_D, 4
	
	pop r24
	ret


/*	{
	uint8_t pin = 0;
	for(uint8_t i = 0; i<4; ++i)
	{
		PORTC |= 0xf;
		PORTC ^= (1<<i);
		pin = ((~PINB)>>4)&0xf;
		if(pin)
			break; 
	}
	PORTC |= 0xf;
	return pin;
}*/

kp_tab:
.asciz " 123A456B789C*0#DEFGH"
.global kp_getchar
kp_getchar:
	push zh
	push zl

	ldi zh, hi8(kp_tab)
	ldi zl, lo8(kp_tab)
	add zl, r24
	adc zh, r1

	lpm r24,z
	
	pop zl
	pop zh
	ret

kp_set_row:			// sets active row on port_C, argument r24 value: 0..5 (5 - non row set)
	push r24
	push r23

	ldi r23, 0b11111110
	kp_set_row_loop:		// rotating 0 bit to match row address
		dec r24
		brlt kp_set_row_loop_end
		rol r23
		rjmp kp_set_row_loop
	kp_set_row_loop_end:

	sbi port_D, 4
	sbrs r23, 4
	cbi port_D, 4

	in r24, port_C	//setting C adress
	andi r23, 0x0f;
	andi r24, 0xf0;
	or r24,r23		//merging nibbles of two registers
	out port_C, r24

	pop r23
	pop r24
	ret

kp_get_row:	// reads current row and returns first down button in r24 (0..3)
	clr r24
	push r23

	in r23, pin_B
	swap r23
	ori r23, 0xf0
	com r23
	breq kp_get_row_ret

	kp_get_row_loop:
		sbrc r23, 0
		rjmp kp_get_row_loop_end //if last bit=0 then button is pressed -> end loop
		inc r24
		lsr r23
		rjmp kp_get_row_loop
	kp_get_row_loop_end:
	inc r24

	kp_get_row_ret:
	pop r23
	ret

.global kp_getkey
kp_getkey:
/*	ldi r24, 0
	rcall kp_set_row
	rcall kp_get_row
	ret
*/
	push r23
	push r22

	clr r23 // <--- row adrres
	clr r22 // row multiplier 
	
	kp_getkey_loop:
		mov r24, r23
		rcall kp_set_row	//setting row adres
		rcall kp_get_row	// reading row
		tst r24
		brne kp_getkey_loop_end	// if result not empty jmp to dinal computation
		subi r22, -4 		// adding 4 by subtracting -4 xd
		inc r23

		cpi r23, 6			// if row address exided 6 jmp to return
		brne kp_getkey_loop
		rjmp kp_getkey_ret
	kp_getkey_loop_end:

	add r24, r22	// adding number of button to row multiplier

	kp_getkey_ret:
	pop r22
	pop r23
	ret
