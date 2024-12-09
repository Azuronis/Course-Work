; Date created: 10/24/2024
; Program that takes in a users selection and does mathmatical operations. Once done it asks the user if they would like to reapeat.
; It also prints a selection table for the user to choose from. 


INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
first_val SWORD 0									; This stores the first input value
second_val SWORD 0									; This stores the second input value
result SDWORD 0										; This stores the result
charIn BYTE 0

;Prompts
repeatPrompt BYTE "Would you like to enter a new string (y/n)? " , 0
zero_div_prompt BYTE "Cannot divide by 0. Result will be set to 0",0
prompt_bad BYTE "Please re-enter an integer value up to 16 bits in size: ",0
prompt_bad_menu BYTE "Please enter one of the displayed menu options.", 0
computation_prompt BYTE "Computation Result: ",0

sum_prompt BYTE "The sum of ",0
sub_prompt BYTE "The subtraction of ",0
mult_prompt BYTE "The multiplication of ",0
div_prompt BYTE "The division of ",0
and_word BYTE " and ",0
is_word BYTE " is ",0

exit_prompt BYTE "Goodbye!", 0
first_prompt BYTE "Please enter an integer value up to 16 bits in size: ",0
second_prompt BYTE "Please enter another integer value up to 16 bits in size: ",0
selection_prompt BYTE "Selection: ",0
menu_options BYTE "	(1) Addition", 10, 13
			BYTE "	(2) Subtraction", 10, 13
		    BYTE "	(3) Multiplication", 10, 13
		    BYTE "	(4) Division", 10, 13
			BYTE "	(5) Exit", 0
			
; 10, 13 are carriage return and newline
menu_prompt BYTE "Please choose one of the menu options: ",0
menu_selection DWORD 0								; Stores the menu option

.code
main PROC
	main_loop:

		MOV EDX, OFFSET first_prompt				; Print the first input prompt asking for a number
		CALL WriteString
		MOV EDX, OFFSET first_val					; Move first_val offset into EDX
		CALL get_int								; Call get_int and set first_val to user input

		MOV EDX, OFFSET second_prompt				; Print the second input prompt asking for a number
		CALL WriteString
		MOV EDX, OFFSET second_val					; Move second_val offset into EDX
		CALL get_int								; Call get_int and set second_val to user input

		MOV EDX, OFFSET menu_options				; This prints the menu options, and then a newline
		CALL WriteString
		CALL Crlf

		MOV EDX, OFFSET menu_prompt					; Print the menu prompt 
		CALL WriteString
		CALL Crlf

		MOV EDX, OFFSET menu_selection				; Print the menu selection prompt
		CALL get_menu_option						; Get the menu option and store it in menu_selection
		CALL Crlf

		CALL compute_option							; Compute the 2 values depending on the menu_selection value



		MOV EDX, OFFSET repeatPrompt  ; prints the repeat prompt option
		CALL WriteString
		CALL ReadChar ;read char (y or Y to restart, other characters will end it)
		MOV charIn, AL  ;move AL into charIn
		CALL WriteChar ;echo char back on screen so its visible. Irvine does not echo by default.

		CALL Crlf

		;logic to check if char is Y or y, otherwise exit
		CMP AL, 59h ;capital Y in hex. Checking if AL == Y
		JE main_loop ; jump if equals to main_loop since we are restarting
		CMP AL, 79h ;lowercase y in hex.  Checking if AL == y
		JE main_loop  ; jump if equals to main_loop since we are restarting
		;else exit
		JMP exit_program

main ENDP

; EDX = offset of variable
; Sets the value of the variable to the input
get_int PROC
	read:
		call ReadInt
		jno  good_input								; If we dont have an overflow of 32 bits we jump to good_input

		MOV  EDX, OFFSET prompt_bad					; Else we print the bad prompt and repeat
		CALL WriteString
		JMP  read

	good_input:										; If its good input we zero fill EAX from AX
		MOVSX EAX, AX	
		MOV [EDX], AX								; We then move AX into EDX since 16 bits

	RET
get_int ENDP

get_menu_option PROC
	read:
		MOV EDX, OFFSET selection_prompt
		CALL WriteString

		CALL ReadInt
		JNO  good_input								; If we dont have an overflow of 32 bits we jump to good_input

		JMP bad_input

	bad_input:
		MOV  EDX, OFFSET prompt_bad_menu			; Else we print the bad prompt and repeat
		CALL WriteString
		CALL Crlf
		JMP  read

	good_input:										; if input is good
		CMP EAX, 5									;compare 5
		JA bad_input								; if its above that means its out of range
		CMP EAX, 1									; compare to 1
		JB bad_input								; if its below that means its out of range
		MOV menu_selection, EAX						; we jump to bad_input if its out of reange, other wise we move EAX
		RET

get_menu_option ENDP


compute_option PROC
	MOVSX EAX, first_val							; Move first val into EAX	
	MOVSX ECX, second_val
													; We need to use EAX, EBX, and EDX for sum, sub etc so this is good
													; if statement chain essentially
	CMP [menu_selection], 1
	JE addition										; jump to sum if it equals 1

	CMP [menu_selection], 2
	JE subtraction									; jump sub if it equals 2

	CMP [menu_selection], 3							; jump to multiplication if it equals 3
	JE multiplication

	CMP [menu_selection], 4							; do divison if it equals 4
	JE division

	CMP [menu_selection], 5							; if its 5, we exit
	JE exit_program
	
	addition:
		ADD EAX, ECX								; add first val and second val
		MOV result, EAX								; store in result

		MOV EDX, OFFSET computation_prompt			; This is for printing the final prompt
		CALL WriteString
		CALL Crlf
		MOV EDX, OFFSET sum_prompt
		CALL print_result


		JMP done

	subtraction:
		SUB EAX, ECX								; Subtract first_val - second_val
		MOV result, EAX								; move EAX into result which is also result

		MOV EDX, OFFSET computation_prompt			; This is for printing the final prompt
		CALL WriteString
		CALL Crlf
		MOV EDX, OFFSET sub_prompt
		CALL print_result

		JMP done


	multiplication:
		MOV EBX, ECX								; move second val in EBX
		IMUL EBX									; inplace mult of second val with EAX
		MOV result, EAX								; mov the result into result from EAX

		MOV EDX, OFFSET computation_prompt			; This is for printing the final prompt
		CALL WriteString
		CALL Crlf
		MOV EDX, OFFSET mult_prompt
		CALL print_result

		JMP done

division:
	MOV EBX, ECX
    CMP EBX, 0										; check if EBX is 0 for zero div
    JE zero_div                                     ; jump if division by zero

    TEST AX, AX                                     ; test the sign of the first value
    JNS positive_dividend                           ; if its not signed we jump

    MOV EDX, 0FFFFFFFFh                             ; signed so we fill it up with a negative compliment
    JMP perform_division                            ; do division

positive_dividend:
    XOR EDX, EDX                                    ; if it is positive, we clear EDX

perform_division:
    IDIV EBX                                        ; signed division with EBX


    MOV result, EAX                                 ; store the result in result from EAX and print the value

    ; Print the computation result
    MOV EDX, OFFSET computation_prompt
    CALL WriteString
    CALL Crlf
    MOV EDX, OFFSET div_prompt
    CALL print_result

    JMP done


	zero_div:
		MOV EDX, OFFSET zero_div_prompt				; print the bad zero div prompt
		CALL WriteString
		CALL Crlf
		MOV result, 0								; move zero into result for error handling and continue

		MOV EDX, OFFSET computation_prompt			; This is for printing the final prompt
		CALL print_result

		JMP done

	done:										; Once done return
		RET
compute_option ENDP

print_result PROC									; Added this to shorten the program since it was just bad programming on my part
		CALL WriteString
		MOVSX EAX, first_val							; Mov first_val into EAX and sign fill it
		CALL WriteInt								; Print the signed integer
		MOV EDX, OFFSET and_word
		CALL WriteString
		MOVSX EAX, second_val							; Move second val into EAX and sign fill
		CALL WriteInt								; Print the integer
		MOV EDX, OFFSET is_word
		CALL WriteString
		MOV EAX, result								; Mov result into eax and print it
		CALL WriteInt
		CALL Crlf
		RET
print_result ENDP

exit_program:									; We exit the program if the user inputs 5
	MOV EDX, OFFSET exit_prompt					; Write a good bye message
	CALL WriteString

END main