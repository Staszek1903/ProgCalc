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

powitansko:
.asciz "press any key"

.global calc_vm
calc_vm:
    ldi zl, lo8(powitansko)
    ldi zh, hi8(powitansko)

    ldi xl,0xff
    ldi xh, 0x00

    clr r25
    ldi r24, 0xff

    rcall strlpm
    rcall LCD_print
    
    ldi r24, 0x40
    rcall LCD_setDDaddr

    ldi r24, 123
    push r24
    clr r24
    push r24

    

    clr r25 // last_key
    calc_loop:
        rcall kp_getkey
        cp r25, r24
        breq calc_loop
        rcall LCD_clear
        mov r25, r24
        tst r25
        breq calc_loop

        ;subi r24, -64
        ;rcall LCD_data

        rcall show_top

        ldi xl, 0xff
        ldi xh, 0x00
        in r24, _SFR_IO_ADDR(SPL)
        in r25, _SFR_IO_ADDR(SPH)
        rcall tostr2B
        ldi r24, 0x40
        rcall LCD_setDDaddr
        ser r24
        clr r25
        rcall LCD_print

    rjmp calc_loop
