delay PROC
                                   push    cx
                                   push    ax
                                   pushf
                                   mov     cx, delay_loops

    loop1:                         
                                   mov     ax, 65535d
    loop2:                         dec     ax
                                   jnz     loop2
            
                                   loop    loop1
                                   popf
                                   pop     ax
                                   pop     cx
                                   ret
delay ENDP

    ;Gets pos given SI,DI and puts it in BX
getPos PROC
                                   push    si
                                   push    di

                                   shl     di,3h
                                   add     di, si

                                   mov     bx, di

                                   pop     di
                                   pop     si

                                   ret
getPos ENDP