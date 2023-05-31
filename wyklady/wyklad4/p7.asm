code1 segment
start1:			
		mov 	ax, seg stos1 
		mov 	ss, ax
		mov 	sp, offset wstos1
;-----------------------------------------
	
		; tu coś się psuło
		;mov		al, 3;320x200 i 256 kolorów
		;mov		ah, 0;zmień tryb graficzny
		;int		10h
		
		
		;0B800h <- to miejsce w pamięci, gdzie mamy tryb tekstowy
		; każdy znak składa się z 2 bajtów - [ASCII | ATTR], gdzie attr mówi o jakiś efektach specjalnych w tym kolor itp
		
		mov		ax, 0B800h
		mov		es, ax
		mov		si, 10 * 160 + 40*2
		
		
		; tu nie ma kodów ascii dla klawiatury tylko scancody som

p1:		
		in		al, 60h
		
		cmp		al, 1
		jz		koniec
		
		cmp		al, byte ptr cs:[k1]
		je		p1
		
		mov		byte ptr cs:[k1], al
		mov		byte ptr es:[si], ' '
		mov		byte ptr es:[si +1], 00000000b
		
		
		
		cmp		al, 75 ;left
		jnz		p2
		
		dec		si
		dec		si
		
p2:		
		cmp		al, 77;right
		jnz 	p3
		inc		si
		inc 	si
		
p3:
		cmp		al, 72;up
		jnz		p4
		sub		si, 160
		
		
		
p4:
		cmp		al, 80;down
		jnz 	p5
		add		si, 160
		
p5:
		mov		byte ptr es:[si], 1
		mov		byte ptr es:[si +1], 00000100b
		jmp		p1

		
koniec:
		mov 	ax, 4c00h
		int		21h


k1		db		0

code1 ends


stos1 segment stack
		dw		300	dup (?)
wstos1	dw		?
stos1 ends


end start1