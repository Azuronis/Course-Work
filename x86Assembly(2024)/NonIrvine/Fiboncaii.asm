; Fiboncaii.asm - Fills an array with 26 fiboncaii numbers 
; Date: 9/15/2024

.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode: dword

.data
arr dword 27 dup (0)
index1 dword 0
index2 dword 1

.code
main proc
    mov [arr+4],1 ;set first number
    mov ecx, 25 ; set loop counter to 24

    fib_loop:
        ;grab values from index1, index2 in arr
        mov eax, index1
        imul eax, 4
        mov eax, [arr+eax]
        mov edx, index2
        imul edx, 4   ;offset index by *4 (dword)
        mov edx, [arr+edx]

        add eax, edx
        mov edx, index2
        inc edx
        imul edx, 4   ;offset index by *4 (dword)
        mov [arr+edx], eax    
        
        mov eax, index2 ;move fib2+fib1 value into next array position
        mov index1, eax
        mov eax, index2
        inc eax
        mov index2, eax

        loop fib_loop

    ;104 is last byte index
    mov eax, [arr+104] ;0001DA31 = 26the dig. 121393

    invoke ExitProcess, 0
main endp
end main
