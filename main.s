.cpu cortex-a53
.fpu neon-fp-armv8

.data
rainbow: .asciz "rainbow2.bmp"
rb: .asciz "rb"
rainbow_out: .asciz "rainbow_out.bmp"
wb: .asciz "wb"
message: .asciz "The covid19 pandemic sucks!"

.text
.align 2
.global main
.type main, %function

main:
  
  push {fp, lr}
  add fp, sp, #4
  mov r6, lr @lr was lost somehow and this is saving it

  @ fpin=fopen(ifile, "rb")
  ldr r0, =rainbow
  ldr r1, =rb
  bl fopen

  @store file address
  mov r4, r0

  ldr r0, =rainbow_out
  ldr r1, =wb
  bl fopen
  mov r5, r0

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

  @@fseek(fpin, offset, SEEK_SET)
  @@file address + offset == first pixel
  @@ldr r1, [fp, #-12]
  @@add r4, r4, r1

  @fseek(fpin, offset, SEEK_SET)
  mov r0, r4
  ldr r1, [fp, #-12]
  mov r2, #0 @SEEK_SET = 0
  bl fseek

  @padding = (3*width) % 4;
  mov r0, #3
  ldr r1, [fp, #-16] @width
  mul r0, r0, r1 @3*width
  mov r1, #4
  bl modulo @(3*width) % 4

  @padding = 4 - padding;
  mov r1, #4
  sub r0, r1, r0
  push {r0}
  
  @B = (unsigned char *) malloc(width*height);
  ldr r1, [fp, #-20] @height
  ldr r2, [fp, #-16] @width
  mul r0, r1, r2 @height*width
  bl malloc @ r0 = malloc(height*width)
  push {r0}  @ store address of first memory location

  @G = (unsigned char *) malloc(width*height);
  ldr r1, [fp, #-20] @height
  ldr r2, [fp, #-16] @width
  mul r0, r1, r2 @height*width
  bl malloc @ r0 = malloc(height*width)
  push {r0}  @ store address of first memory location

  @R = (unsigned char *) malloc(width*height);
  ldr r1, [fp, #-20] @height
  ldr r2, [fp, #-16] @width
  mul r0, r1, r2 @height*width
  bl malloc @ r0 = malloc(height*width)
  push {r0}  @ store address of first memory location
  
  @reorder top of stack for fucntion call to read_image
  ldr r0, [fp, #-16] @width
  ldr r1, [fp, #-20] @height
  ldr r2, [fp, #-24] @padding
  push {r2} @padding
  push {r0} @width
  push {r1} @height

  @read_image(fpin, B, G, R, height, width, padding);
  mov r0, r4 @fpin
  ldr r1, [fp, #-28] @B
  ldr r2, [fp, #-32] @G
  ldr r3, [fp, #-36] @R
  bl read_image

  @reorder top of stack for call to write_image
  ldr r0, [fp, #-24] @padding
  ldr r1, [fp, #-16] @width
  ldr r2, [fp, #-20] @height
  ldr r3, [fp, #-12] @offset
  push {r3} @offset
  push {r5} @fpout aka rainbow_out.bmp
  push {r0} @padding
  push {r1} @width
  push {r2} @height

  @char message[500] = "The covid19 pandemic sucks!";
  @create array of size 500, array[500]
  mov r0, #125 
  mov r0, r0, LSL #2 @r0 = 500 for a char array
  mov r0, r0, LSL #2 @500*4 bytes
  sub sp, sp, r0 

  ldr r0, [fp, #-32] @ this is the first element of array[500]
  ldr r1, =message @ this is the string "The covid19 pandemic sucks!"
  bl strcpy 

  @encode_image(B, G, R, height, width, message);
  ldr r0, =message
  @ldr r0, [fp, #-72] @load array into r0
  ldr r1, [fp, #-16] @width
  push {r0}
  push {r1}
  ldr r0, [fp, #-28] @B
  ldr r1, [fp, #-32] @G
  ldr r2, [fp, #-36] @R
  ldr r3, [fp, #-20] @height
  bl encode_image
  
  @write_image(fpin, B, G, R, height, width, padding, fpout, offset);
  sub sp, fp, #68 @ moves sp to the correct spot on the stack
  mov r0, r4 @fpin
  ldr r1, [fp, #-28] @B
  ldr r2, [fp, #-32] @G
  ldr r3, [fp, #-36] @R
  bl write_image

  @closing rainbow2.bmp
  mov r0, r4
  bl fclose

  @closing rainbow_out.bmp
  mov r0, r5
  bl fclose

  mov lr, r6 @restoring lr as a result of an earlier bug
  mov r0, #0
  sub sp, fp, #4
  pop {fp, pc}
  @pop {fp, pc}
  @pop {fp, lr}
  @ldr lr, [fp]
  @bx lr
  
  