    org 7C00h
start:
; Инициализируем сегменты
    mov     ax,cs
    mov     ds,ax
    mov     es,ax
    mov     ss,ax
    xor     sp,sp
; Очищаем экран
    mov     ax,12h
    int     10h
; Выводим текст
    mov     ax,1300h    ; Печать строки светом bl
    mov     bp, fio     ; Смещение на выводимую строку
    mov     cx,33       ; Длина строки
    mov     bx,25h      ; Нулевая страница, цвет 25h
    mov     dx,0F00h    ; DH,DL = строка,колонка начала вывода
    int     10h

    mov     ax,240      ; y центра
    mov     bx,640 - 45 ; x центра
    mov     dx,20       ; большая полуось (по Y)
    mov     si,40       ; малая полуось (по X)      
    call    Ellips
        
    xor     ax,ax       ; Ожидаем нажатия клавиши
    int     16h
    ret
; Здесь должна начать работу операционная система...  
; Местоположение: Х: Слева, Y: Центр, Фигура – овал    
; Яценко Ирина Юрьевна НМТ-393907
fio db "Yacenko Irina Yur'evna HMT-393907"

ellipst dw      0,0
rad     dw      0,0         ; Квадрат радиуса
XCen    dw      0           ; Центр круга/элипса X
YCen    dw      0           ; Центр круга/элипса Y

; Рисует эллипс
; На входе:
; ax - y центра
; bx - x центра
; dx - большая полуось (по Y)
; si - малая полуось (по X)
Ellips:
    pusha           
    mov     [YCen],ax
    mov     [XCen],bx
; Радиусом будет всегда большая полуось
    mov     di,bx
    cmp     di,ax
    jae     Ellips_start
    mov     di,ax
Ellips_start:       
    mov     [rad],di
    mov     [ellipst],dx    ;  a
    fild    word [ellipst]
    fidiv   word [rad]
    mov     [ellipst],si    ;  b
    fild    word [ellipst]
    fidiv   word [rad]
; st0 = b / r, st1 = a / r

; di - радиус
    mov     ax,di
    mul     ax
    mov     [rad],ax
    mov     [rad + 2],dx
    
Ellips03:
; Определяем фактическое смещение, если нам надо подняться на одну точку
    mov     ax,di
    mul     ax
    sub     ax,[rad]
    sbb     dx,[rad + 2]
    mov     [ellipst],ax
    mov     [ellipst + 2],dx

    fild    dword [ellipst]
    fabs
    fsqrt
    fistp   word [ellipst]
    
    mov     ax,[ellipst]
    mov     cx,ax
    mov     bx,di
; ax - дельта
; bx - остатки радиуса
    call    Ellips00
    
    mov     ax,cx
    mov     bx,di
    neg     bx
    call    Ellips00
    
    mov     bx,cx
    neg     bx
    mov     ax,di
    call    Ellips00
    
    mov     bx,cx
    neg     bx
    mov     ax,di
    neg     ax
    call    Ellips00
    
    mov     ax,cx
    neg     ax
    mov     bx,di
    neg     bx
    call    Ellips00
    
    mov     ax,cx
    neg     ax
    mov     bx,di
    call    Ellips00
    
    mov     bx,cx
    mov     ax,di
    neg     ax
    call    Ellips00
    
    mov     bx,cx
    mov     ax,di
    call    Ellips00
    
    sub     di,1
    jnc     Ellips03

    popa
    fstp    st0
    fstp    st0
    ret


; ax - дельта
; bx - остатки радиуса
Ellips00:
    pusha
    mov     [ellipst],bx
    fild    word [ellipst]
    fmul    st0,st1             ; * b / r
    fistp   word [ellipst]
    mov     cx,[ellipst]

    mov     [ellipst],ax
    fild    word [ellipst]
    fmul    st0,st2             ; * a / r
    fistp   word [ellipst]
    mov     dx,[ellipst]
    
    add     cx,[XCen] ; Колонка
    add     dx,[YCen] ; Строка
    
    mov     ax,0c01h    ; Рисовать точку цветом 1
    xor     bx,bx       ; Номер видеостраницы
    int     10h
    popa
    ret

    db      510-($-$$) dup 0 ; Нули для заполнения остатков до конца сектора    
    dw      0AA55h  ; Признак загрузочного сектора
