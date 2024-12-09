INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

;---------------------------------------------------------------------------------
; Program name:  Data-Converter.asm
; Program description: This program prompts the user to select between 4 options. Decimal, Hex, Binary, and to exit.
; Depending on the choice, the user will then input some values, and it will be converted. A menu will display for the
; user to see and selection options from and see the conversions.
;
; Creation Date: 11/2/24;
;---------------------------------------------------------------------------------
; Decided to format the code better



.data
; ------------------ STRINGS ------------------
menu_options BYTE	"(1) Decimal"			, 10, 13
			 BYTE	"(2) Hexadecimal"		, 10, 13
			 BYTE	"(3) Binary"			, 10, 13
			 BYTE	"(4) Exit"				, 10, 13, 0

selection_prompt    BYTE "Please choose one of the menu options: "	 ,0
integer_prompt      BYTE "Please enter a 32-bit Decimal integer: "	 ,0
hexadecimal_prompt  BYTE "Please enter a 32-bit Hexadecimal Value: " ,0
binary_prompt		BYTE "Please enter a 32-bit Binary Value: "		 ,0

results_string		BYTE "Conversion Results: "  ,0
binary_string		BYTE "	Binary Value: "	     ,0
hexadecimal_string  BYTE "	Hexadecimal Value: " ,0
decimal_string		BYTE "	Decimal Value: "	 ,0

repeat_string BYTE "Would you like to enter a new value? " ,0
bad_input	  BYTE "Invalid input, please enter again."	   ,0
range_string  BYTE "Selection is out of range. Selection must be between 1-4."

; ------------------ DATA ------------------
decimal_value SDWORD 0							; This will hold the signed decimal value
binary_value	  BYTE 32 DUP('0'),0			; This will hold a string value of the binary result. 32 + 1 for null
hexadecimal_value BYTE 8 DUP('0'),0				; This will hold a string value of the hexadecimal result. 8 + 1 for null
menu_selection    BYTE 0						; This holds the menu selection value. 1-4

seperated_binary		BYTE 40 DUP(0),0		; 32 bits + 8 spaces. This holds the final format of binary
seperated_hexadecimal   BYTE 12 DUP(0),0		; 8 Bits + 4 spaces. This holds the final format of the hexadecimal

.code

															; Decided to code a bit different and make everything a procedure
main PROC
	main_prog:
		CALL display_menu									; This will print the menu options
		CALL get_menu_selection								; This will place the menu selection into menu_selection
		CALL execute_menu_selection							; This will then do the selection option. Eg. Binary input, Hex input
		
		CALL format_binary									; Format the final result of binary and place it in seperated_binary
		CALL format_hexadecimal								; Format the final result of hex and place it in seperated_hexadecimal
		CALL display_conversions							; This will then display all of the values. Integer, Hex, and Binary
		
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
; This procedure will format the binary in groups of 4. (1111 1111) from the binary_value
; It will then place the seperated binary into seperated_binary
;---------------------------------------------------------------------------------
format_binary PROC
	MOV ECX, 8												; 8 seperations
	MOV EDX, 0												; Index for binary_value
	MOV EDI, 0												; Index for seperated_binary

	format_loop:
		;binary_value
		;seperated_binary

		MOV AL, [binary_value+EDX]							; Move the first binary value into AL	
		MOV [seperated_binary+EDI], AL						; Move the first binary value into the seperated value. + 1 offset after first loop

		MOV AL, [binary_value+EDX+1]						; Move the second binary value into AL		
		MOV [seperated_binary+EDI+1], AL					; Move the second binary value into the seperated value. + 1 offset after first loop

		MOV AL, [binary_value+EDX+2]						; Move the third binary value into AL
		MOV [seperated_binary+EDI+2], AL					; Move the third binary value into the seperated value. + 1 offset after first loop

		MOV AL, [binary_value+EDX+3]						; Move the fourth binary value into AL
		MOV [seperated_binary+EDI+3], AL					; Move the fourth binary value into the seperated value. + 1 offset after first loop

		MOV [seperated_binary+EDI+4], ' '					; Finally move a space character into the fifth place + offset to seperate the binary

		ADD EDX, 4											; Increment by 4 since we are moving groups of 4
		ADD EDI, 5											; Increment by 5 since group of 4 + the space index
		loop format_loop									; loop again and continue the process

	MOV [seperated_binary+41], 0							; Add the null terminator at the end since it was replaced with a string
	RET
format_binary ENDP

;---------------------------------------------------------------------------------
; This procedure will format the hexadecimal in groups of 2. (FF AA) from the hexadecimal_value
; It will then place the seperated hexadecimal into seperated_hexadecimal
;---------------------------------------------------------------------------------
format_hexadecimal PROC
	MOV ECX, 4												; 4 seperations
	MOV EDX, 0												; Index for hexadecimal_value
	MOV EDI, 0												; Index for seperated_hexadecimal

	format_loop:
		;hexadecimal_value
		;seperated_hexadecimal

		MOV AL, [hexadecimal_value+EDX]						; Move the first hex value + offset into AL
		MOV [seperated_hexadecimal+EDI], AL					; Move the first hex value into seperated hex + string offset

		MOV AL, [hexadecimal_value+EDX+1]					; Move the second hex value + offset into AL
		MOV [seperated_hexadecimal+EDI+1], AL				; Move the second hex value into seperated hex + string offset

		MOV [seperated_hexadecimal+EDI+2], ' '				; Place a string in third value + string offset into seperated hex

		ADD EDX, 2											; Add 2 since we are moving up by 2 in hex value
		ADD EDI, 3											; Add 3 since we are moving by 3 in seperated hex
		loop format_loop									; Loop and repeat the formatting

	MOV [seperated_hexadecimal+13], 0						; Move a space in the last space of the string since it gets replaced. 
	RET
format_hexadecimal ENDP

;---------------------------------------------------------------------------------
; This procedure will print the menu options
;---------------------------------------------------------------------------------
display_menu PROC
	MOV EDX, OFFSET menu_options
	CALL WriteString
	RET
display_menu ENDP

;---------------------------------------------------------------------------------
; This procedure executes the selected option chosen from the menu options
; It will either take input in one of 3 forms: Integer, Binary, or Hexadecimal. Or it may exit the program
;---------------------------------------------------------------------------------
execute_menu_selection PROC
	MOV AL, menu_selection									; Move the selected menu option into AL

	CMP AL, 1
	JE decimal_input										; If EAX is 1, take in decimal input

	CMP AL, 2
	JE hexadecimal_input									; If EAX is 2, take in hexadecimal input

	CMP AL, 3												; If EAX is 3, take in binary input
	JE binary_input
															; We dont need to compare the laast value since there is 1 option left
	JMP exit_program										; If EAX is 4, exit the program

	decimal_input:											; Take in signed input
		MOV EDX, OFFSET integer_prompt						; Print the integer input prompt
		CALL WriteString

		CALL ReadInt										; Read the signed integer
		JO handle_overflow									; If overflow, jump to handle it
		MOV decimal_value, EAX

		CALL convert_int_to_bin								; This will get the binary string value of EAX
		CALL convert_int_to_hex								; This will get the hexadecimal string value of EAX
		RET

	hexadecimal_input:										; Take in hex input. 8 hex values
		MOV EDX, OFFSET hexadecimal_prompt					; Print the hex input prompt
		CALL WriteString

		CALL ReadHex_V2										; Reads 8 hex values
		CALL hex_to_int										; Converts the hex value into an integer value
		MOV decimal_value, EAX								; Move the integer value into the decimal_value
		CALL convert_int_to_bin								; This will get the binary string value of EAX from the decimal_value
		RET
	binary_input:											; Take in binary unput. 32 bits
		MOV EDX, OFFSET binary_prompt						; Print the binary input prompt
		CALL WriteString

		CALL ReadBinary										; Reads 32 bits for the binary value
		CALL bin_to_int										; Converts the 32 bits into an integer value
		MOV decimal_value, EAX								; Move the integer value into decimal_value
		CALL convert_int_to_hex								; This will get the hexadecimal string value of decimal_value
		RET
	exit_program:											; Exit the program and jump to the very bottom
		JMP end_program

	handle_overflow:										; This will handle any overflows from decimal_input
															; Error message
		MOV EDX, OFFSET bad_input
		CALL WriteString
		CALL Crlf

		MOV AL, menu_selection								; EAX is set to 0 when overflow so we need to move selection back in

		CMP AL, 1
		JE decimal_input									; If EAX is 1, take in decimal input

		CMP AL, 2
		JE hexadecimal_input								; If EAX is 2, take in hexadecimal input

		CMP AL, 3											; If EAX is 3, take in binary input
		JE binary_input

		RET
execute_menu_selection ENDP

;---------------------------------------------------------------------------------
; This procedure will print the selection prompt and handle the menu selection.
; Will handle cases where the value is below or above the range 1-4.
; Output: selection 1-4 into menu_selection value defined in .data
;---------------------------------------------------------------------------------
get_menu_selection PROC
	read:													; Read label. This reads the decimal
		MOV EDX, OFFSET selection_prompt					; This prints the selection input prompt
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
		
		MOV menu_selection, AL
		RET													; Finally, we return if its within range. 

get_menu_selection ENDP

;---------------------------------------------------------------------------------
; This procedure will convert an integer value into a binary value
; Input: decimal_value
; Output: binary_value
;---------------------------------------------------------------------------------
convert_int_to_bin PROC
	MOV EAX, decimal_value
	MOV ECX, 32												; Need to loop through EAX 32 times

	eax_loop:												; Main loop for shifting bits
		SHR EAX, 1											; Shift right into the carry flag
		JC set_one											; If its a 1, carry flag is set jump to 'set_one'
		MOV [binary_value+ECX-1], '0'						; Else move move 0 into position
		JMP next_loop										; jump to the next_loop label

	set_one:
		MOV [binary_value+ECX-1], '1'						; Set one if carry flag
		JMP next_loop										; Jump to next loop

	next_loop:
		loop eax_loop										; Loop back the eax_loop and continue
		
	RET														; Return once ECX is 0
convert_int_to_bin ENDP

;---------------------------------------------------------------------------------
; This will convert an integer value from decimal_value into a hexadecimal value
; Input: decimal_value
; Output: hexadecimal_value
;---------------------------------------------------------------------------------
convert_int_to_hex PROC
	MOV EAX, decimal_value
	MOV ECX, 8												; Will be shifting bits to the right 4 times. So 8*4 = 32 bits

	hex_loop:
		MOV BL, AL											; Keep a temporary copy of AL in BL
		AND AL, 0Fh											; Get lower 4 bits of AL by masking

		CMP AL, 9
		JLE digit_convert

		ADD AL, 55											; 10 + 55 = 'A'  (Lower bound) | 15 + 55 = 'F'. (Upper bound)
		JMP store_hex										; Jump to store the value

	digit_convert:
		ADD AL, 48											; 0 + 48 = '0'   (Lower bound) | 9 + 48 = '9'   (Upper bound)

	store_hex:
		MOV [hexadecimal_value+ECX-1], AL					; Store the hex value from AL, into the hex string
		MOV AL, BL											; Move the temp value of BL back into AL
		SHR EAX, 4											; shift the eax register right 4 times for the next 4 bits
		LOOP hex_loop										; loop and repeat. loop 8 times in total

	RET
convert_int_to_hex ENDP

;---------------------------------------------------------------------------------
; This will convert a binary value from binary_value into a integer value
; Input: binary_value
; Output: EAX integer value
;---------------------------------------------------------------------------------
bin_to_int PROC
	MOV ECX, 32												; move 32 into ECX since we are looping through 32 bits
	MOV EDX, 0												; binary index for reading the binary
	MOV EBX, OFFSET binary_value

	convert_loop:
		SHL EDX, 1											; Shift EDX left 1 bit
		MOV AL, BYTE PTR [EBX]								; Move the binary bit at EBX into AL
		INC EBX												; Increment EBX for the next bit

		SUB AL, '0'											; Subtract AL from '0' to convert it to a integer
		OR EDX, EAX											; Add the LSB from EAX into EDX
		LOOP convert_loop									; loop

	MOV EAX, EDX											; Move EDX into EAX since we are using EDX to shift the bits. Final result

	done:
		RET
bin_to_int ENDP

;---------------------------------------------------------------------------------
; This will convert a hex value from hexadecimal_value into a integer value
; Input: hexadecimal_value
; Output: EAX integer value
;---------------------------------------------------------------------------------
hex_to_int PROC
	MOV ECX, 8												; Move 8 into ECX since there are 8 hex values
	MOV EDX, 0												; Move 0 into EDX for the hex indexing
	MOV EBX, OFFSET hexadecimal_value						; Move the address of hexadecimal_value into EBX

	convert_loop:
		SHL EDX, 4											; Shift EDX left by 4 for the hex. First loop is fine since its 0 in EDX
		MOV AL, BYTE PTR [EBX]								; Move the hex value at EBX into AL
		INC EBX												; Increment EBX for the next loop and next hex value

		CMP AL, '9'											; Compare AL to '9' to see if its below and if it needs converted
		JBE convert_digit									; Convert if its below or equal
		SUB AL, 7											; Subtract 7 from AL for the character values

	convert_digit:
		SUB AL, '0'											; Subtract '0' so it becomes a integer
		OR EDX, EAX											; Move the 4 bits from EAX into EDX
		LOOP convert_loop					

	MOV EAX, EDX											; Move EDX into EAX for the final result
	RET

hex_to_int ENDP


;---------------------------------------------------------------------------------
; This will read a 32 bit binary value. 
; Output: binary_value
;---------------------------------------------------------------------------------
ReadBinary PROC
	CALL clear_binary_input
	MOV ECX, 0												; Counts the amount of input characters

	read_binary:
		
		CALL ReadChar										; Read an input character

		CMP AL, 0Dh											; Check for Carriage Return / Enter
		JE end_binary_read									; End the read if equal

		CMP AL, 08h											; If there is a backspace call handle_backspace
		JE handle_backspace

		CMP ECX, 31											; check if ECX is greater than 31
		JA read_binary										; If we have entered the max amount just continue to take input

		CMP Al, ' '											; If we get a space character print the space and loop again
		JE valid_printable

		MOV [binary_value+ECX], AL							; If we get an actual valid binary value save the value
		JMP valid_binary

	valid_binary:
		INC ECX												; Increment ECX meaning we have entered a valid binary value
		CALL WriteChar										; Print the binary value
		JMP read_binary										; Jump back to read_binary and continue

	valid_printable:
		CALL WriteChar										; Valid char. Eg. space
		JMP read_binary										; Print the space

	handle_backspace:
		CMP ECX, 0											; If ECX is 0 ignore the backspace
		JE read_binary

		DEC ECX												; Else, decrement ECX and remove the binary value
		MOV [binary_value + ECX], 0							; Remove the last binary value entered

		mov al, 08h											; backspace character
		call WriteChar

		mov al, ' '											; space character
		call WriteChar

		mov al, 08h											; backspace character
		call WriteChar										; This will just remove the character in the console

		JMP read_binary										; Jump back to read_binary and take in more input

	end_binary_read:
		MOV EDX, ECX										; move the ECX value into EDX temporaily
		CALL Crlf
		JMP filter_binary_input								; Filter the input binary values

	filter_binary_input:
		filter_loop:
			MOV AL, [binary_value+ECX-1]					; move each binary value into AL
			CMP AL, 0										; check if it has reached the last char
			JE end_filter									; If it has, end the filter

			CMP AL, '1'										; Compare AL to '1'
			JE next_char
			CMP AL, '0'										; Compare AL to '0'
			JE next_char									; If its '0' or '1' go to the next character meaning its valid input

			JMP invalid_binary								; Else its invalid input

		invalid_binary:
			MOV EDX, OFFSET bad_input						; Print the invalid prompt
			CALL WriteString
			CALL Crlf
			CALL clear_binary_input							; Clear the binary input and start over
			JMP read_binary

		next_char:
			LOOP filter_loop								; loop back into the filter_loop for the next character

		shift_string:
			MOV ECX, EDX									; Move EDX back into ECX. (Amount of input characters)
			MOV EBX, 0										; Move 0 into EBX for indexing

			push_loop:										; Essentially shifting the entire string to the right
				MOVZX EAX, BYTE PTR [binary_value+EBX]		; zero fill eax from the binary value at EBX
				PUSH EAX									; Push the binary value on the stack
				MOV [binary_value+EBX], '0'					; replace its spot with a '0'
				INC EBX										; increment EBX
				loop push_loop								; Continue shifting

			MOV ECX, EDX									; Move EDX into ECX for the last pop_loop
			MOV EBX, 31										; Move 31 into EBX for the indexing. LSB to MSB
			pop_loop:
				POP EAX										; Pop the value on the stack into EAX
				MOV [binary_value+EBX], AL					; move the value into the last position
				DEC EBX										; decrement EBX for the next bit
				LOOP pop_loop								; continue placing the values in the stack
			RET

		end_filter:
			JMP shift_string								; once done filtering, shift the string so its formatted correctly
	RET
ReadBinary ENDP


;---------------------------------------------------------------------------------
; Decided to make my own ReadHex procedure since Irvines didnt handle errors.
; This will read 8 characters and place them into hexadecimal_value. It will also filter and handle errors
; Output: hexadecimal_value
;---------------------------------------------------------------------------------
ReadHex_V2 PROC
	CALL clear_hex_input									; Clear the hexadecimal input

	MOV ECX, 0												; Counts the amount of input characters
	read_hex:
		
		CALL ReadChar

		CMP AL, 0Dh											; Check for Carriage Return / Enter
		JE end_hex_read

		CMP AL, 08h											; check for a backspace and handle it
		JE handle_backspace

		CMP ECX, 7											; check if we have used all the input availale
		JA read_hex											; If we have just keep reading input but dont do anything with it

		CMP AL, ' '											; If the user presses space print the space
		JE valid_printable

		MOV [hexadecimal_value+ECX], AL						; Move the hex value into hexadecimal_value
		JMP valid_hex										; jump to valid_hex to print the value

	valid_hex:
		INC ECX												; Increment ECX meaning we have entered a value
		CALL WriteChar
		JMP read_hex										; Print the value and loop again

	valid_printable:
		CALL WriteChar										; Print the valid printable. Eg: spaces
		JMP read_hex										; Loop again

	handle_backspace:
		CMP ECX, 0											; Check if ECX is 0, meaning we have no input
		JE read_hex											; If its equal, go back and readin input

		DEC ECX												; Else decrement ECX since we are removing a hex value
		MOV [hexadecimal_value + ECX], 0					; replace the hexadecmial value with 0

		MOV AL, 08h											; Write a backspace in the console
		CALL WriteChar

		MOV AL, ' '											; Write a string in the console
		CALL WriteChar

		MOV AL, 08h											; Then write another backspace
		CALL WriteChar

		JMP read_hex										; Jump to read more hex values

	end_hex_read:
		MOV EDX, ECX										; Once the user has pressed enter end the hex read
		CALL Crlf
		JMP filter_hex_input								; Now filter the hex input

	filter_hex_input:
		filter_loop:
			MOV AL, [hexadecimal_value+ECX-1]				; for each value move it into AL
			CMP AL, 0										; Check for null character
			JE end_filter									; If it reaches the end, end the filter

															; Check if character is 'a' - 'f'
			CMP AL, 'f'
			JA invalid_hex									; If its above, its invalid since max range
			CMP AL, 'a'										; If its above, its within 'a' and 'f'
			JA upper_case									; uppercase the value if its in between

															; Check if character is 'A' - 'F'
			CMP AL, 'F'
			JA invalid_hex									; if its after its invalid since the prev check passed
			CMP AL, 'A'										; if its after its valid since its between 'A' and 'F'
			JA next_char									; jump to the next character if its valid

															; Check if character is '0' - '9'
			CMP AL, '0'										; check the lower range
			JB invalid_hex									; If its below its invalid hex
			CMP AL, '9'										; check if its in the range of '0' to '9'
			JBE next_char									; If its below or equal to 9 its valid


		upper_case:
			AND AL, 11011111b								; Convert to uppercase.
			JMP next_char									; Go to the next character

		invalid_hex:
			MOV EDX, OFFSET bad_input						; If its invalid hex, print the error message
			CALL WriteString
			CALL Crlf
			CALL clear_hex_input							; Clear the hex input
			JMP read_hex									; Read again

		next_char:
			LOOP filter_loop								; continue filtering the hex input

		shift_string:
			MOV ECX, EDX									; Move EDX back into ECX. Amount of input characters
			MOV EBX, 0										; Move 0 into EBX for indexing

			push_loop:
				MOVZX EAX, BYTE PTR [hexadecimal_value+EBX]	; Zero fill the hex value into EAX
				PUSH EAX									; Push the hex value onto the stack
				MOV [hexadecimal_value+EBX], '0'			; Replace the spot it was in with '0'
				INC EBX										; Increment EBX for the next hex value
				loop push_loop								; Continue looping

			MOV ECX, EDX									; Move EDX into ECX again
			MOV EBX, 7										; Set EBX to 7 for the last index
			pop_loop:
				POP EAX										; pop each value from the stack 
				MOV [hexadecimal_value+EBX], AL				; Put the value starting from the end to the start
				DEC EBX										; Decrement EBX so it moves to the left
				loop pop_loop								; Continue looping
			RET

		end_filter:
			JMP shift_string

	RET
ReadHex_V2 ENDP

;---------------------------------------------------------------------------------
; This procedure will clear the hexadecimal_value array. Replaces all values with '0'
;---------------------------------------------------------------------------------
clear_hex_input PROC
	MOV ECX, 8
	clear_loop:
		MOV [hexadecimal_value+ECX-1], '0'					; Replace with '0'
		LOOP clear_loop
	MOV [hexadecimal_value+8], 0							; Add null terminator
	RET
clear_hex_input ENDP

;---------------------------------------------------------------------------------
; This procedure will clear the binary_value array. Replaces all values with '0'
;---------------------------------------------------------------------------------
clear_binary_input PROC
	MOV ECX, 32
	clear_loop:
		MOV [binary_value+ECX-1], '0'
		LOOP clear_loop
	MOV [binary_value+32], 0								; Add null terminator
	RET
clear_binary_input ENDP

;---------------------------------------------------------------------------------
; Display each result and the conversion.
;---------------------------------------------------------------------------------
display_conversions PROC
	MOV EDX, OFFSET results_string							; Prints the result string
	CALL WriteString
	CALL CRLF

	MOV EDX, OFFSET binary_string							; Prints the binary string
	CALL WriteString
	MOV EDX, OFFSET seperated_binary						; Prints the formatted binary
	CALL WriteString
	CALL Crlf

	MOV EDX, OFFSET hexadecimal_string						; Prints the hexadecimal string
	CALL WriteString
	MOV EDX, OFFSET seperated_hexadecimal					; Prints the formatted hexadecimal
	CALL WriteString
	CALL Crlf

	MOV EDX, OFFSET decimal_string							; Prints the decimal string
	CALL WriteString
	MOV EAX, decimal_value									; Prints the decimal_value
	CALL WriteInt
	CALL Crlf

	RET

display_conversions ENDP

end_program:
	END main
