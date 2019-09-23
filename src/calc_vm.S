/*
 * calc_vm.S
 *
 * Created: 2019-09-22
 *  Author: Patryk
 */

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
    
    
    ldi r24, 0x20
    calc_lel:
        rcall LCD_clear
        ldi r22, 0x0a
        push r24
        rcall div1B
        mov r23, r22
        rcall hexprint
        pop r24
        inc r24
        rcall delay3B
        rjmp calc_lel
    

    clr r25 // last_key
    calc_loop:
        rcall kp_getkey
        cp r25, r24
        breq calc_loop
        rcall LCD_clear
        mov r25, r24
        tst r25
        breq calc_loop

        subi r24, -64
        rcall LCD_data

    rjmp calc_loop


delay3B:
    push r24
    push r25
    push r26

    clr r24
    clr r25
    clr r26

    delay3B_loop:
    inc r24
    brne delay3B_loop
    inc r25
    brne delay3B_loop
    inc r26
    cpi r26, 10
    brne delay3B_loop

    pop r26
    pop r25
    pop r24

    ret

