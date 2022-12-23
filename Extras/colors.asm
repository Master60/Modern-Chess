.286
.model small
.stack 64
.data
.code
main proc far

    mov ax, @data
    mov ds, ax

    mov ax, 4F02h
    mov bx, 107h
    int 10h

    mov bp, 0
    mov bx, 0
    mov di, 80d
    mov si, 64d

    mov cx, 0
    mov dx, 0
    mov ah, 0ch
    mov al, 0h

    draw_color_column:
        draw_color_row:
            loopy:
                loopx:
                    int 10h
                    inc cx
                    cmp cx, di
                    jnz loopx
                inc dx
                mov cx, bp
                cmp dx, si
                jnz loopy
            add cx, 80d
            add bp, 80d
            add di, 80d
            add dx, bx
            sub dx, si
            inc al
            cmp di, 1360d
            jnz draw_color_row
        mov bp, 0
        mov di, 80d
        mov cx, 0
        add bx, 64d
        add si, 64d
        add dx, 64d
        cmp si, 1088d
        jnz draw_color_column

    hlt

main endp
end main