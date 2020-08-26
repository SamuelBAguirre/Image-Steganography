.cpu cortex-a53
.fpu neon-fp-armv8

.data

.text
.align 2
.global write_image
.type write_image, %function

write_image:
    push {fp, lr}
    add fp, sp, #4

    @ store the values from volatile registers onto the stack
    push {r0, r1, r2, r3}

    @ fseek(fpin, 0, SEEK_SET)
    mov r1, #0
    mov r2, #0  @ SEEK_SET = 0
    ldr r0, [fp, #-20]  @ load fpin --> r0
    bl fseek

    @ copy header from fpin --> fpout
    // for (i = 0; i < offset; i++)
    ldr r10, [fp, #20]  @ loads offset --> r10
    mov r9, #0  @ r9 = i

    loop_header:
        @ check if i < offset
        cmp r9, r10
        bge done_loop_header
        @ temp = fgetc(fpin)
        ldr r0, [fp, #-20]  @ loads fpin --> r0
        bl fgetc

        @ fputc(temp, fpout)
        ldr r1, [fp, #16]  @ loads fpout --> r1
        bl fputc

        @ i = i+1
        add r9, r9, #1
     b loop_header

     done_loop_header:

     @ write B, G, R --> fpout
     @ for (r = 0; r < height; r++)
     @    for (c = 0; c < width; c++)

     mov r10, #0  @ r10 = r
     
     loop_height:
         ldr r0, [fp, #4]  @ load height --> r0
         cmp r10, r0  @ r < height
         bge done_loop_height

         mov r9, #0  @ r9 = c

         loop_width:
             ldr r0, [fp, #8]  @ loads width -> r0
             cmp r9, r0        @ c < width
             bge done_loop_width

             @ temp = *(B + r*width +c)
             ldr r1, [fp, #8]  @ loads width -> r1
             mul r1, r1, r10   @ r1 = width*r
             add r1, r1, r9    @ r1 = width*r + c

             @ load B --> r2
             ldr r2, [fp, #-16]  @ r2 <-- B

             @ copy memory offset into r8
             mov r8, r1 

             @ fputc(temp, fpout)
             ldrb r0, [r2, r8]  @ r0 = *(B + r*width + c)
             ldr r1, [fp, #16]  @ r1 = fpout
             bl fputc           @ fputc(temp)

             @@@@@@ Do the same for G
             ldr r2, [fp, #-12] @ r2 <- G
            
             ldrb r0, [r2, r8]  @ r0 = *(G + r*width + c)
             ldr r1, [fp, #16]  @ r1 = fpout
             bl fputc           @ fputc(temp)

             @@@@@@ Do the same for R
             ldr r2, [fp, #-8]  @ r2 = R

             ldrb r0, [r2, r8]  @ r0 = *(R + r*width + c)
             ldr r1, [fp, #16]  @ r1 = fpout
             bl fputc           @ fputc(temp)

             @ c = c + 1
             add r9, r9, #1
         b loop_width

         done_loop_width:
         @ fill out padding char with blanks

         mov r9, #0
         @ for (i = 0; i < padding; i++)

         loop_padding:
             ldr r0, [fp, #12]   @ r0 <- padding
             cmp r9, r0          @ i < padding
             bge done_loop_padding

             @ fputc(' ', fpout)
             mov r0, #0x20
             ldr r1, [fp, #16]   @ r1 = fpout
             bl fputc
 
             add r9, r9, #1
         b loop_padding

         done_loop_padding:
 
             add r10, r10, #1
     b loop_height

     done_loop_height:

     sub sp, fp, #4
     pop {fp, pc}

@ Done write_image
