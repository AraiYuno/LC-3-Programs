; Kyle Seokjin Ahn
; 
; Description: Subtraction, using several subroutines
;====================================================================
        .orig x3000

        ; Start by setting up the stack
        LD   R6, stackbase
        
        ; call readposdec to get R1
start   ADD  R6, R6, #-1 ; push space for return value
        JSR  readposdec
        LDR  R1, R6, #0
        ADD  R6, R6, #1  ; remove space from return value

        ; call readposdec to get R2
        ADD  R6, R6, #-1 ; push space for return value
        JSR  readposdec
        LDR  R2, R6, #0
        ADD  R6, R6, #1  ; remove space from return value
        
        ; call readposdec to get R3
        ADD  R6, R6, #-1 ; push space for return value
        JSR  readposdec
        LDR  R3, R6, #0
        ADD  R6, R6, #1  ; remove space from return value
        
        ; call sub3: calculate R1 - R2 - R3 and store in R4
        
        ADD  R6, R6, #-1 ; push R1
        STR  R1, R6, #0
        ADD  R6, R6, #-1 ; push R2
        STR  R2, R6, #0
        ADD  R6, R6, #-1 ; push R3
        STR  R3, R6, #0
        ADD  R6, R6, #-1 ; push space for return value (no data)
        
        JSR  sub3

        LDR  R4, R6, #0  ; put the return value into R4
        ADD  R6, R6, #4  ; remove values from call
        
        BR   start
        
        HALT             ; never actually gets called...

data1   .fill 100
data2   .fill 80
data3   .fill 73

; stack will start at the given location
stackbase
        .fill x4000

;;; readposdec subroutine
; stack usage:
; (top) local variable: saved input digit
;       saved R7
;       saved R4
;       saved R3
;       saved R2
;       saved R1
;       saved FP (R5)
; stack expectation:
; (FP)  return value: input number

readposdec
        ; set up the stack

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

        ADD  R6, R6, #-1 ; push space for saved
        
        ; do the input
        
        AND   R1,R1,#0
        AND   R2,R2,#0
        LD    R3,five

one     IN
i       ADD   R0,R0,R3
        STR   R0,R5,#7   ; save R0 in the local variable
        BRn   four
ii      ADD   R4,R0,#-10
iii     BRzp  four
        ADD   R4,R2,#0
        BRz   three

        AND   R4,R4,#0
        ADD   R4,R4,#9
        ADD   R0,R1,#0
two     ADD   R1,R1,R0
        ADD   R4,R4,#-1
        BRp   two

three   LDR   R0,R5,#7  ; restore R0 from local varaible
        ADD   R1,R1,R0
        ADD   R2,R2,#1
        BR    one
        
four    STR   R1, R5, #0  ; store the result as the return value
        
        ; clean up the stack
        
        ADD  R6, R6, #1  ; pop (and ignore) local variable
        
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

five    .FILL #-48

;;; sub3 subroutine
; stack usage:
; (top) saved R7 (now it's needed!)
;       saved R4
;       saved R3
;       saved R2
;       saved R1
;       saved FP (R5)
; stack expectation:
; (FP)  return value: first value - second value - third value
;       third value
;       second value
;       first value

sub3
        ; set up the stack

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
        
        ; perform R1 - R2 - R3

        ; First call: calculate R1 - R2 and store in R4
        ADD  R6, R6, #-1 ; push R1
        STR  R1, R6, #0
        ADD  R6, R6, #-1 ; push R2
        STR  R2, R6, #0
        ADD  R6, R6, #-1 ; push space for return value (no data)
        
        JSR  subtract    ; call subtract

        LDR  R4, R6, #0  ; put the return value into R4
        ADD  R6, R6, #3  ; pop all three items off the stack (ignoring values)
        
        ; Second call: calculate R4 - R3 and store in R4
        ADD  R6, R6, #-1 ; push R4
        STR  R4, R6, #0
        ADD  R6, R6, #-1 ; push R3
        STR  R3, R6, #0
        ADD  R6, R6, #-1 ; push space for return value (no data)
        
        JSR  subtract    ; call subtract

        LDR  R4, R6, #0  ; put the return value into R4
        ADD  R6, R6, #3  ; pop all three items off the stack (ignoring values)
        
        STR  R4, R5, #0  ; store the result as the return value
        
        ; clean up the stack
        
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
        
;;; subtract subroutine
; stack usage:
; (top) saved R7 (not actually needed)
;       saved R2
;       saved R1
;       saved FP (R5)
; stack expectation:
; (FP)  return value: first value - second value
;       second value (subtrahend)
;       first value

subtract
        ; set up the stack

        ADD  R6, R6, #-1 ; push FP
        STR  R5, R6, #0
        
        ADD  R5, R6, #1 ; update FP (point it to the old top of stack)
        
        ADD  R6, R6, #-1 ; push R1
        STR  R1, R6, #0
        
        ADD  R6, R6, #-1 ; push R2
        STR  R2, R6, #0
        
        ADD  R6, R6, #-1 ; push R7
        STR  R7, R6, #0
        
        ; perform the actual subtraction
        ; R1 - first value
        ; R2 - second value (subtrahend) and result
        
        LDR  R2, R5, #1  ; value #2 is just below FP
        LDR  R1, R5, #2  ; value #1 is just below that
        NOT  R2, R2      ; negate R2
        ADD  R2, R2, #1
        ADD  R2, R1, R2  ; R2 <- value 1 + -value2
        
        STR  R2, R5, #0  ; store the result as the return value
        
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

        .end
