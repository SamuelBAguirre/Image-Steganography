.cpu cortex-a53
.fpu neon-fp-armv8

.data

.text
.align 2
.global encode_image
.type encode_image, %function

encode_image:
  push {fp, lr}
  add fp, sp, #4

ldr r7, [fp, #8]

  @ store the values from volatile registers onto the stack
  push {r0, r1, r2, r3}
  
  @srand(123456)
  mov r0, #123
  mov r1, #100
  mul r0, r0, r1 @r0 = 12300
  mov r1, #10 @r0 = 123000
  mul r0, r0, r1
  mov r1, #228
  mov r1, r1, LSL #1 @r1 = 456
  add r0, r0, r1 @r0 = 123456
  bl srand

  @int length = strlen(message);
  ldr r0, [fp, #8]
  bl strlen
  push {r0} @push length of message onto stack

  @unsigned char len[3];
  mov r0, #12
  sub sp, sp, r0
  
  @len[0] = (unsigned char)(length % 256);
  ldr r0, [fp, #-24] @ r0 = length of message
  mov r1, #256
  bl modulo @(length % 256)
  str r0, [fp, #-28] @len[0] = (length % 256)

  @len[1] = (unsigned char)((length >> 8) % 256);
  ldr r0, [fp, #-24] @ r0 = length of message
  mov r0, r0, LSR #8 @(length >> 8)
  mov r1, #256
  bl modulo @((length >> 8) % 256)
  str r0, [fp, #-32] @len[1] = ((length >> 8) % 256)

  @len[2] = (unsigned char)((length >> 16) % 256);
  ldr r0, [fp, #-24] @ r0 = length of message
  mov r0, r0, LSR #16 @(length >> 16)
  mov r1, #256
  bl modulo @((length >> 16) % 256)
  str r0, [fp, #-36] @len[1] = ((length >> 16) % 256)

  @B[0] = len[0];
  ldr r0, [fp, #-20] @r0 = B
  ldrb r1, [fp, #-28] @r1 = len[0]
  str r1, [r0] @B[0] = len[0]

  @G[0] = len[1];
  ldr r0, [fp, #-16] @r0 = G
  ldrb r1, [fp, #-32] @r1 = len[1]
  str r1, [r0] @B[0] = len[1]

  @R[0] = len[2];
  ldr r0, [fp, #-12] @r0 = R
  ldrb r1, [fp, #-36] @r1 = len[2]
  str r1, [r0] @B[0] = len[2]

push {r7}

  mov r9, #0 @int i = 0
  forloop:
    ldr r3, [fp, #-24] @r3 = length of message
    cmp r9, r3
    bge doneloop

    @c_char = message[i];    
    ldr r7, [fp, #-40] @r7 = message[0]
    add r7, r7, r9 @r7 = message[r9] = message[i] = c_char
    
    @index = rand() % (height*width - 1)  + 1;
    ldr r1, [fp, #-8] @r1 = height
    ldr r0, [fp, #4] @r0 = width
    mul r1, r1, r0 @r1 = height*width
    sub r8, r1, #1 @r8 = height*width - 1
    bl rand @r0 = rand()
    mov r1, r8 @r1 = height*width - 1
    bl modulo @r0 = rand() % (height*width - 1)
    add r8, r0, #1 @r8 = index

    @col = (rand() % 3) + 1;
    bl rand @r0 = rand()
    mov r1, #3
    bl modulo @r0 = rand() % 3
    add r10, r0, #1 @r10 = col

    @if (col == 1)
    cmp r10, #1
    bne not_equal1
      @B[index] = c_char;
      ldr r0, [fp, #-20] @r0 = B = B[0]
      add r0, r0, r8 @B[index]
      ldrb r7, [r7]
      strb r7, [r0] @B[index] = c_char
      b done_if
    not_equal1:

    @else if (col == 2)
    cmp r10, #2
    bne not_equal2
      @G[index] = c_char;
      ldr r0, [fp, #-16] @r0 = G = G[0]
      add r0, r0, r8 @G[index]
      ldrb r7, [r7]
      strb r7, [r0] @G[index] = c_char
      b done_if
    not_equal2:

    @else
      @R[index] = c_char;
      ldr r0, [fp, #-12] @r0 = R = R[0]
      add r0, r0, r8 @R[index]
      ldrb r7, [r7]
      strb r7, [r0] @R[index] = c_char

    done_if:

    add r9, r9, #1 @i++
    b forloop
  doneloop:

  mov r0, #0
  sub sp, fp, #4
  pop {fp, pc}

