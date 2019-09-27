/*
 * calc_vm.S
 *
 * Created: 2019-09-22
 *  Author: Patryk
 */

 #include <avr/io.h>

.macro debug_reg reg pos
    push r24
    push r23
    mov r24, \reg
    ldi r23, \pos
    rcall hexprint
    pop r23
    pop r24
.endm

.macro loadw_24 word
    ldi r24, lo8(\word)
    ldi r25, hi8(\word)
.endm

.macro loadw_x word
    ldi xl, lo8(\word)
    ldi xh, hi8(\word)
.endm

.macro loadw_y word
    ldi yl, lo8(\word)
    ldi yh, hi8(\word)
.endm

.macro loadw_z word
    ldi zl, lo8(\word)
    ldi zh, hi8(\word)
.endm

STPTL = _SFR_IO_ADDR(SPL)
STPTH = _SFR_IO_ADDR(SPH)

powitansko:
.asciz "press any key"

.global calc_vm
.global vm_loop
calc_vm:
    loadw_z(powitansko)
    loadw_x(255)
    loadw_24(255)
    rcall strlpm
    rcall LCD_print

    loadw_24(RAMEND)
    out _SFR_IO_ADDR(SPL), r24
    out _SFR_IO_ADDR(SPH), r25
    
    ldi xl, 0xff
    ldi xh, 0x00
    in r24, STPTL
    in r25, STPTH
    rcall tostr2B
    ldi r24, 0x40
    rcall LCD_setDDaddr
    ser r24
    clr r25
    rcall LCD_print

    clr r25
    mov r2, 25 // last_key

    vm_loop:
        rcall kp_getkey
        cp r2, r24
        breq vm_loop
        mov r2, r24
        tst r2
        breq vm_loop

        ldi zl, pm_lo8(functions_table)
        ldi zh, pm_hi8(functions_table)
        add zl, r2
        adc zh, r1
        ijmp

    rjmp vm_loop

functions_table:
    rjmp no_func

    rjmp dec_input
    rjmp dec_input
    rjmp dec_input
    rjmp calc_add

    rjmp dec_input
    rjmp dec_input
    rjmp dec_input
    rjmp calc_sub

    rjmp dec_input
    rjmp dec_input
    rjmp dec_input
    rjmp no_func

    rjmp calc_pop
    rjmp dec_input
    rjmp calc_push
    rjmp no_func

    rjmp show_sp
    rjmp show_top
    rjmp no_func
    rjmp no_func

