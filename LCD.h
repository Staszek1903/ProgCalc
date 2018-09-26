/*
 * LCD.h
 *
 * Created: 2016-10-04 00:54:48
 *  Author: Patryk
 */ 


#ifndef LCD_H_
#define LCD_H_



extern void LCD_init(void);
extern void LCD_command(char);
extern void LCD_data(char);
extern unsigned char LCD_getaddr();
extern unsigned char LCD_getchar();
extern void LCD_clear();
extern void LCD_print(char*);
extern void LCD_setDDaddr(uint8_t);
extern void LCD_setCGaddr(uint8_t);
extern void LCD_EntryMode(uint8_t right,uint8_t shift); // bool, bool
extern void LCD_DisplayControl(uint8_t display, uint8_t cursor, uint8_t blinking); //bool, bool, bool


#endif /* LCD_H_ */