.cpu cortex-a53
.fpu neon-fp-armv8

.data
    .equ KEY, 123456

.text
.align 2
.global decoder
.type decoder, %function




decoder: 

       push {fp, lr}
       add fp, sp, #4

       push {r0, r1, r2, r3}

       @srand(KEY), reset the random number generate to KEY
       mov r0, #123
       mov r1, #100
       mul r0, r0, r1
       mov r1, #10
       mul r0, r0, r1
       mov r1, #456
       add r0, r0, r1
       bl srand


       @forloop counter
       mov r5, #0

       


       forloop:


               ldr r0, [fp, #12] @ r0 = size
               cmp r5, r0
               bge doneloop

               @load registers for rand(), height, and width
               bl rand
               ldr r1, [fp, #-8] @r1 = height 
               ldr r2, [fp, #4] @r2 = width

               @pixel_ind = (rand() % (height*width -1)) + 1;
               
               @height*width - 1
               mul r1, r1, r2
               sub r1, r1, #1
               @rand() % (height*width - 1)
               bl modulo

               @rand() % (height*width - 1) + 1
               add r0, r0, #1
               mov r6, r0 @r6 = (rand() % (height*width-1)) + 1 = pixel_ind

               @load registers for rand()
               bl rand

               mov r1, #3 @r1 = 3
              
               @color_ind = (rand() % 3)
               bl modulo
               
               add r7, r0, #1 @r7 = (rand()%3) + 1 = color_ind

               ldr r1, [fp, #8] @r1 = message
               add r1, r1, r5 @r1 = message + i 
 

               @if(color_ind == 1)
               cmp r7, #1
               bne not_equalB

               ldr r0, [fp, #-20] @r0 = B;
               add r6, r6, r0 @(B + pixel_ind);
               ldrb r6, [r6] @*(B + pixel_ind)

               @*(message + i) = *(B + pixel_ind);
               str r6, [r1]
       
               b increment
               
               
               not_equalB:
               
                         @if(color_ind == 2)
                         cmp r7, #2
                         bne not_equalG
         
                         ldr r0, [fp, #-16] @r0 = G;
                         add r6, r6, r0 @(G + pixel_ind);
                         ldrb r6, [r6] @*(G + pixel_ind)

                         @*(message + i) = *(G + pixel_ind);
                         str r6, [r1]
 
                         b increment

                not_equalG: 
 
                         @else

                         ldr r0, [fp, #-12] @r0 = R;
                         add r6, r6, r0 @(R + pixel_ind);
                         ldrb r6, [r6] @*(R + pixel_ind)

                         @*(message + i) = *(R + pixel_ind);
                         str r6, [r1]

                         b increment


              increment: 

               
                         add r5, r5, #1
                         b forloop
                        
                         
                     

        doneloop:
  
               @*(message + size) = '\0';
               ldr r0, [fp, #8]
               ldr r1, [fp, #12]

               add r0, r0, r1 @ message + size
               ldr r0, [r0] @*(message + size)

               mov r0, #0
               

               sub sp, fp, #4
               pop {fp,pc} 


   


       
       

