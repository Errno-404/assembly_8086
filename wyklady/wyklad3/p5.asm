code1 segment
start1:			
		mov 	ax, seg stos1 
		mov 	ss, ax
		mov 	sp, offset wstos1
;-----------------------------------------
		
		mov		al, 3;tekstowy
		mov		al, 13h;320x200 i 256 kolorów
		mov		ah, 0;zmień tryb graficzny
		int		10h
		
		
		
		mov		word ptr cs:[x], 160
		mov		word ptr cs:[y], 50
		mov		byte ptr cs:[k], 111
		call	zapal_punkt
		
		
		
		mov		word ptr cs:[x], 160
		mov		word ptr cs:[y], 51
		mov		byte ptr cs:[k], 111
		call	zapal_punkt
		
		
		
		
		mov		word ptr cs:[x], 161
		mov		word ptr cs:[y], 50
		mov		byte ptr cs:[k], 111
		call	zapal_punkt
		
		
		
		
		
		mov		word ptr cs:[x], 161
		mov		word ptr cs:[y], 51
		mov		byte ptr cs:[k], 111
		call	zapal_punkt
		
		
		
		
		
		
		
		
		; czekaj na dowolny klawisz
		xor		ax, ax
		int 	16h
		
		
		; po skończeniu grafiki
		mov		al, 3;tekstowy
		mov		ah, 0;zmień tryb graficzny
		int		10h
		
;-----------------------------------------
		;uproszczone wyjście
		mov 	ax, 4c00h
		int		21h


; obiektowość wg pana doktora
;--------------------------------

x		dw		?
y		dw		?
k		db		?
zapal_punkt:
	; zapalanie punktu o zadanym adresie
		mov		ax, 0A000h
		mov		es, ax
		mov		ax, word ptr cs:[y]
		mov		bx, 320
		mul		bx ; wykorzystuje ax i niszczy dx
		mov		bx, word ptr cs:[x]
		
		add		bx, ax ; bx = 320 * y + x
		mov		al, byte ptr cs:[k]
		mov		byte ptr es:[bx], al
		
	
	
	ret
;--------------------------------






code1 ends


stos1 segment stack
		dw		300	dup (?)
wstos1	dw		?
stos1 ends


end start1