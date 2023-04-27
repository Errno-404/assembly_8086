code1 segment
start1:			
		mov 	ax, seg stos1 
		mov 	ss, ax
		mov 	sp, offset wstos1
		
		
		; argument przekazujemy przez rejestr dx
		; wołamy funkcję poprzez call
		mov		dx, offset t1
		call 	wypisz
		
		mov 	dx, offset t2
		call 	wypisz
		
		
		; kończenie programu
		mov		al, 0
		mov		ah, 4ch 
		int		21h

; tutaj możemy definiować sobie dane, bo powyżej skończył się program :>
; 10, 13 jako bezpieczna nowa linia
t1		db	"to jest tekst1", 10, 13, "$"
t2		db 	"to jest tekst2$"



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