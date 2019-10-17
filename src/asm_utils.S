/*
 * asm_utils.S
 *
 * Created: 2019-09-22
 *  Author: Patryk
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



.global printstrpm
printstrpm:
    push r24
    rcall LCD_setDDaddr
    printstrpm_loop:
        lpm r24, z+     // TODO + makro for const argument loading
        tst r24
        breq printstrpm_end
        rcall LCD_data
        rjmp printstrpm_loop
    printstrpm_end:

    pop r24
ret

/*
* 1 byte for now r24 destination pointer in x
*/
.global tostr1B
tostr1B:  
    push r24
    push r23
    push r22
    push xl
    push xh

    clr r23

    tostr1B_loop:
        ldi r22, 10
        tst r24
        breq tostr1B_loop_ext
        rcall div1B
        subi r22, -48
        push r22
        inc r23
        rjmp tostr1B_loop
    tostr1B_loop_ext:
        tst r23
        brne tostr1B_loop2
        ldi r24, 48
        st x+, r24
    tostr1B_loop2:
        tst r23
        breq tostr1B_ext
        dec r23
        pop r22
        st x+, r22
        rjmp tostr1B_loop2
    tostr1B_ext:
    st x+, r1

    pop xh
    pop xl
    pop r22
    pop r23
    pop r24
    ret

/*
*  converting r24:r25 into char string at x
*/

.global tostr2B 
tostr2B:
    push r24
    push r25
    push r23
    push r22
    push xl
    push xh

    clr r23
    tostr2B_loop:
        ldi r22,10
        cp r24,r1
        cpc r25,r1
        breq tostr2B_loop_ext
        rcall div2B
        subi r22, -48
        push r22
        inc r23
        rjmp tostr2B_loop
    tostr2B_loop_ext:
        tst r23
        brne tostr2B_loop2
        ldi r24, 48
        st x+, r24
    tostr2B_loop2:
        tst r23
        breq tostr2B_ext
        dec r23
        pop r22
        st x+, r22
        rjmp tostr2B_loop2
    tostr2B_ext:
    st x+, r1
    
    pop xh
    pop xl
    pop r22
    pop r23
    pop r25
    pop r24
    ret


/**
* divides r24 by r22
* result in r24
* rest in r22
*/
dividend = 24
divisor = 22
temp = 23
result = 21
iter = 20
.global div1B
div1B:
    push temp
    push result

    clr temp
    clr result

    ldi iter, 8
    div1B_loop:
        clc ; clear carry
        rol dividend ; rotate divident into temp
        rol temp
        brcs div1B_sub  ; if bit roled out of temp subrtract divisor
        cp temp, divisor;
        brlo div1B_nosub ; if temp >= divisor then subtract divisor
        div1B_sub:
            sub temp, divisor ; subtract divisor
            sec     ;set carry for result
            rjmp div1B_res
        div1B_nosub:
            clc ; clear cassy for result
        div1B_res:
        rol result  ; rotate carry into result    

        dec iter    ; after 8 loops end
        breq div1B_end
        rjmp div1B_loop
    div1B_end:

    mov dividend, result
    mov divisor, temp

    pop result
    pop temp
    ret


/**
* divides r25:r24 by r22
* result in r25:r24
* rest in r22
*/
divl = 24
divh = 25
divisor = 22
temp = 23
resl = 20
resh = 21
iter = 19
.global div2B
div2B:
    push temp
    push resl
    push resh
    push iter

    clr resl
    clr resh
    clr temp

    ldi iter, 16
    div2B_loop:
        clc
        rol divl
        rol divh
        rol temp
        brcs div2B_sub
        cp temp, divisor
        brlo div2B_nosub
        div2B_sub:
            sub temp, divisor
            sec
            rjmp div2B_res
        div2B_nosub:
            clc
        div2B_res:
        rol resl
        rol resh

        dec iter
        breq div2B_end
        rjmp div2B_loop
    div2B_end:

    movw divl, resl
    mov divisor, temp

    pop iter
    pop resh
    pop resl
    pop temp
    ret


/*
 * delay3B
 * does argument*131584 cylces (8Mhz - 1.64ms)
 * r24 - argument
 */

.global delay3B
delay3B:
    push r24
    push r25
    push r26
    push r27

    mov r27,r24

    clr r24
    clr r25
    clr r26

    delay3B_loop:
    inc r24
    brne delay3B_loop
    inc r25
    brne delay3B_loop
    inc r26
    cp r26, r27
    brne delay3B_loop

    pop r27
    pop r26
    pop r25
    pop r24

    ret

/*
 * waitforinput
 * waits for input
 */
.global waitforinput
waitforinput:
    push r24
    waitforinput_loop:
    ldi r24, 10
    rcall delay3B
    rcall kp_getkey
    tst r24
    breq waitforinput_loop
    ldi r24, 30
    pop r24
    ret


    






