/*
 * EX_EEPROM_H_.h
 *
 * Created: 2016-11-29 20:50:08
 *  Author: Patryk
 */ 


#ifndef EX_EEPROM_H_
#define EX_EEPROM_H_


extern void TWI_init();
extern void EEPROM_write(char device, uint16_t adrr, char data);
extern char EEPROM_read(char device, uint16_t adrr);


#endif /* EX_EEPROM_H_ */