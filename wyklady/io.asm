; Program ilustrujący instrukcje wejścia / wyjścia oraz wywoływanie funkcji

; Przenieśliśmy dane z segmentu danych do segmentu kodu, aczkolwiek nie musieliśmy

; Segment kodu zawiera główną część programu
kod segment

; etykieta start w połączeniu z ostatnią instrukcją `end start` wskazuje, gdzie program ma się zacząć
start: ; tu się zacznie wykonywanie kodu
	
	
	
	; umieszczamy w rejestrze ss adres segmentu stosu, a w sp jego wierzchołek
	mov ax, seg stos1 
	mov ss, ax
	mov sp, offset wstos


	; w rejestrze dx musi znaleźć się offset zmiennej którą chcemy wypisać
	mov dx, offset t1
	
	; wywołujemy funkcję przy pomocy `call`
	call wypisz
	

	mov dx, offset t2
	call wypisz
	
	
	; funkcja systemowa do pobierania znaków potrzebuje mieć w ds segment danych (może się zmieniać podczas wykonania)
	; natomiast w dx offset bufora, do którego czyta ciąg znaków. W ah musi znaleźć się kod funkcji 0ah, która pobiera znaki
	; na końcu przerwanie systemowe 21h
	mov ax, seg kod
	mov ds, ax
	mov dx, offset buf1
	mov ah, 0ah
	int 21h
	
	
	; teraz chcemy podziałać coś na buforze
	
	; bp zawiera adres buf1 + 1
	
	; ten newline tutaj taki sus nieco
	
	
	
	; chcąc działać coś na pamięci musimy operować na bp / bx (bp - base pointer)
	
	; bp ma adres bufora + 1
	mov bp, offset buf1 + 1 

	; do bl wpisujemy wartość jaka znajduje się pod adresem bp, z tym, że robimy to przy użyciu pointera, cs:[bp] wskazuje na 1 bajt,
	; stąd bl
	mov bl, byte ptr cs:[bp]
	
	; tu tak naprawdę przygotowujemy się do przesunięcia bp o odp. ilość bitów
	add bl, 1 
	
	; zerujemy bh, bo do adresów jest bx = bh + bl, bl mamy, ale w bh może coś być
	xor bh, bh 
	
	; przesuwamy offset bufora o bx ( o to co było w bl) + 1 ttak naprawdę można by dodać 1 do bp zamiast wcześniej do bl
	add bp, bx 
	
	; teraz jeszcze pod adres wskazywany przez nowego bp wpisujemy znak '$', szczerze tu ciężko powiedzieć po co,
	; bo późniejszy nl1 raczej załatwia sprawę samemu, ale przynajmniej wiemy jak obsługiwać bufory!
	mov byte ptr cs:[bp], '$'
	
	
	; nowa linia
	mov dx, offset nl1
	call wypisz
	
	
	; wypisz bufor
	mov dx, offset buf1 + 2
	call wypisz
	
	; kończymy program
	mov al, 0
	mov ah, 4ch
	int 21h


; zmienne wewnątrz segmentu kodu
nl1	db	10, 13,'$'
t1	 db "aaaaaaaaaa" , 13, 10, "$" ; definiujemy bajty na słowo aaaaaaaaaa, dalej bajt 13 i 10 czyli powrót karetki i enter, a na końcu $ dla DOSBOXA
t2 	db "bbbbbbbbbb", "$" ; analogicznie
buf1 db 10, ?, 20 dup('$') ; tworzymy bufor który w 1 bajcie mówi o tym ile znaków wprowadzić, ile wprowadziłem, znaki

; funkcyjki
wypisz: ; alternatywnie wypisz proc\n wypisz endp
	mov ax, seg kod
	mov ds, ax
	mov ah, 9
	int 21h
	ret
kod ends



stos1 segment stack ; tworzymy stos
		dw	300 dup(?) ; definiujemy rozmiar stosu jako 300 słów, każde o wartości obojętnej
wstos	dw	? ; definiujemy dodatkowo wierzchołek stosu
stos1 ends ; kończymy stos
end start