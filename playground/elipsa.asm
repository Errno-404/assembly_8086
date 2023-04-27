code1 segment
start1:	

		; ustawianie stosu
		mov 	ax, seg stos1 
		mov 	ss, ax
		mov 	sp, offset wstos1
;--------------------------------------------------------------
		
		; ustawianie trybu graficznego
		mov		al, 13h
		mov		ah, 0
		int		10h
;--------------------------------------------------------------
		
		
		call 	render

		
; --------------------------------------------------------------
		
		; czekaj na dowolny klawisz
		xor		ax, ax
		int 	16h
		
		; po skończeniu grafiki
		mov		al, 3;tekstowy
		mov		ah, 0;zmień tryb graficzny
		int		10h
		
		;uproszczone wyjście
		mov 	ax, 4c00h
		int		21h


; zapalanie punktu
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


; funkcja renderuje kolorowe tlo na razie, ale chcemy zrobić ifa w srodku
a		dw		?
b		dw		?
render:
		; testowe param
		
		
		; tutaj te parametry będą przekazywane przez stos1
		; najlepiej po otrzymaniu parametrów, od razu zapisać
		; ich ^2 i elo,
		; w podprogramie zabawmy się tym stosem :>
		mov		ax, 4
		mov		word ptr cs:[a], ax
		mov 	ax, 3
		mov		word ptr cs:[b], ax
		
		
		
		
		
		mov		cx, 200
row:
		push 	cx
		mov		cx, 320
col:
		; do dx wrzucamy iteracje ze stosu:
		
		; poniższa kombinacja to inaczej pick
		pop		dx 
		push 	dx
		
		push 	cx
		
		mov		ax, 200
		sub		ax, dx ; tutaj w ax mam wsp.y obliczone
		mov		word ptr cs:[y], ax ; ustawienie punktu, zaraz to zmienimy poprzez stosik

		
		mov		ax, 320
		sub		ax, cx ; tutaj mam w ax wsp.x obliczone
		mov		word ptr cs:[x], ax
		
		
	
		nop
		nop
		nop
		nop
		
		mov		ax, word ptr cs:[a]
		mul		ax
		mov		word ptr cs:[a], ax
		
		cmp		ax, 16
		je   	odd
		
		nop
		nop
		nop
		nop
		
		
		
		
		; obliczamy a^2 i b^2
		
		
		;mov		ax, word ptr cs:[a]
		;mul		ax
		;mov		word ptr cs:[a], ax
		
		
		
		;mov		ax, word ptr cs:[b]
		;mul		ax
		;mov 	word ptr cs:[b], ax
		
		
		
		;mov		ax, word ptr cs:[x]
		;mul		ax
		;mov		bx, word ptr cs:[b]
		;mul		bx
		
		;mov		dx, ax ; zapisujemy sobie wartość b^2x^2
		
		
		;mov 	ax, word ptr cs:[y]
		;mul		ax
		;mov		bx, word ptr cs:[a]
		;mul		bx
		;add 	dx, bx
		
		
		; mamy już lewą stronę elipsy
		
		
		;mov 	ax, word ptr cs:[a]
		;mov		bx, word ptr cs:[b]
		
		;mul		bx
		; prawa strona
		
		
		;mov		bx, dx
		
		
		
		;mov ax, word ptr cs:[a]
		;cmp		ax, 16
		;jnz		odd
		
		
		
		
		
		

		
		mov		byte ptr cs:[k], 111 ; ustawianie koloru	
		call 	zapal_punkt
		
odd:
		
		pop		cx
		loop	col
		
		pop 	cx
		loop	row
		
		
		ret
		


code1 ends


stos1 segment stack
		dw		300	dup (?)
wstos1	dw		?
stos1 ends


end start1