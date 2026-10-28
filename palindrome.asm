; CSC 3410 - Assignment 3: Testing Palindromes
; Name: Laurae Thaete

BITS 32

SYS_EXIT  equ 1
SYS_READ  equ 3
SYS_WRITE equ 4
STDIN     equ 0
STDOUT    equ 1
BUFSIZE   equ 1024

segment .data
    prompt     db "Please enter a string:", 0xA
    prompt_len equ $-prompt

    yes_msg    db "It is a palindrome", 0xA
    yes_len    equ $-yes_msg

    no_msg     db "It is NOT a palindrome", 0xA
    no_len     equ $-no_msg

segment .bss
    buf resb BUFSIZE

section .text
    global main

main:
    ; write(1, "Please enter a string:\n", 23);
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; count = read(0, buf, 1024);
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, buf
    mov edx, BUFSIZE
    int 0x80

while_loop:
    ; EOF / error -> exit
    cmp eax, 0
    jle exit

    ; while (buf[0] != '\n')
    cmp byte [buf], 10
    je exit

    ; count-- 
    dec eax                

    ; is_palindrome
    push eax               
    push buf                
    call is_palindrome
    add esp, 8            

    cmp eax, 0
    je not_pal

    ;("It is a palindrome")
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, yes_msg
    mov edx, yes_len
    int 0x80
    jmp ask_again

not_pal:
    ;("It is NOT a palindrome")
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, no_msg
    mov edx, no_len
    int 0x80

ask_again:
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, buf
    mov edx, BUFSIZE
    int 0x80

    jmp while_loop

exit:
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80




; int is_palindrome
; returns 1 in EAX if palindrome, 0 otherwise (cdecl)

is_palindrome:
    push ebp                
    mov ebp, esp
    push esi               
    push edi

    ; esi = &buf[0]          (i)
    mov esi, [ebp + 8]      
    ; ecx = len
    mov ecx, [ebp + 12]     
    ; edi = &buf[len-1]      (j)
    lea edi, [esi + ecx - 1]
    mov edx, ecx
    ; edx = len / 2 (loop count)
    shr edx, 1              

.loop:
    test edx, edx          
    jz .yes
    mov al, [esi]
    cmp al, [edi]          
    jne .no
    ; i++
    inc esi  
    ; j--               
    dec edi                 
    dec edx
    jmp .loop

.yes:
    mov eax, 1
    jmp .done

.no:
    xor eax, eax

.done:
    
    pop edi                 
    pop esi
    pop ebp                
    ret
