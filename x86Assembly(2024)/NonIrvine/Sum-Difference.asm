; **********************************************************************;
; Program Name: Sum-Difference.asm;
; Program Description: Sum the difference between ascending numbers in an array;
; Date: 9/21/24;
; **********************************************************************;


.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
array DWORD 0,2,5,9,10,15,17,23,25,25
sum DWORD 0
index DWORD 0

.code
main proc
MOV ECX, LENGTHOF array

loop_label:
    MOV EBX, index                      ; move index into EBX
    MOV EAX, [array + EBX * 4]          ; move the value at the index into EAX
    DEC EBX                             ; Decrement the index in EBX
    SUB EAX, [array + EBX * 4]          ; subtract the previous value with the current for the difference.
    ADD sum, EAX                        ; add the results of sum and EAX. (val1 + val2 from the array)
    INC index                           ; inc index for next loop
    loop loop_label


invoke ExitProcess, 0
main endp
end main
