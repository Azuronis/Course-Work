; **********************************************************************;
; Program Name: Pair-Swap.asm;
; Program Description: Swaps every pair of values in an even numbered array;
; Date: 9/21/24;
; **********************************************************************;




.386
.model flat,stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword

.data
array DWORD 1,2,3,4,5,6,7,8
index1 DWORD 0
index2 DWORD 1

.code
main proc
    MOV ECX, LENGTHOF array / 2                 ; half since we are moving from both ends

loop_label:
    MOV EAX, index1                             ; move index1 into EAX
    MOV EDX, index2                             ; move index2 into EDX

    MOV EBX, [array + EAX * 4]                  ; grab the value for Index1
    MOV ESI, [array + EDX * 4]                  ; grab the value for Index2
    MOV [array + EAX * 4], ESI                  ; move the values to the swapped
    MOV [array + EDX * 4], EBX

    ADD index1,2                                ; inc by 2 since we are moving 2 indexes ahead to the next
    ADD index2,2

    loop loop_label
    MOV EAX, array ;2
    MOV EAX, [array+6*4] ; 8

    invoke ExitProcess, 0
main endp
end main
