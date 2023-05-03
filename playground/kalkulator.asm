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
zero			db	"zero$"
one				db	"jeden$"
two				db	"dwa$"
three			db 	"trzy$"
four			db	"cztery$"
five			db	"piec$"
six				db	"szesc$"
seven			db	"siedem$"
eight			db	"osiem$"
nine			db	"dziewiec$"
ten				db	"dziesiec$"
eleven			db	"jedenascie$"
twelve			db 	"dwandascie$"
thirteen		db	"trzynascie$"
fourteen		db	"czternascie$"
fifteen			db	"pietnascie$"
sixteen			db	"szesnascie$"
seventeen		db	"siedemnascie$"
eighteen		db	"osiemnascie$"
nineteen		db	"dziewietnascie$"
twenty			db	"dwadziescia$"
thirty 			db	"trzydziesci$"
forty 			db	"czterdziesci$"
fifty			db	"piecdziesiat$"
sixty 			db	"szescdziesiat$"
seventy			db	"siedemdziesiat$"
eighty			db	"osiemdziesiat$"


plus			db 	"plus$"
minus			db  "minus$"
times_			db  "razy$"

numbers_offsets dw	27 dup(?)



result			db	?,"$"

data1 ends

; ============================================================================================================ ;

code1 segment
start1:	
		call 	initialize 	; ustawia tablice i wypisuje komunikat powitalny
		call 	get_line	; pobiera linię do bufora 
		call 	split_text 	; rozdziela słowa do 3 tablic lub zgłasza błąd, gdy liczba słów się nie zgadza
		
		
		call 	parse_operation ; now ax contains proper value
		
		
		
		push	ax
		; new line
		mov		dx, 0
		call println
		pop		ax
		
		
		; to było do testów, ogółem to al -> wynik, ah -> znak
		
		mov		bp, offset result
		mov		byte ptr ds:[bp], al
		mov		dx, offset result
		call 	print
		
		
		
		
		
		
		
		
		
		
		
		; testowanie
		
		
		; testy
		mov		dx, offset operand1
		call 	println
		
		mov		dx, offset operator
		call 	println
		
		mov		dx, offset operand2
		call	print
		
		mov		dx, offset one
		mov		bx, offset operand1
		call 	compare_strings
		
		
		
	
		mov 	ax, 4c00h
		int		21h
	
; ============================================================================================================ ;

word_counter	db	-1	; licznik słów
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
		
		; wpisujemy do tablicy numbers_offsets offsety liczb
		mov		bp, offset numbers_offsets
		mov		word ptr ds:[bp], offset zero
		mov		word ptr ds:[bp + 2], offset one
		mov		word ptr ds:[bp + 4], offset two
		mov		word ptr ds:[bp + 6], offset three
		mov		word ptr ds:[bp + 8], offset four
		mov		word ptr ds:[bp + 10], offset five
		mov		word ptr ds:[bp + 12], offset six
		mov		word ptr ds:[bp + 14], offset seven
		mov		word ptr ds:[bp + 16], offset eight
		mov		word ptr ds:[bp + 18], offset nine
		mov		word ptr ds:[bp + 20], offset ten
		mov		word ptr ds:[bp + 22], offset eleven
		mov		word ptr ds:[bp + 24], offset twelve
		mov		word ptr ds:[bp + 26], offset thirteen
		mov		word ptr ds:[bp + 28], offset fourteen
		mov		word ptr ds:[bp + 30], offset fifteen
		mov		word ptr ds:[bp + 32], offset sixteen
		mov		word ptr ds:[bp + 34], offset seventeen
		mov		word ptr ds:[bp + 36], offset eighteen
		mov		word ptr ds:[bp + 38], offset nineteen
		mov		word ptr ds:[bp + 40], offset twenty
		mov		word ptr ds:[bp + 42], offset thirty
		mov		word ptr ds:[bp + 44], offset forty
		mov		word ptr ds:[bp + 46], offset fifty
		mov		word ptr ds:[bp + 48], offset sixty
		mov		word ptr ds:[bp + 50], offset seventy
		mov		word ptr ds:[bp + 52], offset eighty
	
		
		
		
		
		
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
		; Ustawiamy informację, że poprzednim znakiem był znak biały
		mov		al, 0
		mov		bx, offset prev_char
		mov		byte ptr cs:[bx], al
		jmp		endif_space
		

if_not_space:
		cmp		prev_char, 0 ; poprzedni znak był spacją
		jnz		if_not_prev
		

if_prev:
		; zmieniamy flagę poprzedniego znaku na znak, ponieważ jesteśmy w gałęzi znak == true && prev == spacja == true
		mov		al, 1
		mov		bx, offset prev_char
		mov		byte ptr cs:[bx], al


		; zwiększamy licznik słów
		nop
		
		nop
		nop
		mov		bx, offset word_counter
		mov		al, byte ptr cs:[bx]
		inc 	al
		mov		byte ptr cs:[bx], al
		
		
		; zerujemy licznik znaków
		mov		bx, offset char_counter
		xor 	al,al
		mov		byte ptr cs:[bx], al
		jmp		endif_prev

if_not_prev:
		jmp		endif_prev

endif_prev:
		mov		bp, offset word_counter
		xor		bx, bx
		mov		bl, byte ptr cs:[bp]
		
		; jeśli słów jest >= 3, tzn. że wpisano za dużo i można zgłosić błąd już teraz
		; tutaj uwaga liczba słów zaczyna się od 0, dla łatwiejszego indeksowania, tzn.
		; dla "jeden plus dwa" słowa zostaną zapisane do: tablicy pod indeksami 0, 1, 2
		; ale wartość 3 może oznaczać, że po prostu po słowie ostatnim pojawiły się spacje,
		; jednak jesteśmy w gałęzi "if_not_space", tzn trafiliśmy na coś co nie jest znakiem!,
		; dlatego w tym miejscu wartość word_countera jako 3 jest błędna
		cmp		bl, 2
		jg		error
		
		
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
		; w tymi miejscu sprawdzamy czy mamy odpowiednie dane w 3 buforach gotowe do parsowania, jeśli nie, to error
		mov		bp, offset word_counter
		xor		ax, ax
		mov		al, byte ptr cs:[bp]
		cmp		ax, 2
		jl		error

		ret

; ======================================================================================================================== ;

; input dx -> string one
; input bx -> stirng two (offsets)
compare_strings:
		mov		ax, seg data1
		mov		ds, ax
	
		mov		bp, dx
		mov		si, 0
		mov		di, 0
	
check_chars:
		xor 	ax, ax
		xor 	dx, dx
	
		mov		al, byte ptr ds:[bp + si]
		mov		dl, byte ptr ds:[bx + di]
		cmp		ax, dx
		jnz		s_not_equal
	
s_equal:
	; characters are equal
		mov		cl, "$"
		cmp		al, cl
		jnz		is_not_end
	
is_end:
		mov		al, 0
		ret
is_not_end:
		; znaki te same ale nie $, wiec badamy kolejne
		inc		si
		inc		di
		jmp		check_chars
	
s_not_equal:
		mov		al, 1
		ret


operand_offset		dw	0
parse_input:
		; poprzez dx operanda offset dajemy
		
		mov		si, offset operand_offset
		mov		word ptr cs:[si], dx
	
		mov		ax, seg data1
		mov		ds, ax
		
		 ; to string do sprawdzenia -> dx nie zmieniamy tutaj poki co		
		
		mov		cx, 10
p2:		
		push 	cx
		mov		ax, 10
		sub		ax, cx
		mov		bx, 2
		mul		bx
		mov		bp, ax
		
		
		mov		si, offset operand_offset
		mov		dx, word ptr cs:[si]
		mov		si, offset numbers_offsets
		
		
		
		mov		bx, word ptr ds:[si + bp]
		; mamy bx i dx do porównania już
		call 	compare_strings
		
		cmp		al, 0
		jnz		not_found
		
found_:
		pop		cx
		mov		ax, 10
		sub		ax, cx
		ret
not_found:
		pop		cx
		loop	p2

		; jeśli wyjdziemy z pętli, tzn, że nie znaleziono tego symbolu
		jmp		error
		ret
		
		
		;przed pętlą w jednym rejestrze powinien być offset do operanda a w drugim do offsetu do tablicy offsetów
		
		
		
left_op		db 	0
right_op	db  0
parse_operation:
		mov		dx, offset operand1
		call	parse_input
		mov		bp, offset left_op
		mov		byte ptr cs:[bp], al
		
		mov		dx, offset operand2
		call 	parse_input
		mov		bp, offset right_op
		mov		byte ptr cs:[bp], al
		
		
		mov		bx, offset operator
		mov		dx, offset plus
		call 	compare_strings	
				
		cmp		al, 0
		jnz		not_plus
		
is_plus:
		mov		bp, offset left_op
		mov		al, byte ptr cs:[bp]
		mov		bp, offset right_op
		mov		bl, byte ptr cs:[bp]
		add		al, bl
		mov		ah, 0
		jmp		after_parsing
not_plus:
		mov		dx, offset minus
		call	compare_strings
		cmp		al, 0
		jnz		not_minus
		
is_minus:
		mov		bp, offset left_op
		mov		al, byte ptr cs:[bp]
		mov		bp, offset right_op
		mov		bl, byte ptr cs:[bp]
		sub		al, bl
		cmp		al,	0
		jl		is_negative
		mov		ah, 0
		jmp		after_parsing
		
is_negative:
		add		al, bl
		sub		bl, al
		mov		al, bl
		mov		ah, 1
	
		jmp		after_parsing
not_minus:
		mov		dx, offset times_
		call	compare_strings
		cmp		al, 0
		jnz		not_times
is_times:
		mov		bp, offset left_op
		mov		al, byte ptr cs:[bp]
		mov		bp, offset right_op
		mov		bl, byte ptr cs:[bp]
		mul		bl
		mov		ah, 0
		jmp		after_parsing

not_times:
		jmp		error


after_parsing:
		add		al, 30h
		ret




error:
		; wypisuje błąd i wraca do systemu
		xor		dx, dx
		call	println
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