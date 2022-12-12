    ;Checks whether or not there was an error when opening a bitmap file containing the image of any piece.
    ;All of the interrupts used to access files set the carry flag if an error occurs, and reset the carry flag if the file is opened successfully.
    ;Hence, checking the carry flag is sufficient to detect errors.
check_file_error proc
                                   jc      error_handling
                                   ret
    error_handling:                
                                   mov     ah, 9
                                   mov     dx, offset error_msg
                                   int     21h
                                   mov     ax, 4c00h
                                   int     21h
check_file_error endp


    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;Gets the file handle of the bitmap file we wish to access
get_file_handle proc
                                   mov     ax, 3d00h
                                   int     21h
                                   call    check_file_error
                                   mov     [file_handle], ax
                                   ret
get_file_handle endp


    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;Moves file pointer to the beginning of the file (Read the documentation of the interrupt INT 21H, AH=42H "Seek File").
go_to_file_start proc
                                   mov     ax, 4200h
                                   mov     bx, file_handle
                                   mov     cx, 0
                                   mov     dx, 0
                                   int     21h
                                   call    check_file_error
                                   ret
go_to_file_start endp


    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;Every bitmap file contains a header block that is used to identify the file. We wish to bypass this block, so we use this procedure.
    ;We read the first 14 bytes of the header to extract information about the starting point of the image, then we go to that starting point.
pass_file_header proc
                                   call    go_to_file_start
                                   mov     ax, 3f00h
                                   mov     cx, 14d
                                   mov     dx, offset bitmap_buffer
                                   int     21h

    ;Moves file pointer to the beginning of the data we wish to read. Bytes 10d and 12d in the header contain the needed information to position
    ;the file pointer at the starting point of the actual image.
                                   mov     bx, offset bitmap_buffer
                                   mov     dx, [bx+10d]
                                   mov     cx, [bx+12d]
                                   mov     ax, 4200h
                                   mov     bx, [file_handle]
                                   int     21h
                                   call    check_file_error
pass_file_header endp


    ;----------------------------------------------------------------------------------------------------------------------------------------------


    ;loads the image of a piece, with its picture stored as a bitmap file.
    ;The image will be placed at the cell with row number stored in DI and column number stored in SI.
    ;Note: rows/columns range from 0 to 7, since the chess board has 8 rows and 8 columns.
load_piece proc

    ;Get the actual position of the top left corner of the cell we wish to draw at, and store the coordinates in the x_temp and y_temp variables.
                                   mov     ax, si
                                   mul     cell_size
                                   mov     x_temp, ax

                                   mov     ax, di
                                   mul     cell_size
                                   mov     y_temp, ax
                
    ;Load the image into the bitmap_buffer.
                        
                                   mov     bx, file_handle
                                   mov     ah, 3fh
                                   mov     cx, file_size
                                   mov     dx, offset bitmap_buffer
                                   int     21h
                                   mov     bx, offset bitmap_buffer
                                   add     bx, 75d


    ;Nested loops which print the bitmap image pixel by pixel
                                   mov     si, file_width
                                   dec     si
    loop_y_bitmap:                 
                                   mov     di, file_width
                                   dec     di

    loop_x_bitmap:                 
    ;Load the color of the current pixel to AL, since AL stored the color when drawing a pixel using INT 10H
                                   mov     al, byte ptr [bx]
                                   cmp     al, 0ffh                            ;Do not draw any white pixels, to preserve the background color of the board.
                         
                                   je      continue_bitmap_loop
                         
    ;Draws a pixel at the position specified by CX and DX, with color stored in AL.
                                   push    bx
                                   mov     ah, 0ch
                                   mov     bl, 0
                                   mov     cx, di
                                   add     cx, x_temp
                                   mov     dx, si
                                   add     dx, y_temp
                                   int     10h
                                   pop     bx
    continue_bitmap_loop:          
    ;Go to the next pixel.
                                   dec     bx
                                   dec     di
                                   jnz     loop_x_bitmap
                                   add     bx, 151d
                                   dec     si
                                   jnz     loop_y_bitmap

                                   ret
load_piece endp


    ;-----------------------------------------------------------------------------------------------------------------------------------------------

    ;Draws a piece
draw_piece proc
    ;pusha is not recognized, so manually pushed all potentially critical registers for safety :).
                                   push    ax
                                   push    bx
                                   push    cx
                                   push    dx
                                   push    si
                                   push    di

                                   add     si, margin_x                        ;Adjust the column position using the x_margin.
                                   add     di, margin_y                        ;Adjust the row position using the y_margin.
                                   push    si
                                   push    di
                                   call    get_file_handle                     ;Prepare the file handle for other interrupts
                                   call    pass_file_header                    ;Move the file pointer to the starting point of the image
                                   pop     di
                                   pop     si
                                   call    load_piece                          ;Draw the image at the rows and columns specified by SI and DI.
                                   call    close_file                          ;Close the file
                         
    ;popa not supported :)
                                   pop     di
                                   pop     si
                                   pop     dx
                                   pop     cx
                                   pop     bx
                                   pop     ax
                         
                                   ret

draw_piece endp

;---------------------------------------------------------------------------------------------------------

    ;Closes the bitmap file.
close_file proc
                                   mov     ah, 3Eh
                                   mov     bx, [file_handle]
                                   call    check_file_error
                                   int     21h
                                   ret
close_file endp


    ;-------------------------------------------------------------------------------------------------------------------------------------------------
