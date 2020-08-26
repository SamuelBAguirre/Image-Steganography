.cpu cortex-a53
.fpu neon-fp-armv8

.data

.text
.align 2
.global read_int
.type read_int, %function

read_int:
    push {fp, lr}
    add fp, sp, #4

    @ fp --> r0 and sbyte --> r1
    mov r10, r0  @ r10 <-- fp
    mov r9, r1   @ r9 <-- sbyte

    @ int value = 0
    mov r8, #0  @ r8 = value

    @ use r7 as the loop counter:  r7 = i
    mov r7, #0

    @ set up fseekL  fseek(fp, sbyte, SEEK_SET)
    mov r0, r10
    mov r1, r9
    mov r2, #0  @ SEEK_SET = 0
    bl fseek

    loop_readint:
       cmp r7, #4  @ i < 4
       bge done_loop_readint

       @ c = fgetc(fp)
       mov r0, r10  @ r0 <-- fp
       bl fgetc     @ char c --> r0

       @ calculate the shift = 8*i
       mov r1, #8
       mul r1, r1, r7  @ r1 = 8*r7

       @ value = value + (int)c << shift 
       add r8, r8, r0, LSL r1

       @ i = i + 1
       add r7, r7, #1

    b loop_readint

    done_loop_readint:

    @ return value to the calling function
    mov r0, r8   @ r0 <-- r8 for returning

    sub sp, fp, #4
    pop {fp, pc}
