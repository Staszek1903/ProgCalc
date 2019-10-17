/*
 * calc_funcs.S
 *
 * Created: 2019-09-26
 *  Author: Patryk
 */

#include <avr/io.h>
#include "../inc/defines.S"
#include "../inc/macros.S"

/*
 * calc function will not restore register after execution
 * registers they change: r16-r32
 * mashine state registers r2-r15
 */

/*
 */
.macro check_stackptr_bottom
    in r24, STPTL           ; load stack ptr value
    in r25, STPTH
    subi r24, -1
    sbc r24, zero_reg
    cp r24, stack_bottomL   ; compare with bottom
    cpc r25, stack_bottomH  
    in r24, _SFR_IO_ADDR(SREG)
    sbrs r24, SREG_C
    rjmp empty_stack_error

.endm


/*
 */
.macro check_stackptr_top
    in r24, STPTL           ; load stack ptr value
    in r25, STPTH
    cpi r24, RAMBEGIN+4
    cpc r25, r1
    in r24, _SFR_IO_ADDR(SREG)
    sbrc r24, SREG_C
    rjmp stack_overflow_error
.endm

mode_str:
.asciz "MODE: "
.byte 0


/*
 * clr vm_state
 * avoids printing top of the stack after function execution
 */
.macro override_stack_print
    mov vm_state, zero_reg 
.endm

.global calc_push
calc_push:
    check_stackptr_top

    push r1
    push r1
rjmp vm_loop

.global calc_pop
calc_pop:
    check_stackptr_bottom

    pop r0
    pop r0
rjmp vm_loop

/*
 * shows two byte unsigned number on top of the stack
 */
.global show_top
show_top:
    check_stackptr_bottom
    override_stack_print

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

    printstrpm mode_str 0x40
    debug_reg keypad_mode 0x45          ; showing mode

    ldi r24, ' '
    rcall LCD_data                     ; puting space

    in r24, _SFR_IO_ADDR(SPL)
    in r25, _SFR_IO_ADDR(SPH)
    ldi xl, 0xff
    ldi xh, 0x00
    rcall tostr2B
    movw r24,xl
    rcall LCD_print                     ; showing stack pointer

rjmp vm_loop

/*
 * shows stack pointer value
 */
.global show_sp
show_sp:
    override_stack_print

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
    in r24, STPTL           ; load stack ptr value
    in r25, STPTH
    cp r24, stack_bottomL   ; compare with bottom
    cpc r25, stack_bottomH
    brlo dec_input_notempty

    push r1
    push r1

    dec_input_notempty:
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

    sub r22, r24
    sbc r23, r25

    push r23
    push r22
    rjmp vm_loop

.global calc_mul
calc_mul:
    pop r24
    pop r25
    pop r22
    pop r23

    mul r24, r22
    movw r26, r0
    mul r24, r23
    add r27, r0
    mul r23, r25
    add r27, r0

    clr r24
    mov r1, r24

    push r27
    push r26

rjmp vm_loop

.global calc_div
calc_div:
    pop r22
    pop r23
    pop r24
    pop r25

    rcall div2B

    push r25
    push r24

rjmp vm_loop

.global no_func
no_func:
rjmp vm_loop

.global kp_mode_change
kp_mode_change:

    mov r24, last_key
    subi r24, 0x11
    mov keypad_mode, r24
    
rjmp vm_loop



/* BOOLEAN */

.global calc_eq
calc_eq:
    check_stackptr_bottom
    pop r26
    pop r27
    check_stackptr_bottom
    pop r22
    pop r23

    cp r26, r22
    cpc r27, r23

    in r24, _SFR_IO_ADDR(SREG)
    sbrs r24, SREG_Z
    rjmp calc_bool_false
    rjmp calc_bool_true

.global calc_gt
calc_gt:
    check_stackptr_bottom
    pop r26
    pop r27
    check_stackptr_bottom
    pop r22
    pop r23
calc_gt_regs:
    cp r26, r22
    cpc r27, r23

    in r24, _SFR_IO_ADDR(SREG)
    in r25, _SFR_IO_ADDR(SREG)
    lsr r25
    or r24, r25
    andi r24, 1

    sbrs r24, SREG_C
    rjmp calc_bool_true
    rjmp calc_bool_false

.global calc_lt
calc_lt:
    check_stackptr_bottom
    pop r26
    pop r27
    check_stackptr_bottom
    pop r22
    pop r23
    cp r26, r22
    cpc r27, r23

    in r24, _SFR_IO_ADDR(SREG)
    sbrc r24, SREG_C
    rjmp calc_bool_true
    rjmp calc_bool_false

.global calc_neq
calc_neq:
    check_stackptr_bottom
    pop r26
    pop r27
    check_stackptr_bottom
    pop r22
    pop r23
    cp r26, r22
    cpc r27, r23

    in r24, _SFR_IO_ADDR(SREG)
    sbrs r24, SREG_Z
    rjmp calc_bool_true
    rjmp calc_bool_false

.global calc_ngt
calc_ngt:
    check_stackptr_bottom
    pop r26
    pop r27
    check_stackptr_bottom
    pop r22
    pop r23
    cp r26, r22
    cpc r27, r23

    in r24, _SFR_IO_ADDR(SREG)  ; get C bit
    in r25, _SFR_IO_ADDR(SREG)  ; get Z bit
    lsr r25                     ; move Z bit to LSB position
    or r24, r25                 ; Z | C
    andi r24, 1                 ; mask LSB

    sbrs r24, SREG_C                 ; if Z | C then true
    rjmp calc_bool_false
    rjmp calc_bool_true

.global calc_nlt
calc_nlt:
    check_stackptr_bottom
    pop r26
    pop r27
    check_stackptr_bottom
    pop r22
    pop r23
    cp r26, r22
    cpc r27, r23
    in r24, _SFR_IO_ADDR(SREG)  ; get C bit from sreg
    sbrs r24, SREG_C            ; when C is set trzen false
    rjmp calc_bool_true
    rjmp calc_bool_false

.global calc_and
calc_and:
    check_stackptr_bottom
    pop r26
    pop r27
    check_stackptr_bottom
    pop r22
    pop r23
    cp r26, zero_reg
    cpc r27, zero_reg
    breq calc_and_zero
        ldi r26, 0xff
        ldi r27, 0xff
    rjmp calc_and_ext
    calc_and_zero:
        ldi r26, 0x00
        ldi r27, 0x00
    calc_and_ext:
    and r26, r22
    and r27, r23
    clr r22
    clr r23
    rjmp calc_gt_regs


.global calc_or
calc_or:
    check_stackptr_bottom
    pop r26
    pop r27
    check_stackptr_bottom
    pop r22
    pop r23
    or r26, r22
    or r27, r23
    clr r22
    clr r23
    rjmp calc_gt_regs

.global calc_xor
calc_xor:
    check_stackptr_bottom
    pop r26
    pop r27
    check_stackptr_bottom
    pop r22
    pop r23
    cp r26, zero_reg
    cpc r27, zero_reg
    breq calc_xor_zero
        ldi r26, 0xff
        ldi r27, 0xff
    rjmp calc_xor_ext
    calc_xor_zero:
        ldi r26, 0x00
        ldi r27, 0x00
    calc_xor_ext:

    cp r22, zero_reg
    cpc r23, zero_reg
    breq calc_xor_zero1
        ldi r22, 0xff
        ldi r23, 0xff
    rjmp calc_xor_ext1
    calc_xor_zero1:
        ldi r22, 0x00
        ldi r23, 0x00
    calc_xor_ext1:
    eor r26, r22
    eor r27, r23
    clr r22
    clr r23

    rjmp calc_gt_regs

.global calc_not
calc_not:
    check_stackptr_bottom
    pop r24
    pop r25
    cp r24, zero_reg
    cpc r25, zero_reg
    breq calc_bool_true
    rjmp calc_bool_false

calc_bool_true:
    ldi r16, 0xff
    rjmp calc_bool_ext
calc_bool_false:
    ldi r16, 0x00
calc_bool_ext:
    ;check_stackptr_top
    push r16
    push r16
    rjmp vm_loop


.global test_func
test_func:
    override_stack_print
    ldi r24, SREG
    debug_reg r24 0x41
    ldi r24, _SFR_IO_ADDR(SREG)
    debug_reg r24 0x44
    ldi r24, SREG_C
    debug_reg r24 0x48
rjmp vm_loop



