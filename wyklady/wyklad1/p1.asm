; tworzymy odpowiednie segmenty - danych, kodu, stosu
; tworzymy etykietę (nazwa symboliczna) w segmencie kodu, od niej zacznie się program
; za etykietą (która jest offsetem) umieszczamy w rejestrach segmentowych stos i dane1
; na koniec programu wypisujemy to co jest ds:dx na ekran za pomocą przerwania 21h,
; a do ah umieszczamy kod 9, który odpowiada za pisanie po ekranie
; potem umieszczamy w ah 4c, co jest kodem zakończenia programu, wywołujemy ponownie przerwanie
; 
;
; ważne, aby stos zawierał wierzchołek (na dole) i miał jakąś wielkość (na górze)
; przy czym jego wielkość definiujemy słowami (dw)
dane1 segment
t1		db	"to jest tekst$"

dane1 ends

code1 segment
start1:			; nazwa symboliczna (offset)
		mov 	ax, seg stos1 ; seg wyciąga adres segmentu
		mov 	ss, ax
		mov 	sp, offset wstos1
		
		mov 	ax, seg t1
		mov 	ds, ax
		mov 	dx, offset t1
		
		mov 	ah, 9 ;wypisz teskt pod adresem ds:dx
		int 	21h ;przerwanie systemowe do 
		
		mov		ah, 4ch ; zakończ program
		int		21h
		
code1 ends


stos1 segment stack
		dw		300	dup (?)
wstos1	dw		?
stos1 ends


end start1