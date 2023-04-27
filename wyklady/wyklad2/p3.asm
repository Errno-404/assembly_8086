code1 segment
start1:			
		mov 	ax, seg stos1 
		mov 	ss, ax
		mov 	sp, offset wstos1
		
		
		mov		dx, offset t1
		call 	wypisz
		
		mov 	dx, offset t2
		call 	wypisz
		
		
		
		
		; podajemy adres bufora, do którego będą zapisywane dane
		mov		ax, seg code1
		mov		ds, ax
		mov 	dx, offset buf1
		
		; czytamy linię do bufora buf1
		mov		ah, 0ah
		int		21h
		
		
		; modyfikujemy bufor
		mov		bp, offset buf1 + 1
		
		
		; wyjaśnienie poniższych instrukcji
		; [bp] -> oznacza to co jest pod offsetem bp (u nas jest to 2 element (idx=1) bufora)
		; byte ptr -> oznacza, że chcemy zajmować się bajtem pod podanym adresem, a nie np słowem (bo niektóre operacje typu add
		; mogą działać i na bajcie i na słowie!
		
		; cs:[bp] -> chyba chodzi o to, że kiedy interesuje nas jakaś zmienna to musimy powiedzieć z jakiego segmentu jest
		; unless użyjemy ASSUME, którego jeszcze nie ogarniam xd
		mov 	bl, byte ptr cs:[bp] ;bl zawiera liczbę wczytanych znaków
		xor		bh, bh ; zerowanie rejestru bl
		add		bl, 1
		add		bp, bx
		
		; zapis do pamięci
		mov		byte ptr cs:[bp], "$"
		
			
		mov		dx, offset newline
		call wypisz
		
		; wypisz bufor
		mov 	dx, offset buf1 + 2
		call 	wypisz
		
		
		; kończenie programu
		mov		al, 0
		mov		ah, 4ch 
		int		21h

t1		db	"to jest tekst1", 10, 13, "$"
t2		db 	"to jest tekst2", 10, 13, "$"

; capacity, size, real size in memory
newline	db	10, 13, "$"
buf1	db	10, ?, 20 dup("$")


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