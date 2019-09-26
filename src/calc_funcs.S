/*
 * calc_funcs.S
 *
 * Created: 2019-09-26
 *  Author: Patryk
 */

#include <avr/io.h>

.global calc_push
calc_push:
    push r1
    push r1
    ret

.global calc_pop
calc_pop:
    pop r2
    pop r2
    ret

.global show_top
show_top:
    rcall LCD_clear
    in xl, _SFR_IO_ADDR(SPL)
    in xh, _SFR_IO_ADDR(SPH)
    ld r25, -x
    ld r24, x
    ldi xl, 0xff
    ldi xh, 0x00
    rcall tostr2B
    movw r24,xl
    rcall LCD_print
    ret


.global dec_input


.global calc_add