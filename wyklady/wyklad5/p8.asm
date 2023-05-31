.387													; w programie wykorzystany zostanie koprocesor matematyczny
		
		
data_ 	segment

a_str	db		4 dup("$")
b_str	db		4 dup("$")


a_int	dw		1
b_int 	dw		1 

data_ 	ends

; ------------------------------------------
code_ 	segment
main:			
		call 	initialize
		
		; tu będziemy najpierw parsować parametry, aby nie uruchamiać od razu graficznego, jeśli wystąpi błąd danych wejściowych
		mov		al, 13h 								;Uruchomienie trybu graficznego - 320 x 200 i 256 kolorów
		mov		ah, 0									;zmień tryb graficzny
		int		10h
		
		
		
		
		call	run
		
; po skończeniu procedury run, program zostaje zakończony
		call 	clr_screen								; wyczyść ekran przed wyjściem z programu
		mov		al, 3										
		mov		ah, 0									; zmieniamy tryb graficzny na tekstowy
		int		10h
	
		mov 	ax, 4c00h
		int		21h

; ------------------------------------------
initialize:
		mov		ax, seg data_							
		mov		ds, ax									; ustawianie segmentu danych

		mov 	ax, seg stack_ 
		mov 	ss, ax
		mov 	sp, offset stack_pointer				; ustawianie segmentu stosu i wierzchołka stosu
		
		ret	

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
		
		cmp		al, byte ptr cs:[prev_key]				; tego tu nie rozumiem
		je		get_key									; tego nie rozumiem
		mov		byte ptr cs:[prev_key], al				; tego nie czaję
		
left_arrow:
		cmp		al, 75 ;left			
		jnz		right_arrow
		dec		word ptr ds:[a_int]
		
		call	check_bounds
		cmp		dl, 0										
		jz		run										; jeśli check_bounds zwróciło True, to rysuj nową elipsę i nasłuchuj klawiszy
		inc		word ptr ds:[a_int]						; jeśli check_bounds zwróciło False, to przywracamy a_int i słuchamy klawiszy
		jmp		get_key
		
right_arrow:		
		cmp		al, 77;right
		jnz 	up_arrow
		inc		word ptr ds:[a_int]
		
		call	check_bounds
		cmp		dl, 0										
		jz		run										; jeśli check_bounds zwróciło True, to rysuj nową elipsę i nasłuchuj klawiszy
		
		dec		word ptr ds:[a_int]						; jeśli check_bounds zwróciło False, to przywracamy a_int i słuchamy klawiszy
		jmp		get_key
		
		
up_arrow:
		cmp		al, 72;up
		jnz		down_arrow
		inc 	word ptr ds:[b_int]
		
		call	check_bounds
		cmp		dl, 0										
		jz		run										; jeśli check_bounds zwróciło True, to rysuj nową elipsę i nasłuchuj klawiszy
		
		dec		word ptr ds:[b_int]						; jeśli check_bounds zwróciło False, to przywracamy a_int i słuchamy klawiszy
		jmp		get_key
		
		
down_arrow:
		cmp		al, 80;down
		jnz 	get_key
		dec		word ptr ds:[b_int]
		
		call	check_bounds
		cmp		dl, 0										
		jz		run										; jeśli check_bounds zwróciło True, to rysuj nową elipsę i nasłuchuj klawiszy
		
		inc		word ptr ds:[b_int]						; jeśli check_bounds zwróciło False, to przywracamy a_int i słuchamy klawiszy
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
		fild	word ptr cs:[b_int]
		fdiv											; dzieli to co na stosie przez wierzchołek
		fsin 											; wykonaj sinus na wierzchołku stosu (zmienna x tam jest)
		fld1											; załaduj na stos 1, można też załadować pi, lub e		
		fadd											; dodaj do stosu jedynkę
		fild	word ptr cs:[a_int]		
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
		mov		ax, word ptr ds:[b_int] 				; zmienić na cs:[y] 
		mov		bx, 320
		mul		bx 
		
		mov		bx, word ptr ds:[a_int]					; zmienić na cs:[x]
		add		bx, ax 									; bx = 320 * y + x
		mov		al, byte ptr cs:[k]						
		mov		byte ptr es:[bx], al					; ustawiamy kolor pixela o adresie [x][y] na k
		
		ret
		
; ------------------------------------------			
; ta procedura jest wywoływana po aktualizacji parametrów i jeśli zwróci False,
; parametry są przywracane do poprzedniej postaci

; zwraca True (0) lub False (1) poprzez rejestr dl
check_bounds:					
check_left_bound:
		cmp		word ptr ds:[a_int], 0 		
		jle		check_bound_negative					; jeśli a_int <= 0, to a było 1 i zmieniono je na 0

check_right_bound:
		cmp		word ptr ds:[a_int], 199
		jg		check_bound_negative					; jeśli a_int > 200, to znaczy, że zwiększyliśmy parametr a z 200 na 201
	
check_lower_bound:
		cmp		word ptr ds:[b_int], 0 		
		jle		check_bound_negative					; jeśli b_int <= 0, to znaczy, że b był 1 i został zmniejszony na 0

check_upper_bound:
		cmp		word ptr ds:[b_int], 199
		jg		check_bound_negative					; jeśli b_int > 200, to b był 200 i zmieniono go na 201
		mov		dl,	0									; wszystkie testy przeszły, ustawiamy dl na 0 (True)
		
end_check_bound:
		ret

check_bound_negative:
		mov		dl, 1									; jeden z testów nie przeszedł, ustawiamy dl na 1 (False) 
		jmp 	end_check_bound								
		
; -----------------------------------------
code_ 	ends

stack_ 	segment stack
				dw		300	dup (?)
stack_pointer	dw		?

stack_ 	ends


end main