/*
 * asm_utils.S
 *
 * Created: 2019-10-03
 *  Author: Patryk
 */

#include "../inc/macros.S"
#include "../inc/defines.S"

se_err_msg:
.asciz "STACK EMPTY"
.byte 0

so_err_msg:
.asciz "STACK OVERFLOW"

clear_line:
.asciz "                "
.byte 0

.global empty_stack_error
empty_stack_error:
    
    printstrpm se_err_msg 0
    ldi r24, 20
    rcall delay3B 
    printstrpm clear_line 0

rjmp vm_loop
    

.global stack_overflow_error
stack_overflow_error:
    loadw_24(TEMP_RAM -1)       ; load first stack bottom into stack pointer to reset
    out STPTL, r24
    out STPTH, r25
    movw stack_bottomL, r24

    printstrpm so_err_msg 0
    ldi r24, 20
    rcall delay3B 
    printstrpm clear_line 0

rjmp vm_loop

