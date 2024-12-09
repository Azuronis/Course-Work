INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

;---------------------------------------------------------------------------------
; Program name: Hangman.asm
; Program description: This program makes a hangman and asks the user ot enter characters as input to try and guess the corrrect word. 
;
; Creation Date: 11/23/24;
;---------------------------------------------------------------------------------



.data
; ------------------ STRINGS ------------------
intro_string			BYTE "Welcome to Hangman!", 0
info_string				BYTE "The Hangman will gain a body part for every incorrrect guess. Try and guess the word in the least amount of tries!", 0
input_string			BYTE "Guess: ", 0
attempts_left_string	BYTE "Attempts left: ", 0
correct_string			BYTE "Correct!" , 0
answer_was_string		BYTE "The word was: ",0

repeat_string			BYTE "Would you like to play again? " ,0
exit_string				BYTE "Exiting program.",0

space					BYTE  " ", 0
head					BYTE  " ", 0							; head
left_arm				BYTE  " ", 0							; left arm
right_arm				BYTE  " ", 0							; right arm
body					BYTE  " ", 0							; body
left_leg				BYTE  " ", 0							; left leg
right_leg				BYTE  " ", 0							; right leg

; ------------------ DATA ------------------
guessed_chars			BYTE 26 DUP(0), 0						; array to store guesses
guessed_count			DWORD 0									; stores the amount of guesses
max_tries				DWORD 6									; Stores the maximum amount of tries
attempts_left			DWORD 6									; holds the number of attempts left

words					BYTE "Quartz", 0						; word array. All 6 chars long
						BYTE "Sizzle", 0
						BYTE "Eagles", 0
						BYTE "Vacuum", 0
						BYTE "Wacked", 0
						BYTE "Yachts", 0
						BYTE "Wabble", 0
						BYTE "Vacant", 0
						BYTE "Tabbed", 0
						BYTE "Pacify", 0

chosen_word_int			DWORD ?
chosen_word_string		BYTE 6 DUP(?),0
current_input_string	BYTE "______", 0						; Holds the current input string
empty_string			BYTE 6 DUP(0),0
letters_left			DWORD 6									; Holds the amount of letters left
input					BYTE 6 DUP(?),0							; Holds the input string

.code

main PROC
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
	CALL reset_hangman
	CALL Randomize
	MOV EDX, OFFSET intro_string
	CALL WriteString
	CALL Crlf

	MOV EDX, OFFSET info_string
	CALL WriteString
	CALL Crlf

    MOV EAX, 10                                              ; Move 10 into eax for the Irvine upper range
    CALL RandomRange                                         ; Generate 0-9
    MOV chosen_word_int, EAX
	;MOV EAX, 2
	MOV BX, 7
	MUL BX

	LEA EDX, [words+EAX]

    MOV ESI, EDX											; (source) move over the chosen word into the correct memory
    MOV EDI, OFFSET chosen_word_string						; (Destination)
	MOV ECX, 6												; Amount to copy
    REP MOVSB												; * Found this while trying not to loop and reset each time. Very nice

	; Debugging for chosen word
    MOV EDX, OFFSET chosen_word_string
    CALL WriteString
    CALL Crlf

	MOV ESI, 0												; reset ESI. Used as the counter for how many correct chars
	JMP game_loop

game_loop:

    MOV EDX, OFFSET attempts_left_string					; Print attemptd left
    CALL WriteString
    MOV EAX, attempts_left
	CALL WriteDec
	CALL Crlf

    CALL print_hangman										; Print the hangman
    CMP ESI, 6												; check if we have fully matched all chars to input
    JE full_match

	CMP attempts_left, 0									; check if the user has used all attempts
	JE game_over											; jump to game over if so
		
    MOV EDX, OFFSET input_string							; Print the input string
    CALL WriteString
    CALL ReadChar											; Read the input characters
    CALL WriteChar
    CALL Crlf
    MOV BL, AL												; Move the input to BL from AL

    MOV ECX, guessed_count									; Mov the guessed count to ECX for checking
    CMP ECX, 0												; compare ecx to 0 to see if there are no other characters that are the same
    JE add_guess											;add that chracter as a guess

check_guessed:
    MOV AL, BYTE PTR [guessed_chars + ECX - 1]				; move the guessed char at ECX into AL
    CMP AL, BL												; compare the guessed char to input
    JE already_guessed										; check if its already guessed and jump
    DEC ECX													; if it hasnt been guessed decrement ECX to move on
    CMP ECX, 0												; compare ecx to 0 to see if its at the end of the string
    JNZ check_guessed										; if its not at the end continue

add_guess:
    MOV AL, BL												; move the input into AL
    MOV ECX, guessed_count									; move the guessed count into ECX so that we can get the match
    MOV BYTE PTR [guessed_chars + ECX], AL					; move the input into the guessed chars to save it
    INC guessed_count										; increment the guessed count 

    MOV ECX, 6												; Move 6 into ecx for string looping
	MOV EDI, 0												; EDI is a flag (1 or 0) to see if there was an overall match
    JMP check_word

already_guessed:
    JMP game_loop

check_word:
    MOV AL, BYTE PTR [chosen_word_string + ECX - 1]					; move the chosen char from the word into AL
    OR BL, 00100000b        ; Convert word character to lowercase	; Convert both to lowercase for case matching
    OR AL, 00100000b        ; Convert word character to lowercase
    CMP AL, BL														; compare them to eachother
    JE match_found													; if they are the same move to the matching logic for checking if duplicates

    DEC ECX															; otherwise decrement guess, as the user made a wrong choice
    CMP ECX, 0
    JNZ check_word

	CMP EDI, 1
	JE pass

    DEC attempts_left												; decrement attempts left

	CMP attempts_left, 5											; logic for adding body parts of the hangman
	JE add_head
	CMP attempts_left, 4
	JE add_body
	CMP attempts_left, 3
	JE add_left_arm
	CMP attempts_left, 2
	JE add_right_arm
	CMP attempts_left, 1
	JE add_left_leg
	CMP attempts_left, 0
	JE add_right_leg

    JMP game_loop

pass:
	JMP game_loop

add_head:
	MOV [head], 'O'
	JMP game_loop
add_body:
	MOV [body], '|'
	JMP game_loop
add_left_arm:
	MOV [left_arm], '-'
	JMP game_loop
add_right_arm:
	MOV [right_arm], '-'
	JMP game_loop
add_left_leg:
	MOV [left_leg], '/'
	JMP game_loop
add_right_leg:
	MOV [right_leg], '\'
	JMP game_loop

match_found:
	MOV EDI, 1											; Set the flag for edi if we have an overall match
    MOV BYTE PTR [current_input_string + ECX - 1], AL	; move the char into the current string overrding the undersocre
    INC ESI

    DEC ECX												; decrement ecx for the next char
    CMP ECX, 0											; compare to see if its at the end
    JNZ check_word

    JMP game_loop

game_over:												; if game over print the hangman again and the answer
	CALL print_hangman
    MOV EDX, OFFSET answer_was_string
    CALL WriteString
    MOV EDX, OFFSET chosen_word_string
    CALL WriteString
    JMP done

full_match:												; if there was a full string match then return and print the correct answer
    MOV EDX, OFFSET correct_string
    CALL WriteString
	CALL Crlf
    JMP done

done:
    RET

game ENDP




;---------------------------------------------------------------------------------
; This procedure mainly just resets the state of the hangman strings. Not going to comment each line
;---------------------------------------------------------------------------------
reset_hangman PROC
    MOV [head],       ' '
    MOV [left_arm],   ' '
    MOV [right_arm],  ' '
    MOV [body],       ' '
    MOV [left_leg],   ' '
    MOV [right_leg],  ' '

    MOV ECX, 6                                       ; Reset current input
reset_loop:
    MOV [current_input_string + ECX - 1], "_"
    LOOP reset_loop

    MOV EAX, max_tries                               ; Reset attempts
    MOV attempts_left, EAX

    MOV ECX, guessed_count                           ; Clear guessed characters
    CMP ECX, 0
    JE reset_done

clear_guessed:
    MOV BYTE PTR [guessed_chars + ECX - 1], 0
    DEC ECX
    JNZ clear_guessed

reset_done:
    MOV guessed_count, 0                             ; Reset guessed count
    RET
reset_hangman ENDP


;---------------------------------------------------------------------------------
; This procedure prints the hangman string. Head, body, arms, legs. 
;---------------------------------------------------------------------------------
print_hangman PROC
	MOV EDX, OFFSET space
	CALL WriteString
	MOV EDX, OFFSET head
	CALL WriteString
	CALL Crlf

	MOV EDX, OFFSET left_arm
	CALL WriteString
	MOV EDX, OFFSET body
	CALL WriteString
	MOV EDX, OFFSET right_arm
	CALL WriteString
	CALL Crlf

	MOV EDX, OFFSET left_leg
	CALL WriteString
	MOV EDX, OFFSET space
	CALL WriteString
	MOV EDX, OFFSET right_leg
	CALL WriteString
	CALL Crlf
	
	MOV EDX, OFFSET current_input_string
	CALL WriteString
	CALL Crlf

	RET
print_hangman ENDP

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
    MOV EDX, OFFSET exit_string
    CALL WriteString
    CALL Crlf
    RET

END main
