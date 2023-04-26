; Słowa kluczowe
; - VGA
; - Skamieliny tututu

code1 segment
start1:
	mov ax, seg stos1
	mov ss, ax
	mov sp, offset wstos1
	
	
	
	
	mov	al,13h; oznacza 320 x 256 i 256 kolorow
	mov	ah, 0 ;zmien tryb graficzny
	int 10h ; używane przez BIOS do obsługi karty graficznej
	
	
	
	mov word ptr cs:[x], 0
	mov word ptr cs:[y], 50
	mov byte ptr cs:[k], 13
	mov cx, 100
p1:	push cx
	call zapal_punkt
	inc	word ptr cs:[x]
	pop cx
	loop p1
	
	
	;mov ax, 0a000h ; adres segmentu grafiki
	;mov es, ax
	;mov ax, 50 ; nwm co to za liczba (ponoć y)
	;mov bx, 320 ; 320 znakow w linii komend
	;mul bx		; AX * BX wynik będzie 32 bitowy, jeśli oba są 16 bitowe
	; jak wyliczy nam 32 bitowa liczbe, to wynik bedzie zapisany w dx:ax
	; mul niszczy dx <- bo tam bedzie starsza czesc wyniku
	
	;mov bx, 160 ; liczba x
	;add bx, ax ; bx = 320  * y + x 
	
	; es ustawiony na pamiec obrazu
	;mov byte ptr es:[bx], 15
	
	;mov	word ptr cs:[x], 160 ; 160 do x wrzucamy
	;mov word ptr cs:[y], 50; 50 do y
	;mov byte ptr cs:[k], 13 ; kolor ustawiony
	;call zapal_punkt
	
	xor ax, ax
	int 16h ; czekaj na dowolny klawisz :>
	
	; na portach znacznie więcej pracy O>.<O
	
	
	mov	al,3h; wracamy do trybu tekstowego
	mov	ah, 0 ;zmien tryb graficzny
	int 10h ; używ
	
	
	mov ax, 4c00h;
	int 21h
	
	
;.......................................................
x	dw	?
y	dw	?
k	db	?
;.......................................................
zapal_punkt:
	mov ax, 0a000h ; adres segmentu grafiki
	mov es, ax
	mov ax, word ptr cs:[y] ; nwm co to za liczba (ponoć y)
	mov bx, 320 ; 320 znakow w linii komend
	mul bx		; AX * BX wynik będzie 32 bitowy, jeśli oba są 16 bitowe
	; jak wyliczy nam 32 bitowa liczbe, to wynik bedzie zapisany w dx:ax
	; mul niszczy dx <- bo tam bedzie starsza czesc wyniku
	
	mov bx, word ptr cs:[x]				; liczba x
	add bx, ax ; bx = 320  * y + x 
	mov al, byte ptr cs:[k]
	mov byte ptr es:[bx], al
	
	
	
	
	ret

;a 	dw ?

;linia:
;	mov	cs, word ptr cs:[a]
;p1: push cx
;	call zapal_punkt
;	inc word ptr cs:[x]
;	pop cx
;	loop p1
;	ret


code1 ends


stos1 segment stack
		dw	300 dup(?)
wstos1	dw	?
stos1 ends


end start1














; ------------------- wykład notatsy -----------------


; A000 adres segmentowy karty graficznej
; A0000 adres fizyczny

; ale mov ax, A000 nie zadziała

; segment ma 64KB w 8086
; 

; 1000 x 500 rozdzielczość chcemy mieć, to mamy 500 KB jeśli 
; damy 1 B na komórkę, no to nie zmieścimy w segmencie :/


; można było przestawiać banki pamięci karty, ale nie robimy tego teraz tak


; użyjemy za to 320 x 200 i 256 kolorów, wtedy 320 x 200 = 64000, czyli wystarczy nam

; Bajt pod adresem A000 odpowiada lewy górny róg (osie w dół i prawo)

; 320 w x, a y ma 200


; to poniżej chyba źle
; czyli offset 319 ( A = 0A000h : 319) to punkt w wierszu 1 oddalony od początku układu w prawo o 319 punktów
; to poniżej jest ok

; adres = y * 320 + x (offset)



;czyli dla y > 320 idziemy do kolejnej liniii

