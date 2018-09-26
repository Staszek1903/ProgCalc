/*
 * ProgCalc.c
 *
 * Created: 2017-12-24 16:39:55
 * Author : Patryk
 */ 

#define F_CPU 8000000UL

#include <avr/io.h>
#include <util/delay.h>
#include "LCD.h"
#include "keypad.h"
#include "ExEeprom.h"

void binprint(uint8_t data)
{
	LCD_data('<');
	for(uint8_t i=0; i<8; ++i)
		LCD_data((data&(1<<(7-i)))? '1':'0');
	LCD_data('>');
}

uint16_t stoi(const char * tab, uint8_t size)
{
	uint16_t result =0;
	for(uint8_t i=0; i<size; ++i)
	{
		result *=10;
		result += tab[i] -48;
	}
	
	return result;
}

void decprint(uint16_t num)
{
	if(num == 0)
	{
		LCD_data('0');
		return;
	}
	
	uint8_t i = 0;
	char tab[16];
	while(num != 0)
	{
		tab[i] = num%10;
		num/=10;
		i++;
	}
	
	while(i != 0)
	{
		i--;
		LCD_data(tab[i] + 48);
	}
}

void delay_5_ms(void)
{
	_delay_ms(5);
}

uint16_t entry(uint8_t pos, uint8_t size)
{
	LCD_setDDaddr(pos);
	LCD_DisplayControl(-1,0,-1);
	
	uint8_t prev_key = 0;
	uint8_t i =0;
	char tab[16] = {0};
	while(1)
	{
		uint8_t key = kp_getkey();
		delay_5_ms();
		if(key == prev_key)
			continue;
		prev_key = key;
		
		uint8_t keychar = kp_getchar(key);
		if(keychar == 'B')
			break;
			
		if(keychar >= 48 && keychar <58)
		{
			LCD_data(keychar);
			tab[i] = keychar;
			i++;
		}
		
		if(i == size)
		{
			LCD_setDDaddr(pos);
			i =0;
		}
	}
	
	LCD_setDDaddr(pos);
	for(uint8_t a =0; a<size; a++)
		LCD_data(' ');
	LCD_setDDaddr(pos);
	uint16_t result = stoi(tab,size);
	decprint(result);
	
	LCD_DisplayControl(-1,0,0);
	return result;
}

uint16_t adress_reg;
void adr_entry()
{
	adress_reg = entry(0x44,4);
}

uint8_t data_reg;
void data_entry()
{
	data_reg = entry(0x4d,3);
}

int main(void)
{
	
	_delay_ms(100);
	
	LCD_init();
	kp_init();
	TWI_init();
	
	LCD_DisplayControl(-1,-1,-1);
	
	LCD_clear();
	
	LCD_setDDaddr(0x40);
	LCD_print("Adr:");
	LCD_setDDaddr(0x48);
	LCD_print("Data:");
	
	
    while (1) 
    {
		LCD_setDDaddr(0);
		uint8_t key = kp_getkey();
		binprint(key);
		LCD_data(' ');
		char keychar = kp_getchar(key);
		LCD_data(keychar);	
		
		
		if(keychar == 'A')
			adr_entry();
		if(keychar == 'D')
			data_entry();
		if(keychar == '*')
		{
			data_reg = EEPROM_read(0,adress_reg);
			LCD_setDDaddr(0x4d);
			decprint(data_reg);
		}
		if(keychar == '#')
		{
			EEPROM_write(0,adress_reg,data_reg);
			LCD_setDDaddr(0);
			LCD_print("SAVED        ");
			_delay_ms(300);
		}
				
	}
	
	return 0;
}

