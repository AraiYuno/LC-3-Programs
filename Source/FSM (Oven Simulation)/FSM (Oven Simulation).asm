;======================================================================================================
;A4Q2
;Author: Kyle Seokjin Ahn
;Student#: 7794966
;Professor: John Braico
;
;Description: This program simulates the microwave using the concept of FSM. This program uses an interrupt
;             handler to accept user input infinitely, and tracks the state using hard-coded linkedlist.
;                 
;             The length of the list is 12 since my graph consists of 12 states. The program is initated with
;             state of "READY" initially using LEA, READY. 
;
;             The structure of each node in the list is as follows.
;             struct Node {
;  		short strOutput// though we only use unsigned values
;  		struct Node *UP;
;               struct Node *DOWN;
;               struct NODE *START;
;               struct NODE *CANCEL;
;               struct NODE *COUNT;
;             };
;
;             The program should technically never end.
;=======================================================================================================
; Registers Dictionary
; R0 - Enable keyboard interrupt
; R1 - KBVEC
; R3 - Pointer to the head of the list (in Main)
; 

  .orig x3000

;this is the main line
Main
  LD  R6,STACKBASE   ;set up user stack (MUST be done)

  LEA R0,KBHandler    
  LD  R1,KBVEC
  STR R0,R1,#0       ;set kb interrupt vector

  LD  R0,KBEN        ;enable keyboard interrupt
  STI R0,KBSR

  AND R3,R3,#0
  LEA R3,A          ; starting with state A = READY

Loop
  BR  Loop           ;loop forever!

  LEA R0, EOP
  PUTS
  HALT
  
;---------------------------------------------------------------
;Keyboard interrupt handler (no need for Frame pointer)
; KBHandler
;   takes in the keyboard input from the user, and simulates FSM 
;   for a microwave.
;---------------------------------------------------------------
; Registers Dictionary
; R0 - I/O
; R2 - input comparison
; R3 - pointer to the LinkedList
KBHandler
  ADD R6,R6,#-1    ;save R0
  STR R0,R6,#0
  ADD R6,R6,#-1    ;save R1
  STR R1,R6,#0

  LDI R0,KBDR      ;get command amongst UP, DOWN, START, CANCEL, COUNT
  LD  R2,UP        ;Check if the input is UP
  ADD R2,R0,R2     
  BRz isUP

  LD  R2,DOWN     ;check if the input is DOWN
  ADD R2,R0,R2    ;
  BRz isDOWN

  LD  R2,START    ;check if the input is START
  ADD R2,R0,R2
  BRz isSTART

  LD  R2,CANCEL   ;check if the input is CANCEL
  ADD R2,R0,R2
  BRz isCANCEL

  LD  R2,COUNTdown ;check if the input is COUNTdown
  ADD R2,R0,R2  
  BRz isCOUNTdown
  
  AND R0,R0,#0     ;if reaches here, it means the input is an invalid one.
  BRnzp isInvalidInput

isUP
  LDR R3,R3,#1    ;transition of the state for UP
  LDR R0,R3,#0    ;to get the display message for the current state
  BRnzp toNextState  

isDOWN
  LDR R3,R3,#2    ;transition of the state for DOWN
  LDR R0,R3,#0    ;to get the display message for the current state
  BRnzp toNextState  

isSTART
  LDR R3,R3,#3    ;transition of  the state for START
  LDR R0,R3,#0    ;to get the display message for the current state
  BRnzp toNextState

isCANCEL
  LDR R3,R3,#4    ;transition of the state for CANCEL input
  LDR R0,R3,#0	  ;to get the display message for the current state
  BRnzp toNextState

isCOUNTdown
  LDR R3,R3,#5    ;transition of the state for COUNTdown input
  LDR R0,R3,#0    ;to get the display message for the current state
  BRnzp toNextState

isInvalidInput
  LEA R0,INVALID
  PUTS  
  BRnzp finish

toNextState
  AND R2,R2,#0
  PUTS

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

; definition of inputs for FSM
UP	.FILL #-97     ;represented by ASCII character 'a'
DOWN    .FILL #-122    ;represented by ASCII character 'z'
START   .FILL #-115    ;represented by ASCII character 's'
CANCEL  .FILL #-120    ;represented by ASCII character 'x'
COUNTdown .FILL #-32     ;represented by ASCII character ' '

; States are represented between A~M since there are 12 states in my graph.
; State transitions are represented as LinkedList in sequence of UP, DOWN, START, CANCEL, COUNT
A	.FILL READY     ;representing A
	.FILL B		;UP
	.FILL A		;DOWN
	.FILL A		;CANCEL
	.FILL A		;COUNT
READY   .STRINGZ "READY\n" 
INVALID .STRINGZ "Invalid Input!"

B	.FILL oneMIN  
	.FILL C		;UP
	.FILL A		;DOWN
	.FILL I		;START
	.FILL A		;CANCEL
	.FILL B		;COUNT
oneMIN  .STRINGZ "1 MIN\n"

C	.FILL twoMINS
	.FILL D		;UP
	.FILL B		;DOWN
	.FILL J		;START
	.FILL A		;CANCEL
	.FILL C		;COUNT
twoMINS .STRINGZ "2 MINS\n"
 
D	.FILL threeMINS
	.FILL E		;UP
	.FILL C		;DOWN
	.FILL K		;START
	.FILL A		;CANCEL
	.FILL D		;COUNT
threeMINS .STRINGZ "3 MINS\n"

E	.FILL fourMINS
	.FILL F		;UP
	.FILL D		;DOWN
	.FILL L		;START
	.FILL A		;CANCEL
	.FILL E		;COUNT
fourMINS .STRINGZ "4 MINS\n"

F	.FILL fiveMINS
	.FILL F		;UP
	.FILL E		;DOWN
	.FILL M		;START
	.FILL A		;CANCEL
	.FILL F		;COUNT
fiveMINS .STRINGZ "5 MINS\n"

H	.FILL DONE	;DONE
	.FILL B		;UP
	.FILL A		;DOWN
	.FILL A		;START
	.FILL A		;CANCEL
	.FILL H		;COUNT
DONE    .STRINGZ "DONE\n"

I	.FILL oneMIN
	.FILL I		;UP
	.FILL I		;DOWN
	.FILL I		;START
	.FILL A		;CANCEL
	.FILL H		;COUNT 

J	.FILL twoMINS
	.FILL J		;UP
	.FILL J		;DOWN
	.FILL J		;START
	.FILL A		;CANCEL
	.FILL I		;COUNT

K	.FILL threeMINS
	.FILL K		;UP
	.FILL K		;DOWN
	.FILL K		;START
	.FILL A		;CANCEL
	.FILL J		;COUNT

L	.FILL fourMINS
	.FILL L		;UP
	.FILL L		;DOWN
	.FILL L		;START
	.FILL A		;CANCEL
	.FILL K		;COUNT

M	.FILL fiveMINS
	.FILL M		;UP
	.FILL M		;DOWN
	.FILL M		;START
	.FILL A		;CANCEL
	.FILL L		;COUNT


Enter .FILL #-10      ;enter key
EOP   .STRINGZ "\nEnd of Program\n"


KBEN  .FILL x4000     ;use to enable keyboard interrupt
KBVEC .FILL x0180     ;keyboard vector number/location

  .END