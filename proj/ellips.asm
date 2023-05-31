.387
			
data_ 	segment

; komunikaty błędów
usage_msg					db	"Usage: ellipse.exe <2a> <2b>, where both parametrs are in range (0, 200)$"
is_digit_err_msg 			db "Parameters must be integers!$"
bounds_err_msg				db	"Parameters must be integers in range (0, 200)$"


params					db	200 dup ("$")
a	dw		0
b 	dw		0 

data_ 	ends

; ------------------------------------------
code_ 	segment
main:			
		call 	initialize
		call	parse_params
				
		mov		al, 13h 								;Uruchomienie trybu graficznego - 320 x 200 i 256 kolorów
		mov		ah, 0									;zmień tryb graficzny
		int		10h
		
		
		
		call	run
		


		call	clr_screen
		
	
		mov		al, 3	
		mov		ah, 0									
		int		10h	
exit: 
		mov 	ax, 4c00h
		int		21h

; ------------------------------------------
params_len		db 	0
initialize:
		; inicjowanie stosu i wierchołka stosu
		mov 	ax, seg stack_ 
		mov 	ss, ax
		mov 	sp, offset stack_pointer
	
	
		; pobranie liczby znaków parametru z PSP i sprawdzenie czy jest ona większa lub równa 3,
		; muszą być co najmniej 3 znaki (<cyfra> <spacja> <cyfra>), ale w tym momencie można to
		; obejść wpisując kilka spacji a po nich 2 znaki (niekoniecznie przedzielone spacją)
		xor 	cx, cx
		mov		cl, byte ptr ds:[080h]
		mov		byte ptr cs:[params_len], cl			
		
		cmp		cl, 3
		jl		usage												
	
		; przygotowanie przepisanie zawartości ds:[082h] (z PSP) do zmiennej params za pomocą
		; instrukcji łańcuchowych, gdzie cx został ustawiony powyżej
		mov		ax, seg params							
		mov		es, ax
		mov		si, 082h								
		mov		di, offset params						
		cld
		rep		movsb									
			
		; zmiana rejestru ds na segment danych, nie jest już potrzebny fragment pamięci z PSP
		mov		ax, seg data_							
		mov		ds, ax									
		
		ret												

; ------------------------------------------
usage:
		; ds musi zostać ustawiony, gdyż pierwsze możliwe wywołanie procedury znajduje się 
		; jeszcze przed pobraniem linii parametrów z PSP
		mov		ax, seg usage_msg
		mov		ds, ax
		mov		dx, offset usage_msg
		call	print
		jmp 	exit
		
; ------------------------------------------
; procedura ma za zadanie sprawdzić czy podana linia parametrów jest w formacie <arg1> ' '* <arg2>
; i przepisuje <arg1> do zmiennej a_str, a <arg2> do zmiennej b_str 
parse_params:

		; usuwanie początkowych spacji; funkcja skip_spaces zwróci rejestr di, który wskazuje na pierwszy znak, niebędący spacją
		mov		di, offset params
		mov		si, di
		xor		cx, cx
		mov		cl, byte ptr cs:[params_len]
		call	skip_spaces		
		
		
		; aktualizacja zmiennej params_len tak, aby zawierała liczbę znaków do końca linii
		mov		ax, di
		sub		ax, si
		sub		byte ptr cs:[params_len], al
			
		; ustawienie si na pierwszy znak niebędący spacją, co zostanie wykorzystane za chwilę do przepisania argumentu do zmiennej	
		mov		si, di	
		
		; obliczenie liczby znaków do przekopiowania, cx zostało wyzerowane, można więc zaoszczędzić jednego xor-a
		mov		cl, byte ptr cs:[params_len]
		mov		al, ' '
		call	skip_other_chars
		
		; aktualizacja zmiennej params_len tak, aby zawierała znaki do końca liniii pomijając wszystkie znaki
		; aż do końca argumentu pierwszego
		mov		cx, di
		sub		cx, si				
		sub		byte ptr cs:[params_len], cl
		
		
		
		
		; wywołanie procedury konwertującej napis na liczbę oraz sprawdzającej, czy parametry są w odpowiednim zakresie
		push	cx
		push	si
		push	di
		push	dx
		mov		dx, offset a
		
		
		call 	string_to_int
		
		mov		si, 0
		mov		di, 199
		call	check_bounds
		
		cmp		dl, 1
		je		bounds_err
		
		
		pop		dx
		pop		di
		pop		si
		pop  	cx
		
		; zmiana si na kolejny fragment 
		add		si, cx
		
			
		; usuwanie spacji pomiędzy dwoma argumentami, w wyniku dostajemy w rejestrze di adres na początek 2 argumentu
		mov		di, si
		mov		cl, byte ptr cs:[params_len]					
		call	skip_spaces
		
		
		; aktualizacja zmiennej param_len, teraz zawiera liczbę znaków do końca od początku 2-go argumentu
		mov		ax, di
		sub		ax, si
		sub		byte ptr cs:[params_len], al	
			
		
		; ustawienie si na pierwszy znak 2-go argumentu, aby obliczyć za chwilę z ilu znaków składa się argument 2
		mov		si, di	
		
		
		; obliczenie liczby znaków do przekopiowania
		mov		cl, byte ptr cs:[params_len]
		mov		al, ' '
		call	skip_other_chars
				

		; aktualizacja zmiennej params_len tak, aby zawierała znaki do końca liniii pomijając wszystkie znaki
		; aż do końca argumentu drugiego, a wcześniej sprawdzenie, czy liczba znaków nie jest równa 0
		mov		cx, di
		sub		cx, si
		jz		usage
		
		sub		byte ptr cs:[params_len], cl
			
		
		push	cx
		push	si
		push	di
		push	dx
		mov		dx, offset b
		
		
		call 	string_to_int
		mov		si, 0
		mov		di, 199
		call	check_bounds
		cmp		dl, 1
		je		bounds_err
		
		
		pop		dx
		pop		di
		pop		si
		pop  	cx
		
		
		add		si, cx
		
		; sprawdzanie czy nie wpisano więcej niż 2 argumentów
		cmp		byte ptr ds:[si + 1], '$'
		jnz		usage
		
		ret
		
; ------------------------------------------
skip_spaces:
		; procedura na wejściu przyjmuje rejestry di oraz cx i zwraca przez rejestr di, adres
		; pierwszego znaku, który nie jest spacją; po instrukcji repz scasb użyto dec di,
		; ponieważ scasb ustawia odpowiednie flagi i zwiększa di, a sprawdzenie flag zostawia
		; instrukcji repz, stąd konieczność zmniejszenia rejestru di
		cld
		mov		al, ' '
		repz	scasb
		dec		di		
		ret
	
; ------------------------------------------
skip_other_chars:
		; procedura na wejściu przyjmuje rejestry di, cx oraz al, gdzie rejestr al wskazuje,
		; jaki znak jest poszukiwany
		; procedura zwraca natomiast adres di pierwszej znalezionej spacji
		cld 
		repnz	scasb
		dec		di
		ret

; ------------------------------------------
var_	dw		?
string_to_int:
		; procedura zamienia napis na liczbę, parametr wejściowy cx -> mówi o liczbie znaków w napisie, napis jest w sekcji [si, di) w dx offset zmiennej 
		mov		word ptr cs:[var_], dx
		

string_iter:
		push 	cx
		
		xor		bx, bx
		mov		bl, byte ptr ds:[si]
		sub		bl, 48 ; 3 int
		
		xor		dx, dx
		mov		dl, bl ; 3
		call	is_digit
		
		cmp		dl, 1 ;  False 
		jz		is_digit_err
		
		; bl jest cyfrą
		
		; var_ = var_ * 10 + znak
		; ax = ax * 10 + bx
		mov		bp, word ptr cs:[var_]
		mov		ax, word ptr ds:[bp]
		mov		dx, 10
		mul		dx
		add		ax, bx
		
	
		mov		word ptr ds:[bp], ax
		inc si
		
			
		pop  	cx
		loop 	string_iter

		ret

; ------------------------------------------
is_digit:
		; w dl dostajemy znak  zwracamy w dl-u True (0) lub False (1)
		cmp		dl, 0
		jl		is_digit_negative

		cmp		dl, 9
		jg		is_digit_negative
		
		mov		dl, 0
is_digit_exit:

		ret
			
is_digit_negative:
		mov		dl, 1
		jmp		is_digit_exit

; ------------------------------------------
is_digit_err:
		mov		dx, offset is_digit_err_msg
		call	print
		jmp		exit

; ------------------------------------------
bounds_err:
		mov		dx, offset bounds_err_msg
		call	print
		jmp		exit

; ------------------------------------------
; zmienne "lokalne" metody run
prev_key 		db		0								; zmienna przechowująca poprzednio wciśnięty klawisz

; metoda w pętli sprawdza wciśnięte klawisze i aktualizuje kształt elipy
run:
		call	pixel_on								; do testów tylko!

get_key:
		in		al, 60h									; do al wrzucamy klawisz wciśnięty
		cmp		al, 1									; jeżeli wciśnięto escape, to zakończ program
		jz		break_run					
		
		cmp		al, byte ptr cs:[prev_key]				
		je		get_key									
		mov		byte ptr cs:[prev_key], al				
		
left_arrow:
		cmp		al, 75 ;left			
		jnz		right_arrow
		dec		word ptr ds:[a]
		
		mov		si, 1
		mov		di, 199
		call	check_bounds
		cmp		dl, 0										
		jz		run		; jeśli check_bounds zwróciło True, to rysuj nową elipsę i nasłuchuj klawiszy
		
		
		inc		word ptr ds:[a]						; jeśli check_bounds zwróciło False, to przywracamy a i słuchamy klawiszy
		jmp		get_key
		
right_arrow:		
		cmp		al, 77;right
		jnz 	up_arrow
		inc		word ptr ds:[a]
		
		mov		si, 1
		mov		di, 199
		call	check_bounds
		cmp		dl, 0										
		jz		run										; jeśli check_bounds zwróciło True, to rysuj nową elipsę i nasłuchuj klawiszy
		dec		word ptr ds:[a]						; jeśli check_bounds zwróciło False, to przywracamy a i słuchamy klawiszy
		jmp		get_key
		
		
up_arrow:
		cmp		al, 72;up
		jnz		down_arrow
		inc 	word ptr ds:[b]
		
		mov		si, 1
		mov		di, 199
		call	check_bounds
		cmp		dl, 0										
		jz		run										; jeśli check_bounds zwróciło True, to rysuj nową elipsę i nasłuchuj klawiszy
		
		dec		word ptr ds:[b]						; jeśli check_bounds zwróciło False, to przywracamy a i słuchamy klawiszy
		jmp		get_key
		
		
down_arrow:
		cmp		al, 80;down
		jnz 	get_key
		dec		word ptr ds:[b]
		
		mov		si, 1
		mov		di, 199
		call	check_bounds
		cmp		dl, 0										
		jz		run										; jeśli check_bounds zwróciło True, to rysuj nową elipsę i nasłuchuj klawiszy
		
		inc		word ptr ds:[b]						; jeśli check_bounds zwróciło False, to przywracamy a i słuchamy klawiszy
		jmp		get_key

break_run:
		ret
		
; ------------------------------------------
draw_ellipse:	
		call	clr_screen								; wyczyszczenie ekranu przed narysowaniem elipsy										; chwilowo dummy code rysuje sinusa
		

		
		
		mov		cx, 320					
p1:														; rysowanie elipsy ( tutaj zmiany będą na pewno)
		push 	cx
		call	sinus									; wywołanie rysowania elipsy TODO
		call 	pixel_on								; wywołanie rysowania elipsy TODO
		inc 	word ptr cs:[x]
		pop		cx
		loop 	p1
		mov		word ptr cs:[x], 0	

		ret

; ------------------------------------------
clr_screen:												; procedura czyści cały ekran (pixel po pixelu)
		mov		ax, 0a000h
		mov		es, ax
		
		xor		ax, ax
		mov		di, ax
		
		cld		
		mov		cx, 320 * 200
		rep		stosb									
	
		ret
		
; ------------------------------------------
sinus:													; (kod przeniosę do draw albo zrobię funkcję typu "bresenham"
		finit
		fild 	word ptr cs:[x] 						;float integer load
		fild	word ptr cs:[b]
		fdiv											; dzieli to co na stosie przez wierzchołek
		fsin 											; wykonaj sinus na wierzchołku stosu (zmienna x tam jest)
		fld1											; załaduj na stos 1, można też załadować pi, lub e		
		fadd											; dodaj do stosu jedynkę
		fild	word ptr cs:[a]		
		fmul	
		fist 	word ptr cs:[y] 						;float integer store
		
	
		ret

;-------------------------------------------
; zmienne "lokalne" procedury pixel_on
x		dw		?										; współrzędna x pixela
y		dw		?										; współrzędna y pixela
k		db		?										; kolor pixela

; procedura zapala pixel o współrzędnych (x, y) oraz ustawia jego kolor na k
pixel_on:
		mov		byte ptr cs:[k], 111
		mov		ax, 0A000h
		mov		es, ax
		mov		ax, word ptr ds:[b] 				; zmienić na cs:[y] 
		mov		bx, 320
		mul		bx 
		
		mov		bx, word ptr ds:[a]					; zmienić na cs:[x]
		add		bx, ax 									; bx = 320 * y + x
		mov		al, byte ptr cs:[k]						
		mov		byte ptr es:[bx], al					; ustawiamy kolor pixela o adresie [x][y] na k
		
		ret
		
; ------------------------------------------			
; ta procedura jest wywoływana po aktualizacji parametrów i jeśli zwróci False,
; parametry są przywracane do poprzedniej postaci; in: si, di

; zwraca True (0) lub False (1) poprzez rejestr dl
check_bounds:					
check_left_bound:
		cmp		word ptr ds:[a], si 		
		jl		check_bound_negative					; jeśli a <= 0, to a było 1 i zmieniono je na 0

check_right_bound:
		cmp		word ptr ds:[a], di
		jg		check_bound_negative					; jeśli a > 200, to znaczy, że zwiększyliśmy parametr a z 200 na 201
	
check_lower_bound:
		cmp		word ptr ds:[b], si 		
		jl		check_bound_negative					; jeśli b <= 0, to znaczy, że b był 1 i został zmniejszony na 0

check_upper_bound:
		cmp		word ptr ds:[b], di
		jg		check_bound_negative					; jeśli b > 200, to b był 200 i zmieniono go na 201
		mov		dl,	0									; wszystkie testy przeszły, ustawiamy dl na 0 (True)
		
end_check_bound:
		ret

check_bound_negative:
		mov		dl, 1									; jeden z testów nie przeszedł, ustawiamy dl na 1 (False) 
		jmp 	end_check_bound								
		
; -----------------------------------------
print: 													; funkcja wypisuje na ekran zawartość ds:dx
	mov 	ah, 9 
	int 	21h 
		
	ret
	
; -----------------------------------------

code_ 	ends

stack_ 	segment stack
				dw		300	dup (?)
stack_pointer	dw		?

stack_ 	ends


end main