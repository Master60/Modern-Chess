.model huge ;To be adjusted (maybe), setting the model to huge for now just to be safe :)
.stack 64


;---------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------

.data

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PATH CONTROL AND ERROR MESSAGE:
    ;---------------------------------------------------------------------------------------------------------------------------------------------
    
    ;Name of the folder containing images of all pieces, will be used to change directory at the start of the main proc.
    pieces_wd              db "pieces", 0

    ;Message to be displayed if a file fails to open.
    error_msg              db "Error! Could not open bitmap files.$"

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED FOR PREPARING AND DRAWING THE BOARD:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;An array that will store the current state of the board, each element of the array corresponds to a cell on the board.
    board                  db 64d dup(0)

    ;
    selectedPiecePos       dw ?

    ;
    possibleMoves_DI       dw 8 Dup(7 Dup(-1d))
    possibleMoves_SI       dw 8 Dup(7 Dup(-1d))
    ;            --------------------------------------------------------------------------> Possible moves in that direction
    ;           |  Up          (possibleMoves_DI[0],possibleMoves_SI[0]) .  .  .  .  .  .  .  .  .  .  .
    ;               |  Up-Right                                 .
    ;           |  Right                                .
    ;           |  Down-Right                           .
    ;           |  Down                                 .
    ;           |  Down-Left                            .
    ;           |  Left                                 .
    ;               |  Up-Left    (possibleMoves_DI[49],possibleMoves_SI[49])
    ;           v
    ;       Directions

    ; Keeps track of the possible move that the player is currently selecting and are used to write the moves to memory in "recordMove"
    directionPtr           db 0d
    currMovePtr            db 0d

    ; the position (containing a piece) that the player is currently selecting
    currSelectedPos_SI     dw ?
    currSelectedPos_DI     dw ?

    ; Step unit (-1 for white & 1 for black)
    walker                 dw ?

    ;The size of each cell on the chessboard.
    cell_size              dw 75d

    ;Horizontal margin is set to 4 cells
    margin_x               dw 4

    ;Vertical margin is set to 2 cells (This might be altered later, to clear some space for chatting).
    margin_y               dw 2

    ;Cells can have 2 colors: white and gray. The codes of those colors are stored here, and will be used when drawing the board.
    board_colors           db 31d, 28d

    ; Used for highlighting (hover effect)
    highlighted_cell_color db 14d

    ;Stores the color of the cell being drawn at a specific iteration.
    temp_color             db ?

    ;No. of loops that the delay function will execute
    delay_loops            dw ?
    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED TO ACCESS AND DRAW CHESS PIECES:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Unique reference number that will be assigned to files when accessing them. This variable is used when calling interrupts to read from the bitmap files.
    file_handle            dw 0
    
    ;The number of bytes in each image.
    file_size              dw 5776d

    ;The dimensions of each image.
    file_width             dw 76d

    ;Reading a bitmap image will be done row by row (each row contains 76 bytes).
    ;Hence, a buffer of size 76 is used to store the temporary data being read.
    bitmap_buffer          db 5776d dup(?)
                      
    ;Temporary x-coordinate that will be used when loading a bitmap image to the board.
    x_temp                 dw ?

    ;Temporary y-coordinate that will be used when loading a bitmap image to the board.
    y_temp                 dw ?
    
    
    ;White Pieces

    ;Preparing file names
    whitePawn_file         db 'wPawn.bmp', 0
    whiteKnight_file       db 'wKnight.bmp', 0
    whiteBishop_file       db 'wBishop.bmp', 0
    whiteRook_file         db 'wRook.bmp', 0
    whiteQueen_file        db 'wQueen.bmp', 0
    whiteKing_file         db 'wKing.bmp', 0
	
    ;An array of pointers to every file name. Will be used to draw the pieces in a clean manner.
    white_pieces           dw 0
                           dw whitePawn_file
                           dw whiteKnight_file
                           dw whiteBishop_file
                           dw whiteRook_file
                           dw whiteQueen_file
                           dw whiteKing_file



    ;Black Pieces

    ;Preparing file names
    blackPawn_file         db 'bPawn.bmp', 0
    blackKnight_file       db 'bKnight.bmp', 0
    blackBishop_file       db 'bBishop.bmp', 0
    blackRook_file         db 'bRook.bmp', 0
    blackQueen_file        db 'bQueen.bmp', 0
    blackKing_file         db 'bKing.bmp', 0
    
    ;An array of pointers to every file name. Will be used to draw the pieces in a clean manner.
    black_pieces           dw 0
                           dw blackPawn_file
                           dw blackKnight_file
                           dw blackBishop_file
                           dw blackRook_file
                           dw blackQueen_file
                           dw blackKing_file


    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;---------------------------------------------------------------------------------------------------------------------------------------------

.code

                         include "initializations.inc"
                         include "pieces.inc"
                         include "board_gui.inc"
                         include "misc.inc"
                         include "io.inc"
                         include "moves.inc"

selected_cell_hover proc

                         call    removeSelections
                         call    get_cell_colour
                         mov     temp_color, al
    ;cmp     ax,ax           ;lw rg3taha hdrbk
                          
                          

    breathe:             cmp     al, temp_color
                         jz      highlight
                         jmp     darken

              

    draw:                call    draw_cell
                          
                         mov     delay_loops,10d
                         call    delay

    ; Checks for keyboard input
                         mov     ah,1
                         int     16h

                         jz      breathe
                         ret
    
    
    highlight:           mov     al, highlighted_cell_color
                         jmp     draw


    darken:              mov     al, temp_color
                         jmp     draw
selected_cell_hover endp

check_user_input proc
    ;Consumes keyboard buffer
                         mov     ah,0
                         int     16h
    ; Before moving hover, check if a piece is selected
    ; If one is selected, return to the main function to display the possible positions for the selected piece.
                         cmp     ah, 10h
                         jnz     move_selection
                         ret
                                   
    move_selection:      call    move_selected_cell
check_user_input endp

same_selection proc
    same_selection:      
                         mov     ah,1
                         int     16h

                         jz      same_selection
                         ret
same_selection endp

show_possible_moves proc
                         call    recordCurrPos
                          
                         mov     al, highlighted_cell_color
                         call    draw_cell
                          
                         call    getPos

                         cmp     board[bx], -1
                         jz      white_pawn
                         cmp     board[bx], 1
                         jz      black_pawn
                         jmp     same_selection
                          
    black_pawn:          mov     walker, 1
                         jmp     get_pawn_positions

    white_pawn:          mov     walker, -1
    get_pawn_positions:  call    getPawnMoves

    ; Selections
                         call    getFirstSelection

                          
    same_selection:      
                         cmp     ax,ax
                          
                         mov     ah,1
                         int     16h

                         jnz     end_selection
                         call    same_selection
    end_selection:       ret

show_possible_moves endp

main proc far
    ;Initializing the data segment register
                         mov     ax, @data
                         mov     ds, ax

    ;Setting working directory to the folder containing bitmaps of the pieces
                         mov     ah, 3bh
                         mov     dx, offset pieces_wd
                         int     21h

                         call    init_board                    ;Initialize board

                         call    init_video_mode               ;Prepare video mode

    ;Clear the screen, in preparation for drawing the board
                         mov     al, 14h                       ;The color by which we will clear the screen (light gray).
                         call    clear_screen

                         call    draw_board                    ;Draw the board
                         
    ;Hover over selected cell by changing its color, and wait for user input.
                         mov     si,0
                         mov     di,7d

    start:               call    selected_cell_hover
                         call    check_user_input
                         call    show_possible_moves

    change_event:        
    ;Consumes keyboard buffer
                         mov     ah,0
                         int     16h
    ; Before changing move, check if a move is selected / Deselection of piece
                         cmp     ah, 10h
                         jnz     go_to_next_selection
    ; deselects the cell it is curr on (will be modified)
                         jmp     far ptr start

    ; The key is now in ah
    go_to_next_selection:
    ; save current positions
                         mov     currSelectedPos_DI, di
                         mov     currSelectedPos_SI, si

                         call    goToNextSelection

                         mov     al, 00h
                         call    drawBorder

                         jmp     same_selection
                          

    halt:                hlt
main endp
end main