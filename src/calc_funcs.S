/*
 * calc_funcs.S
 *
 * Created: 2019-09-26
 *  Author: Patryk
 */

#include <avr/io.h>

/*
 * calc function will not restore register after execution
 * registers they change: r16-r32
 * mashine state registers r2-r15
 */

.global calc_push
calc_push:
    push r1
    push r1
rjmp vm_loop

.global calc_pop
calc_pop:
    pop r0
    pop r0
rjmp vm_loop

/*
 * shows two byte unsigned number on top of the stack
 */
.global show_top
show_top:
    rcall LCD_clear
    in xl, _SFR_IO_ADDR(SPL)
    in xh, _SFR_IO_ADDR(SPH)
    adiw x, 1
    ld r24, x+
    ld r25, x
    ldi xl, 0xff
    ldi xh, 0x00
    rcall tostr2B
    movw r24,xl
    rcall LCD_print
rjmp vm_loop

/*
 * shows stack pointer value
 */
.global show_sp
show_sp:
    rcall LCD_clear
    in r24, _SFR_IO_ADDR(SPL)
    in r25, _SFR_IO_ADDR(SPH)
    ldi xl, 0xff
    ldi xh, 0x00
    rcall tostr2B
    movw r24,xl
    rcall LCD_print
rjmp vm_loop

/*
 * multipies number on top of the stack by 10
 * and adds last key value
 * then puts the number back on the stack
 */
.global dec_input
dec_input:
    pop r24
    pop r25

    ldi r23, 10     
    mul r23, r24
    mov r20, r0
    mov r21, r1
    mul r23, r25
    add r21, r0     ; possible overflow !

    mov r24, r2
    rcall kp_getchar
    subi r24, 48
    clr r25
    mov r1, r25
    add r20, r24
    adc r21, r1

    push r21
    push r20
rjmp vm_loop 

.global calc_add
calc_add:
    pop r24
    pop r25
    pop r22
    pop r23

    add r24, r22
    adc r25, r23

    push r25
    push r24
rjmp vm_loop

.global calc_sub
calc_sub:
    pop r24
    pop r25
    pop r22
    pop r23

    sub r24, r22
    sbc r25, r23

    push r25
    push r24
    rjmp vm_loop

.global calc_mul
calc_mul:
    

rjmp vm_loop

.global calc_div
calc_div:

rjmp vm_loop

.global no_func
no_func:
rjmp vm_loop
