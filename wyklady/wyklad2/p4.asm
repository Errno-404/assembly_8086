code1 segment
start1:			
		mov 	ax, seg stos1 
		mov 	ss, ax
		mov 	sp, offset wstos1
		
		
		
		; po włączeniu programu system tworzy program segment prefix
		; to taki segment na początku segmentu programu, i tam są np
		; te attrybuty w skrócie PSP
		
		; na początku jest w ds ta linia komend, dlatego tak go używamy
		
		; ds wskazuje, a offset: 80h, 81h, 82h <- ciąg znaków
		; 80h <- ile znaków
		; 81h <- spacja
		
		; skopiować ciąg znaków z segment pref do programu, np zmienna linia
		
		mov		ax, seg lin_c
		mov		es, ax
		mov		si, 082h
		mov		di, offset lin_c
		; do pętli -> cx używamy, ale ilość znaków jest pod bajtem
		; więc zerujemy
		
		xor		cx, cx
		mov		cl, byte ptr ds:[080h]; ile znaków jest?
		
		
		; uwaga, jeśli cx jest = 0 przed pętlą, to ta pętla będzie nieskończona
petla1:
		; tą pętle można zamienić 2 instrukcjami łańcuchowymi,
		; które muszą używać si i di
		push 	cx
		mov		al, byte ptr ds:[si]
		mov		byte ptr es:[di], al
		inc		si
		inc		di
		pop		cx
		loop	petla1 ; cx - cx -1, potem czy cx == 0? if not -> skok, else exit loop
		mov		byte ptr es:[di], "$"
		
		
		mov		dx, offset lin_c
		call wypisz
		
		
		; kończenie programu
		mov		al, 0
		mov		ah, 4ch 
		int		21h

t1		db	"to jest tekst1", 10, 13, "$"
t2		db 	"to jest tekst2", 10, 13, "$"

; capacity, size, real size in memory
newline	db	10, 13, "$"
buf1	db	10, ?, 20 dup ("$")

lin_c	db	200 dup ("$")


; .........................................................

; tak tworzymy podprogramy - jako nowe etykiety
wypisz: ; in dx = offset tekstu
	mov 	ax, seg code1
	mov 	ds, ax
	
	mov 	ah, 9 ;wypisz teskt pod adresem ds:dx
	int 	21h ;przerwanie systemowe do 
		
	; na koniec wracamy z procedury
	ret

code1 ends








; tutaj nic się nie zmienia póki co

stos1 segment stack
		dw		300	dup (?)
wstos1	dw		?
stos1 ends


end start1