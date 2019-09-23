/*
 * asm_utils.S
 *
 * Created: 2019-09-22
 *  Author: Patryk
 */


/**
* loads string in program memory into ram
* xl, xh - ram location
* zl, zh - pm location
* NOTE: to load z use lo8, hi8 macros (pm_lo8, pm_hi8 doesn't work)
*/
.global strlpm
strlpm: 
    push r24

    strlpm_loop:
        lpm r24, z+
        st x+, r24
        tst r24
        breq strlpm_end
        rjmp strlpm_loop
    strlpm_end:

    pop r24
    ret

.global tostr
tostr:  ; 1 byte for now r24 destination pointer in x
    ; need div func
    ret

/**
* divides r24 by r22
* result in r24
* rest in r22
*/
.global div1B
div1B:
    push r23  
    push r21

    ldi r23, 1 ; temp 
    clr r21    ; result register
    cp r24, r22 ; return if r24 < r22
    brlo div1B_loop_ext


    div1B_loop1: ;shift left r22 and r23 while r22<r24
        cp r24, r22;
        brlo div1B_loop2
        lsl r23
        lsl r22
        rjmp div1B_loop1
    div1B_loop2:
        cp r24,r22      ; if r22 > r24 skip to shifting
        brlo div1B_shift
        sub r24, r22   ; subracting divident
        add r21, r23   ; add tem to result
        div1B_shift:
        lsr r22
        lsr r23
        breq div1B_loop_ext; if temp (r23) = 0 then end div1B_loop1
        rjmp div1B_loop2
    div1B_loop_ext:

    mov r22, r24
    mov r24, r21

    pop r21
    pop r23
    ret



    






