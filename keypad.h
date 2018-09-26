/*
 * keypad.h
 *
 * Created: 2017-12-24 22:43:36
 *  Author: Patryk
 */ 


#ifndef KEYPAD_H_
#define KEYPAD_H_


extern void kp_init();
extern uint8_t kp_getkey();
extern uint8_t kp_getchar(uint8_t key_num);




#endif /* KEYPAD_H_ */