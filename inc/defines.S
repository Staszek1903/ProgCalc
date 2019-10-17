/*
 * defines.S
 *
 * Created: 2019-10-03
 *  Author: Patryk
 */

#ifndef _DEFINES_S_
#define _DEFINES_S_

#include <avr/io.h>

/* IO DEFINES */

STPTL = _SFR_IO_ADDR(SPL)
STPTH = _SFR_IO_ADDR(SPH)

/* REGISTER DEFINES */

zero_reg = 1
last_key = 2
vm_state = 3
stack_bottomL = 4
stack_bottomH = 5
keypad_mode = 6

/* CONSTANT DEFINES */

TEMP_RAM = RAMEND - 64
RAMBEGIN = 0x60

//kp modes
KP_DECIMAL = 0
KP_BOOLEAN = 1
KP_MISC1 = 2
KP_MISC2 = 3

#endif /* _DEFINES_S_ */