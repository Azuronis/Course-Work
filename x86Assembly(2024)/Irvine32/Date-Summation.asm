
; **********************************************************************;
; Program Name: Date-Summation.asm;
; Description: Adds the total hours, minutes, and seconds and displays the total in all 3 formats.
; Date: 10/1/24
; **********************************************************************;

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
newline BYTE 0Dh,0Ah,0 ;newline 
period BYTE 2Eh,0 ;period string
promptBad BYTE "Invalid input, please enter again",0 ; from irvine lib

hoursPrompt BYTE "Enter the number of hours: ",0
hoursEnteredPrompt BYTE "The number of hours entered was ",0
hours DWORD ?

minutesPrompt BYTE "Enter the number of minutes: ",0
minutesEnteredPrompt BYTE "The number of minutes entered was ",0
minutes DWORD ?

secondsPrompt BYTE "Enter the number of seconds: ",0
secondsEnteredPrompt BYTE "The number of seconds entered was ",0
seconds DWORD ?

totalMinutes DWORD 0 ;stores total number of miniutes for the final calculations
totalSeconds DWORD 0 ;stores total number of seconds for the final calculations
minutesWord BYTE " minutes.",0 ; used for final output formatting
secondsWord BYTE " seconds.",0 ; used for final output formatting

totalMinutesPrompt BYTE "The total number of minutes is ",0 ; final output formatting for the totals
totalSecondsPrompt BYTE "The total number of seconds is ",0 ; final output formatting for the totals

repeatPrompt BYTE "Try again (y/n)? ",0 ; this is the prompt for repeating the program
charIn BYTE ? ; this is the input char that the input stream recieves.

.code
main PROC
    main_loop:
    ;input prompts and data collection
    MOV EAX, OFFSET hoursPrompt ; moves hour prompt address into EAX
    MOV EBX, OFFSET hours ; moves hours DWORD address into EBX
    CALL readNumber ; call the readNumber from irvine and store the final result in hours variable

    MOV EAX, OFFSET minutesPrompt ; moves minute prompt address into EAX
    MOV EBX, OFFSET minutes ; moves minutes DWORD address into EBX
    CALL readNumber ; call the readNumber from irvine and store the final result in minutes variable

    MOV EAX, OFFSET secondsPrompt ; moves second prompt address into EAX
    MOV EBX, OFFSET seconds ; moves seconds DWORD address into EBX
    CALL readNumber ; call the readNumber from irvine and store the final result in seconds variable

    CALL printNewLine ;newline ( I didnt realize there was a irvine call function for this beforehand)

    ;result output
    MOV EDX, OFFSET hoursEnteredPrompt ; moves the result prompt address into EDX
    CALL WriteString ; calls write string to print hoursEnteredPrompt
    MOV EAX, hours ;move the hours value into EAX
    CALL WriteDec  ; print EAX or hours
    CALL printPeriod ; print a period

    CALL printNewLine

    ;final values being printed
    MOV EDX, OFFSET minutesEnteredPrompt ;prints the total minutes entered
    CALL WriteString
    MOV EAX, minutes
    CALL WriteDec
    CALL printPeriod

    CALL printNewLine

    MOV EDX, OFFSET secondsEnteredPrompt ; shows the total seconds entered
    CALL WriteString
    MOV EAX, seconds
    CALL WriteDec
    CALL printPeriod

    CALL printNewLine ;newline
    CALL printNewLine

    ;total seconds and minutes calculation
    MOV EAX, hours          ;move hours value into EAX
    IMUL EAX, 60 ;minutes   ;multiply hours * 60 for total minutes
    ADD EAX, minutes        ;add all minutes to EAX (hours + minutes)
    IMUL EAX, 60 ;seconds   ;convert all hours and minutes to seconds
    ADD EAX, seconds        ; add final seconds to the hour and minute total seconds. 
    MOV totalSeconds, EAX ; mov the final seconds result into totalSeconds from EAX
    MOV EDX, 0  ;took me like 20 minutes to figure out DIV uses 2 32-bit values for 64 bits. clear EDX
    MOV EBX, 60 ;mov 60 into EBX for future div
    DIV EBX   ;divide EAX / EBX = (totalSeconds / 60) = totalMinutes
    MOV totalMinutes, EAX ;move EAX into totalMinutes
    

    ;Writing final total output
    MOV EDX, OFFSET totalMinutesPrompt ; prints the final minute line showing the final result
    CALL WriteString
    MOV EAX, totalMinutes
    CALL WriteDec
    MOV EDX, OFFSET minutesWord
    CALL WriteString
    CALL printNewLine

    MOV EDX, OFFSET totalSecondsPrompt ; prints the total seconds line showing the total calculation
    CALL WriteString
    MOV EAX, totalSeconds
    CALL WriteDec
    MOV EDX, OFFSET secondsWord
    CALL WriteString
    CALL printNewLine

    CALL printNewLine

    MOV EDX, OFFSET repeatPrompt  ; prints the repeat prompt option
    CALL WriteString
    CALL ReadChar ;read char (y or Y to restart, other characters will end it)
    MOV charIn, AL  ;move AL into charIn
    CALL WriteChar ;echo char back on screen so its visible. Irvine does not echo by default.

    CALL printNewLine

    ;logic to check if char is Y or y, otherwise exit
    CMP AL, 59h ;capital Y in hex. Checking if AL == Y
    JE main_loop ; jump if equals to main_loop since we are restarting
    CMP AL, 79h ;lowercase y in hex.  Checking if AL == y
    JE main_loop  ; jump if equals to main_loop since we are restarting
    ;else exit

    INVOKE ExitProcess,0

main ENDP

; Input: EAX as message prompt
; Input: EBX as resulting variable offset
readNumber PROC USES EAX EDX ; read number procudure.
    read:
        MOV EDX, EAX ; moves the message address prompt into EDX from EAX
        CALL WriteString ; this prints the message prompt
        CALL ReadInt ; read an integer into EAX
        JO error_loop ; if it overflows go to the error_loop
        MOV [EBX], EAX ; move EAX into EBX
        RET ; return or end the procedure

        ; error handling code. (Couldn't find a way for it to NOT print <Invalid Integer> sadly)
        ; Maybe thats why it said to edit the irvine library if we wanted.

    error_loop: 
        CALL printNewLine 
        MOV EDX, OFFSET promptBad ;move the error prompt address into EDX
        CALL WriteString ; print the error prompt
        CALL printNewLine ; make a newline
        JMP read ; jump back to the read loop to start asking for input again.

readNumber ENDP

;prints a newline. Got tired of moving EDX
;made this before I knew about irvine CALL Crlf
printNewLine PROC USES EDX
    MOV EDX, OFFSET newline
    CALL WriteString
    RET
printNewLine ENDP

;No outputs. Just prints a period
printPeriod PROC USES EDX
    MOV EDX, OFFSET period
    CALL WriteString
    RET
printPeriod ENDP

END main