/*
 * ProgCalc.c
 *
 * Created: 2017-12-24 16:39:55
 * Author : Patryk
 */ 
#include <inttypes.h>

#include "../inc/LCD.h"
#include "../inc/keypad.h"
#include "../inc/ExEeprom.h"
#include "../inc/calc_vm.h"

#include <avr/interrupt.h>

ISR(TIMER1_OVF_vect)
{

}

int main(void)
{
	LCD_init();
	kp_init();
	TWI_init();
	
	LCD_DisplayControl(-1,0,0);
	LCD_clear();
	calc_vm();
	return 0;
}

/*
		if(keychar == '*')
		{
			data_reg = EEPROM_read(0,adress_reg);
			LCD_setDDaddr(0x4d);
			LCD_print("   ");
			LCD_setDDaddr(0x4d);
			decprint(data_reg);
		}
		if(keychar == '#')
		{
			EEPROM_write(0,adress_reg,data_reg);
			LCD_setDDaddr(0);
			LCD_print("SAVED        ");
			_delay_ms(300);
		}*/