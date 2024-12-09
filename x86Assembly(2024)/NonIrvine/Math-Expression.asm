; **********************************************************************;
; Program Name: Math-Expression.asm;
; Description: Does (A+B-C-D) and stores the result
; Date: 9/14/2024
; **********************************************************************;


.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode: dword

.data                               ; intitialize data of choice. I chose 1s
varA dword 1
varB dword 1
varC dword 1
varD dword 1
result dword 0


.code
main proc
                                    ; (varA + varB - varC - varD)
    mov eax, varA                   ; move varA into eax
    add eax, varB                   ; add varB to varA in eax
    sub eax, varC                   ; subtract varC from eax (A+B)
    sub eax, varD                   ; subtract varD from eax (A+B-C)
    mov result, eax                 ; move final result into result var from eax
                                    ; EAX = 00000000 (1+1-1-1)=0
    
    invoke ExitProcess, 0
main endp
end main
