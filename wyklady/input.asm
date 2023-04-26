.model small
.stack 100h

.data
    ; brak danych

.code
    ; funkcja odpowiedzialna za czytanie znaków
    read_string proc
        mov ah, 0        ; numer przerwania 0 (odczyt znaku z klawiatury)
        int 16h          ; wywołaj przerwanie
        mov si, offset buffer ; adres bufora
        cmp al, 13       ; czy znak to 13?
        je end_input     ; jeśli tak, koniec wczytywania
        cmp al, 8        ; czy znak to backspace?
        je backspace     ; jeśli tak, usuń ostatni znak
        cmp al, ' '      ; czy znak to spacja?
        je read_space    ; jeśli tak, wczytaj go i kontynuuj
        mov byte ptr [si], al ; zapisz znak do bufora
        inc si           ; przesuń wskaźnik na kolejną pozycję
        jmp read_string  ; kontynuuj wczytywanie
    backspace:
        dec si           ; cofnij wskaźnik na poprzednią pozycję
        mov byte ptr [si], '$' ; usuń ostatni znak z bufora
        mov dl, 8        ; znak backspace
        mov ah, 2        ; numer przerwania 2 (wypisywanie znaku)
        int 21h          ; wywołaj przerwanie
        mov dl, ' '      ; wypisz spację
        int 21h
        mov dl, 8        ; ponownie znak backspace
        int 21h
        jmp read_string  ; kontynuuj wczytywanie
    read_space:
        mov byte ptr [si], ' ' ; zapisz spację do bufora
        inc si           ; przesuń wskaźnik na kolejną pozycję
        jmp read_string  ; kontynuuj wczytywanie
    end_input:
        mov byte ptr [si], '$' ; wstaw zero na końcu bufora
        ret              ; zakończ procedurę
    read_string endp

    ; procedura odpowiedzialna za wypisywanie ciągu znaków na ekran
    write_string proc
        mov ah, 9        ; numer przerwania 9 (wypisywanie na ekran)
        mov dx, offset buffer ; adres bufora
        int 21h          ; wywołaj przerwanie
        ret              ; zakończ procedurę
    write_string endp

    ; procedura główna programu
    start:
        mov ax, @data    ; załaduj adres segmentu danych
        mov ds, ax
        mov es, ax      
