
/*
 * keypad.s
 *
 * Created: 2017-12-26 17:56:32
 *  Author: Patryk
 */ 

  #include <avr/io.h>
 
//keypad 1  2  3  4  5  6  7  8  (left to right)
//proc   c0 c1 c2 c3 b4 b5 b6 b7
//       ustawianie  pobieranie

port_C = _SFR_IO_ADDR(PORTC)
port_B = _SFR_IO_ADDR(PORTB)
ddr_C = _SFR_IO_ADDR(DDRC)
ddr_B = _SFR_IO_ADDR(DDRB)
pin_B = _SFR_IO_ADDR(PINB)

/*{
	DDRC |= 0xf;
	PORTC |= 0xf;
	DDRB &= ~(0xf0);
	PORTB |= 0xf0;
}*/

.global kp_init
kp_init:
	in r24, ddr_C
	ori r24, 0xf
	out ddr_C, r24

	in r24, port_C
	ori r24, 0xf
	out port_C, r24

	in r24, ddr_B
	andi r24, 0xf
	out ddr_B, r24

	in r24, port_B
	ori r24, 0xf0
	out port_B, r24

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
.asciz " 123A456B789C*0#D"
.global kp_getchar
kp_getchar:
	ldi zh, hi8(kp_tab)
	ldi zl, lo8(kp_tab)
	add zl, r24
	adc zh, r1

	lpm r24,z
	ret


.global kp_getkey
kp_getkey:
	clr r23		// result = 0
	ldi r25, 1	// i=1
	kp_gc_loop:
		in r24, port_C  //temp = port_C
		ori r24, 0xf	//temp &= 0xf
		eor r24, r25	//temp ^=i
		out port_C, r24 //port_C = temp

		nop
		nop
		nop

		in r24, pin_B	//pin = pin_B
		com r24			//pin = ~pin
		swap r24		//swap
		andi r24,0xf	//pin &= 0xf
		brne kp_gc_ret  // if(pin != 0) goto kp_gc_ret

		inc r23			// icrement row num
		lsl r25			//i<<1
		andi r25, 0xf	//i &= 0xf
		brne kp_gc_loop // if(i != 0) goto kp_gc_loop

kp_gc_ret:

	tst r24
	breq kp_gc_ret2

	push r0			//save r0 on stack
	ldi r25, 4		//i = 4
	mul r23, r25   
	mov r23, r0		// result = i*4
	pop r0
	clr r1

	ldi r25, 1		//i=1	
	kp_gc_num:
		inc r23				//result++
		mov r26,r24 
		and r26,r25 
		brne kp_gc_ret2		//if(pin & i != 0) goto ret2
		lsl r25				//i<<1
		andi r25,0xf		//i &= 0xf
		breq kp_gc_ret2		//if(i==0) goto ret2
		rjmp kp_gc_num		//goto num

kp_gc_ret2:

	in r26, port_C
	ori r26, 0xf
	out port_C, r26

	cpse r24, r1
	mov r24, r23

	ret

