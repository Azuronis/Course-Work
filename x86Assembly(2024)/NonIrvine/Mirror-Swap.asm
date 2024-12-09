; **********************************************************************
; Program Name: Mirror-Swap.asm
; Program Description: Swap an array in-place from the left side to the right side mirroring the middle.
; Date: 9/21/24
; **********************************************************************




.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
array DWORD 0,2,5,9,10,15,17,23,25,25
sum DWORD 0
index1 DWORD 0
index2 DWORD (SIZEOF array) / 4 - 1         ; could also have used LENTHGOF-1 

.code
main proc
    MOV ECX, LENGTHOF array / 2             ; half since we are moving from both ends

loop_label:
    MOV EAX, index1                         ; move index1 into EAX
    MOV EDX, index2                         ; move index2 into EDX

    MOV EBX, [array + EAX * 4]              ; grab the value for Index1
    MOV ESI, [array + EDX * 4]              ; grab the value for Index2
    MOV [array + EAX * 4], ESI              ; move the values to the swapped
    MOV [array + EDX * 4], EBX

    INC index1                              ; increment and decrement both sides of index
    DEC index2

    loop loop_label

    MOV EAX, sum

    invoke ExitProcess, 0
main endp
end main
