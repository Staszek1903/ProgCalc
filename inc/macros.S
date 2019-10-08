/*
 * macros.S
 *
 * Created: 2019-10-03
 *  Author: Patryk
 */


#ifndef _MACROS_S_
#define _MACROS_S_

/* debug_reg
 * prints content of register in hexprint
 * reg - number of register
 * pos - lcd dd address
 */
.macro debug_reg reg pos
    push r24
    push r23
    mov r24, \reg
    ldi r23, \pos
    rcall hexprint
    pop r23
    pop r24
.endm


/*
 * loadw_24
 * loadw_x
 * loadw_y
 * loadw_z
 * load registers pairs with 16 bit constant word
 */
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

.macro printstrpm str pos
    push r24
    loadw_z \str
    ldi r24, \pos
    rcall printstrpm
    pop r24
.endm

#endif /* _MACROS_S_ */