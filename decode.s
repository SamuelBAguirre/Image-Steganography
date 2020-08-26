.cpu cortex-a53
.fpu neon-fp-armv8

.data
    
    rainbow_out: .asciz "rainbow_out.bmp"
    rb: .asciz "rb"
    output: .asciz "The hidden message is: %s\n"
    test: .ascii "%c"
@[^\n]

.text
.align 2
.global main
.type main, %function

main:
    push {fp, lr}
    add fp, sp, #4
    
    @FILE *fpin = fopen(fname, "rb")
    ldr r0, =rainbow_out
    ldr r1, =rb
    bl fopen

    @store file address
    mov r4, r0


    @filesize = read_int(fpin, 2)
    mov r0, r4
    mov r1, #2
    bl read_int
    push {r0}


    @offset = read_int(fpin, 10)
    mov r0, r4
    mov r1, #10
    bl read_int
    push {r0}


    @width = read_int(fpin, 18)
    mov r0, r4
    mov r1, #18
    bl read_int
    push {r0}


    @height = read_int(fpin, 22)
    mov r0, r4
    mov r1, #22
    bl read_int
    push {r0}


    @fseek(fpin, offset, SEEK_SET)
    mov r0, r4
    ldr r1, [fp, #-12]
    mov r2, #0 @SEEK_SET = 0?
    bl fseek


    @padding = (3*width)%4
    mov r0, #3
    ldr r1, [fp,#-16] @width
    mul r0, r0, r1 @3*width
    mov r1, #4
    bl modulo @(3*width) % 4
    
    cmp r0, #0
    bne not_equal
    b equal
    not_equal:
      @padding = 4 - padding
      mov r1, #4
      sub r0, r1, r0
      push {r0}
      b next
    equal:
    push {r0}
    next:
    
    @B = (unsigned char*) malloc(width*height)
    ldr r1, [fp, #-20] @height
    ldr r2, [fp, #-16] @width
    mul r0, r1, r2 @height*width
    bl malloc @r0 = malloc(height*width)
    push {r0} @store address of first memory location


    @G = (unsigned char*) malloc(width*height)
    ldr r1, [fp, #-20] @height
    ldr r2, [fp, #-16] @width
    mul r0, r1, r2 @height*width
    bl malloc @r0 = malloc(height*width)
    push {r0} @store address of first memory location

    @R = (unsigned char*) malloc(width*height) 
    ldr r1, [fp, #-20] @height 
    ldr r2, [fp, #-16] @width 
    mul r0, r1, r2 @height*width
    bl malloc @r0 = malloc(height@width)
    push {r0} @store address of first memory location


    @reorder top of the stack for function call to read_image
    ldr r0, [fp, #-24] @padding
    ldr r1, [fp, #-16] @width
    ldr r2, [fp, #-20] @height
    push {r0}
    push {r1}
    push {r2}

    @length = read_image(fpin, B, G, R, height, width, padding)
    mov r0, r4 @ fpin
    ldr r1, [fp, #-28] @B
    ldr r2, [fp, #-32] @G
    ldr r3, [fp, #-36] @R
    bl read_image

    @adds length to the stack
    push {r0}

    @message = (char *) malloc(length+1);
    add r0, r0, #1 @length + 1
    bl malloc @malloc(length+1)

    mov r5, r0 @ r5 = *message

    @reorder top stack
    ldr r1, [fp, #-16] @width
    push {r1, r5}


    @decode(B, G, R, height, width, message, length)
    ldr r0, [fp, #-28] @B
    ldr r1, [fp, #-32] @G
    ldr r2, [fp, #-36] @R
    ldr r3, [fp, #-20] @height
    bl decoder

@    mov r7, #0
@    loop:
@      cmp r7, #14
@      bge doneloop   
@      ldr r8, [r5, r7]      
@      ldr r0, =test
@      mov r1, r8
@      bl printf
@      add r7, r7, #1
@      b loop
doneloop:

    @printf("The hidden message is: %s\n", message);
    ldr r1, [fp, #-56]
    ldr r0, =output
    bl printf

    @fclose(fpin);
    mov r0, r4
    bl fclose

    mov r0, #0
    sub sp, fp, #4
    pop {fp, pc}
    
    


    
    
    
