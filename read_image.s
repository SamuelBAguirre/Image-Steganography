.cpu cortex-a53
.fpu neon-fp-armv8

.data

.text
.align 2
.global read_image
.type read_image, %function

read_image:
    push {fp, lr}
    add fp, sp, #4

    @ fpin --> r0,  B --> r1,  G --> r2, R --> r3
    @ height, width, padding are on stack
    @ push r0, r1, r2, r3 --> stack
    
    push {r3, r2, r1, r0}

    @ for (int r = 0; r < height; r++)
    mov r9, #0   @ r9 <-- r

    loopr:
       @ Get height into r0 -- temp register
       ldr r0, [fp, #4]  @ load height --> r0
       cmp r9, r0   @ r < height
       bge end_loopr

       @ r8 <-- c
       mov r8, #0
       @ for (int c = 0; c < width; c++)
       
       loopc:
          ldr r0, [fp, #8]  @ loads width --> r0
          cmp r8, r0  @ c < width
          bge end_loopc

          @ *(B + r*width + c) = (unsigned char)(fgetc(fpin));
          @ fgetc(fpin --> char
          @ 1. load r0, fpin
          ldr r0, [fp, #-20]  @ r0 = fpin
          bl fgetc  @ reads a char into r0

          @ char read from file --> r0
          @ *(B + r*width + c)
          @ *(B + r9*width + r8)

          ldr r1, [fp, #8]  @ loads width into r1
          mul r1, r9, r1  @ r1 = r*width = r1*r9
          add r1, r1, r8  @ r1 = r*width + c
          ldr r2, [fp, #-16]  @ loads r2 <-- B
          @ *(r2 + r1) = r0
          @ *(B + r*width + c) = fgetc(fpin)
          strb r0, [r2, r1]

          @ *(G + r*width + c) = fgetc
          @ Repeat the procedure for Green

          ldr r0, [fp, #-20]  @ r0 <-- fpin
          bl fgetc  @ reads a char into r0

          @ *(G + r*width + c)
          ldr r1, [fp, #8]  @ width --> r1
          mul r1, r1, r9    @ r1 = r9*width = r*width
          add r1, r1, r8    @ r1 = r*width + c
          
          ldr r2, [fp, #-12]  @ r2 <-- G
          strb r0, [r2, r1]   @ *(G + r1) = r0

          @ Repeat the process for R
          ldr r0, [fp, #-20]
          bl fgetc
 
          @ *(R + r*width + c) = fgetc
          ldr r1, [fp, #8]  @ width --> r1
          mul r1, r1, r9
          add r1, r1, r8

          ldr r2, [fp, #-8]  @ r2 <-- R
          strb r0, [r2, r1]   @ *(R + r1) = r0

          add r8, r8, #1  @ c = c + 1

          b loopc

       end_loopc:

       @ fseek(fpin, padding, SEEK_CUR)
       @ SEEK_SET = 0, SEEK_CUR = 1, SEEK_END = 2
 
       ldr r0, [fp, #-20]  @ r0 <-- fpin
       ldr r1, [fp, #12]   @ r1 <-- padding
       mov r2, #1         @ r2 = SEEK_CUR
          
       bl fseek

       add r9, r9, #1  @ r = r + 1

       b loopr
    
    end_loopr:

    @ calculate the size
    @ size = R[0] << 16 + G[0] << 8 + B[0]
    @ step 1: r0 = B[0]
    @ step 2: r0 = r0 + G[0] << 8
    @ step 3: r0 = r0 + R[0] << 16

    @ step 1
    ldr r2, [fp, #-16]  @ r2 <-- B
    ldrb r0, [r2]        @ r0 = *B = B[0]

    @ step 2
    ldr r2, [fp, #-12]  @ r2 <-- G
    ldrb r2, [r2]        @ r2 = G[0]

    add r0, r0, r2, LSL #8  @ r0 = r0 + r2 << 8

    @ step 3
    ldr r2, [fp, #-8]  @ r2 <-- R
    ldrb r2, [r2]        @ r2 = R[0]

    add r0, r0, r2, LSL #16  @ r0 = r0 + r2 << 16

    @ return the value of r0 = size

    sub sp, fp, #4
    pop {fp, pc}
