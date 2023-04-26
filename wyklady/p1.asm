; assume cs:kod , ds:dane

dane segment
	napis db "test $"
dane ends

kod segment
start:
	mov ax, seg napis
	mov ds, ax
	mov dx, offset napis
	mov ah, 9
	int 21h

	mov al, 0
	mov ah, 4ch
	int 21h
kod ends
end start