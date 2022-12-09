    ;Returns color of the cell specified by SI(x-pos) & DI(y-pos) in AL
get_cell_colour PROC

                                   push    di
    
                                   add     di,si
                                   and     di,1
                                   mov     al,board_colors[di]
                          
                                   pop     di

                                   ret
    
get_cell_colour ENDP


    ; I think its pretty clear
drawBorder PROC
                                   push    si
                                   push    di
                                   push    bx
                                   push    cx
                                   push    dx
                                   push    bp

                                   add     si, margin_x
                                   add     di, margin_y

                                   mov     ah, 0ch
                                   push    ax

                                   mov     ax, si
                                   mul     cell_size
                                   mov     si, ax

                                   mov     ax, di
                                   mul     cell_size
                                   mov     di, ax
                         
                                   pop     ax


                                   mov     bp, 3d
                                   mov     dx, 1

                                   add     dx, di
    line1_1:                       
                                   mov     cx, 1
    line1_2:                       
                                   add     cx, si
                                   int     10h
                                   sub     cx, si

                                   inc     cx
                                   cmp     cx, cell_size
                                   jnz     line1_2

                                   inc     dx
                                   dec     bp
                                   jnz     line1_1

                          
                                   mov     bp, 3d
                                   add     cx, si
    line2_1:                       
                                   mov     dx, 1
    line2_2:                       
                                   add     dx, di
                                   int     10h
                                   sub     dx, di

                                   inc     dx
                                   cmp     dx, cell_size
                                   jnz     line2_2

                                   dec     cx
                                   dec     bp
                                   jnz     line2_1
                        
                          
                                   mov     bp, 3d
                                   add     dx, di
    line3_1:                       
                                   mov     cx, cell_size
    line3_2:                       
                                   add     cx, si
                                   int     10h
                                   sub     cx, si

                                   dec     cx
                                   cmp     cx, 1d
                                   jnz     line3_2

                                   dec     dx
                                   dec     bp
                                   jnz     line3_1

                                   mov     bp,3
                                   add     cx, si
    line4_1:                       
                                   mov     dx, cell_size
    line4_2:                       
                                   add     dx, di
                                   int     10h
                                   sub     dx, di
                                   dec     dx
                                   cmp     dx, 1d
                                   jnz     line4_2

                                   inc     cx
                                   dec     bp
                                   jnz     line4_1
                          


                                   pop     bp
                                   pop     dx
                                   pop     cx
                                   pop     bx
                                   pop     di
                                   pop     si

                                   ret
    
drawBorder ENDP




    ;-------------------------------------------------------------------------------------------------------------------------------------------------


    ;Draws a cell at the row and columns positions specified by SI and DI.
draw_cell proc

    ;Adjust SI and DI for the margins
                                   push    si
                                   push    di
                                   add     si, margin_x
                                   add     di, margin_y

    ;Calculate and store the actual row and column positions of the upper left corner of each cell, and place them in SI and DI
                                   mov     ah, 0ch
                                   push    ax
                                   mov     ax, si
                                   mul     cell_size
                                   mov     si, ax

                                   mov     ax, di
                                   mul     cell_size
                                   mov     di, ax
                         
                                   pop     ax
                         
    ;Prepare for drawing the cell.
                                   mov     cx, cell_size
                                   add     cx, si

    loop_x_cell:                   
                                   mov     dx, cell_size
    loop_y_cell:                   
    ;CX and DX store the row and columns positions for INT 10H.
                                   add     dx, di
                                   int     10h

                                   sub     dx, di
                                   dec     dx
                                   jnz     loop_y_cell
                                   dec     cx
                                   cmp     cx, si
                                   jnz     loop_x_cell

    ;After drawing the cell, we now wish to draw the piece in the cell (if any).

    ;Get back the original row and column positions (from 0 to 7).
                                   pop     di
                                   pop     si
                        
    ;From SI and DI, get the position of the cell we are drawing in board array, which contains the current state of the board.
                                   mov     bx, di
    ;Multiplies by 8, we don't need to move 3 to register first in this assembler. We multiply the row number by 8 since each row has 8 positions.
                                   shl     bx, 3
                                   add     bx, si
                                   add     bx, offset board
                                   mov     ah, [bx]
                                   mov     bh, 0
                                   cmp     ah, 0

    ;If the current element in the board array contains 0, we draw no pieces.
    ;If it contains a negative value, we draw a white piece.
    ;If it contains a positive value, we draw a black piece.
                                   je      finish_draw_cell
                                   jl      draw_white_piece
    ;Drawing a black piece
    draw_black_piece:              
                                   mov     bl, ah
                                   shl     bl, 1
    ;Move the offset of the file we wish to access and draw to dx
                                   mov     dx, word ptr [black_pieces + bx]
                                   call    draw_piece
                                   jmp     finish_draw_cell
    ;White Mate
    draw_white_piece:              
                                   neg     ah
                                   mov     bl, ah
                                   shl     bl, 1
    ;Move the offset of the file we wish to access and draw to dx
                                   mov     dx, word ptr [white_pieces + bx]
                                   call    draw_piece
    ;Exiting
    finish_draw_cell:              
                                   ret
draw_cell endp


    ;-------------------------------------------------------------------------------------------------------------------------------------------


    ;Calls draw_cell in a nested loop to display the whole board.
draw_board proc

    ;Position of the first (upper left) cell
                                   mov     si, 0
                                   mov     di, 0
    ;Color of the first cell
    ;   mov  al, byte ptr cell_colors
                         
    loop_y_board:                  
                                   mov     si, 0
    loop_x_board:                  
    ;Draw the current cell
                                   call    get_cell_colour
    ;   push ax
                                   call    draw_cell
    ;   pop  ax
    ;Update the color of the cell for the next iteration
    ;                       cmp  al, byte ptr cell_colors
    ;                       jz   change_to_dark_color
    ; ; change_to_light_color:
    ;                       mov  al, byte ptr cell_colors
    ;                       jmp  continue_board_loop
    ; change_to_dark_color:
    ;                       mov  al, byte ptr cell_colors + 1
    ; continue_board_loop:
                                   inc     si
                                   cmp     si, 8
                                   jnz     loop_x_board
                         
    ;Before going to the next iteration of the outer loop, reverse the color of the cell
    ;                       cmp  al, byte ptr cell_colors
    ;                       jz   set_dark_color
    ;                       mov  al, byte ptr cell_colors
    ;                       jmp  new_iteration
    ; set_dark_color:
    ;                       mov  al, byte ptr cell_colors + 1
    new_iteration:                 
                                   inc     di
                                   cmp     di, 8
                                   jnz     loop_y_board

                                   ret
draw_board endp


    ;delays according to no. of 'delay_loops' in memory