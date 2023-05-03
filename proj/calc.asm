data1 segment

; definiujemy wiadomość początkową, a także wiadomość błędu (zakładam, że wystarczy powiedzieć o błędzie a nie jaki typ)
start_msg		db	"Wprowadz slowny opis dzialania: $"
error_msg		db	"Wystapil blad danych wejsciowych!$"
result_msg		db 	"Wynikiem jest: $"

; pomocniczo definiujemy znak nowej linii oraz znak spacji
new_line		db	13, 10, "$"
space_			db	" $"

; definiujemy bufor na wejście, na nim odbędzie się parsowanie. Bufor wypełniamy wartościami $ dla systemu MS-DOS
input_buf		db	200, ?, 210 dup ("$") 

; definiujemy "tablice" pomocnicze, do których trafią wyrazy po odrzuceniu spacji i znaku tabulacji
operand1		db	20 dup("$")
operator		db	20 dup("$")
operand2		db	20 dup("$")

; definiujemy "tablicę", która zawierać będzie offsety do powyższych tablic pomocniczych
expression		dw	3 dup(?)

; definiujemy potrzebne słowne nazwy cyfr 0,1, ..., 9
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

; definiujemy słowne nazwy liczb 10, 11, ..., 19
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

; definiujemy nazwy dziesiątek 20, 30 ..., 80
twenty			db	"dwadziescia$"
thirty 			db	"trzydziesci$"
forty 			db	"czterdziesci$"
fifty			db	"piecdziesiat$"
sixty 			db	"szescdziesiat$"
seventy			db	"siedemdziesiat$"
eighty			db	"osiemdziesiat$"

; definiujemy dostępne nazwy operatorów
plus			db 	"plus$"
minus			db  "minus$"
times_			db  "razy$"

; definiujemy tablice dla cyfr, "nastek" i dziesiątek
numbers_offsets dw	10 	dup(?)
teens_offsets	dw 	10  dup(?)
tens_offsets	dw 	7 	dup(?)

data1 ends

; ======================================================================================================================= ;

code1 segment
start1:	
		call 	initialize 	; wypełnia tablice odpowiednimi offsetami oraz wypisuje komunikat powitalny
		call 	get_line	; pobiera linię do bufora 
		call 	split_text 	; rozdziela słowa do 3 tablic lub zgłasza błąd, gdy liczba słów się nie zgadza
		call 	parse_operation ; parsuje wyrażenie i zwraca błąd w przypadku niepoprawnych danych wejściowych
								; lub dla poprawnych danych wejściowych - rejestr ax przechowuje wynik w postaci:
								; ah -> znak działania, al -> wartość bezwzględna działania
		
		push	ax 			; korzystamy ze stosu aby zapisać wynik
		xor		dx, dx		
		call println		; funkcja wypisze pustą linię
		pop		ax
		
		;	funkcja wyświetli słowny wynik działania
		call	get_string_result
		
		; kończymy program z powodzeniem
		mov 	ax, 4c00h
		int		21h
	
; ======================================================================================================================= ;

word_counter	db	-1	; licznik słów (ustawiany na wartość -1, w celu łatwiejszego parsowania)
char_counter 	db  0	; licznik znaków
prev_char		db	0 	; flaga mówiąca czy poprzedni znak był spacją lub tabulatorem, 0 - spacja / tab, 1 - inny znak

; funkcja inicjuje stos, wypełnia tablice offsetami oraz wypisuje tekst powitalny
initialize:
		; Ustawiamy stos
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
		
		; wpisujemy do tablic numbers_offsets, teens_ofsets oraz tens_offsets offsety odpowiednich liczb
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
		
		mov		bp, offset teens_offsets
		mov		word ptr ds:[bp], offset ten
		mov		word ptr ds:[bp + 2], offset eleven
		mov		word ptr ds:[bp + 4], offset twelve
		mov		word ptr ds:[bp + 6], offset thirteen
		mov		word ptr ds:[bp + 8], offset fourteen
		mov		word ptr ds:[bp + 10], offset fifteen
		mov		word ptr ds:[bp + 12], offset sixteen
		mov		word ptr ds:[bp + 14], offset seventeen
		mov		word ptr ds:[bp + 16], offset eighteen
		mov		word ptr ds:[bp + 18], offset nineteen
		
		mov		bp, offset tens_offsets
		mov		word ptr ds:[bp], offset twenty
		mov		word ptr ds:[bp + 2], offset thirty
		mov		word ptr ds:[bp + 4], offset forty
		mov		word ptr ds:[bp + 6], offset fifty
		mov		word ptr ds:[bp + 8], offset sixty
		mov		word ptr ds:[bp + 10], offset seventy
		mov		word ptr ds:[bp + 12], offset eighty
		
		; wyświetlamy komunikat powitalny
		mov		dx, offset start_msg
		call 	print
		ret

; funkcja pobiera linię do bufora 
get_line:
		; pobieramy linię tekstu do bufora
		mov		ax, seg input_buf
		mov		ds, ax
		mov 	dx, offset input_buf
		mov		ah, 0ah
		int		21h
		ret

; funkcja dokonuje wstępnej kontroli liczby słów i rozdziela podane słowa do odpowiednich tablic
split_text:
		; ustawiamy pętlę i rejestr si, który wskazuje na początek bufora i jest wykorzystywany później w tej funkcji
		mov		ax, seg data1
		mov		ds, ax
		mov		si, offset input_buf
		xor		cx, cx
		mov		cl, byte ptr ds:[si + 1] ; wpisujemy jako licznik pętli liczbę znaków pobranych do bufora
		
		
		; ustawiamy si, aby wskazywał na pierwszy znak
		add		si, 2


skip_white:
		; sprawdzamy czy obecnie badany znak jest spacją lub tabulatorem
		push	cx
		cmp		byte ptr ds:[si], ' '
		jnz		if_not_space
		
if_white:
		; Ustawiamy informację, że poprzednim znakiem był znak biały
		mov		al, 0
		mov		bx, offset prev_char
		mov		byte ptr cs:[bx], al
		jmp		endif_space
		
if_not_space:
		; sprawdzamy czy był to tabulator
		cmp		byte ptr ds:[si], 9h
		je 		if_white

if_not_white:
		cmp		prev_char, 0 ; poprzedni znak był spacją
		jnz		if_not_prev
		

if_prev:
		; zmieniamy flagę poprzedniego znaku na znak, ponieważ jesteśmy w gałęzi znak == true && prev == spacja == true
		mov		al, 1
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
		jmp		endif_prev

if_not_prev:
		jmp		endif_prev

endif_prev:
		; pobieramy wartość licznika słów 
		mov		bp, offset word_counter
		xor		bx, bx
		mov		bl, byte ptr cs:[bp]
		
		; sprawdzamy czy słów jest więcej niż 3
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

; ======================================================================================================================= ;

; funkcja porównuje 2 napisy o offsetach podanych jako dx oraz bx i zwraca w rejestrze al -> 0 jeśli są identyczne, 1 w p.p.
compare_strings:
		mov		ax, seg data1
		mov		ds, ax
	
		mov		bp, dx
		mov		si, 0
		mov		di, 0
	
check_chars:
		xor 	ax, ax
		xor 	dx, dx
	
		mov		dl, byte ptr ds:[bp + si]
		mov		al, byte ptr ds:[bx + di]
		cmp		ax, dx
		jnz		s_not_equal
	
s_equal:
		; znaki są identyczne
		mov		cl, "$"
		cmp		al, cl
		jnz		is_not_end
	
is_end:
		; oba znaki są znacznikami końca ($)
		mov		al, 0
		ret
is_not_end:
		; znaki są takie same ale nie są znakami końca danych ($), wiec badamy kolejne
		inc		si
		inc		di
		jmp		check_chars
	
s_not_equal:
		; znaki nie są identyczne, sprawdźmy czy problem nie tkwi w wielkości litery! wiadomo, że dx jest małą literą!
		push	dx
		sub		dx, 20h
		cmp		ax, dx
		pop		dx
		je		s_equal
	
		mov		al, 1
		ret


; funkcja parsująca operand, offset badanego operandu podajemy w dx
operand_offset		dw	0
parse_input:
		mov		si, offset operand_offset
		mov		word ptr cs:[si], dx
	
		mov		ax, seg data1
		mov		ds, ax	
		
		mov		cx, 10
p2:		
		; ustalamy indeks odpowieniej cyfry z tablicy
		push 	cx
		mov		ax, 10
		sub		ax, cx
		mov		bx, 2
		mul		bx
		mov		bp, ax
		
		; ustawiamy bx na offset badanego operandu
		mov		si, offset operand_offset
		mov		bx, word ptr cs:[si]
		mov		si, offset numbers_offsets
		
		; dx przechowuje offset aktualnie badanej nazwy liczby z tablicy
		mov		dx, word ptr ds:[si + bp]
		
		call 	compare_strings
		cmp		al, 0
		jnz		not_found
		
found_:
		; operand znaleziony -> zwracamy jego indeks w rejestrze ax
		pop		cx
		mov		ax, 10
		sub		ax, cx
		ret
not_found:
		; operand nieznaleziony -> kontynuujemy poszukiwania
		pop		cx
		loop	p2

		; jeśli wyjdziemy z pętli, tzn, że nie znaleziono tego symbolu
		jmp		error
		ret
		

; funkcja parsuje operator i następnie wykonuje zadaną operację, zwraca wynik przez rejestr ax
left_op		db 	0 ; offset lewego operanda
right_op	db  0 ; offset prawego operanda
parse_operation:
		; parsujemy a następnie pobieramy lewy operand
		mov		dx, offset operand1
		call	parse_input
		mov		bp, offset left_op
		mov		byte ptr cs:[bp], al
		
		; parsujemy i pobieramy prawy operand
		mov		dx, offset operand2
		call 	parse_input
		mov		bp, offset right_op
		mov		byte ptr cs:[bp], al
		
		; sprawdzamy czy operator jest dodawaniem
		mov		bx, offset operator
		mov		dx, offset plus
		call 	compare_strings	
				
		cmp		al, 0
		jnz		not_plus
		
is_plus:
		; operator jest dodawaniem, wykonujemy je
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
		; operator jest odejmowaniem, wykonujemy je a następnie sprawdzamy znak działania
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
		; jeśli wynik jest ujemny, to ustawiamy w ah informację o tym a w al zwracamy wartość bezwzględną
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
		; operator jest mnożeniem, wykonujemy je
		mov		bp, offset left_op
		mov		al, byte ptr cs:[bp]
		mov		bp, offset right_op
		mov		bl, byte ptr cs:[bp]
		mul		bl
		mov		ah, 0
		jmp		after_parsing

not_times:
		; jeśli operator nie jest żadnym z powyższych, to wystąpił błąd
		jmp		error


after_parsing:
		ret

; funkcja wypisuje słowny wynik działania 
get_string_result:
		push	ax
		mov		ax, seg data1
		mov		ds, ax
		mov		dx, offset result_msg
		call	print
		pop		ax
		
		cmp		ah, 0
		jnz		negative_result
positive_result:
		jmp		both_results
	
negative_result:
		; jeśli wynik był ujemny, to wypisujemy słowo "minus"
		push 	ax
		mov		dx, offset minus
		call	print
		mov		dx, offset space_
		call 	print
		pop		ax
		
both_results:
		; dzielimy z resztą wartość bezwzględną z wyniku, np: 47 // 10 = 4 * 10 + 7
		mov		ah, 0
		mov		bl, 10
		div		bl
		
		cmp		al, 0
		jnz 	not_digit
		
is_digit:
		; jeśli wynik zawiera tylko cyfrę (liczba dziesiątek == 0)
		xor		bx, bx
		mov		bl, ah
		mov		ax, bx
		mov		bx, 2
		mul		bx
		mov		si, ax
		
		mov		bp, offset numbers_offsets
		mov		dx, word ptr ds:[bp + si]
		call	print	
		jmp		finish_get
	
not_digit:
		cmp		al, 1
		jnz 	not_teen

is_teen:
		; jeśli jest "nastką", tzn. ma liczbę dziesiątek równą 1
		xor		bx, bx
		mov		bl, ah
		mov		ax, bx
		mov		bx, 2
		mul		bx
		mov		si, ax
		
		mov		bp, offset teens_offsets
		mov		dx, word ptr ds:[bp + si]
		call	print	
		jmp		finish_get

not_teen:
		; liczba jest dwucyfrowa (20 - 81)
		push 	ax
		sub		al, 2 ; obliczamy indeks dziesiątek
		xor		bx, bx
		mov		bl, al
		mov		ax, bx
		mov		bx, 2
		mul		bx
		mov		si, ax
		
		mov		bp, offset tens_offsets
		mov		dx, word ptr ds:[bp + si]
		call	print	
		pop		ax
		
		cmp		ah, 0
		jnz		not_full_tens
		jmp		finish_get
not_full_tens:
		push 	ax
		mov		dx, offset space_
		call 	print
		pop		ax
		xor		bx, bx
		mov		bl, ah
		mov		ax, bx
		mov		bx, 2
		mul		bx
		mov		si, ax
		
		mov		bp, offset numbers_offsets
		mov		dx, word ptr ds:[bp + si]
		call	print	
		
finish_get:
		ret

; funkcja wypisuje błąd danych wejściowych
error:
		xor		dx, dx
		call	println
		mov		dx, offset error_msg
		call	print
		mov		ah, 4ch
		mov		al, 1h
		int		21h

; funkcja wypisuje zawartość dx (tego co pod tym offsetem w segmencie danych się znajduje)
print:
		mov		ax, seg data1
		mov		ds, ax
		mov		ah, 9
		int 	21h
		ret

; funkcja po wywołaniu `print` wypisuje pustą linię
println:
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