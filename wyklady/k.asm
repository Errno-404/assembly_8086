DATA SEGMENT
    ; Define an array to store the input string
    inputStr DB 20 DUP(?)
    ; Define a variable to store the integer value of the input
    intValue DW 0
DATA ENDS



CODE SEGMENT
start:
    ASSUME CS:CODE, DS:DATA, SS:stos1

    ; Read the input string from the user
    MOV AH, 0Ah ; Interrupt number for reading a string
    LEA DX, inputStr ; Load the address of the input buffer
    MOV CX, 20 ; Maximum number of characters to read
    INT 21h ; Read the string

    ; Convert the input string to an integer value
    MOV AX, 0 ; Initialize the integer value to zero
    MOV BX, 0 ; Initialize the index to zero
parse_loop:
    CMP BYTE PTR [inputStr+BX], 0Dh ; Check for end of string
    JE parse_done
    CMP BYTE PTR [inputStr+BX], ' ' ; Check for space character
    JE parse_next
    MOV DX, 0 ; Clear DX register
    MOV DL, BYTE PTR [inputStr+BX] ; Load current character into DL
    CALL parse_digit ; Convert the digit to an integer value
    ADD AX, CX ; Add the digit value to the integer value
    INC BX ; Increment the index value
    JMP parse_loop

parse_next:
    INC BX ; Increment the index value
    JMP parse_loop

parse_done:
    MOV intValue, AX ; Store the integer value in memory

    ; Display the integer value on the screen
    MOV AH, 02h ; Interrupt number for displaying a character
    MOV DL, ' ' ; Display a space character
    INT 21h
    MOV AX, intValue ; Move the integer value into the AX register
    ADD AX, 30h ; Convert from binary to ASCII
    MOV DL, AH ; Move the first digit into the DL register
    INT 21h
    MOV DL, AL ; Move the second digit into the DL register
    INT 21h

    ; Exit the program
    MOV AH, 4Ch ; Interrupt number for exiting a program
    INT 21h

parse_digit:
    ; Convert the character in DL to an integer value
    CMP DL, 'o' ; Check for 'one'
    JE digit_one
    JMP digit_error

digit_one:
    MOV CX, 1 ; Move the integer value of 1 into CX
    RET

digit_error:
    ; Handle unrecognized input characters
    MOV CX, 0 ; Set the digit value to zero
    RET

CODE ENDS

stos1 segment stack
		dw	300 dup(?)
wstos1	dw	?
stos1 ends


END start



