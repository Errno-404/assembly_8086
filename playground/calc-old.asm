data1 segment

; definiujemy wiadomość początkową, a także wiadomość błędu (zakładam, że wystarczy powiedzieć o błędzie a nie jaki typ)
start_msg		db	"Wprowadz slowny opis dzialania: $"
error_msg		db	"Error!$"


; pomocniczo definiuję znak nowej linii
new_line		db	13, 10, "$"


; definiuję bufor na wejście, w nim odbędzie się parsowanie. Bufor wypełniam wartościami $ dla systemu MS-DOS
input_buf		db	200, ?, 210 dup ("$") 


; definiuję "tablice" pomocnicze, do których trafią wyrazy po odrzuceniu spacji
operand1		db	20 dup("$")
operator		db	20 dup("$")
operand2		db	20 dup("$")


; definiuję "tablicę", która zawierać będzie offsety do powyższych tablic pomocniczych
expression		dw	3 dup(?)


; TO BE DONE 
zero			db	"zero"
one				db	"jeden"
two				db	"dwa"
three			db 	"trzy"
four			db	"cztery"
five			db	"piec"
six				db	"szesc"
seven			db	"siedem"
eight			db	"osiem"
nine			db	"dziewiec"

data1 ends

; ============================================================================================================ ;

code1 segment
start1:	
		call 	initialize 	; ustawia tablice i wypisuje komunikat powitalny
		call 	get_line	; pobiera linię do bufora 
		call 	split_text 	; rozdziela słowa do 3 tablic lub zgłasza błąd, gdy liczba słów się nie zgadza
		
		
		
		; testowanie
		mov		dx, 0
		call println
		
		; testy
		mov		dx, offset operand1
		call 	println
		
		mov		dx, offset operator
		call 	println
		
		mov		dx, offset operand2
		call	print
		
		
		
	
		mov 	ax, 4c00h
		int		21h
	
; ============================================================================================================ ;

word_counter	db	0	; licznik słów
char_counter 	db  0	; licznik znaków
prev_char		db	0 	; flaga czy poprzedni znak był spacją; 0 - spacja / tab, 1 - inny znak


initialize:
		; Ustawiamy stack pointera
		mov 	ax, seg stos1 
		mov 	ss, ax
		mov 	sp, offset wstos1


		; wpisujemy do "tablicy" expression offsety odpowiednich "tablic"
		mov		ax, seg data1
		mov		ds, ax
		mov		bp, offset expression
		mov		word ptr ds:[bp], offset operand1
		mov		word ptr ds:[bp + 2], offset operator
		mov		word ptr ds:[bp + 4], offset operand2
		
		
		; wyświetlamy komunikat powitalny
		mov		dx, offset start_msg
		call 	print
		ret


get_line:
		; pobieramy linię tekstu do bufora
		mov		ax, seg input_buf
		mov		ds, ax
		mov 	dx, offset input_buf
		mov		ah, 0ah
		int		21h
		ret


split_text:
		; ustawiamy pętlę i rejestr si, który wskazuje na początek bufora i jest wykorzystywany w tej funkcji
		mov		ax, seg data1
		mov		ds, ax
		mov		si, offset input_buf
		xor		cx, cx
		mov		cl, byte ptr ds:[si + 1]
		
		
		; ustawiamy si, aby wskazywał na pierwszy znak
		add		si, 2


skip_white:
		; sprawdzamy czy obecnie badany znak jest spacją lub tabulatorem
		push	cx
		cmp		byte ptr ds:[si], ' ' ; input traversal
		jnz		if_not_space
		
		
if_space:
		; znak jest spacją - sprawdzamy, czy poprzedni znak nie był spacją
		cmp		prev_char, 1
		jnz		endif_space
		

if_prev:
		; znak jest spacją oraz poprzedni znak nią nie był
		; zmieniamy flagę poprzedniego znaku na przeciwną
		mov		al, 0
		mov		bx, offset prev_char
		mov		byte ptr cs:[bx], al


		; zwiększamy licznik słów
		mov		bx, offset word_counter
		mov		al, byte ptr cs:[bx]
		inc 	al
		mov		byte ptr cs:[bx], al
		
		
		; zerujemy licznik znaków
		mov		bx, offset char_counter
		xor 	al,al
		mov		byte ptr cs:[bx], al
		jmp		endif_space


if_not_space:
		; znak nie był spacją
		; pobieramy liczbę słów
		mov		bp, offset word_counter
		xor		bx, bx
		mov		bl, byte ptr cs:[bp]
		
		; jeśli słów jest >= 3, tzn. że wpisano za dużo i można zgłosić błąd już teraz
		; tutaj uwaga liczba słów zaczyna się od 0, dla łatwiejszego indeksowania, tzn.
		; dla "jeden plus dwa" słowa zostaną zapisane do: tablicy pod indeksami 0, 1, 2
		; ale wartość 3 może oznaczać, że po prostu po słowie ostatnim pojawiły się spacje,
		; jednak jesteśmy w gałęzi "if_not_space", tzn trafiliśmy na coś co nie jest znakiem!,
		; dlatego w tym miejscu wartość word_countera jako 3 jest błędna
		cmp		bl, 3
		jge		error
		
		
		; aby otrzymać właściwe przesunięcie musimy pomnożyć word_counter * 2
		mov		ax, bx
		mov		bx, 2
		mul		bx
		mov		bx, ax
		
		
		; Ustawiamy bp na offset właściwej tablicy (operand1, operator, operand2)
		mov 	di, offset expression
		mov		bp, word ptr ds:[di + bx]	
		
		
		; W ax zapisujemy numer znaku aktualnie przetwarzanego (liczony od 0)
		mov		bx, offset char_counter
		xor		ax, ax
		mov		al, byte ptr cs:[bx]


		; zapisujemy do odpowiedniej tablicy spod adresu bp, odpowiedni znak o numerze di; znak ten
		; pobieramy z ds:[si], czyli z input_buf, gdzie si wskazuje odpowiedni znak
		mov		di, ax
		mov		al, byte ptr ds:[si]
		mov		byte ptr ds:[bp + di], al
		
		
		; Ustawiamy informację, że poprzednim znakiem był znak inny niż biały (spacja / tab)
		mov		al, 1
		mov		bx, offset prev_char
		mov		byte ptr cs:[bx], al
		
		
		; Zwiększamy licznik znaków
		mov		bx, offset char_counter
		mov		al, byte ptr cs:[bx]
		inc 	al
		mov		byte ptr cs:[bx], al
		
		
		jmp		endif_space
endif_space:
		inc 	si
		pop		cx
		loop	skip_white


end_skip_white:	
		ret

; ======================================================================================================================== ;

parse_input:










error:
		; wypisuje błąd i wraca do systemu
		mov		dx, offset error_msg
		call	print
		mov 	ax, 4c00h
		int		21h


print:
		; wypisuje zawartość dx
		mov		ax, seg data1
		mov		ds, ax
		mov		ah, 9
		int 	21h
		ret


println:
		; wypisuje zawartość dx oraz znak nowej linii
		call 	print
		mov		dx, offset new_line
		call 	print
		ret

		
code1 ends


stos1 segment stack
		dw		300	dup (?)
wstos1	dw		?
stos1 ends


end start1