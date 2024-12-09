INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

;---------------------------------------------------------------------------------
; Program name: Float-Rounder.asm
; Program description:  This program accepts a floating point input and precision between 1 and 4. It then rounds the float to that precision
;
; Creation Date: 11/9/24;
;---------------------------------------------------------------------------------



.data
; ------------------ STRINGS ------------------
repeat_string		BYTE "Would you like to enter a new value? " ,0
bad_input			BYTE "Invalid input, please enter again."	   ,0
range_string		BYTE "Selection is out of range. Selection must be between 1-4.",0
precision_string	BYTE "Enter a Precision amount (1-4): ",0
float_string		BYTE "Enter a floating-point number: ",0
rounded_result      BYTE "Rounded Number: ",0
exit_string			BYTE "Exiting program.",0

; ------------------ DATA ------------------
precision		DWORD 0										; Store the precicion.
original_number REAL8 ?										; Store the original floating-point
integer_number  DWORD ?										; Store the factor for rounding operation
rounded_number  REAL8 ?										; This stores the final rounded number
factor			DWORD ?										; Store the factor for converting and precision

.code

															; Decided to code a bit different and make everything a procedure
main PROC
	FINIT													; Initilize floating stack
	FLD original_number										; Push the float onto the stack

	main_prog:
		CALL read_float										; Read a float and put it on the stack
		CALL get_precision_selection						; This will get the float precision.
		CALL calculate_multiplier							; Calculate the multiplier based on the precision
		CALL round											; Round the floating point based on multiplier

		MOV EDX, OFFSET rounded_result						; Move the result string to EDX
		CALL WriteString									; Print the rounded number
		FLD rounded_number									; Load the rounded numver
		CALL WriteFloat										; Write the float result
		CALL Crlf


		CALL repeat_program									; This will do the repeat program procedure and get the user input
		CMP EAX, 0											; If the user wants to exit the program jump to end_program
		JE end_program

		JMP main_prog										; Else, repeat the program and jump to main_prog

	RET

main ENDP

;---------------------------------------------------------------------------------
; This procedure prints the repeat_string prompt, and asks the the user if they want to repeat the program
; If they enter 'y' or 'Y', the program will repeat. Else, it will end the program
; Output: EAX = 1 (Repeat the program)
; Output: EAX = 0 (Exit the program)
;---------------------------------------------------------------------------------
repeat_program PROC
	MOV EDX, OFFSET repeat_string
	CALL WriteString

	CALL ReadChar											; read char (y or Y to restart, other characters will end it)
	CALL WriteChar											; echo char back on screen so its visible. Irvine does not echo by default.

	CALL Crlf

															; logic to check if char is Y or y, otherwise exit
	CMP AL, 59h												; capital Y in hex. Checking if AL == Y
	JE set_repeat											; jump if equals to main_loop since we are restarting
	CMP AL, 79h												; lowercase y in hex.  Checking if AL == y
	JE set_repeat											; jump if equals to main_loop since we are restarting
															; else exit
	MOV EAX, 0												; Mov 0 into EAX showing the user wants to exit
	RET

	set_repeat:												; Move 1 into EAX meaning the user wants to repeat
		MOV EAX, 1
		RET

repeat_program ENDP


;---------------------------------------------------------------------------------
; This gets input 1-4. If the user exceeds or goes below the range it will print an error and restart. 
; It will place the precision result in `precision`
;---------------------------------------------------------------------------------
get_precision_selection PROC
	read:													; Read label. This reads the decimal
		MOV EDX, OFFSET precision_string					; This prints the selection input prompt
		CALL WriteString

	    CALL ReadDec										; This will call ReadDec to get an unsigned value
        JNC good_read										; If it doesnt carry its good input
	    JMP bad_read										; Else, jump to the bad read label

	bad_read:
		MOV EDX,OFFSET bad_input							; This will print the bad input string
        CALL WriteString
	    CALL Crlf
        JMP read											; We then jump back to read to take in input again

	out_of_range:											; Out of range label if its below 1 or above 4
		MOV EDX, OFFSET range_string						; Print the 1-4 error message
		CALL WriteString
		CALL Crlf
		JMP read											; Jump to read for more input

	good_read:												; If we get good unsigned input, we can then filter
		CMP EAX, 1											; Compare EAX to 1
		JB out_of_range										; If its below, we jump to the out of range label
		CMP EAX, 4											; Compare EAX to 4
		JA out_of_range										; If its above, we jump to out of range label
		
		MOV precision, EAX
		RET													; Finally, we return if its within range. 

get_precision_selection ENDP


;---------------------------------------------------------------------------------
; This will read a float and store it in original_number
;---------------------------------------------------------------------------------
read_float PROC
	MOV EDX, OFFSET float_string
	CALL WriteString

	CALL ReadFloat											; Call read float and put value on stack
	FSTP original_number									; Store the floating point number from stack and pop into original_number

	RET

read_float ENDP

;---------------------------------------------------------------------------------
; This will calculate the multiplier factor based on precision. 
; 10^precision
;---------------------------------------------------------------------------------
calculate_multiplier PROC
	MOV ECX, precision						; Move precision into ECX for the loop count
	MOV EAX, 1
	MOV EBX, 10								


	multiplier_loop:						; Will essentially keep multiplying the previous result (10*1, 10*10, 10*100...)
		MUL EBX								; Multiply EBX * EAX
		loop multiplier_loop				; Loop again
	MOV factor, EAX
	RET
calculate_multiplier ENDP

;---------------------------------------------------------------------------------
; This will round the original_number and place it into rounded_number based on precision
;---------------------------------------------------------------------------------
round PROC
	FLD original_number						; Load the original float onto stack
	FILD factor								; Load the integer onto stack
	FMUL									; multiply factor * original number

	FISTP DWORD PTR [integer_number]		; Store the integer result

	FLD integer_number						; Load the integer onto the stack

	FDIV factor								; Divide integer by the factor
	FSTP rounded_number						; Pop the number and store it in rounded_number for final result
	RET
round ENDP

end_program:
    FWAIT
    FINIT									; Seems like I had to remove the values that were in the stack.
    MOV EDX, OFFSET exit_string
    CALL WriteString
    CALL Crlf
    RET

END main
