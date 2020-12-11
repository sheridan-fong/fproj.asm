%include "simple_io.inc"

global asm_main 

SECTION .data 
err1: db "wrong number of command line arguments",10,0
err2: db "input string too long",10,0

array_mess: db "border array:",0

plus_print: db "+++  ",0
empty_print: db "     ", 0
dot_print: db "...  ",0


bordar: dq 0,0,0,0,0,0,0,0,0,0,0,0


 
SECTION.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Too many argument handler 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Arg_error: 
	enter	0,0 	; setting up the routine 
	saveregs 	; saving all the registers 
	
	mov	rax, err1
	call	print_string
	
	restoreregs
	leave 
	ret	

;;;;;;;;;;;;;;;;
;; length error 
;;;;;;;;;;;;;;

Length_error: 
	enter 	0,0	; setting up the routine 
	saveregs	; saving all the registers 
	
	mov 	rax, err2
	call 	print_string
		
	
	restoregs
	leave
	jmp	asm_main_end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; subroutine maxboard	
;;;;;;;;;;;;;;;;;;;;;;;;;;

maxboard: 
	enter 	0,0
	saveregs
	

	;; getting the values from the stack and storing them 
	mov 	rbx, qword [rbp+24]	;; the length	
	mov	rcx, qword [rbp+32]	;; string

	
	;; making the loop and initializing max and the counters
	mov	r15, 0 	;; maxboard value that will be eventually returned to rax aka max = 0
	mov	r12, 1 ;; outer loop counter aka r ;; should be one btw but changed for testing
 
	
	Outer_Loop_R:
		cmp	r12, rbx ;; counter and length 
		jge	return_value

		
		mov	rcx, qword [rbp+32] ;; address of the string

		;; setting up in inner loop for i in range(r) one
		mov	r13, 0 ;; counter aka i
		mov	r14, 1 ;; is border calculation 
		mov	rdx, rcx ;; points to the beginning of the adress of the string this is the string
				 ;; that will be manipulated 		

		Inner_Loop_I:
			cmp	r13, r12 ;; counter (i) and length
			je	continue_outer

			;; updating the rdx value 
			mov 	rdx, qword [rbp+32] 	;; this is the string that will be manipulated
		
					
			;; manipulating the string[L-r+i]
			add	rdx, [rbp+24] ;; string address + Length stored in rdx
			sub	rdx, r12 ;; rdx - r12 aka L - r
			add	rdx, r13 ;; ((L - r) + i) 
				
			;; comparing the two bytes
 			mov	al, byte[rcx]
			cmp	al, byte[rdx] ;; comparing the string[L-r+i]
			jne	inner_not_equal
		
			;; if equal you are going to increase the string address pointer by one 
			inc	rcx		
			inc	r13
			jmp 	Inner_Loop_I
			
		inner_not_equal: 
			;; setting isborder = 0
			mov	r14, 0
			
		continue_outer:
			;; check if isborder == 1
			cmp	r14, qword 1	;; may need to specify size not sure?
			jne 	continuing_outer

			cmp	r15, r12		;; checking if max < r
			jge	continuing_outer	;; if max >= r then continue the outer loop and get out of here 
			
			;; if you made it this far change the max = r
			mov	r15, r12	;; max = r
		

	
		continuing_outer:
			;; increasing r loop counter and jumping to the top
                        inc     r12
			jmp	Outer_Loop_R


	return_value:
		mov	rax, r15 ;; moving the appropriate value back to r15

	restoregs
	leave
	ret 

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; subroutine: simple_display 
;;;;;;;;;;;;;;;;;;;;;;;

simple_display: 
	enter 0,0 	; setup routine 
	saveregs	; save all registers 

	;; getting inputs 
	mov	rcx, qword [rbp+24] ;; moving the length 
	mov	rdx, qword [rbp+32] ;; moving the array
	
	mov	rax, array_mess
	call	print_string
	
	mov	r12, qword 0 	;; counter for the array 
	dec 	rcx	;; decrease by one since we only need to iterate through n - 1 times	
	
	mov	rax, [rdx]
	call	print_int
	add	rdx, qword 8

	simple_loop:
		cmp 	r12, rcx
		je	end_loop
		mov	al, ","
		call	print_char
		mov 	al," "
		call	print_char
		mov	rax, [rdx]
		call	print_int
		
		inc 	r12
		add	rdx, qword 8
		jmp	simple_loop		

	end_loop: 
		call	print_nl


	restoregs
	leave
	ret

;;;;;;;;;;;;;;;;;;;;;;;
;;; subroutine: fancy_display
;;;;;;;;;;;;;;;;;;;;;

fancy_display: 
	enter 0,0
	saveregs

	mov     rcx, qword [rbp+24] ;; moving the length
        mov     rdx, qword [rbp+32] ;; moving the array

	mov	r12, rcx	;; counter for outer loop (level) starts at length and decreases 
	
		
	level_loop: 
		cmp	r12, qword 0
		je	ending_loop

		mov	rdx, qword [rbp+32]	;; declare again before each loop
		mov	r13, qword 0		;; count variable starting at 0
		

		bordar_loop_inner:

			cmp	r13, qword [rbp+24]	;; count == L 
			je	level_loop_continued
			
			;; first if statement if level == 1:

                        cmp     r12, qword 1
                        jne     else_statement

                        ;; if here it means they are equal
                        cmp     qword [rdx], qword 0
                        jg      plus_print_state        ; x > 0

                        ;; means  x < 0
                        mov     rax, dot_print
                        call    print_string
                        jmp     bordar_continued

                        plus_print_state:
                        ;; x > 0
                                mov     rax, plus_print
                                call    print_string

                        jmp     bordar_continued

                        else_statement:
                                cmp     [rdx], r12
                                jge     plus_print_state        ;; if greater than level or equal to

                                ;; if here x < level

                                mov     rax, empty_print
                                call    print_string
                                jmp bordar_continued			


		bordar_continued: 
			add	rdx, qword 8	;; moving over to the next word in the array
			inc	r13 
			jmp	bordar_loop_inner
	
	level_loop_continued: 
		dec	r12	;; decreasing level
		call	print_nl
		jmp	level_loop
		
	ending_loop:
		call	print_nl 

	restoregs
	leave
	ret

;;;;;;;;;;;;;;;;;;;;;;;;
;; asm_main
;;;;;;;;;;;;;;;;;;

asm_main: 
	enter	0,0
	saveregs 

	;; check argc, must be 2
	cmp	rdi, qword 2
	je	Check_length
	
	;; if the arguments were 2 it would jump to check_length 
	;; if not it would go to the error message page

	call Arg_error
	jmp asm_main_end

Check_length: 
	;; calculating the length of argv[1] 
	;; r12 is being used as the counter 
	mov	r12, 0
	
	;; counting loop
	mov	 rbx, [rsi+8] ;; pointer to argv[1]
	mov	 rcx, rbx

	
	CL1:
		cmp	byte[rcx],byte 0
		je	CL2
		;; incrementing the counter
		inc	r12
		;; moving the pointer
		inc 	rcx
		jmp 	CL1

	CL2:
		dec	rcx ;;  makes the pointer at the end of the string
		cmp	r12, qword 12 	;; if greater than 12 it is a length error
		jg	Length_error
	
		
	mov	r13, 0		;; loop counter
	mov 	r14, r12	;; current string length counter
	mov	r10, r12	;; moving the lenght into r10 for safe keeping
	mov	r15, r12	;; moving the length into safe keeping

	;; changed rbx to out here
	mov	rbx, [rsi+8]
	mov 	rcx, rbx			
	
	;; decreasing r12 which is the length - 1 is how many times you want it to run 
	dec 	r12

	;;; moving bordar into a register 
	mov	rdx, bordar

	Loop_1:
		cmp	r13, r12
		je	main_continued
		
		;; pushing the appropriate string to the stack 
		push 	qword rcx	;; pushing the string
		push 	r14 		;; pushing the length (number)
		push	qword 0		;; fake
		call	maxboard	;; jmping to maxboard 
	
		;; remember to initialize the border
		mov	[rdx], qword rax
		add	rdx, 8
		
	
		;; increasing all counters 
		inc	r13
		inc 	rcx
		dec 	r14
		jmp 	Loop_1			
		
	main_continued: 	
	;;  Adding the additional 0 to bordar to make the array correct
		
		mov	r12, qword 0 	;; r12 is our counter
		dec	r10

		;; moving the vlaue of bordar back to beginning 
	
		bordar_loop: 
			cmp	r12, r10
			je	simple_display_call
			sub	rdx, qword 8
			inc	r12
			jmp	bordar_loop
		 		
		simple_display_call: 
			inc	r10 ;; back to normal length now	
	
		
		;; function called simple_display 
		push 	rdx		;; pushing the bordar array contained in rdx
		push 	r15		;; the length (number of items in the array)
		push 	qword 0		;; dummy push 


		call	simple_display	;; jumping to simple display to display the bordar array

		;;;;;; setting up fancy display

	 
		push 	rdx	;; pushing the array 
		push 	r15	;;  the length (number of items in the array)
		push	qword 	0	;; dummy push 

		
		call fancy_display 	;; making the bar chart
		
		jmp	asm_main_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; subroutine asm_main_end 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

asm_main_end: 
	restoregs
	leave
	ret
