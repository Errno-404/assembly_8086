dane1 segment
t1	db "My first assembly programm!!! $"
t2	db "tekst2 $"
dane1 ends


code1 segment
start1:
	mov	ax, seg stos1
	mov	ss, ax
	mov	sp, offset wstos1


	mov	ax, seg dane1
	mov	ds, ax
	mov	dx, offset t2
	
	mov	ah,9 ; wypisz tekst pod adresem ds:dx <- one wskazują miejsce gdzie chcemy wypisac
	int	21h

	mov	al, 0 ; to co zwraca do systemu
	mov	ah, 4ch ; end program
	int	21h

code1 ends


stos1 segment stack
	dw	300 dup(?)
wstos1	dw	?
stos1 ends


end start1