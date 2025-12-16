        org 100h

        jmp start
cin:
        push bp
        mov bp, sp
        mov dx, [bp + 4] ; адрес буфера строки
        mov ah, 0ah  ; читает строку на входе
        int 21h
        mov bx, dx ; сохранение адреса буфера
        movzx ax, byte [bx + 1] ; количество введенных символов
        add bx, ax
        add bx, 2
        mov byte [bx], '$' ; в конец строки $
        pop bp
        ret 2

cout:
        push bp
        mov bp, sp
        mov dx, [bp + 4] ; получение адреса строки
        mov ah, 09h ; вывод строки
        int 21h
        pop bp
        ret 2

sortWords:
        push bp
        mov bp, sp

        mov bx, [bp + 4] ; адрес строки
        movzx dx, byte [bx - 1] ; количество символов строки

        mov si, -1 ; -1 для того чтобы с началом циула стало 0
        mov di, -1
cycle1:
        inc si
cycle2:
        inc di
        cmp byte [bx + di], '$'
        je endCycle
        cmp byte [bx + di], ' '  ; находит конец первого слова
        jne cycle2

        inc di ; +1 для того чтобы встать на начало второго слова

        mov ax, [bx + si]
        cmp [bx + di], ax
        jg cycle1  ; если 1 символ второго слова больше то возвращается на цикл 1

cycleSwap:
        ;проверка на пробел и конец строки
        ;если второе слово больше первого
        cmp byte [bx + si], ' '
        je l1
        cmp byte [bx + si], '$'
        je endCycle
        ;если первое больше второго
        cmp byte [bx + di], ' '
        je  l2
        cmp byte [bx + di], '$'
        je l2
        ; меняются буквы местами
        mov al, [bx + di]
        mov cl, [bx + si]
        mov [bx + si], al
        mov [bx + di], cl
        inc si
        inc di
        jmp cycleSwap

l1:    ; 2 больше 1 переход
        mov al, [bx + di]
        cmp [bx + si], al    ; сравнение на пробелы если = то выйти и если у 2 слова конец то выйти в конец циклов вообще
        je cycle1
        cmp byte [bx + di], '$'
        je endCycle

        mov [bx + si], al   ;меняются пробел из первого и буква лишняя из второго
        mov cx, di  ;записывается размещение di чтобы вернуться и не потерять
        inc si
cycleSecWord:  ;смещается второе слово на 1 символ вперед
        mov al, [bx + di - 1]
        mov [bx + di], al
        dec di
        cmp si, di    ;если размещение di = si + 1 значит второе слово следующим декрементом залезет на первое
        jne cycleSecWord

        mov byte [bx + si], ' '
        mov di, cx  ; возвращение указателя на прежнее место чтобы продолжить проверять остальные буквы
        cmp byte [bx + di + 1], ' '
        je cycle1
        cmp byte [bx + di + 1], '$'
        je endCycle

        inc di
        jmp l1
l2:   ; 1 больше 2 переход
        mov al, [bx + si]
        mov [bx + di], al  ; перемещается лишняя буква из 1 слова в конец 2 слова
        mov byte [bx + si], ' '
        cmp byte [bx + si + 1], ' ' ; сравнивается если следующий символ пробел то дальше не надо перемещать лишние буквы
        je startSecWord
        inc si ; для следующих букв добавляется индекс
        inc di
        jmp l2

startSecWord:  ; сохраняется значение si и устанавливается новое для di на начало второго слова
        push si
        add si, 2
        mov di, si
        pop si

cycleFirstWord:  ; для перемещения второго слова на место через один пробел от первого
        mov al, [bx + di]
        mov [bx + si], al  ; ставится первая буква второго слова на место через 1 пробел и дальше каждая
        inc di ; для остальных букв +1 к индексам
        inc si
        cmp byte [bx + di], '$'  ; сравнение с концом строки
        jne cycleFirstWord
        mov byte [bx + si], '$' ; на оставшиеся повторяющиеся буквы во втором слове знак конца строки
        mov byte [bx + di - 1], '$'
        jmp endCycle

        cmp di, dx  ; конец циклов тут
        jne cycle2
endCycle:
        cmp si, dx
        jne cycle1

        pop bp
        ret 2

printNewLine: ; вывод пустой строки
        push newLine
        call cout
        ret

endProgram:
        mov ah, 01h
        int 21h
        ret

start:
        push instring
        call cin

        push string
        call sortWords

        call printNewLine
        push string
        call cout

        call endProgram
        ret
; глобальные переменные
instring db 255, 0 ; значения до начала строки (255 - длина и 0 - текущая длина) для 0ah
string db 255 dup('$') ; строка полностью заполненная $
newLine db 13,10,'$' ; как \n
