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
render:
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
		sub		ax, dx ; tutaj w ax mam wsp.x obliczone
		mov		word ptr cs:[y], ax ; ustawienie punktu, zaraz to zmienimy poprzez stosik

		
		mov		ax, 320
		sub		ax, cx ; tutaj mam w ax wsp.y obliczone
		mov		word ptr cs:[x], ax
		
		; rysowanie kolek,
		; wydajniej by bylo narysowac tylko te punkty, ktore przewiduje
		; wzor, ale do tego rownanie trzebaby rozwiazywac
		; podejscie bedzie takie, zeby testowac kazdy punkt
		
		
		
		sub		ax, 160
		mul		ax	
		mov		bx, ax ; w bx mamy zapisane (x-a)^2
		
		
		mov		ax, word ptr cs:[y]
		sub		ax, 100
		mul 	ax; w ax mamy (y-b)^2
		
		
		add		ax, bx ; (x-a)^2 + (y-b)^2
		
		mov		bx, ax
		mov		ax, 50
		mul		ax ; r^2
		
		
		
		;push 	ax
		sub		ax, 50
		;mul		ax
		cmp		bx, ax
		;pop		ax
		jl		odd
		
		;cmp		ax, bx
		;je		odd
		
		
		add		ax, 100
		;mul		ax
		cmp		bx, ax
		jg		odd
		
		
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