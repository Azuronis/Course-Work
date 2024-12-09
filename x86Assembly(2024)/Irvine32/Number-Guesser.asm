INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

;---------------------------------------------------------------------------------
; Program name: Number-Guesser.asm
; Program description: This program generates a number 1-50 and asks the user to guess it within 10 tries. The user can repeat
;
; Creation Date: 11/16/24;
;---------------------------------------------------------------------------------



.data
; ------------------ STRINGS ------------------
random_string			BYTE "A random number between 1-50 has been made. Try and guess the number!", 0
no_more_tries			BYTE "You have used all of your tries :( , better luck next time.", 0
input_string			BYTE "Guess: ", 0
attempts_left_string	BYTE "Attempts left: ", 0
too_low_string			BYTE "Too low!", 0
too_high_string			BYTE "Too high!", 0
correct_string			BYTE "Correct!" , 0
invalid_prompt			BYTE "Invalid Input!", 0
answer_was_string		BYTE "The correct number was: ",0

repeat_string			BYTE "Would you like to play again? " ,0
exit_string				BYTE "Exiting program.",0
; ------------------ DATA ------------------
number				DWORD 0									; Will store the random numver
guess				DWORD ?									; Will store the guess number
max_tries			DWORD 10								; Stores the maximum amount of tries
attempts_left		DWORD 10								; holds the number of attempts left

.code

main PROC

	CALL Randomize											; Generate a new seed based on the current time.

	main_prog:
		CALL game											; Call the game procedure

		CALL repeat_program									; This will do the repeat program procedure and get the user input
		CMP EAX, 0											; If the user wants to exit the program jump to end_program
		JE end_program

		JMP main_prog										; Else, repeat the program and jump to main_prog

	RET
main ENDP


;---------------------------------------------------------------------------------
; This procedure is sort of like the game loop. It contains all the logic for the game and holds labels.
; No input is needed as it handles the entire game and all of the logic.
;---------------------------------------------------------------------------------
game PROC
	MOV ECX,max_tries										; Set ECX to the amount of tries so it can loop that many times
	MOV attempts_left, ECX									; Reset the attempts left to the max amount of tries.


	MOV EAX, 50												; Move 50 into eeax for the irvine upper range
	CALL RandomRange										; generate 0-49
	INC EAX													; 0+1, 49+1 -> 1,50 range
	MOV number, EAX											; Move the random numver to number

	MOV EDX, OFFSET random_string
	CALL WriteString
	CALL Crlf
	JMP game_loop											; Jumpt to the game loop

	below:													; If the guess is below, we print the too low string
		MOV EDX, OFFSET too_low_string
		CALL WriteString
		CALL Crlf
		JMP next_loop
	after:													; if the guess is above, we print the too high string
		MOV EDX, OFFSET too_high_string
		CALL WriteString
		CALL Crlf
		JMP next_loop
	equal:													; If the guess is equal, its correct and then return
		MOV EDX, OFFSET correct_string
		CALL WriteString
		CALL Crlf
		RET
	next_loop:												; next loop. decrement the amount of attempts in the data, and ECX
		DEC attempts_left
		loop game_loop										; loop to the next game_loop iteration

	game_loop:
		CMP ECX, 0											; compare ecx to 0 to see if they ran out of attempts
		JE no_more											; jump to "no_more" if they have no more attempts


		MOV EDX, OFFSET attempts_left_string
		CALL WriteString
		MOV EAX, attempts_left								; Print the amount of attempts they have left.
		CALL WriteDec
		CALL Crlf
		CALL Crlf

		MOV EDX, OFFSET input_string
		CALL WriteString

		read_input:											; Reads the decimal input from the user
			CALL ReadDec
			JNC  good_input

			MOV  EDX, OFFSET invalid_prompt					; If its overflow its invalid
			CALL WriteString
			CALL Crlf
			JMP next_loop									; jump to next loop , count as guess

		invalid_input:
			MOV EDX, OFFSET invalid_prompt					; print this if invalid input and go to next loop
			CALL WriteString
			CALL Crlf
			JMP next_loop


		good_input:
			
			CMP EAX, 0										; if no overflow, check if its in range
			JBE invalid_input
			CMP EAX, 50										; check if its above 0 and below oe equal to 50
			JA invalid_input

			MOV guess, EAX									; move the guess into memory
			CMP EAX, number									; compare the number to see if its after 
			JA after
			CMP EAX, number									; check if the number is below
			JB below
			CMP EAX, number									; check if the number is equal
			JE equal
		no_more:											; Print the strings if the user has no more tries left.
			MOV EDX, OFFSET no_more_tries
			CALL WriteString
			CALL Crlf
			MOV EDX, OFFSET answer_was_string
			CALL WriteString
			MOV EAX, number									; Move the number into eax and print the answer
			CALL WriteDec
			CALL Crlf										; repeat the program
		
	RET
game ENDP

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


end_program:
    FWAIT
    FINIT									; Seems like I had to remove the values that were in the stack.
    MOV EDX, OFFSET exit_string
    CALL WriteString
    CALL Crlf
    RET

END main
