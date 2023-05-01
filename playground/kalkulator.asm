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




code1 segment
start1:	
		; call initializing method
		call initialize
		call get_line
		
		
	
		call 	split_text
		
		
		
		
		
		
		; print buffor after parsing!
		;mov 	dx, offset input_buf + 2
		;call  	print_msg
		
		mov		dx, offset new_line
		call 	print_msg
		
		mov		dx, offset operand1
		call 	print_msg
		
		mov		dx, offset new_line
		call 	print_msg
		
		mov		dx, offset operator
		call 	print_msg
		
		mov		dx, offset new_line
		call 	print_msg
		
		mov		dx, offset operand2
		call	print_msg
		
		
		
	
		mov 	ax, 4c00h
		int		21h
	
; ----------------------------------------------------------------------	

word_counter	db	0
char_counter 	db  0
prev_char		db	0 ; 0 means space


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
		call 	print_msg
		ret


get_line:
		; pobieramy linię tekstu do bufora
		mov		ax, seg input_buf
		mov		ds, ax
		mov 	dx, offset input_buf
		
		mov		ah, 0ah
		int		21h
		ret

; here we parse input into three arrays
; ----------------------------------------------------------------------
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
		push	cx
		; na razie tylko spacja!
		cmp		byte ptr ds:[si], ' ' ; input traversal
		jnz		not_space
		
		; if it is space then check prev sign:
		cmp		prev_char, 0
		jz		contiune_
		mov		al, 0
		mov		bx, offset prev_char
		mov		byte ptr cs:[bx], al
		
		
		; if it is space and prev_char was a character then
		
		; setting word counter
		nop
		nop
		nop
		nop
		nop
		mov		bx, offset word_counter
		mov		al, byte ptr cs:[bx]
		inc 	al
		mov		byte ptr cs:[bx], al
		
		; setting char counter to zero
		mov		bx, offset char_counter
		xor 	al,al
		mov		byte ptr cs:[bx], al
		
		

		
		
contiune_:
		inc 	si
		pop		cx
		loop	skip_white
		
		
		
		ret


not_space:
		; getting offset to the correct array
		
		; getting value of word_counter
		mov		bp, offset word_counter
		xor		bx, bx
		mov		bl, byte ptr cs:[bp]

		cmp		bl, 3
		jge		error

		
		nop
		
		nop
		
		mov		ax, bx
		mov		bx, 2
		mul		bx
		mov		bx, ax
		
		
		mov 	di, offset expression
		mov		bp, word ptr ds:[di + bx] ; bp has now offset of appropriate array	
		
		
		
		mov		bx, offset char_counter
		xor		ax, ax
		mov		al, byte ptr cs:[bx]
		; ax has now saved character counter
		push	di
		mov		di, ax
		mov		al, byte ptr ds:[si]
	
		mov		byte ptr ds:[bp + di], al
		pop 	di

		
		
		
		
		; setting prev_char as character
		mov		al, 1
		mov		bx, offset prev_char
		mov		byte ptr cs:[bx], al
		
		; increase character_counter
		
		
		mov		bx, offset char_counter
		mov		al, byte ptr cs:[bx]
		inc 	al
		mov		byte ptr cs:[bx], al
		
		
		
		jmp		contiune_
	
		
error:
		mov		dx, offset error_msg
		call	print_msg
		mov 	ax, 4c00h
		int		21h


; ----------------------------------------------------------------------



print_msg:
		mov		ax,	seg data1
		mov		ds, ax
		mov		ah, 9
		int		21h
		ret





		
code1 ends


stos1 segment stack
		dw		300	dup (?)
wstos1	dw		?
stos1 ends


end start1