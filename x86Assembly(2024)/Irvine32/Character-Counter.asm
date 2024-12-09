; **********************************************************************;
; Program Name: Character-Counter.asm;
; Program Description: Uses the string compresser, and then counts the number of each character and displays them. 
; Creation Date: 10/19/24;
;*********

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
													;Static Data
alphabet BYTE "abcdefghijklmnopqrstuvwuxyz",0
excludeCharacters BYTE "0123456789.;,:!?'`()[]{}<>|-_+=*&@#%$^~ ", "/", 92, 34, 0
													; 34 is double quote (")
													; 92 is backslash (\)
													

													;Prompts
prompt BYTE "Please enter a string of 100 characters or less: ", 0
repeatPrompt BYTE "Enter a new string (y/n)? ", 0
originalPrompt BYTE "The original string entered was: ", 0
modifiedPrompt BYTE "The compressed string is: ", 0

													;Dynamic Data
originalString BYTE 101 dup(?)						;string to hold the original string
compressedString BYTE 100 dup(?),0					;final string for the compressed version of originalString
charIn BYTE 0										;charIn for the Y/N response for retrying
counts DWORD 26 DUP(0)
	
.code
main PROC

	main_loop:
	MOV EDX, OFFSET prompt							;print the prompt
	CALL WriteString
	CALL Crlf

	MOV EDX, OFFSET originalString					;move the string into EDX
	MOV ECX, 100		;move the length into ECX
	CALL ReadString ; read the string
	MOV [originalString+100], 0						;add null terminator

    CALL remove ;call the remove proecure a

	MOV EDX, OFFSET originalPrompt					;move the prompt into EDX to print it
	CALL WriteString
	CALL Crlf
    MOV EDX, OFFSET originalString					;move the original string to print it
    CALL WriteString
	CALL Crlf

	MOV EDX, OFFSET modifiedPrompt					;move the modified prompt into edx to print it
	CALL WriteString
	CALL Crlf
    MOV EDX, OFFSET compressedString				;move the modified string to print it
    CALL WriteString

	CALL Crlf
	CALL Crlf

	CALL count										;calling count procedure to fill counts array
	CALL display_alphabet							; we then display the alphabet with display_alphabet procedure
	CALL display_counts								; we then display all of the counts for each letter underneath

	CALL clear_counts								;clear the counts array / set all to 0 for the next possible loop.

	MOV EDX, OFFSET repeatPrompt				    ; prints the repeat prompt option
    CALL WriteString
    CALL ReadChar									;read char (y or Y to restart, other characters will end it)
    MOV charIn, AL									;move AL into charIn
    CALL WriteChar									;echo char back on screen so its visible. Irvine does not echo by default.

    CALL Crlf
	CALL Crlf

													;incase we accept more input, just wipe both buffers for the next loop
	MOV EDX, OFFSET originalString
	CALL flush_string								;Flush the original string / clear it
	MOV EDX, OFFSET compressedString
	CALL flush_string								;Flush the compressed string / clear it


													;logic to check if char is Y or y, otherwise exit
    CMP AL, 59h										;capital Y in hex. Checking if AL == Y
    JE main_loop									;jump if equals to main_loop since we are restarting
    CMP AL, 79h										;lowercase y in hex.  Checking if AL == y
    JE main_loop									;jump if equals to main_loop since we are restarting
													;else exit

    CALL WaitMsg									;wait for the user to click a button to close console


main ENDP

remove PROC
    MOV ESI, 0										;index for originalString
    MOV EDI, 0										;index for compressedString

	scan_loop:
		MOV AL, [originalString+ESI]				;move the original string value at ESI+originalString into AL
		CMP AL, 0									;check if at end of string
		JE done										;check if its equal and move to "done" loop

		INC ESI										;else, inc ESI and set ECX to 0
		MOV ECX, 0									; index for excludeCharacters
		JMP check_exclude							;start the loop check again

	check_exclude:
		MOV AH, [excludeCharacters+ECX]
		CMP AH, 0									;check if at end of string. No matches
		JE no_match									;if we reach the end null terminator, we can confirm there are no exclusion characters

		CMP AL, AH									;if they match, we just skip since we only want non matching characters
		JE skip										;skip
		
		INC ECX										;increment ECX for next loop
		JMP check_exclude							;Repeat the loop

	skip:											;I just made this so its easier to debug
		JMP scan_loop								;Just jumps back to scan_loop.

	no_match:
		MOV BYTE PTR [compressedString+EDI], AL		;if no match, we move the AL value into the compressed String array with EDI
		INC EDI
		JMP scan_loop								;we then increment the compressed index, and loop again

	done:
		MOV [compressedString+100], 0				;we finally add the null operator at the end and return
		RET

remove ENDP


count PROC
	MOV EDX, OFFSET compressedString				;move compressed string offset into EDX
	MOV EBX, OFFSET counts							;move counts offset into EBX
	MOV ECX, 0										;Move 0 into ECX for string iteration
	string_iterate:
		MOV AL, [EDX+ECX]							;char at ecx inside the string
		CMP AL, 0									;compare null terminator to string
		JE end_iterate								;if its null, end the iteration

		CMP AL, 'Z'									;upper bound of upper-case ascii
		JLE lowercase								;lower case it if its uppercase
													;else we jump to compare
		JMP compare
	
	lowercase:
		OR AL, 00100000b							;convert to lowercase so we can compare
		JMP compare									;compare to lowercase array

	compare:
		SUB AL, 'a'									;subtract from 'a' to find the lowercase offset
		MOVZX EAX, AL								;zero fill AL into EAX 
		INC DWORD PTR [EBX + EAX*4]					;increment the count for this letter
		INC ECX										;increment ECX for the next character
		JMP string_iterate							;jump to the next character to continue checking counts
		
	end_iterate:									;once done, we return
		RET
count ENDP

clear_counts PROC									;we use this for clearing the counts in case the user wants a new string
	MOV EBX, OFFSET counts							;move counts offset into EBX
	MOV ECX, 26										;move 26 into ECX since 26 chars
	MOV EAX, 0										;set EAX to 0. This is so we can set each char in counts to 0. for the next loop
	clear_loop:
		MOV [EBX], EAX								;set each char to 0 from EAX
		ADD EBX, 4									;4 since Im using DWORDs. Increase the index
		loop clear_loop								;continue looping until ECX == 0
	RET												;return once done looping

clear_counts ENDP

display_alphabet PROC								;this procedure will display the alphabet like: " A B C D..."
	MOV EBX, OFFSET alphabet						;move alphabet offset into EBX
	; uppercase it all
	MOV ECX, 26										;26 characters , so we move 26 into ECX

	display_alphabet_loop:
		MOV AL, ' '									;move a space and print it before each character
		CALL WriteChar 

		MOV AL, [EBX]								;move the lowercase character from EBX into AL
		XOR AL, 00100000b							;make it uppercase by changing the 6th bit
		INC EBX										;inrement EBX so we can iterate to the next character
		CALL WriteChar   
		loop display_alphabet_loop

													;I could have just made an uppercase alphabet, or used it to check, but I realized too late.
	CALL Crlf
	RET
display_alphabet ENDP

display_counts PROC									;this will display the count of each character. " 1 0 0 1" and so on
	MOV EBX, OFFSET counts							; move counts offset into EBX
	MOV ECX, 26										;move 26 into ECX since we have 26 elements in the counts array

	display_counts_loop:
		MOV AL, ' '									;print a space before each count
		CALL WriteChar

		MOV EAX, [EBX]								;move the count into EAX from EBX
		ADD EBX, 4									;add 4 to EBX since we are using DWORDs
		CALL WriteDec								;print the count to screen
		loop display_counts_loop
	CALL Crlf
	RET												;Return once we are done printing everything

display_counts ENDP

													;Input EDX is the string offset position
													;this makes the entire input string set to 0
flush_string PROC USES EAX ECX
	MOV ECX, 0										;set the index to 0 so we can loop

	replace_loop:
		MOV AL, [EDX+ECX]
		CMP AL, 0									;check if at end of string
		JE string_done								;check if its equal and move to "string_done" loop

		MOV [EDX+ECX], BYTE PTR 0					;set each chracter to null
		INC ECX										;increment loop
		JMP replace_loop							;start again

	string_done:									;return once done
		RET
flush_string ENDP	


END main