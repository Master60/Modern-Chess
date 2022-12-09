    ;Initializes the board pieces in memory.
init_board proc
    ;Before placing any pieces on the board, initialize every location on the board to zero (i.e. empty the board)
                                   mov     cx, 64d
                                   mov     bx, offset board
    clear_board:                   
                                   mov     [bx], byte ptr 0
                                   inc     bx
                                   loop    clear_board



    ;Places the pawns on their initial positions on board, 1 indicates a black pawn and -1 indicates a white pawn.
    ;Pawns fill the second and eighth rows.
                                   mov     bx, offset board + 8
                                   mov     cx, 8
    init_pawns:                    
                                   mov     [bx], byte ptr 1
                                   add     bx, 40d
                                   mov     [bx], byte ptr -1
                                   sub     bx, 39d
                                   loop    init_pawns



    ;Places the knights on their initial positions on the board, 2 indicates a black knight and -2 indicates a white knight.
                                   mov     bx, offset board + 1
                                   mov     cx, 2
    init_knights:                  
                                   mov     [bx], byte ptr 2
                                   add     bx, 56d
                                   mov     [bx], byte ptr -2
                                   sub     bx, 51d
                                   loop    init_knights



    ;Places the bishops on their initial positions on the board, 3 indicates a black bishop and -3 indicates a white bishop.
                                   mov     bx, offset board + 2
                                   mov     cx, 2
    init_bishops:                  
                                   mov     [bx], byte ptr 3
                                   add     bx, 56d
                                   mov     [bx], byte ptr -3
                                   sub     bx, 53d
                                   loop    init_bishops



    ;Places the rooks on their initial positions on the board, 4 indicates a black rook and -4 indicates a white rook.
                                   mov     bx, offset board
                                   mov     cx, 2
    init_rooks:                    
                                   mov     [bx], byte ptr 4
                                   add     bx, 56d
                                   mov     [bx], byte ptr -4
                                   sub     bx, 49d
                                   loop    init_rooks



    ;Places the queens on their initial positions on the board, 5 indicates a black queen and 6 indicates a white queen.
                                   mov     bx, offset board + 3
                                   mov     [bx], byte ptr 5
                                   add     bx, 56d
                                   mov     [bx], byte ptr -5



    ;Places the kings on their initial positions on the board, 6 indicates a black king and -6 indicates a white king.
                                   mov     bx, offset board + 4
                                   mov     [bx], byte ptr 6
                                   add     bx, 56d
                                   mov     [bx], byte ptr -6

                                   ret
init_board endp
    ;Notice: magnitudes of the numeric values assigned to the pieces are ordered in the way that the white_pieces/black_pieces arrays are ordered.
    ;This is intentional, and will allow us to access the array positions easily when mapping the board to a drawing.


    ;--------------------------------------------------------------------------------------------------------------------------------------------


    ;Prepares the video mode for displaying the board. INT 10H with AX = 4F02H was used, which sets a VESA compliant video mode that allows for
    ;higher resolution when compared to the traditional 10H interrupts.
init_video_mode proc
                                   mov     ax, 4F02h
                                   mov     bx, 107h                            ;Resolution = 1280x1024, with a 256 color palette
                                   int     10h
                                   ret
init_video_mode endp


    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;Clears the entire screen (in this case, the dimensions of the screen are 1280x1024).
    ;The screen is set to the color stored in register AL.
clear_screen proc
                                   mov     ah, 0ch
                                   mov     cx, 1280d
    loop_x_direction:              
                                   mov     dx, 1024d
    loop_y_direction:              
                                   int     10h
                                   dec     dx
                                   jnz     loop_y_direction
                                   loop    loop_x_direction
                                   ret
clear_screen endp


    ;---------------------------------------------------------------------------------------------------------------------------------------------
