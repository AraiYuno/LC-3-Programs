;Keyboard interrupt test
;Each time a key is pressed, the character with ASCII code one higher will be echoed
;Pretty standard code that waits for interrupts and then processes them.


  .orig x3000

;this is the main line
Main
  LD  R6,STACKBASE   ;set up user stack (MUST be done)

  LEA R0,KBHandler    
  LD  R1,KBVEC
  STR R0,R1,#0       ;set kb interrupt vector

  LD  R0,KBEN        ;enable keyboard interrupt
  STI R0,KBSR

Loop
  AND R5, R5, #0
  ADD R5, R2, #0
  ADD R5, R5, #-5
  ADD R5, R5, #-5
  BRnp  Loop           ;loop forever!


  LEA R0, EOP
  PUTS
  HALT
  
;---------------------------------------------------------------
;Keyboard interrupt handler (no need for Frame pointer)
KBHandler
  ADD R6,R6,#-1    ;save R0
  STR R0,R6,#0
  ADD R6,R6,#-1    ;save R1
  STR R1,R6,#0

  LDI R0,KBDR      ;get key
  AND R2, R2, #0
  LD R2, Enter
  ADD R2, R0, R2 ;check for the enter key
  BRz finish
  ADD R0,R0,#1     ;add one to the key's ASCII code

WaitToWrite
  LDI R1,DSR       ;get console output status
  BRzp  WaitToWrite

  STI R0,DDR       ;write new character to console

finish
  AND R2, R2, #0
  ADD R2, R0, #0

  LDR R1,R6,#0     ;restore register values
  ADD R6,R6,#1

  LDR R0,R6,#0
  ADD R6,R6,#1

  RTI              ;return from interrupt


STACKBASE .FILL x4000 ;stack base (can be changed)
KBSR  .FILL xFE00     ;keyboard status register
KBDR  .FILL xFE02     ;keyboard data register 
DSR .FILL xFE04       ;console status register
DDR .FILL xFE06       ;console data register 

Enter .FILL #-10      ;enter key
EOP   .STRINGZ "\nEnd of Program\n"


KBEN  .FILL x4000     ;use to enable keyboard interrupt
KBVEC .FILL x0180     ;keyboard vector number/location

  .END