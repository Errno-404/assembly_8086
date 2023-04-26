.model small ; ustawiamy model na small, aby mieć pewność, że segmenty zajmują maksymalnie 64kB w pamięci
.stack 100h ; ustawiamy stos na 

.data
num1 dw ?
num2 dw ?
result dw ?
operator db ?

message1 db "Enter first number: $"
message2 db "Enter operator (+, -, *): $"
message3 db "Enter second number: $"

message4 db "Result: $"

.code
main proc
    mov ax, @data
    mov ds, ax
    
    ; Get first number
    lea dx, message1
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    sub al, 30h
    mov num1, ax
    
    ; Get second number
    lea dx, message3
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    sub al, 30h
    mov num2, ax
    
    ; Get operator
    lea dx, message2
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    mov operator, al
    
    ; Perform calculation
    cmp operator, '+'
    je add_numbers
    
    cmp operator, '-'
    je subtract_numbers
    
    cmp operator, '*'
    je multiply_numbers
    
    
    ; Unknown operator
    jmp unknown_operator




; funkcja dodająca do siebie 2 liczby i wyświetlająca wynik
add_numbers:
    mov ax, num1
    add ax, num2
    mov result, ax
    jmp print_result





; funkcja odejumująca od liczby num1, liczbę num2 i wyświetlająca wynik    
subtract_numbers:
    mov ax, num1
    sub ax, num2
    mov result, ax
    jmp print_result


; funkcja wykonuje mnożenie num1 * num2 i wykonuje skok do funkcji wyświetlającej wynik
multiply_numbers:
    mov ax, num1
    mul num2
    mov result, ax
    jmp print_result

    
unknown_operator:
    mov dx, offset message4
    mov ah, 09h
    int 21h
    mov ax, 0
    jmp end_program
    
print_result:
    ; Display result
    mov dx, offset message4
    mov ah, 09h
    int 21h
    
    mov ax, result
    add ax, 30h
    mov dl, ah
    mov ah, 02h
    int 21h
    
    mov dl, al
    mov ah, 02h
    int 21h
    
end_program:
    mov ah, 4ch
    int 21h
main endp

end main
