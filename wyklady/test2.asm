; analiza przykładowego kodu w asemblerze!


.model small ; ustawiamy model na taki, w którym segmenty mają po 64kB max

.data ; ustawiamy segment danych a w nim odpowiednie komunikaty
str1 db "Enter first number: $" ; definiujemy bajty w postaci tekstu
str2 db 13,10,"Enter second number: $" ; definiujemy bajty w postaci przejścia do nowej linii a następnie teskstu
str3 db 13,10,"The sum is: $" ; definiujemy bajty w postaci przejścia do nowej linii a następnie tekstu
.stack 100h ; ustawiamy stos na 256B
.code ; segment kodu -> tutaj mają miejsce wszystkie instrukcje!
main proc ; definiujemy sobie główną procedurę -> to od niej asembler zacznie wykonywanie kodu!
    mov ax,@data ; zapisujemy w rejestrze ax adres początku segmentu danych
    mov ds,ax ; zapisujemy w rejestrze ds (DataSegment) początek segmentu danych korzystając z wartości zapisanej w rejestrze ax -> to inicjalizacja stosu
	
	
    
	
	; wyświetlanie tekstu:

	lea dx,str1 ; ładuje efektywny adres łańcucha znaków, do rejestru dx
    mov ah,9 ; ustawia wartość rejestru ah na kod 9 czyli kod funkcji przerwania 21h
    int 21h ; wywołuje przerwanie 21h, którego kod jest w rejestrze ah
	
	; ten fragment służy do wczytania tylko 1 znaku!, a nam zależy na wczytaniu kilku
    mov ah,1 ; ładujemy do ah kod 1 czyli kod funkcji przerwania 21h odpowiedzialny za wczytanie z klawiatury 1 znaku (!!!)
    int 21h ; wykonujemy przerwanie systemowe
    mov bl,al
	

	
	
	; wyświetlanie tekstu ponownie -> zobaczyć na wykładzie jak przenieść do procedury!!
    lea dx,str2
    mov ah,9
    int 21h
	
	
	
    mov ah,1
    int 21h
    mov bh,al
    sub bh,48
    sub bl,48
    lea dx,str3
    mov ah,9
    int 21h   
    add bh,bl
    add bh,48
    mov dl,bh
    mov ah,2
    int 21h
    mov ah,4Ch
    int 21h
main endp
end main