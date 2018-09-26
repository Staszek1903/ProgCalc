
/*
 * ExEeprom.s
 *
 * Created: 2016-10-14 16:26:35
 *  Author: Patryk
 */

#include <util/twi.h>
tw_status	= _SFR_IO_ADDR(TWSR)
tw_bitrate	= _SFR_IO_ADDR(TWBR)
tw_control	= _SFR_IO_ADDR(TWCR)
tw_data		= _SFR_IO_ADDR(TWDR)


 .global TWI_init
 TWI_init:
	clr r24
	out tw_status,r24
	ldi r24, 0x0c
	out tw_bitrate, r24
	ldi r24, (1<<TWEN)
	out tw_control,r24
	ret

.global TWI_start
TWI_start:
	ldi r24, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	out tw_control,r24
	TWI_start_w:
		in r24,tw_control
		sbrs r24,TWINT
		rjmp TWI_start_w
	TWI_start_ack:
		in r24, tw_status
		andi r24, 0xF8
		cpi r24,0x10
		breq TWI_start_ret
		cpi r24,0x08
		brne TWI_start_ack
	TWI_start_ret:
	ret

.global TWI_stop
TWI_stop:
	ldi r24, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN)
	out tw_control, r24
	/*TWI_stop_w:
		in r24, tw_control
		sbrc r24, TWSTO
		rjmp TWI_stop_w*/
	ret

.global TWI_write
TWI_write:
	out tw_data, r24
	ldi r24, (1<<TWINT) | (1<<TWEN)
	out tw_control, r24
	TWI_write_w:
		in r24, tw_control
		sbrs r24, TWINT
		rjmp TWI_write_w
	in r24, tw_status
	andi r24, 0xF8
	ret

.global TWI_read
TWI_read:
	tst r24
	breq TWI_noack
		ldi r24, (1 << TWINT) | (1 << TWEN) | (1 << TWEA)
		rjmp TWI_setack
	TWI_noack:
		ldi r24, (1 << TWINT) | (1 << TWEN)
	TWI_setack:
		out tw_control, r24
	TWI_read_w:
		in r24, tw_control
		sbrs r24, TWINT
		rjmp TWI_read_w
		
	in r24, tw_data
	ret

.extern delay_5_ms
.global EEPROM_write ;(char device, uint16_t address, char data)
EEPROM_write: 
	lsl r24
	ori r24,0xA0
	push r24
	rcall TWI_start
	pop r24
	rcall TWI_write
	mov r24,r23
	rcall TWI_write
	mov r24,r22
	rcall TWI_write
	mov r24,r20
	rcall TWI_write
	rcall TWI_stop
	rcall delay_5_ms
	ret

.global EEPROM_read
EEPROM_read:
	/*TWI_start();
	TWI_write(0xA0);
	TWI_write(0x0);
	TWI_write(0x0);
	TWI_start();
	TWI_write(0xA1);
	print_int(TWI_read(-1));
	print_int(TWI_read(-1));
	print_int(TWI_read(-1));
	print_int(TWI_read(0));
	LCD_print("KEK");
	TWI_stop();*/
	lsl r24
	ori r24, 0xA0
	push r24
	rcall TWI_start
	pop r24
	push r24
	rcall TWI_write
	mov r24, r23
	rcall TWI_write
	mov r24, r22
	rcall TWI_write
	rcall TWI_start
	pop r24
	ori r24, 0x01
	rcall TWI_write
	ldi r24,0
	rcall TWI_read
	//rcall delay_5_ms
	ret

