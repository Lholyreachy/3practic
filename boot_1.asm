    org 7C00h
start:
; �������������� ��������
    mov     ax,cs
    mov     ds,ax
    mov     es,ax
    mov     ss,ax
    xor     sp,sp
; ������� �����
    mov     ax,12h
    int     10h
; ������� �����
    mov     ax,1300h    ; ������ ������ ������ bl
    mov     bp, fio     ; �������� �� ��������� ������
    mov     cx,33       ; ����� ������
    mov     bx,25h      ; ������� ��������, ���� 25h
    mov     dx,0F00h    ; DH,DL = ������,������� ������ ������
    int     10h

    mov     ax,240      ; y ������
    mov     bx,640 - 45 ; x ������
    mov     dx,20       ; ������� ������� (�� Y)
    mov     si,40       ; ����� ������� (�� X)      
    call    Ellips
        
    xor     ax,ax       ; ������� ������� �������
    int     16h
    ret
; ����� ������ ������ ������ ������������ �������...  
; ��������������: �: �����, Y: �����, ������ � ����    
; ������ ����� ������� ���-393907
fio db "Yacenko Irina Yur'evna HMT-393907"

ellipst dw      0,0
rad     dw      0,0         ; ������� �������
XCen    dw      0           ; ����� �����/������ X
YCen    dw      0           ; ����� �����/������ Y

; ������ ������
; �� �����:
; ax - y ������
; bx - x ������
; dx - ������� ������� (�� Y)
; si - ����� ������� (�� X)
Ellips:
    pusha           
    mov     [YCen],ax
    mov     [XCen],bx
; �������� ����� ������ ������� �������
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

; di - ������
    mov     ax,di
    mul     ax
    mov     [rad],ax
    mov     [rad + 2],dx
    
Ellips03:
; ���������� ����������� ��������, ���� ��� ���� ��������� �� ���� �����
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
; ax - ������
; bx - ������� �������
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


; ax - ������
; bx - ������� �������
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
    
    add     cx,[XCen] ; �������
    add     dx,[YCen] ; ������
    
    mov     ax,0c01h    ; �������� ����� ������ 1
    xor     bx,bx       ; ����� �������������
    int     10h
    popa
    ret

    db      510-($-$$) dup 0 ; ���� ��� ���������� �������� �� ����� �������    
    dw      0AA55h  ; ������� ������������ �������
