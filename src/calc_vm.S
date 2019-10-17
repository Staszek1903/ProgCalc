/*
 * calc_vm.S
 *
 * Created: 2019-09-22
 *  Author: Patryk
 */

 #include <avr/io.h>
 #include "../inc/macros.S"
 #include "../inc/defines.S"

powitansko:
.asciz "press any key"

.global calc_vm
.global vm_loop
calc_vm:

    printstrpm powitansko 1

    loadw_24(TEMP_RAM -1)       ; load first stack bottom into stack pointer
    out _SFR_IO_ADDR(SPL), r24
    out _SFR_IO_ADDR(SPH), r25
    movw stack_bottomL, r24
    
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
    mov last_key, r25
    mov vm_state, r25
    mov r1, r25
    mov keypad_mode, r25

    vm_loop:

        cp vm_state, zero_reg
        breq vm_k ; dont output if state not raised 
             mov vm_state, zero_reg    ; clear state
             rjmp show_top

        vm_k:
        ldi r24, 2
        rcall delay3B
        rcall kp_getkey ; reading keypad state
        cp r2, r24      ; is same as previous
        breq vm_loop    ; continue if is same
        mov r2, r24     ; save new state if diferent
        tst r2          ; check zero
        breq vm_loop    ; continue if zero, no button pressed

        /* debug 
            debug_reg last_key 8
            rjmp vm_loop
        */

        ldi r24, KP_DECIMAL
        cp keypad_mode, r24
        brne vm_boolean 
            ldi zl, pm_lo8(functions_table_decimal)
            ldi zh, pm_hi8(functions_table_decimal)
        rjmp vm_exec
        vm_boolean:
        ldi r24, KP_BOOLEAN
        cp keypad_mode, r24
        brne vm_misc1
            ldi zl, pm_lo8(functions_table_boolean)
            ldi zh, pm_hi8(functions_table_boolean)
        rjmp vm_exec
        vm_misc1:
        ldi r24, KP_MISC1
        cp keypad_mode, r24
        brne vm_misc2
            ldi zl, pm_lo8(functions_table_misc1)
            ldi zh, pm_hi8(functions_table_misc1)
        rjmp vm_exec
        vm_misc2:
        ldi r24, KP_MISC2
        cp keypad_mode, r24
        brne vm_loop
            ldi zl, pm_lo8(functions_table_misc2)
            ldi zh, pm_hi8(functions_table_misc2)
        vm_exec:
        add zl, last_key
        adc zh, zero_reg
        inc vm_state ; raise state for prinitng stack
        ijmp

    rjmp vm_loop

functions_table_decimal:
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
    rjmp calc_mul

    rjmp calc_pop
    rjmp dec_input
    rjmp calc_push
    rjmp calc_div

    rjmp kp_mode_change
    rjmp kp_mode_change
    rjmp kp_mode_change
    rjmp kp_mode_change

functions_table_boolean:
    rjmp no_func
    
    rjmp calc_eq
    rjmp calc_gt
    rjmp calc_lt
    rjmp calc_and
    
    rjmp calc_neq
    rjmp calc_ngt
    rjmp calc_nlt
    rjmp calc_or

    rjmp no_func
    rjmp no_func
    rjmp no_func
    rjmp calc_xor

    rjmp calc_pop
    rjmp no_func
    rjmp calc_push
    rjmp calc_not

    rjmp kp_mode_change
    rjmp kp_mode_change
    rjmp kp_mode_change
    rjmp kp_mode_change

functions_table_misc1:

    rjmp no_func

    rjmp show_sp
    rjmp show_top
    rjmp no_func
    rjmp no_func

    rjmp no_func
    rjmp no_func
    rjmp no_func
    rjmp no_func

    rjmp no_func
    rjmp no_func
    rjmp no_func
    rjmp no_func

    rjmp calc_pop
    rjmp no_func
    rjmp calc_push
    rjmp no_func

    rjmp kp_mode_change
    rjmp kp_mode_change
    rjmp kp_mode_change
    rjmp kp_mode_change

functions_table_misc2:

    rjmp no_func

    rjmp show_top
    rjmp show_sp
    rjmp no_func
    rjmp no_func

    rjmp no_func
    rjmp no_func
    rjmp no_func
    rjmp no_func

    rjmp no_func
    rjmp no_func
    rjmp no_func
    rjmp no_func

    rjmp calc_pop
    rjmp test_func
    rjmp calc_push
    rjmp no_func

    rjmp kp_mode_change
    rjmp kp_mode_change
    rjmp kp_mode_change
    rjmp kp_mode_change




