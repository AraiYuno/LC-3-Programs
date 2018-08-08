;================================================================================
; Kyle Seokjin Ahn
; 
; Description: Sorting a linked list using subroutines.
;
;================================================================================
; R1 - head of the destination (sorted) list
; R2 - head of the original (unsorted) list
; R3 - current node of interest (being moved during sort)
; R4 - countdown to print every 10 changes

        .orig x3000
        
        ; set up the stack
        LD    R6, stackbase

	; set up the lists
        LEA   R2, head
	AND   R1, R1, #0

newprint
	; set up print counter
	AND   R4, R4, #0
	ADD   R4, R4, #10
	
        ; print the original list
	LEA   R0, origmsg
	PUTS
        ADD   R6, R6, #-1 ; push the head of original
        STR   R2, R6, #0
        JSR   printAll
        ADD   R6, R6, #1  ; clear the stack
        
        ; print the sorted list
	LEA   R0, sortmsg
	PUTS
        ADD   R6, R6, #-1 ; push the head of destination
        STR   R1, R6, #0
        JSR   printAll
        ADD   R6, R6, #1  ; clear the stack
	
	; end if the original list is empty
	ADD   R2, R2, #0
	BRz   done
	
	; perform a round of the sorting
sort
	; find the maximum value in the original list
        ADD   R6, R6, #-1 ; push the head
        STR   R2, R6, #0
        ADD   R6, R6, #-1 ; push space for the result
        JSR   max
        LDR   R3, R6, #0  ; pop the result into R3
        ADD   R6, R6, #1
        ADD   R6, R6, #1  ; clear the stack
	
	; remove the node from the original list
        ADD   R6, R6, #-1  ; push the head (variable parameter)
        STR   R2, R6, #0
        ADD   R6, R6, #-1  ; push the node to remove
        STR   R3, R6, #0
        ADD   R6, R6, #-1  ; push space for the result
        JSR   remove
        LDR   R3, R6, #0   ; get the result into R3
	LDR   R2, R6, #2   ; variable parameter: get the updated head
        ADD   R6, R6, #3   ; clear the stack
	
	; prepend the node to the destination list
	ADD   R0, R3, #0   ; copy R3 into R0 (node: first register parameter)
	JSR   prepend      ; head is already in R1 (head: second register parameter)

	; decide if we need to print or repeat
	ADD   R4, R4, #-1  ; print if we hit 10 items
	BRz   newprint
	ADD   R2, R2, #0   ; print if we are done
	BRz   newprint
	BR    sort         ; repeat but do not print

done
	LEA   R0, donemsg
	PUTS
        
        HALT

newline .fill #10
origmsg	.stringz "\nOriginal list:\n"
sortmsg	.stringz "\nSorted list:\n"
donemsg	.stringz "\nEnd of processing.\n"
stackbase
        .fill x4000


head	.fill -4358
	.fill nodeD
nodeA	.fill 85
	.fill nodeJ
nodeB	.fill 2280
	.fill nodeL
nodeC	.fill -53
	.fill nodeT
nodeD	.fill 102
	.fill nodeG
nodeE	.fill -1337
	.fill nodeH
nodeF	.fill -1
	.fill nodeB
nodeG	.fill -32768
	.fill nodeQ
nodeH	.fill 687
	.fill nodeM
nodeI	.fill 7
	.fill nodeC
nodeJ	.fill 20000
	.fill nodeR
nodeK	.fill 0
	.fill nodeP
nodeL	.fill -1024
	.fill nodeS
nodeM	.fill -15316
	.fill nodeK
nodeN	.fill 15316
	.fill nodeO
nodeO	.fill 30123
	.fill nodeF
nodeP	.fill -9999
	.fill nodeN
nodeQ	.fill -1234
	.fill nodeA
nodeR	.fill 6502
	.fill nodeE
nodeS	.fill 8008
	.fill nodeI
nodeT	.fill 6800
	.fill nodeU
nodeU	.fill 32767
	.fill nodeV
nodeV	.fill 29329
	.fill nodeW
nodeW	.fill -204
	.fill nodeX
nodeX	.fill 6744
	.fill nodeY
nodeY	.fill 85
	.fill nodeZ
nodeZ	.fill -9
	.fill tail
tail	.fill 27541
	.fill 0

;;; max subroutine
; Find the node containing the maximum value in a linked list
; R1: current node
; R2: largest node
; R3: largest node's value or sign bit
; stack usage:
;       saved R7
;       saved R3
;       saved R2
;       saved R1
;       saved FP (R5)
; stack expectation:
; (FP)  head of the list

max
        ; set up the stack

        ADD   R6, R6, #-1 ; push FP
        STR   R5, R6, #0
        
        ADD   R5, R6, #1 ; update FP (point it to the old top of stack)
        
        ADD   R6, R6, #-1 ; push R1
        STR   R1, R6, #0
        
        ADD   R6, R6, #-1 ; push R2
        STR   R2, R6, #0
	
        ADD   R6, R6, #-1 ; push R3
        STR   R3, R6, #0
	
        ADD   R6, R6, #-1 ; push R7
        STR   R7, R6, #0

        ; do the traversal and find the max node

        LDR   R1, R5, #1  ; get the head from the stack
	ADD   R2, R1, #0  ; assume it is the max value

nextMAX	; first, check for different signs, to avoid overflow
	LDR   R3, R2, #0  ; get the value from the max node
	BRzp  posMAX

negMAX	; max value is negative
	LDR   R0, R1, #0  ; get the value from the current node
	BRn   typMAX	  ; typical case: both negative
	BR    isMAX       ; max is negative, current is positive: new max

posMAX	; max value is positive
	LDR   R0, R1, #0  ; get the value from the current node
	BRn   skipMAX	  ; max is positive, current is negative: no change
	; otherwise, fall through to the typical case
	
typMAX	; typical case: calculate R0 - R3 and if it is positive, then current node is max
	NOT   R3, R3      ; complement R3 but DO NOT add 1 yet...
	ADD   R0, R0, R3
	ADD   R0, R0, #1  ; ... wait until now (just in case R3 is -32768)
	BRnz  skipMAX

isMAX	ADD   R2, R1, #0  ; this is the max value

skipMAX	LDR   R1, R1, #1  ; go to next
        BRnp  nextMAX
	
	; put the result onto the stack
	STR   R2, R5, #0

        ; clean up the stack
        
        LDR   R7, R6, #0  ; pop R7
        ADD   R6, R6, #1

        LDR   R3, R6, #0  ; pop R3
        ADD   R6, R6, #1
        
        LDR   R2, R6, #0  ; pop R2
        ADD   R6, R6, #1
        
        LDR   R1, R6, #0  ; pop R1
        ADD   R6, R6, #1
        
        LDR   R5, R6, #0  ; pop FP
        ADD   R6, R6, #1

        RET

;;; remove subroutine
; Remove the given node from a linked list.
; NOTE: assumes that the node exists; if not found, behaviour is undefined!
; R1: current node
; R2: previous node
; R3: node to remove (target), negated
; stack usage:
;       saved R7
;       saved R3
;       saved R2
;       saved R1
;       saved FP (R5)
; stack expectation:
; (FP)	return value (removed node from the list)
;	pointer to node to remove
;	head of the list (variable parameter)

remove
        ; set up the stack

        ADD   R6, R6, #-1 ; push FP
        STR   R5, R6, #0
        
        ADD   R5, R6, #1 ; update FP (point it to the old top of stack)
        
        ADD   R6, R6, #-1 ; push R1
        STR   R1, R6, #0
        
        ADD   R6, R6, #-1 ; push R2
        STR   R2, R6, #0
	
        ADD   R6, R6, #-1 ; push R3
        STR   R3, R6, #0
	
        ADD   R6, R6, #-1 ; push R7
        STR   R7, R6, #0

        ; do the traversal and remove the node

        LDR   R1, R5, #2  ; get the head from the stack
	LDR   R3, R5, #1  ; get the node to remove (target) from the stack
	NOT   R3, R3      ; negate the target pointer, for comparison
	ADD   R3, R3, #1
	
	; check for special case: node is head
	ADD   R0, R3, R1  ; compare the target node to the head
	BRnp  nextRM

	; special case: node is head, head has to be changed to head->next
	LDR   R0, R1, #1  ; get the next pointer from the head
	STR   R0, R5, #2  ; update the variable parameter (change head on the stack)
	BR    doneRM

nextRM	ADD   R2, R1, #0  ; current node is previous
        LDR   R1, R1, #1  ; go to next node
	ADD   R0, R3, R1  ; compare the target node to current
	BRnp  nextRM

	; found the target node; have to set previous->next = current->next;
	LDR   R0, R1, #1  ; R0 = current->next
	STR   R0, R2, #1  ; previous->next = R0;

	; node that was removed is now in R1
doneRM  AND   R0, R0, #0  ; null out the next pointer, just to be clean
	STR   R0, R1, #1
	STR   R1, R5, #0  ; put the result onto the stack

        ; clean up the stack
        
        LDR   R7, R6, #0  ; pop R7
        ADD   R6, R6, #1

        LDR   R3, R6, #0  ; pop R3
        ADD   R6, R6, #1
        
        LDR   R2, R6, #0  ; pop R2
        ADD   R6, R6, #1
        
        LDR   R1, R6, #0  ; pop R1
        ADD   R6, R6, #1
        
        LDR   R5, R6, #0  ; pop FP
        ADD   R6, R6, #1

        RET

;;; prepend subroutine
; Prepend a node to the head of a list
; R0: node to prepend
; R1: head of existing list (variable parameter)
; no stack usage (if we called another subroutine we'd have to save R7)

prepend
	STR   R1, R0, #1  ; node->next = head;
	ADD   R1, R0, #0  ; head = node;
        RET

;;; printAll subroutine
; Print every value in the list, in decimal.
; R1: current node
; stack usage:
;       saved R7
;       saved R1
;       saved FP (R5)
; stack expectation:
; (FP)  head of the list

printAll
        ; set up the stack

        ADD   R6, R6, #-1 ; push FP
        STR   R5, R6, #0
        
        ADD   R5, R6, #1 ; update FP (point it to the old top of stack)
        
        ADD   R6, R6, #-1 ; push R1
        STR   R1, R6, #0
        
        ADD   R6, R6, #-1 ; push R7
        STR   R7, R6, #0

        ; do the traversal and print

        LDR   R1, R5, #0  ; get the head from the stack

nextPA  BRz   donePA
        LDR   R0, R1, #0  ; get the value from the node
        
        ; call printDec
        ADD   R6, R6, #-1 ; push the value
        STR   R0, R6, #0
        JSR   printDec
        ADD   R6, R6, #1  ; clear the stack
        
        LD    R0, newline
        OUT

        LDR   R1, R1, #1  ; go to next
        BR    nextPA

donePA
        ; clean up the stack
        
        LDR   R7, R6, #0  ; pop R7
        ADD   R6, R6, #1
        
        LDR   R1, R6, #0  ; pop R1
        ADD   R6, R6, #1
        
        LDR   R5, R6, #0  ; pop FP
        ADD   R6, R6, #1

        RET

;;; printDec subroutine
; Print a single value (positive or negative) in decimal.
; R1: the value to print, shifted
; R2: the digit to print
; stack usage:
;       local array to store number (push digits)
;       saved R7
;       saved R2
;       saved R1
;       saved FP (R5)
; stack expectation:
; (FP)  value to print

printDec
        ; set up the stack

        ADD   R6, R6, #-1 ; push FP
        STR   R5, R6, #0
        
        ADD   R5, R6, #1 ; update FP (point it to the old top of stack)
        
        ADD   R6, R6, #-1 ; push R1
        STR   R1, R6, #0
        
        ADD   R6, R6, #-1 ; push R2
        STR   R2, R6, #0
        
        ADD   R6, R6, #-1 ; push R7
        STR   R7, R6, #0

        ; do the printing

        LDR   R1, R5, #0  ; get the value from the stack

        ; print a minus sign and make it positive, if necessary
        BRzp  startPD
        LD    R0, minus
        OUT
        NOT   R1, R1      ; negate R1 (make it positive)
        ADD   R1, R1, #1

startPD
	; push a \0 on the stack to mark the end of the string
	AND   R0, R0, #0
	ADD   R6, R6, #-1
	STR   R0, R6, #0

nextPD  
        ; call divmod
        ADD   R6, R6, #-1 ; push the dividend (10)
        AND   R0, R0, #0
        ADD   R0, R0, #10
        STR   R0, R6, #0
        ADD   R6, R6, #-1 ; push the divisor
        STR   R1, R6, #0
        ADD   R6, R6, #-2 ; space for two return values
        JSR   divmod
        LDR   R1, R6, #0  ; get the div result
        LDR   R2, R6, #1  ; get the mod result
        ADD   R6, R6, #4  ; clear the stack

        LD    R0, zero    ; push the mod result as a digit
        ADD   R0, R0, R2
	ADD   R6, R6, #-1
	STR   R0, R6, #0

        ADD   R1, R1, #0  ; check R1's value
        BRp   nextPD      ; not zero: go to next digit

	; print the number
	ADD   R0, R6, #0  ; starts at the top of the stack
	PUTS

        ; clean up the stack
	
	; pop characters from the string until \0
clearPD	LDR   R0, R6, #0  ; pop into R0
	ADD   R6, R6, #1
	ADD   R0, R0, #0  ; check R0
	BRnp  clearPD
        
        LDR   R7, R6, #0  ; pop R7
        ADD   R6, R6, #1
        
        LDR   R2, R6, #0  ; pop R2
        ADD   R6, R6, #1
        
        LDR   R1, R6, #0  ; pop R1
        ADD   R6, R6, #1
        
        LDR   R5, R6, #0  ; pop FP
        ADD   R6, R6, #1

        RET

zero    .fill #48
minus   .fill #45

;;; divmod subroutine
; Calculate n div m and n mod m, and return both.
; R1: n (gets broken down)
; R2: m (gets negated)
; R3: n div m
; R4: n mod m
; stack usage:
;       saved R7
;       saved R4
;       saved R3
;       saved R2
;       saved R1
;       saved FP (R5)
; stack expectation:
; (FP)  n div m (return value)
;       n mod m (return value)
;       n
;       m

divmod
        ; set up the stack

        ADD   R6, R6, #-1 ; push FP
        STR   R5, R6, #0
        
        ADD   R5, R6, #1 ; update FP (point it to the old top of stack)
        
        ADD   R6, R6, #-1 ; push R1
        STR   R1, R6, #0
        
        ADD   R6, R6, #-1 ; push R2
        STR   R2, R6, #0
        
        ADD   R6, R6, #-1 ; push R3
        STR   R3, R6, #0
        
        ADD   R6, R6, #-1 ; push R4
        STR   R4, R6, #0
        
        ADD   R6, R6, #-1 ; push R7
        STR   R7, R6, #0

        ; perform the calculation

        LDR   R1, R5, #2  ; get n from the stack
        LDR   R2, R5, #3  ; get m from the stack
        ADD   R4, R2, #0  ; copy R2 to R4 before negating it
        NOT   R2, R2      ; negate R2
        ADD   R2, R2, #1
        AND   R3, R3, #0  ; clear R3 (for div)
        
        ; divide R1 by R2, storing the result in R3
divide  ADD  R3, R3, #1
        ADD  R1, R1, R2
        BRzp divide
        ADD  R3, R3, #-1 ; one step too far
        ADD  R4, R1, R4  ; one step too far: add m back to get n mod m

        STR  R3, R5, #0  ; put the div on the stack
        STR  R4, R5, #1  ; put the mod on the stack

        ; clean up the stack
        
        LDR   R7, R6, #0  ; pop R7
        ADD   R6, R6, #1
        
        LDR   R4, R6, #0  ; pop R4
        ADD   R6, R6, #1
        
        LDR   R3, R6, #0  ; pop R3
        ADD   R6, R6, #1
        
        LDR   R2, R6, #0  ; pop R2
        ADD   R6, R6, #1
        
        LDR   R1, R6, #0  ; pop R1
        ADD   R6, R6, #1
        
        LDR   R5, R6, #0  ; pop FP
        ADD   R6, R6, #1

        RET

        .end