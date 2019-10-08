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

.global empty_stack_error
empty_stack_error:
    
    rcall LCD_clear
    loadw_z(se_err_msg)
    loadw_x(TEMP_RAM)
    loadw_24(TEMP_RAM)
    rcall strlpm
    rcall LCD_print

    rcall waitforinput
rjmp vm_loop
    

.global stack_overflow_error
stack_overflow_error:
    loadw_24(TEMP_RAM -1)       ; load first stack bottom into stack pointer to reset
    out STPTL, r24
    out STPTH, r25
    movw stack_bottomL, r24

    rcall LCD_clear
    loadw_z(so_err_msg)
    loadw_x(TEMP_RAM)
    loadw_24(TEMP_RAM)
    rcall strlpm
    rcall LCD_print

    rcall waitforinput
rjmp vm_loop

