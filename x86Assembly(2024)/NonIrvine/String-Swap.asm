; **********************************************************************;
; Program Name: String-Swap.asm;
; Program Description: Swap a string array in-place;
; Date: 9/21/24;
; **********************************************************************;




.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
source BYTE "This is the source string",0 
target BYTE SIZEOF source DUP('#')

.code
main proc
    MOV ECX, SIZEOF source
    MOV EAX, 0                          ; Just so I can debug easier

loop_label:
    MOV EBX, SIZEOF source              ; 26
    MOV AL, [source+ECX-1]              ; -1 since null terminator. Move to lower end of EAX
    SUB EBX, ECX                        ; 26 - current Index
    MOV [target+EBX], AL                ; move AL into target
    loop loop_label

    MOV [target+EBX+1], 0               ; add null terminating

    invoke ExitProcess, 0
main endp
end main
