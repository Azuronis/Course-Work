; **********************************************************************;
; Program Name: String-Exclusion.asm;
; Program Description: Takes input from a user, removes all exlclusion characters, and makes a compressed version;
; Creation Date: 10/5/24;
;*********

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
originalString BYTE 101 dup(?)    ;string to hold the original string
compressedString BYTE 100 dup(?),0 ;final string for the compressed version of originalString
charIn BYTE 0	;charIn for the Y/N response for retrying

excludeCharacters BYTE "0123456789.;,:!?'`()[]{}<>|-_+=*&@#%$^~ ", "/", 92, 34, 0
; 34 is double quote (")
; 92 is backslash (\)
; I had problems getting to work without specifying codes
;I also compressed it more. Didnt realize you didnt need to have everythign on a seperate line. Makes sense though. 

prompt BYTE "Enter a one-line string: ", 0
repeatPrompt BYTE "Would you like to enter a new string (y/n)? " , 0
originalPrompt BYTE "Original String: ", 0
modifiedPrompt BYTE "Compressed String: ", 0

.code
main PROC

	main_loop:
	MOV EDX, OFFSET prompt			;print the prompt
	CALL WriteString

	MOV EDX, OFFSET originalString		;move the string into EDX
	MOV ECX, 100		;move the length into ECX
	CALL ReadString ; read the string
	MOV [originalString+100], 0			;spent like 2 hours just for this single line. Forgot that ReadString doesnt add null

    CALL remove ;call the remove proecure a

	MOV EDX, OFFSET originalPrompt   ;move the prompt into EDX to print it
	CALL WriteString
    MOV EDX, OFFSET originalString   ;move the original string to print it
    CALL WriteString
	CALL Crlf

	MOV EDX, OFFSET modifiedPrompt   ;move the modified prompt into edx to print it
	CALL WriteString
    MOV EDX, OFFSET compressedString ;move the modified string to print it
    CALL WriteString
	CALL Crlf

	MOV EDX, OFFSET repeatPrompt  ; prints the repeat prompt option
    CALL WriteString
    CALL ReadChar ;read char (y or Y to restart, other characters will end it)
    MOV charIn, AL  ;move AL into charIn
    CALL WriteChar ;echo char back on screen so its visible. Irvine does not echo by default.

    CALL Crlf

	;incase we accept more input, just wipe both buffers for the next loop
	MOV EDX, OFFSET originalString
	CALL flush_string
	MOV EDX, OFFSET compressedString
	CALL flush_string

    ;logic to check if char is Y or y, otherwise exit
    CMP AL, 59h ;capital Y in hex. Checking if AL == Y
    JE main_loop ; jump if equals to main_loop since we are restarting
    CMP AL, 79h ;lowercase y in hex.  Checking if AL == y
    JE main_loop  ; jump if equals to main_loop since we are restarting
    ;else exit


    CALL WaitMsg


main ENDP

remove PROC
    MOV ESI, 0							 ; index for originalString
    MOV EDI, 0							 ; index for compressedString

	scan_loop:
		MOV AL, [originalString+ESI] ;move the original string value at ESI+originalString into AL
		CMP AL, 0 ;check if at end of string
		JE done ;check if its equal and move to "done" loop

		INC ESI ;else, inc ESI and set ECX to 0
		MOV ECX, 0						  ; index for excludeCharacters
		JMP check_exclude ;start the loop check again

	check_exclude:
		MOV AH, [excludeCharacters+ECX]
		CMP AH, 0						 ;check if at end of string. No matches
		JE no_match ;if we reach the end null terminator, we can confirm there are no exclusion characters

		CMP AL, AH  ;if they match, we just skip since we only want non matching characters
		JE skip ;skip
		
		INC ECX  ;increment ECX for next loop
		JMP check_exclude

	skip:						;I just made this so its easier to debug
		JMP scan_loop

	no_match:
		MOV BYTE PTR [compressedString+EDI], AL  ;if no match, we move the AL value into the compressed String array with EDI
		INC EDI
		JMP scan_loop  ; we then increment the compressed index, and loop again

	done:
		MOV [compressedString+100], 0 ;we finally add the null operator at the end and return
		RET

remove ENDP


; Input EDX is the string offset position
;this makes the entire input string set to 0
flush_string PROC USES EAX ECX
	MOV ECX, 0 ;set the index to 0

	replace_loop:
		MOV AL, [EDX+ECX]
		CMP AL, 0 ;check if at end of string
		JE string_done ;check if its equal and move to "string_done" loop

		MOV [EDX+ECX], BYTE PTR 0 ;set each chracter to null
		INC ECX ;increment loop
		JMP replace_loop ;start again

	string_done: ;return once done
		RET

flush_string ENDP	


END main