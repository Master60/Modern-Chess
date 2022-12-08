.model huge ;To be adjusted (maybe), setting the model to huge for now just to be safe :)
.stack 64


;---------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------

.data

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PATH CONTROL AND ERROR MESSAGE:
    ;---------------------------------------------------------------------------------------------------------------------------------------------
    
    ;Name of the folder containing images of all pieces, will be used to change directory at the start of the main proc.
    pieces_wd        db "pieces", 0

    ;Message to be displayed if a file fails to open.
    error_msg        db "Error! Could not open bitmap files.$"

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED FOR PREPARING AND DRAWING THE BOARD:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;An array that will store the current state of the board, each element of the array corresponds to a cell on the board.
    board            db 64d dup(0)

    ;The size of each cell on the chessboard.
    cell_size        dw 75d

    ;Horizontal margin is set to 4 cells
    margin_x         dw 4

    ;Vertical margin is set to 2 cells (This might be altered later, to clear some space for chatting).
    margin_y         dw 2

    ;Cells can have 2 colors: white and gray. The codes of those colors are stored here, and will be used when drawing the board.
    board_colors     db 31d, 28d

    ; Used for highlighting (hover effect)
    highlighted_cell_color  db 14d

    ;Stores the color of the cell being drawn at a specific iteration.
    temp_color       db ?

    ;No. of loops that the delay function will execute
    delay_loops      dw ?
    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED TO ACCESS AND DRAW CHESS PIECES:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Unique reference number that will be assigned to files when accessing them. This variable is used when calling interrupts to read from the bitmap files.
    file_handle      dw 0
    
    ;The dimensions of each image.
    file_size        dw 76d

    ;Reading a bitmap image will be done row by row (each row contains 76 bytes).
    ;Hence, a buffer of size 76 is used to store the temporary data being read.
    bitmap_buffer    db 76d dup(?)
                      
    ;Temporary x-coordinate that will be used when loading a bitmap image to the board.
    x_temp           dw ?

    ;Temporary y-coordinate that will be used when loading a bitmap image to the board.
    y_temp           dw ?
    
    
    ;White Pieces

    ;Preparing file names
    whitePawn_file   db 'wPawn.bmp', 0
    whiteKnight_file db 'wKnight.bmp', 0
    whiteBishop_file db 'wBishop.bmp', 0
    whiteRook_file   db 'wRook.bmp', 0
    whiteQueen_file  db 'wQueen.bmp', 0
    whiteKing_file   db 'wKing.bmp', 0
	
    ;An array of pointers to every file name. Will be used to draw the pieces in a clean manner.
    white_pieces     dw 0
                     dw whitePawn_file
                     dw whiteKnight_file
                     dw whiteBishop_file
                     dw whiteRook_file
                     dw whiteQueen_file
                     dw whiteKing_file



    ;Black Pieces

    ;Preparing file names
    blackPawn_file   db 'bPawn.bmp'			,0
    blackKnight_file db 'bKnight.bmp'			,0
    blackBishop_file db 'bBishop.bmp'			,0
    blackRook_file   db 'bRook.bmp'			,0
    blackQueen_file  db 'bQueen.bmp'			,0
    blackKing_file   db 'bKing.bmp'			,0
    
    ;An array of pointers to every file name. Will be used to draw the pieces in a clean manner.
    black_pieces     dw 0
                     dw blackPawn_file
                     dw blackKnight_file
                     dw blackBishop_file
                     dw blackRook_file
                     dw blackQueen_file
                     dw blackKing_file


    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;---------------------------------------------------------------------------------------------------------------------------------------------

.code
    ;Initializes the board pieces in memory.
init_board proc
    ;Before placing any pieces on the board, initialize every location on the board to zero (i.e. empty the board)
                          mov  cx, 64d
                          mov  bx, offset board
    clear_board:          
                          mov  [bx], byte ptr 0
                          inc  bx
                          loop clear_board



    ;Places the pawns on their initial positions on board, 1 indicates a black pawn and -1 indicates a white pawn.
    ;Pawns fill the second and eighth rows.
                          mov  bx, offset board + 8
                          mov  cx, 8
    init_pawns:           
                          mov  [bx], byte ptr 1
                          add  bx, 40d
                          mov  [bx], byte ptr -1
                          sub  bx, 39d
                          loop init_pawns



    ;Places the knights on their initial positions on the board, 2 indicates a black knight and -2 indicates a white knight.
                          mov  bx, offset board + 1
                          mov  cx, 2
    init_knights:         
                          mov  [bx], byte ptr 2
                          add  bx, 56d
                          mov  [bx], byte ptr -2
                          sub  bx, 51d
                          loop init_knights



    ;Places the bishops on their initial positions on the board, 3 indicates a black bishop and -3 indicates a white bishop.
                          mov  bx, offset board + 2
                          mov  cx, 2
    init_bishops:         
                          mov  [bx], byte ptr 3
                          add  bx, 56d
                          mov  [bx], byte ptr -3
                          sub  bx, 53d
                          loop init_bishops



    ;Places the rooks on their initial positions on the board, 4 indicates a black rook and -4 indicates a white rook.
                          mov  bx, offset board
                          mov  cx, 2
    init_rooks:           
                          mov  [bx], byte ptr 4
                          add  bx, 56d
                          mov  [bx], byte ptr -4
                          sub  bx, 49d
                          loop init_rooks



    ;Places the queens on their initial positions on the board, 5 indicates a black queen and 6 indicates a white queen.
                          mov  bx, offset board + 3
                          mov  [bx], byte ptr 5
                          add  bx, 56d
                          mov  [bx], byte ptr -5



    ;Places the kings on their initial positions on the board, 6 indicates a black king and -6 indicates a white king.
                          mov  bx, offset board + 4
                          mov  [bx], byte ptr 6
                          add  bx, 56d
                          mov  [bx], byte ptr -6

                          ret
init_board endp
    ;Notice: magnitudes of the numeric values assigned to the pieces are ordered in the way that the white_pieces/black_pieces arrays are ordered.
    ;This is intentional, and will allow us to access the array positions easily when mapping the board to a drawing.


    ;--------------------------------------------------------------------------------------------------------------------------------------------


    ;Prepares the video mode for displaying the board. INT 10H with AX = 4F02H was used, which sets a VESA compliant video mode that allows for
    ;higher resolution when compared to the traditional 10H interrupts.
init_video_mode proc
                          mov  ax, 4F02h
                          mov  bx, 107h                            ;Resolution = 1280x1024, with a 256 color palette
                          int  10h
                          ret
init_video_mode endp


    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;Clears the entire screen (in this case, the dimensions of the screen are 1280x1024).
    ;The screen is set to the color stored in register AL.
clear_screen proc
                          mov  ah, 0ch
                          mov  cx, 1280d
    loop_x_direction:     
                          mov  dx, 1024d
    loop_y_direction:     
                          int  10h
                          dec  dx
                          jnz  loop_y_direction
                          loop loop_x_direction
                          ret
clear_screen endp


    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;Checks whether or not there was an error when opening a bitmap file containing the image of any piece.
    ;All of the interrupts used to access files set the carry flag if an error occurs, and reset the carry flag if the file is opened successfully.
    ;Hence, checking the carry flag is sufficient to detect errors.
check_file_error proc
                          jc   error_handling
                          ret
    error_handling:       
                          mov  ah, 9
                          mov  dx, offset error_msg
                          int  21h
                          mov  ax, 4c00h
                          int  21h
check_file_error endp


    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;Gets the file handle of the bitmap file we wish to access
get_file_handle proc
                          mov  ax, 3d00h
                          int  21h
                          call check_file_error
                          mov  [file_handle], ax
                          ret
get_file_handle endp


    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;Moves file pointer to the beginning of the file (Read the documentation of the interrupt INT 21H, AH=42H "Seek File").
go_to_file_start proc
                          mov  ax, 4200h
                          mov  bx, file_handle
                          mov  cx, 0
                          mov  dx, 0
                          int  21h
                          call check_file_error
                          ret
go_to_file_start endp


    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;Every bitmap file contains a header block that is used to identify the file. We wish to bypass this block, so we use this procedure.
    ;We read the first 14 bytes of the header to extract information about the starting point of the image, then we go to that starting point.
pass_file_header proc
                          call go_to_file_start
                          mov  ax, 3f00h
                          mov  cx, 14d
                          mov  dx, offset bitmap_buffer
                          int  21h

    ;Moves file pointer to the beginning of the data we wish to read. Bytes 10d and 12d in the header contain the needed information to position
    ;the file pointer at the starting point of the actual image.
                          mov  bx, offset bitmap_buffer
                          mov  dx, [bx+10d]
                          mov  cx, [bx+12d]
                          mov  ax, 4200h
                          mov  bx, [file_handle]
                          int  21h
                          call check_file_error
pass_file_header endp


    ;----------------------------------------------------------------------------------------------------------------------------------------------


    ;loads the image of a piece, with its picture stored as a bitmap file.
    ;The image will be placed at the cell with row number stored in DI and column number stored in SI.
    ;Note: rows/columns range from 0 to 7, since the chess board has 8 rows and 8 columns.
load_piece proc

    ;Get the actual position of the top left corner of the cell we wish to draw at, and store the coordinates in the x_temp and y_temp variables.
                          mov  ax, si
                          mul  cell_size
                          mov  x_temp, ax

                          mov  ax, di
                          mul  cell_size
                          mov  y_temp, ax
                
    ;Nested loops, vs code formatting distorted it slightly.
                          mov  si, file_size
    loop_y_bitmap:        
    
    ;Read a row from the bitmap file, and place it in the bitmap_buffer.
                          mov  bx, file_handle
                          mov  ah, 3fh
                          mov  cx, file_size
                          mov  dx, offset bitmap_buffer
                          int  21h

                          mov  di, file_size
                          dec  di

    loop_x_bitmap:        
    ;Load the color of the current pixel to AL, since AL stored the color when drawing a pixel using INT 10H
                        ;   mov  bx, offset bitmap_buffer
                        ;   add  bx, di
                          mov  al, byte ptr bitmap_buffer[di]
                          cmp  al, 0ffh                            ;Do not draw any white pixels, to preserve the background color of the board.
                         
                          je   continue_bitmap_loop
                         
    ;Draws a pixel at the position specified by CX and DX, with color stored in AL.
                          mov  ah, 0ch
                          mov  bl, 0
                          mov  cx, di
                          add  cx, x_temp
                          mov  dx, si
                          add  dx, y_temp
                          int  10h

    continue_bitmap_loop: 
    ;Go to the next pixel.
                          dec  di
                          jnz  loop_x_bitmap
                          dec  si
                          jnz  loop_y_bitmap

                          ret
load_piece endp


    ;-----------------------------------------------------------------------------------------------------------------------------------------------


    ;Closes the bitmap file.
close_file proc
                          mov  ah, 3Eh
                          mov  bx, [file_handle]
                          call check_file_error
                          int  21h
                          ret
close_file endp


    ;-------------------------------------------------------------------------------------------------------------------------------------------------


    ;Returns color of the cell specified by SI(x-pos) & DI(y-pos) in AL
get_cell_colour PROC

    push di
    
    add di,si
    and di,1
    mov al,board_colors[di]
                          
    pop di 

    ret
    
get_cell_colour ENDP

    ;Draws a piece
draw_piece proc
    ;pusha is not recognized, so manually pushed all potentially critical registers for safety :).
                          push ax
                          push bx
                          push cx
                          push dx
                          push si
                          push di

                          add  si, margin_x                        ;Adjust the column position using the x_margin.
                          add  di, margin_y                        ;Adjust the row position using the y_margin.
                          push si
                          push di
                          call get_file_handle                     ;Prepare the file handle for other interrupts
                          call pass_file_header                    ;Move the file pointer to the starting point of the image
                          pop  di
                          pop  si
                          call load_piece                          ;Draw the image at the rows and columns specified by SI and DI.
                          call close_file                          ;Close the file
                         
    ;popa not supported :)
                          pop  di
                          pop  si
                          pop  dx
                          pop  cx
                          pop  bx
                          pop  ax
                         
                          ret

draw_piece endp


    ;-------------------------------------------------------------------------------------------------------------------------------------------------


    ;Draws a cell at the row and columns positions specified by SI and DI.
draw_cell proc

    ;Adjust SI and DI for the margins
                          push si
                          push di
                          add  si, margin_x
                          add  di, margin_y

    ;Calculate and store the actual row and column positions of the upper left corner of each cell, and place them in SI and DI
                          mov  ah, 0ch
                          push ax
                          mov  ax, si
                          mul  cell_size
                          mov  si, ax

                          mov  ax, di
                          mul  cell_size
                          mov  di, ax
                         
                          pop  ax
                         
    ;Prepare for drawing the cell.
                          mov  cx, cell_size
                          add  cx, si

    loop_x_cell:          
                          mov  dx, cell_size
    loop_y_cell:          
    ;CX and DX store the row and columns positions for INT 10H.
                          add  dx, di
                          int  10h

                          sub  dx, di
                          dec  dx
                          jnz  loop_y_cell
                          dec  cx
                          cmp  cx, si
                          jnz  loop_x_cell

    ;After drawing the cell, we now wish to draw the piece in the cell (if any).

    ;Get back the original row and column positions (from 0 to 7).
                          pop  di
                          pop  si
                        
    ;From SI and DI, get the position of the cell we are drawing in board array, which contains the current state of the board.
                          mov  bx, di
    ;Multiplies by 8, we don't need to move 3 to register first in this assembler. We multiply the row number by 8 since each row has 8 positions.
                          shl  bx, 3
                          add  bx, si
                          add  bx, offset board
                          mov  ah, [bx]
                          mov  bh, 0
                          cmp  ah, 0

    ;If the current element in the board array contains 0, we draw no pieces.
    ;If it contains a negative value, we draw a white piece.
    ;If it contains a positive value, we draw a black piece.
                          je   finish_draw_cell
                          jl   draw_white_piece
    ;Drawing a black piece
    draw_black_piece:     
                          mov  bl, ah
                          shl  bl, 1
    ;Move the offset of the file we wish to access and draw to dx
                          mov  dx, word ptr [black_pieces + bx]
                          call draw_piece
                          jmp  finish_draw_cell
    ;White Mate
    draw_white_piece:     
                          neg  ah
                          mov  bl, ah
                          shl  bl, 1
    ;Move the offset of the file we wish to access and draw to dx
                          mov  dx, word ptr [white_pieces + bx]
                          call draw_piece
    ;Exiting
    finish_draw_cell:     
                          ret
draw_cell endp


    ;-------------------------------------------------------------------------------------------------------------------------------------------


    ;Calls draw_cell in a nested loop to display the whole board.
draw_board proc

    ;Position of the first (upper left) cell
                          mov  si, 0
                          mov  di, 0
    ;Color of the first cell
                        ;   mov  al, byte ptr cell_colors
                         
    loop_y_board:         
                          mov  si, 0
    loop_x_board:         
    ;Draw the current cell
                          call get_cell_colour
                        ;   push ax
                          call draw_cell
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
                          inc  si
                          cmp  si, 8
                          jnz  loop_x_board
                         
    ;Before going to the next iteration of the outer loop, reverse the color of the cell
    ;                       cmp  al, byte ptr cell_colors
    ;                       jz   set_dark_color
    ;                       mov  al, byte ptr cell_colors
    ;                       jmp  new_iteration
    ; set_dark_color:       
    ;                       mov  al, byte ptr cell_colors + 1
    new_iteration:        
                          inc  di
                          cmp  di, 8
                          jnz  loop_y_board

                          ret
draw_board endp


;delays according to no. of 'delay_loops' in memory
delay PROC
    push cx
    push ax
    pushf
    mov cx, delay_loops

    loop1:
            mov ax, 65535d
            loop2:  dec ax 
                    jnz loop2
            
            loop loop1 
    popf
    pop ax  
    pop cx  
    ret 
delay ENDP


clear_keyboard_buffer PROC 

    push ax
    
    mov ah, 0Ch
    mov al,0
    int 21h

    pop ax

    ret
clear_keyboard_buffer ENDP 

;Moves the piece (if possible) according to the scan codes of keys pressed (A->1E, D->20, W->11, S->1F)
hover PROC

            push cx 
            push dx

            ; Storing current positons [DX,CX]
            mov cx,si 
            mov dx,di 
    
            cmp ah, 1Eh 
            jz move_left

            cmp ah, 20h
            jz move_right

            cmp ah, 11h
            jz move_up

            cmp ah, 1Fh
            jz move_down

            jmp dont_move

move_left:
            cmp si, 0
            jz dont_move
            dec si
            jmp redraw        

move_right:
            cmp si, 7h
            jz dont_move
            inc si
            jmp redraw        
move_up:
            cmp di, 0h
            jz dont_move
            dec di
            jmp redraw        
move_down:
            cmp di, 7h
            jz dont_move
            inc di
            jmp redraw        


redraw:     
            ; Redraw the prev cell with its original color
            push si
            push di
            mov si, cx
            mov di, dx
            mov al, temp_color
            call draw_cell
            pop di
            pop si

dont_move:  
            pop dx
            pop cx
            ret

hover ENDP

main proc far
    ;Initializing the data segment register
                          mov  ax, @data
                          mov  ds, ax

    ;Setting working directory to the folder containing bitmaps of the pieces
                          mov  ah, 3bh
                          mov  dx, offset pieces_wd
                          int  21h

                          call init_board                          ;Initialize board

                          call init_video_mode                     ;Prepare video mode

    ;Clear the screen, in preparation for drawing the board
                          mov  al, 14h                             ;The color by which we will clear the screen (light gray).
                          call clear_screen

                          call draw_board                          ;Draw the board
                         
    ;Listen for keyboard press and change its colour
                          mov si,0
                          mov di,7d

                          


    start:                call get_cell_colour
                          mov temp_color, al
                          cmp ax,ax 
                          
                          

    breathe:              cmp al, temp_color
                          jz highlight 
                          jmp darken  

              

    draw:                 call draw_cell
                          
                          mov delay_loops,10d
                          call delay                

                          mov ah,1 
                          int 16h 

                          jnz check
                          jmp breathe 
    
    
    highlight:            mov al, highlighted_cell_color  
                          jmp draw                      


    darken:               mov al, temp_color   
                          jmp draw  


    check:                                          
                          call clear_keyboard_buffer

                          ; Before moving hover, check if a piece is selected
                          ; If one is selected, show all possible moves
                          cmp ah, 10h
                          jz show_possible_moves

                          call hover

                          jmp start

    show_possible_moves:   
                          mov al, highlighted_cell_color
                          call draw_cell

                          hlt
main endp
end main


