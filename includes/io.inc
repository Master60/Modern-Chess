    ;Moves the selected cell (if possible) according to the scan codes of keys pressed (A->1E, D->20, W->11, S->1F)
move_selected_cell PROC

                                   push    cx
                                   push    dx

    ; Storing current positons [DX,CX]
                                   mov     cx,si
                                   mov     dx,di
    
                                   cmp     ah, 1Eh
                                   jz      move_left

                                   cmp     ah, 20h
                                   jz      move_right

                                   cmp     ah, 11h
                                   jz      move_up

                                   cmp     ah, 1Fh
                                   jz      move_down

                                   jmp     dont_move

    move_left:                     
                                   cmp     si, 0
                                   jz      dont_move
                                   dec     si
                                   jmp     redraw

    move_right:                    
                                   cmp     si, 7h
                                   jz      dont_move
                                   inc     si
                                   jmp     redraw
    move_up:                       
                                   cmp     di, 0h
                                   jz      dont_move
                                   dec     di
                                   jmp     redraw
    move_down:                     
                                   cmp     di, 7h
                                   jz      dont_move
                                   inc     di
                                   jmp     redraw


    redraw:                        
    ; Redraw the prev cell with its original color
                                   push    si
                                   push    di
                                   mov     si, cx
                                   mov     di, dx
                                   mov     al, temp_color
                                   call    draw_cell
                                   pop     di
                                   pop     si

    dont_move:                     
                                   pop     dx
                                   pop     cx

                                   call    selected_cell_hover
                                   ret

move_selected_cell ENDP