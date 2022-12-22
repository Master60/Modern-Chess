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

mov di, 80d
mov si, 64d
mov cx, 0
mov dx, 0
mov ah, 0ch
mov al, 0

draw_color:
loopy:
loopx:
int 10h
inc cx
cmp cx, di
jnz loopx

inc dx
mov cx, 0
cmp dx, si
jnz loopy

add si, 64d
inc al
jmp draw_color

hlt

main endp
end main