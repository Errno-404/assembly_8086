data1 segment

start_msg		db	"Wprowadz slowny opis dzialania: $"

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


new_line		db	13, 10, "$"
input_buf		db	200, ?, 210 dup ("$") 



operand1		db	20 dup("$")
operand2		db	20 dup("$")
operator		db	10 dup("$")


expression		dw	3 dup(?)

data1 ends




code1 segment
start1:	

		; ustawianie stosu
		mov 	ax, seg stos1 
		mov 	ss, ax
		mov 	sp, offset wstos1
;-----------------------------------------------------------------------
		
		; print initial message
		mov		dx, offset start_msg
		call 	print_msg
		
		; take line
		mov		ax, seg input_buf
		mov		ds, ax
		mov 	dx, offset input_buf
		
		mov		ah, 0ah
		int		21h
		mov		dx, offset new_line
		call 	print_msg
		
		
		
		call 	parse
		
		
		
		
		
		
		; print buffor after parsing!
		mov 	dx, offset input_buf + 2
		call  	print_msg
		
	
		mov 	ax, 4c00h
		int		21h
	
; ----------------------------------------------------------------------	

word_counter	db	0
parse:
		mov		ax, seg data1
		mov		ds, ax
		mov		bp, offset input_buf


		xor		cx, cx
		mov		cl, byte ptr ds:[bp]
		inc		bp
		inc		bp
avoid_spaces:
		push	cx

		; na razie tylko spacja!
		cmp		byte ptr ds:[bp], ' '
		jnz		contiune_
		
		
		
		mov		byte ptr ds:[bp], '*'
		
contiune_:
		



		inc 	bp
		pop		cx
		loop	avoid_spaces
		
		
		
		ret

		
	
		



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