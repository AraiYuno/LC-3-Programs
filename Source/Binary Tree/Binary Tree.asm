;=========================================================================================================
; Main
;
;  Description: This program accepts 5 single character input commands. 
;   I: Insertion -> you will be prompted for 4 digit 16bit positive hexadecimal integer to be inserted. 
;		    You must enter 0 for the first few digits if you want to enter lower integers. For ex)
;		    9 = 0 0 0 9	
;   R: Removal   -> You will be prompted for 4 digit 16 bit positive hexadecimal integer to be deleted from
;                   the tree. You must specify leading 0's just like Insertion
;   D: Depth     -> It will calculate and display the depth of the tree
;   P: Print     -> Print will list all of the nodes in order.
;   Q: Quit      -> Quit will halt the program
;
;   All the commands are implemented fully.
;=========================================================================================================
; R0 - I/O 
; R1 - pointer to the root of the tree
; R2 - Various AND and ADD for registers comparison
; R3 - Depth of the tree, and other returning values
; R6 - Stack
        .ORIG x3000

	LD   R6, StackBase	;initialise the stackbase 
	LEA  R1, ROOT            ;R1 = pointer to the root of the tree.
	LEA  R0, Welcome
	PUTS
LoopMain
	LEA R0, Command
	PUTS
	
	IN
	LD   R2, Q
	ADD  R2, R0, R2
	BRz  quitProgram

	LD   R2, P
	ADD  R2, R0, R2
	BRz  printTree

	LD   R2, I
	ADD  R2, R0, R2
	BRz  insertNode

	LD   R2, D
	ADD  R2, R0, R2
	BRz  calcDepth
	BRz  calcDepth

	LD   R2, R
	ADD  R2, R0, R2
	BRz  removeNode
	BRnzp LoopMain


printTree	
	ADD  R6, R6, #-1	;pass the current ROOT of the tree as a parameter.
	STR  R1, R6, #0
	JSR  InOrderTraversal
	ADD  R6, R6, #1 	
	BRnzp LoopMain

insertNode
	ADD  R6, R6, #-1         ;push one empty space for return value
	JSR  ReadHexInt
	LDR  R3, R6, #0

        ADD  R6, R6, #1  	; remove space from return value
	
	ADD  R6, R6, #-1        ;Pass the entered hex integer to the Insert subroutine
	STR  R3, R6, #0         ;
	LEA  R1, ROOT           ;Pass ROOT to the Insert subroutine
	ADD  R6, R6, #-1
	STR  R1, R6, #0
	ADD  R6, R6, #-1        ;push one empty space for the returning value
	JSR  Insert
	ADD  R6, R6, #3		;Clear pushed stack
	BRnzp LoopMain

calcDepth
	LEA  R1, ROOT		;Pass the root of the tree
	ADD  R6, R6, #-1
	STR  R1, R6, #0
	ADD  R6, R6, #-1	;Push one empty memory space for returning depth of the tree.
	JSR  CalculateDepth     
	LDR  R3, R6, #0		;R3 = depth of the tree
	ADD  R6, R6, #2		;Clear the stack
	LEA  R0, DepthIs
	PUTS
	ADD  R6, R6, #-1
	STR  R3, R6, #0   
	JSR  Print              ;Print the depth of the tree in hexadecimal integer
	ADD  R6, R6, #1
	BRnzp LoopMain

removeNode
	ADD  R6, R6, #-1         ;push one empty space for return value
	JSR  ReadHexInt
	LDR  R3, R6, #0

        ADD  R6, R6, #1 	 ; remove space from return value

	LEA  R1, ROOT
	ADD  R6, R6, #-1         ;pramaeter: node* currNode, int data
	STR  R1, R6, #0
	ADD  R6, R6, #-1
	STR  R3, R6, #0
	ADD  R6, R6, #-1	
	JSR  Remove
	LDR  R3, R6, #0          ;R3 = node that was removed.
	ADD  R6, R6, #3
	BRnzp LoopMain 

quitProgram	
	LEA R0, EOP
	PUTS

	HALT

Welcome .STRINGZ "Welcome to Kyle Ahn's binary tree program!\n"
EOP     .STRINGZ "End of Processing"
Command .STRINGZ "\nPlease enter a command character: "
DepthIs .STRINGZ "The depth of the tree in hexadecimal integer is "
Q       .FILL #-81
P	.FILL #-80
I	.FILL #-73
R       .FILL #-82
D       .FILL #-68

StackBase .FILL x4000

ROOT    .FILL x2280
        .FILL nodeA
        .FILL nodeB
nodeA   .FILL x9
        .FILL 0
        .FILL nodeC
nodeC   .FILL xABC
        .FILL 0
        .FILL 0
nodeB   .FILL x3000
        .FILL nodeD
        .FILL nodeE
nodeD   .FILL x2FFF
        .FILL 0
        .FILL 0
nodeE   .FILL x5555
        .FILL nodeF
        .FILL nodeG
nodeF   .FILL x3A0F
        .FILL 0
        .FILL 0
nodeG   .FILL x5EDE
        .FILL nodeH
        .FILL nodeI
nodeH   .FILL x5832
        .FILL 0
        .FILL 0
nodeI   .FILL x6123
        .FILL 0
        .FILL nodeJ
nodeJ   .FILL x6125
        .FILL nodeK
        .FILL 0
nodeK   .FILL x6124
        .FILL 0
        .FILL 0

;=========================================================================================================
; Remove
;	params: CurrentNode( Root initially ), int data 
;
;	removes the node that has the same data as given data, and returns the removed node.
;=========================================================================================================
; Registers Dictionary
;
;
Remove
	ADD  R6, R6, #-1 ; push FP
        
	STR  R5, R6, #0
        
        
	ADD  R5, R6, #1 ; update FP (point it to the old top of stack)
     
   
        
	ADD  R6, R6, #-1 ; push R1
	STR  R1, R6, #0

	ADD  R6, R6, #-1 ; push R2

        STR  R2, R6, #0	

	ADD  R6, R6, #-1 ; push R3
        STR  R3, R6, #0	

	ADD  R6, R6, #-1 ; push R4
        STR  R4, R6, #0	
	 
	ADD  R6, R6, #-1 ; push R7
        STR  R7, R6, #0	


	LDR  R1, R5, #2  ;R1 = pointer to the current node
	BRz  isNullReturn
	LDR  R2, R1, #0  ;R2 = curr.data
	LDR  R3, R5, #1  ;R3 = pData (parameter)
	NOT  R2, R2
	ADD  R2, R2, #1	 ;
	ADD  R0, R2, R3  ; 
	BRz  isEqual

	ADD  R0, R0, #0  ;
	BRp  keyIsLarger

	LDR  R2, R1, #1          ;R2 = curr.left
	ADD  R6, R6, #-1         ;pramaeter: node* currNode, int data
	STR  R2, R6, #0
	ADD  R6, R6, #-1
	STR  R3, R6, #0
	ADD  R6, R6, #-1	
	JSR  Remove
	LDR  R7, R6, #0          ;R3 = node that was removed.
	ADD  R6, R6, #3
	STR  R7, R1, #1		 ;curr.left = remove(curr->left, pData);
	BRnzp isNullReturn
keyIsLarger
	LDR  R2, R1, #2		;R2 = curr.right
	ADD  R6, R6, #-1
	STR  R2, R6, #0
	ADD  R6, R6, #-1
	STR  R3, R6, #0
	ADD  R6, R6, #-1
	JSR  Remove
	LDR  R7, R6, #0
	ADD  R6, R6, #3		
	STR  R7, R1, #2		;curr->right = remove( curr->right, pData );
	BRnzp isNullReturn
		

isEqual ;in case that curr.data = pData 
	LDR  R2, R1, #1        ;R2 = curr->left
	BRnp elseIfRightIsNull ;if(curr->left == NULL)
	LDR  R4, R1, #2        ;  R4(tempNode) = curr->right
	AND  R0, R0, #0
	STR  R0, R1, #0        ;free(curr)
	ADD  R1, R4, #0        ;R1 = tempNode
	BRnzp isNullReturn

elseIfRightIsNull
	LDR  R2, R1, #2        ;R2 = curr->right
	BRnp bothNotNull       ;if(curr->right == NULL)
	LDR  R4, R1, #1	       ;  R4(tempNode) = curr->left;
	AND  R0, R0, #0
	STR  R0, R1, #0	       ;free(curr)
	ADD  R1, R4, #0        ;R1 = tempNode
	BRnzp isNullReturn

bothNotNull
	ADD  R6, R6, #-1
	LDR  R0, R5, #2        ;R0 = pointer to curr
	LDR  R0, R0, #2	       ;R0 = curr->right
	STR  R0, R6, #0
	ADD  R6, R6, #-1       ;push one space for returning node
	JSR  GetMinValueNode
	LDR  R7, R6, #0        ;R7 = minNodeValue
	ADD  R6, R6, #2
	AND  R4, R4, #0
	ADD  R4, R7, #0        ;R4 = pointer to tempNode(minNodeValue)
	
	LDR  R0, R5, #2     
	LDR  R2, R4, #0        ;R2 = minNodeValue 
	STR  R2, R0, #0        ;curr->data = minNode->data
	
	LDR  R2, R0, #2        ;R2 = curr->right
	ADD  R6, R6, #-1
	STR  R2, R6, #0
	LDR  R2, R4, #0        ;R2 = minNodeValue
	ADD  R6, R6, #-1
	STR  R2, R6, #0
	ADD  R6, R6, #-1
	JSR  Remove
	LDR  R7, R6, #0
	ADD  R6, R6, #3
	LDR  R0, R5, #2        ;R0 = currNode
	STR  R7, R0, #2        ;currNode->Right = Remove(currNode->right, minNode->data);
	LDR  R1, R5, #2        ;R1 = currNode

isNullReturn
	STR  R1, R5, #0   

	LDR  R7, R6, #0  ; pop R3

        ADD  R6, R6, #1
	
	LDR  R4, R6, #0  ; pop R3

        ADD  R6, R6, #1

	LDR  R3, R6, #0  ; pop R3

        ADD  R6, R6, #1


        
LDR  R2, R6, #0  ; pop R2

        ADD  R6, R6, #1
        
  

        LDR  R1, R6, #0  ; pop R1
        ADD  R6, R6, #1
        
	LDR  R5, R6, #0  ; pop FP

        ADD  R6, R6, #1

	RET


;=========================================================================================================
; GetMinValueNode
;	params: CurrentNode ( Root initially )
;
;	returns the leftmost leaf (minimum value)
;=========================================================================================================
GetMinValueNode
	ADD  R6, R6, #-1 ; push FP
        
	STR  R5, R6, #0
        
        
	ADD  R5, R6, #1 ; update FP (point it to the old top of stack)
     
   
        
	ADD  R6, R6, #-1 ; push R1
	STR  R1, R6, #0

	ADD  R6, R6, #-1 ; push R2

        STR  R2, R6, #0	

	ADD  R6, R6, #-1 ; push R3
        STR  R3, R6, #0	

	ADD  R6, R6, #-1 ; push R4
        STR  R4, R6, #0	
	 
	ADD  R6, R6, #-1 ; push R7
        STR  R7, R6, #0	

	LDR  R1, R5, #1  ; R1 = currNode
	
whileNotNull
	AND  R2, R2, #0
	ADD  R2, R1, #0  
	LDR  R1, R1, #1  ; R2 = curr->left;
	BRnp whileNotNull 

	STR  R2, R5, #0  ; return minValueNode

	LDR  R7, R6, #0  ; pop R3

        ADD  R6, R6, #1
	
	LDR  R4, R6, #0  ; pop R3

        ADD  R6, R6, #1

	LDR  R3, R6, #0  ; pop R3

        ADD  R6, R6, #1


        
LDR  R2, R6, #0  ; pop R2

        ADD  R6, R6, #1
        
  

        LDR  R1, R6, #0  ; pop R1
        ADD  R6, R6, #1
        
	LDR  R5, R6, #0  ; pop FP

        ADD  R6, R6, #1

	RET

;=========================================================================================================
; CalculateDepth
;	params: CurrentNode ( Root initially )
;
;	calculates the maximum depth of the tree, and returns it.
;=========================================================================================================
; Registers Dictionary
; R1 - Pointer to the current node
; R2 - current depth
; R3 - curr.left
; R4 - curr.right
; R5 - FP
; R6 - Stack
;
CalculateDepth     
	ADD  R6, R6, #-1 ; push FP
        
	STR  R5, R6, #0
        
        
	ADD  R5, R6, #1 ; update FP (point it to the old top of stack)
     
   
        
	ADD  R6, R6, #-1 ; push R1
	STR  R1, R6, #0

	ADD  R6, R6, #-1 ; push R2

        STR  R2, R6, #0	

	ADD  R6, R6, #-1 ; push R3
        STR  R3, R6, #0	

	ADD  R6, R6, #-1 ; push R4
        STR  R4, R6, #0	
	 
	ADD  R6, R6, #-1 ; push R7
        STR  R7, R6, #0	

	LDR  R1, R5, #1  ;R1 = current node
	BRnp isNotNullNode ;if( curr == null ) return 0;
	AND  R2, R2, #0
	BRnzp returnDepth
isNotNullNode 
	LDR  R3, R1, #1		;R3 = pointer to curr.left
	ADD  R6, R6, #-1
	STR  R3, R6, #0
	ADD  R6, R6, #-1	;Push one empty memory space for returning depth of the tree.
	JSR  CalculateDepth     
	LDR  R3, R6, #0		;R3 = depth of the left child
	ADD  R6, R6, #2		;Clear the stack

	LDR  R4, R1, #2		;R3 = pointer to curr.left
	ADD  R6, R6, #-1
	STR  R4, R6, #0
	ADD  R6, R6, #-1	;Push one empty memory space for returning depth of the tree.
	JSR  CalculateDepth     
	LDR  R4, R6, #0		;R4 = depth of the right child
	ADD  R6, R6, #2		;Clear the stack
	
	AND  R0, R0, #0		;if leftDepth(R3) > rightDepth(R4)
	NOT  R0, R3
	ADD  R0, R0, #1
	ADD  R0, R0, R4  
	BRp  isBigger
	
	ADD  R3, R3, #1         ;leftDepth++;
	AND  R2, R2, #0
	ADD  R2, R3, #0	
	BRnzp returnDepth	
isBigger
	ADD  R4, R4, #1		;rightDepth++;
	AND  R2, R2, #0
	ADD  R2, R4, #0

returnDepth
	STR  R2, R5, #0  ;return R2 (result)

	LDR  R7, R6, #0  ; pop R3

        ADD  R6, R6, #1
	
	LDR  R4, R6, #0  ; pop R3

        ADD  R6, R6, #1

	LDR  R3, R6, #0  ; pop R3

        ADD  R6, R6, #1


        
LDR  R2, R6, #0  ; pop R2

        ADD  R6, R6, #1
        
  

        LDR  R1, R6, #0  ; pop R1
        ADD  R6, R6, #1
        
	LDR  R5, R6, #0  ; pop FP

        ADD  R6, R6, #1

	RET


;=========================================================================================================
; InOrderTraversal
;	params: CurrentNode
;
;	in order traversal of binary search tree
;=========================================================================================================
; Registers Dictionary
;
;
InOrderTraversal
	ADD  R6, R6, #-1 ; push FP
        
	STR  R5, R6, #0
        
        
	ADD  R5, R6, #1 ; update FP (point it to the old top of stack)
     
   
        
	ADD  R6, R6, #-1 ; push R1
	STR  R1, R6, #0

	ADD  R6, R6, #-1 ; push R2

        STR  R2, R6, #0	

	ADD  R6, R6, #-1 ; push R3
        STR  R3, R6, #0	

	ADD  R6, R6, #-1 ; push R4
        STR  R4, R6, #0	
	 
	ADD  R6, R6, #-1 ; push R7
        STR  R7, R6, #0	
	

	LDR  R1, R5, #0  ; R1 = Address to the current node.
	BRz  isNull      ; if( curr == null )  return;

	
	LDR  R2, R1, #1  ; R2 = node.leftChild
	ADD  R6, R6, #-1 
	STR  R2, R6, #0 
	JSR  InOrderTraversal  ;InOrderTraversal(node.leftChild)
	ADD  R6, R6, #1

	LDR  R0, R1, #0        ;print the current node's value in hexadecimal integer by calling Print subroutine
	ADD  R6, R6, #-1       ; 
	STR  R0, R6, #0
	JSR  Print
	ADD  R6, R6, #1        ;Clean up the stack that was pushed for the parameter since Print subroutine returns nothing.
	
	LDR  R3, R1, #2  ; R2 = node.leftChild
	ADD  R6, R6, #-1 
	STR  R3, R6, #0 
	JSR  InOrderTraversal  ;InOrderTraversal(node.rightChild)
	ADD  R6, R6, #1
	
	
isNull
	STR  R1, R5, #0  ; return

	LDR  R7, R6, #0  ; pop R3

        ADD  R6, R6, #1
	
	LDR  R4, R6, #0  ; pop R3

        ADD  R6, R6, #1

	LDR  R3, R6, #0  ; pop R3

        ADD  R6, R6, #1


        
LDR  R2, R6, #0  ; pop R2

        ADD  R6, R6, #1
        
  

        LDR  R1, R6, #0  ; pop R1
        ADD  R6, R6, #1
        
	LDR  R5, R6, #0  ; pop FP

        ADD  R6, R6, #1

	RET


;=========================================================================================================
; Print
;	params: hexadecimal value to be converted to ASCII character and to be printed
;
;	returns nothing, but prints the hexadecimal integer of given value.
;=========================================================================================================
; Registers Dictionary
; R1 - Hexadecimal value to be printed
; R2 -
; R5 - FP
; R6 - Stack
; R7 - Number of bits left for counting loop

Print
	ADD  R6, R6, #-1 ; push FP
        
	STR  R5, R6, #0
        
        
	ADD  R5, R6, #1 ; update FP (point it to the old top of stack)
     
   
        
	ADD  R6, R6, #-1 ; push R1
	STR  R1, R6, #0

	ADD  R6, R6, #-1 ; push R2

        STR  R2, R6, #0	

	ADD  R6, R6, #-1 ; push R3
        STR  R3, R6, #0	

	ADD  R6, R6, #-1 ; push R4
        STR  R4, R6, #0	
	 
	ADD  R6, R6, #-1 ; push R7
        STR  R7, R6, #0	

	AND  R1, R1, #0  ;Clear R1
	AND  R2, R2, #0  ;Clear R2
	AND  R3, R3, #0  ;Clear R3
	AND  R4, R4, #0  ;Clear R4
	AND  R7, R7, #0  ;Clear R7


	LDR  R1, R5, #0  ;R1 = hexadecimal value to be printed.
	AND  R2, R2, #0
	ADD  R2, R2, #1  ;R2 is used for bitmasking
	AND  R7, R7, #0
	ADD  R7, R7, #4  ;R7 = counter for the outer loop, which is set to be 4. we are printing four of 4-bit hex number, which is total of 16-bit( 15-bit cuz it's positive )
	
LoopPrintI
	AND  R5, R5, #0
	ADD  R5, R5, #4
	AND  R3, R3, #0
	AND  R4, R4, #0
	ADD  R4, R4, #1
LoopPrintJ
	AND  R0, R1, R2 
	BRnz skipBitMasking
	ADD  R3, R3, R4
skipBitMasking
	ADD  R2, R2, R2  ;R2 = 2*R2, which moves one bit to the left.
	ADD  R4, R4, R4  ;R4 = 2*R4, which moves one bit to the left.
	ADD  R5, R5, #-1
	BRp  LoopPrintJ  ;if R5 > 0, then we loop in LoopPrintJ again
	
	LD   R0, CheckNumeric
	ADD  R0, R0, R3   
	BRn  isNumericToPrint ;If R3 < 10, then we are printing a numeric value.
	
	LD   R0, CharPrint
	ADD  R3, R3, R0  
	BRnzp nowStore 	

isNumericToPrint
	LD   R0, NumericPrint
	ADD  R3, R3, R0  ;  

nowStore
	
	ADD  R7, R7, #-1
	LEA  R0, ToStorePrint
	ADD  R0, R0, R7
	STR  R3, R0, #0
	ADD  R7, R7, #1
	ADD  R7, R7, #-1
	BRp  LoopPrintI  ;If R7 > 0, then we loop in the outer loop again.

	LEA  R1, ToStorePrint
	LDR  R0, R1, #0
	PUTC
	LDR  R0, R1, #1	
	PUTC
	LDR  R0, R1, #2
	PUTC
	LDR  R0, R1, #3
	PUTC

	AND  R0, R0, #0
	LEA  R0, NextLine
	PUTS
	

	LDR  R7, R6, #0  ; pop R3

        ADD  R6, R6, #1
	
	LDR  R4, R6, #0  ; pop R3

        ADD  R6, R6, #1

	LDR  R3, R6, #0  ; pop R3

        ADD  R6, R6, #1


        
LDR  R2, R6, #0  ; pop R2

        ADD  R6, R6, #1
        
  

        LDR  R1, R6, #0  ; pop R1
        ADD  R6, R6, #1
        
	LDR  R5, R6, #0  ; pop FP

        ADD  R6, R6, #1

	RET

NextLine  .STRINGZ "\n"
NumericPrint .FILL #48
CharPrint    .FILL #55
ToStorePrint .FILL #0
	     .FILL #0
	     .FILL #0
	     .FILL #0



;=========================================================================================================
; ShiftRight
;	params: value to be divided by 2
;
;	returns the value after division by 2
;=========================================================================================================
ShiftRight
        ; set up the stack

        ADD  R6, R6, #-1 ; push FP
        STR  R5, R6, #0
        ADD  R5, R6, #1  ; update FP (point it to the old top of stack)
        
        ADD  R6, R6, #-1 ; push R1
        STR  R1, R6, #0
        
        ADD  R6, R6, #-1 ; push R2
        STR  R2, R6, #0
        
        ADD  R6, R6, #-1 ; push R7
        STR  R7, R6, #0

        ; do the shift
        
        LDR  R1, R5, #1  ; get the value to shift
        AND  R2, R2, #0

        ; divide R1 by 2, storing the result in R2
divide  ADD  R2, R2, #1
        ADD  R1, R1, #-2
        BRzp divide
        ADD  R2, R2, #-1 ; one step too far

        STR  R2, R5, #0  ; put the result on the stack

        ; clean up the stack
        
        LDR  R7, R6, #0  ; pop R7
        ADD  R6, R6, #1
        
        LDR  R2, R6, #0  ; pop R2
        ADD  R6, R6, #1
        
        LDR  R1, R6, #0  ; pop R1
        ADD  R6, R6, #1
        
        LDR  R5, R6, #0  ; pop FP
        ADD  R6, R6, #1
        
        RET


;---------------------------------------------------------------------------------------------------------
; ReadHexInt
;  No parameter.
;  
;  This subroutine reads in a positive hexadecimal integer value from the keyboard
;---------------------------------------------------------------------------------------------------------
; Registers Dictionary
; R1 - Current input digit value
; R2 - Various AND and ADD operations for comparison
; R3 - Total hex value, that is, all the digits are added up.
; R4 - Loop counter = 4. If we want 15 bits positive integer, we don't need to loop more than 4 times.
; R5 - FP
; R6 - Stack
ReadHexInt
	ADD  R6, R6, #-1 ; push FP
        
	STR  R5, R6, #0
        
        
	ADD  R5, R6, #1 ; update FP (point it to the old top of stack)
     
   
        
	ADD  R6, R6, #-1 ; push R1
	STR  R1, R6, #0

	ADD  R6, R6, #-1 ; push R2

        STR  R2, R6, #0	

	ADD  R6, R6, #-1 ; push R3
        STR  R3, R6, #0	

	ADD  R6, R6, #-1 ; push R4
        STR  R4, R6, #0	
	 
	ADD  R6, R6, #-1 ; push R7
        STR  R7, R6, #0	

	AND  R1, R1, #0
	AND  R2, R2, #0
	AND  R3, R3, #0
	AND  R4, R4, #0
	ADD  R4, R4, #4

ReadHexCount
	AND  R2, R2, #0    ;When R4 = 4, there has not been any input yet so we don't need to shift any bits.
	ADD  R2, R2, #-4
	ADD  R2, R2, R4
        BRz  skipShiftBit 

	ADD  R6, R6, #-1   ;pass the current digit as a parameter.
	STR  R3, R6, #0
	ADD  R6, R6, #-1   ;Push one space for the returning shifted hex value. ( 4 bits shifted to the left ) 
	JSR  ShiftLeft
	LDR  R3, R6, #0	   ;R0 = shifted value
	ADD  R6, R6, #1	   ;
	ADD  R6, R6, #1    ;Pop one space for the parameter.

skipShiftBit
	IN
	LD   R2, Numeric
        ADD  R1, R0, R2     ;If the input is numeric, then R1 < 10
	LD   R2, CheckNumeric
        ADD  R1, R1, R2     
        BRn  isNumeric      ;now if R1 is negative, then it means the input was a numeric, otherwise a character to represent a hex value.
        
	LD   R2, Character  ;else if it's character, we do R0 - 55 to get the hex digit value in decimal.
        AND  R1, R1, #0
        ADD  R1, R0, R2
	BRnzp hexStored
   
isNumeric
	LD   R2, Numeric
	AND  R1, R1, #0
        ADD  R1, R0, R2

hexStored
	ADD  R3, R1, R3    ;hex value all added up together. Each digit is added up.
	ADD  R4, R4, #-1
	BRp  ReadHexCount

	STR  R3, R5, #0  ;store the result as the return value

	LDR  R7, R6, #0  ; pop R3

        ADD  R6, R6, #1
	
	LDR  R4, R6, #0  ; pop R3

        ADD  R6, R6, #1

	LDR  R3, R6, #0  ; pop R3

        ADD  R6, R6, #1


        
LDR  R2, R6, #0  ; pop R2

        ADD  R6, R6, #1
        
  

        LDR  R1, R6, #0  ; pop R1
        ADD  R6, R6, #1
        
	LDR  R5, R6, #0  ; pop FP

        ADD  R6, R6, #1

	RET

Enter	  .FILL #-13
CheckNumeric .FILL #-10
Numeric   .FILL #-48
Character .FILL #-55



;=========================================================================================================
; ShiftLeft
;	params: value before 4 bits shifted to the left )
;
;	returns the value after 4 bits shifted to the left
;=========================================================================================================
; Registers Dictionary
; R1 - current hex value before 4 bits shifted.
; R2 - Bitmask for 4 bits shifting to the left.
; R3 - Bitmask for the current bit of R1.
; R4 - Value after 4 bits shifted to the left
; R5 - FP
; R6 - Stack
; R7 - Number of bit shifts left (counter)
ShiftLeft
	ADD  R6, R6, #-1 ; push FP
        
	STR  R5, R6, #0
        
        
	ADD  R5, R6, #1 ; update FP (point it to the old top of stack)
     
   
        
	ADD  R6, R6, #-1 ; push R1
	STR  R1, R6, #0

	ADD  R6, R6, #-1 ; push R2

        STR  R2, R6, #0	

	ADD  R6, R6, #-1 ; push R3
        STR  R3, R6, #0	

	ADD  R6, R6, #-1 ; push R4
        STR  R4, R6, #0	
	 
	ADD  R6, R6, #-1 ; push R7
        STR  R7, R6, #0	

 	LDR  R1, R5, #1  ; R1 = the current hex value before shift (parameter)  
	AND  R4, R4, #0     ;R4 will store the bitshifted value	
	LD   R7, BitShiftCount ;R7 counts the number of shifts left
	LD   R2, LeftShift  ;in order to shift 4 bits to the left except for the first input, we set R2 to 16 bit
	AND  R3, R3, #0
	ADD  R3, R3, #1     
LoopLeftShift
	AND  R0, R1, R3     
	BRnz skipShifting   ;if the bit is 1, then we shift this 4 bits to the left
	ADD  R4, R2, R4         
skipShifting
	ADD  R2, R2, R2	    ;move one bit to the left
	ADD  R3, R3, R3     ;
	ADD  R7, R7, #-1
	BRp  LoopLeftShift  

	STR  R4, R5, #0     

	LDR  R7, R6, #0  ; pop R7
        ADD  R6, R6, #1
	
	LDR  R4, R6, #0  ; pop R4
        ADD  R6, R6, #1

	LDR  R3, R6, #0  ; pop R3

        ADD  R6, R6, #1


        
LDR  R2, R6, #0  ; pop R2

        ADD  R6, R6, #1
        
  

        LDR  R1, R6, #0  ; pop R1
        ADD  R6, R6, #1
        
	LDR  R5, R6, #0  ; pop FP

        ADD  R6, R6, #1

	RET

BitShiftCount .FILL #12
LeftShift .FILL #16

;=========================================================================================================
; Insert
;	params: CurrrentNode, hexValue
;
;	insert a hexadecimal integer 
;=========================================================================================================
; Registers Dictionary
; R1 - pointer to the current node
; R2 - pointer to LAST, and pointer to the inserted node after insertion
; R3 - a hexadecimal integer to be inserted.
; R4 - various ADD/Substract operation
; R5 - FP
; R6 - Stack
; R7 - Temporarily used in order to store next node to pass in the recursvie Insert subroutine.
Insert	
	ADD  R6, R6, #-1 ; push FP
        
	STR  R5, R6, #0
        
        
	ADD  R5, R6, #1 ; update FP (point it to the old top of stack)
     
   
        
	ADD  R6, R6, #-1 ; push R1
	STR  R1, R6, #0

	ADD  R6, R6, #-1 ; push R2

        STR  R2, R6, #0	

	ADD  R6, R6, #-1 ; push R3
        STR  R3, R6, #0	

	ADD  R6, R6, #-1 ; push R4
        STR  R4, R6, #0	
	 
	ADD  R6, R6, #-1 ; push R7
        STR  R7, R6, #0	
	

	LDR  R3, R5, #2  ; R3 = hex integer value
	LDR  R1, R5, #1  ; R1 = pointer to the current node
	BRnp isNotNull   ; 
			 ; if(curr == null), curr = new Node(); and return;
	LEA  R2, LAST    ; a bit of memory address to insert the current node
	LDR  R0, R2, #0	 ;
	BRz  isFirstInsertion
	AND  R2, R2, #0
	ADD  R2, R0, #0  
isFirstInsertion

	STR  R3, R2, #1  ; 
	AND  R0, R0, #0  ; curr.data = hex integer value ( the parameter )
	STR  R0, R2, #2  ; curr.left = nul0;
	STR  R0, R2, #3	 ; curr.right = null
	AND  R0, R0, #0
	ADD  R0, R2, #4  ; address of the new LAST
	ST   R0, LAST
	ADD  R2, R2, #1  ; address of the newly added node
	BRnzp returnNode

isNotNull
	LDR  R4, R1, #0  ; R4 = current node value 
	NOT  R4, R4	 ; R4 = -R4
	ADD  R4, R4, #1  
	ADD  R4, R3, R4  ; if current node value < hex integer value (the parameter)
	BRnz isSmaller   ;   curr.right = insert(currentHexValue, curr.right);
	
	ADD  R6, R6, #-1 ;Pass the entered hex integer to the Insert subroutine
	STR  R3, R6, #0  ;
	LDR  R7, R1, #2  ;Pass curr.right as the next current node
	ADD  R6, R6, #-1
	STR  R7, R6, #0
	ADD  R6, R6, #-1 ;push one empty space for the returning value
	JSR  Insert
	LDR  R2, R6, #0  ; R2 = the inserted Node 
	BRz isAlreadyLinkedRight
	STR  R2, R1, #2  ; curr.right = Insert(data, curr.right)
	AND  R2, R2, #0
isAlreadyLinkedRight
	ADD  R6, R6, #3	 ; Clear pushed stack
	BRnzp returnNode

isSmaller
	
	ADD  R6, R6, #-1 ;Pass the entered hex integer to the Insert subroutine
	STR  R3, R6, #0  ;
	LDR  R7, R1, #1  ;Pass curr.left as the next current node
	ADD  R6, R6, #-1
	STR  R7, R6, #0
	ADD  R6, R6, #-1 ;push one empty space for the returning value
	JSR  Insert
	LDR  R2, R6, #0  ; R2 = the inserted Node
	BRz isAlreadyLinkedLeft
	STR  R2, R1, #1  ; curr.left = Insert(data, curr.left) 
	AND  R2, R2, #0
isAlreadyLinkedLeft
	ADD  R6, R6, #3	 ; Clear pushed stack

	; At this point, R2 has the inserted node
returnNode
	AND  R0, R0, #0
	ADD  R0, R2, #0
	STR  R0, R5, #0  ; Return the inserted node

	LDR  R7, R6, #0  ; pop R7
        ADD  R6, R6, #1
	
	LDR  R4, R6, #0  ; pop R4
        ADD  R6, R6, #1

	LDR  R3, R6, #0  ; pop R3

        ADD  R6, R6, #1


        
LDR  R2, R6, #0  ; pop R2

        ADD  R6, R6, #1
        
  

        LDR  R1, R6, #0  ; pop R1
        ADD  R6, R6, #1
        
	LDR  R5, R6, #0  ; pop FP

        ADD  R6, R6, #1
	RET


LAST	.BLKW 1


        .end

