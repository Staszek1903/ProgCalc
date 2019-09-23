/*
 * asm_utils.S
 *
 * Created: 2019-09-23
 *  Author: Patryk
 */

/**
*   binprint
*  prints 1 byte value on LCD in binary form
*  r24 - value to prints
*  r23 - adress on lcd screen to prints
*/
 .global binprint
binprint:
    push r22
    push r23
    push r24

    push r24        ; setting adress
    mov r24,r23
    rcall LCD_setDDaddr
    pop r24

    ldi r22, 9  ; iterator
    binprint_loop:  ; putting every bit onto the stack in ascii form
        dec r22
        breq binprint_loop_ext
        ldi r23, '0'
        sbrc r24, 0
        ldi r23, '1'
        push r23
        lsr r24
        rjmp binprint_loop

    binprint_loop_ext:
    ldi r22, 9
    binprint_loop2:     ; reading chars from a spac and print
        dec r22
        breq binprint_loop2_ext
        pop r24
        rcall LCD_data
        rjmp binprint_loop2
    binprint_loop2_ext:

    pop r24
    pop r23
    pop r22
    ret
    


/**
*   hexprint
*  prints 1 byte value on LCD in hex form
*  r24 - value to prints
*  r23 - adress on lcd screen to prints
*/
hexprint_table:
.asciz "0123456789ABCDEFG"

.global hexprint
hexprint:
    push r24
    push r23
    push r22
    push zl
    push zh

    push r24        ; setting LCD address
    mov r24,r23
    rcall LCD_setDDaddr
    pop r24

    mov r23, r24    ; separating nibbles
    mov r22, r24
    swap r23
    andi r23, 0x0f  
    andi r22, 0x0f

    ldi zl, lo8(hexprint_table) ; loading char from pm and print
    ldi zh, hi8(hexprint_table)
    add zl, r23
    adc zh, r1
    lpm r24, z
    rcall LCD_data

    ldi zl, lo8(hexprint_table) ; dito
    ldi zh, hi8(hexprint_table)
    add zl, r22
    adc zh, r1
    lpm r24, z
    rcall LCD_data

    pop zl
    pop zh
    pop r22
    pop r23
    pop r24

    ret