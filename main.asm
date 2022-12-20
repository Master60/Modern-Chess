.286    ;For 8086 microprocessor assembly instructions

;-------------------------------------------------------------------------------------------------------------------------------------------------

.model huge ;To be adjusted (maybe), setting the model to huge for now just to be safe :)

;-------------------------------------------------------------------------------------------------------------------------------------------------

.stack 64

;-------------------------------------------------------------------------------------------------------------------------------------------------

.data

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PATH CONTROL AND ERROR MESSAGE:
    ;---------------------------------------------------------------------------------------------------------------------------------------------
    
    ;Name of the folder containing images of all pieces, will be used to change directory at the start of the main proc.
    pieces_wd                db      "pieces", 0

    ;Message to be displayed if a file fails to open.
    error_msg                db      "Error! Could not open bitmap files.$"

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED IN THE MAIN MENU:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Three command messages to be displayed at the main menu
    cmd1                     db      'To start chatting press F1', '$'

    cmd2                     db      'To start the game press F2', '$'

    cmd3                     db      'To end the program press ESC', '$'

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED IN THE CHAT MENU:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Chat screen title
    chat_title               db      'Chat', '$'

    ;Name of the other player (to be modified in phase 2)
    temp_name                db      'Miro', '$'

    ;Dummy text to be displayed
    dummy1                   db      'This window is to be further developed in phase 2, thanks for checking in.', '$'

    dummy2                   db      'Press F3 to exit', '$'

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED FOR PREPARING AND DRAWING THE BOARD:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;An array that will store the current state of the board, each element of the array corresponds to a cell on the board.
    board                    db      64d dup(0)

    selectedPiecePos         dw      ?

    possibleMoves_DI         dw      8 Dup(8 Dup(-1d))
    possibleMoves_SI         dw      8 Dup(8 Dup(-1d))

    ;           ---------------------------------------------------------------------------> Possible moves in that direction
    ;           |   Up          (possibleMoves_DI[0],possibleMoves_SI[0]) .  .  .  .  .  .  .  .  .  .  .
    ;           |   Up-Right                             .
    ;           |   Right                                .
    ;           |   Down-Right                           .
    ;           |   Down                                 .
    ;           |   Down-Left                            .
    ;           |   Left                                 .
    ;           |   Up-Left     (possibleMoves_DI[49],possibleMoves_SI[49])
    ;           v
    ;       Directions

    ; Keeps track of the possible move that the player is currently selecting and are used to write the moves to memory in "recordMove"
    directionPtr             db      -1d
    currMovePtr              db      -1d

    ; the position (containing a piece) that the player is currently selecting
    currSelectedPos_SI       dw      -1d
    currSelectedPos_DI       dw      -1d

    ; Step unit (-1 for white & 1 for black)
    walker                   dw      ?

    ; Navigation Buttons
    Left_Arrow      db  4Bh
    Right_Arrow     db  4Dh
    Up_Arrow        db  48h
    Down_Arrow      db  50h

    Enter_Key       db  28d           

    ;The size of each cell on the chessboard.
    cell_size                dw      75d

    ;Horizontal margin is set to 4 cells
    margin_x                 dw      4

    ;Vertical margin is set to 2 cells (This might be altered later, to clear some space for chatting).
    margin_y                 dw      2

    ;Cells can have 2 colors: white and gray. The codes of those colors are stored here, and will be used when drawing the board.
    board_colors             db      31d, 28d

    ; Used for highlighting (hover effect)
    highlighted_cell_color   db      14d
    hover_cell_color         db      102d
    possible_take_cell_color db      12d
    ;Stores the color of the cell being drawn at a specific iteration.
    temp_color               db      ?

    ;No. of loops that the delay function will execute
    delay_loops              dw      ?

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED TO ACCESS AND DRAW CHESS PIECES:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Unique reference number that will be assigned to files when accessing them. This variable is used when calling interrupts to read from the bitmap files.
    file_handle              dw      0

    image_size               dw      1280d
    
    ;The number of bytes in each image.
    file_size                dw      5776d

    ;The dimensions of each image.
    file_width               dw      76d

    bitmap_background_buffer db      1280  dup(?)

    ;Reading a bitmap image will be done row by row (each row contains 76 bytes).
    ;Hence, a buffer of size 76 is used to store the temporary data being read.
    bitmap_buffer            db      5776d dup(?)
                      
    ;Temporary x-coordinate that will be used when loading a bitmap image to the board.
    x_temp                   dw      ?

    ;Temporary y-coordinate that will be used when loading a bitmap image to the board.
    y_temp                   dw      ?
    
    ;White Pieces

    ;Preparing file names
    whitePawn_file           db      'wPawn.bmp', 0
    whiteKnight_file         db      'wKnight.bmp', 0
    whiteBishop_file         db      'wBishop.bmp', 0
    whiteRook_file           db      'wRook.bmp', 0
    whiteQueen_file          db      'wQueen.bmp', 0
    whiteKing_file           db      'wKing.bmp', 0
	
    ;An array of pointers to every file name. Will be used to draw the pieces in a clean manner.
    white_pieces             dw      0
                             dw      whitePawn_file
                             dw      whiteKnight_file
                             dw      whiteBishop_file
                             dw      whiteRook_file
                             dw      whiteQueen_file
                             dw      whiteKing_file

    ;Black Pieces

    ;Preparing file names
    blackPawn_file           db      'bPawn.bmp', 0
    blackKnight_file         db      'bKnight.bmp', 0
    blackBishop_file         db      'bBishop.bmp', 0
    blackRook_file           db      'bRook.bmp', 0
    blackQueen_file          db      'bQueen.bmp', 0
    blackKing_file           db      'bKing.bmp', 0
    
    ;An array of pointers to every file name. Will be used to draw the pieces in a clean manner.
    black_pieces             dw      0
                             dw      blackPawn_file
                             dw      blackKnight_file
                             dw      blackBishop_file
                             dw      blackRook_file
                             dw      blackQueen_file
                             dw      blackKing_file

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;DEFINING LETTERS AND NUMBERS:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;recommended:   length:15-20,   width:10-15
    ;used       :   length:19   ,   width:13

                             letters label byte

    letter_A                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1

    letter_B                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1

    letter_C                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1

    letter_D                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1

    letter_E                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1

    letter_F                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0

    letter_G                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1

    letter_H                 db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1

                             numbers label byte

    number_1                 db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1

    number_2                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1

    number_3                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1

    number_4                 db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1

    number_5                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1

    number_6                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,0,0,0,0,0,0,0,0,0,0
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1

    number_7                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1
                             db      0,0,0,0,0,0,0,0,0,0,1,1,1

    number_8                 db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,0,0,0,0,0,0,0,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1,1,1,1,1

    temp_sp                  dw      ?

.code

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;MISCELLANEOUS PROCEDURES:
    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;sets carry flag
setcarry PROC
                                                 push  ax
    
                                                 mov   ax, 0ffffh
                                                 shl   ax, 1d

                                                 pop   ax
                                                 ret
setcarry ENDP

    ;delays according to no. of 'delay_loops' in memory
delay proc

                                                 push  cx
                                                 push  ax
                                                 pushf
                                                 mov   cx, delay_loops

    loop1:                                       
                                                 mov   ax, 65535d

    loop2:                                       
                                                 dec   ax
                                                 jnz   loop2
            
                                                 loop  loop1

                                                 popf
                                                 pop   ax
                                                 pop   cx

                                                 ret

delay endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

clear_keyboard_buffer proc

                                                 push  ax
    
                                                 mov   ah, 0Ch
                                                 mov   al,0
                                                 int   21h

                                                 pop   ax

                                                 ret

clear_keyboard_buffer endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

draw_letters proc

                                                 pusha

                                                 mov   temp_sp, sp

                                                 mov   di, cell_size
                                                 mov   si, 0

                                                 mov   ax, 0
                                                 mov   ax, margin_x
                                                 mul   di
                                                 add   ax, 31d
                                                 add   ax, 13d
                                                 mov   bp, ax

                                                 mov   ax, 0
                                                 mov   ax, margin_y
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, 4
                                                 add   ax, 19d
                                                 mov   sp, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 mul   di
                                                 add   ax, 31d
                                                 mov   bx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 mul   di
                                                 add   ax, 31d
                                                 mov   cx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_y
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, 4
                                                 mov   dx, ax

                                                 mov   al, 3
                                                 mov   ah, 0ch

                                                 mov   di, 8

    draw_letters_1:                              

    loop_y_letter_1:                             

    loop_x_letter_1:                             
                                                 cmp   letters + [si], 1
                                                 je    draw_the_letter_1
    back_1:                                      
                                                 inc   si
                                                 inc   cx
                                                 cmp   cx, bp
                                                 jnz   loop_x_letter_1

                                                 inc   dx
                                                 mov   cx, bx
                                                 cmp   dx, sp
                                                 jnz   loop_y_letter_1

                                                 add   cx, cell_size
                                                 add   bp, cell_size
                                                 add   bx, cell_size
                                                 sub   dx, 19d
                                                 dec   di
                                                 jnz   draw_letters_1
                                                 jmp   end_draw_letters_1

    draw_the_letter_1:                           
                                                 int   10h
                                                 jmp   back_1

    end_draw_letters_1:                          


                                                 mov   di, cell_size
                                                 mov   si, 0

                                                 mov   ax, 0
                                                 mov   ax, margin_x
                                                 mul   di
                                                 add   ax, 31d
                                                 mov   bp, ax

                                                 mov   ax, 0
                                                 mov   ax, margin_y
                                                 mul   di
                                                 sub   ax, 4
                                                 sub   ax, 19d
                                                 mov   sp, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 mul   di
                                                 add   ax, 31d
                                                 add   ax, 13d
                                                 mov   bx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 mul   di
                                                 add   ax, 31d
                                                 add   ax, 13d
                                                 mov   cx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_y
                                                 mul   di
                                                 sub   ax, 4
                                                 mov   dx, ax

                                                 mov   al, 3
                                                 mov   ah, 0ch

                                                 mov   di, 8

    draw_letters_2:                              

    loop_y_letter_2:                             

    loop_x_letter_2:                             
                                                 cmp   letters + [si], 1
                                                 je    draw_the_letter_2
    back_2:                                      
                                                 inc   si
                                                 dec   cx
                                                 cmp   cx, bp
                                                 jnz   loop_x_letter_2

                                                 dec   dx
                                                 mov   cx, bx
                                                 cmp   dx, sp
                                                 jnz   loop_y_letter_2

                                                 add   cx, cell_size
                                                 add   bp, cell_size
                                                 add   bx, cell_size
                                                 add   dx, 19d
                                                 dec   di
                                                 jnz   draw_letters_2
                                                 jmp   end_draw_letters_2

    draw_the_letter_2:                           
                                                 int   10h
                                                 jmp   back_2

    end_draw_letters_2:                          

                                                 mov   sp, temp_sp

                                                 popa

                                                 mov   temp_sp, di

                                                 ret

draw_letters endp



draw_numbers proc

                                                 pusha

                                                 mov   temp_sp, sp

                                                 mov   di, cell_size
                                                 mov   si, 0

                                                 mov   ax, 0
                                                 mov   ax, margin_x
                                                 mul   di
                                                 sub   ax, 6
                                                 mov   bp, ax

                                                 mov   ax, 0
                                                 mov   ax, margin_y
                                                 mul   di
                                                 add   ax, 31d
                                                 add   ax, 19d
                                                 mov   sp, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 mul   di
                                                 sub   ax, 6
                                                 sub   ax, 13d
                                                 mov   bx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 mul   di
                                                 sub   ax, 6
                                                 sub   ax, 13d
                                                 mov   cx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_y
                                                 mul   di
                                                 add   ax, 31d
                                                 mov   dx, ax

                                                 mov   al, 3
                                                 mov   ah, 0ch

                                                 mov   di, 8

    draw_numbers_1:                              

    loop_y_number_1:                             

    loop_x_number_1:                             
                                                 cmp   numbers + [si], 1
                                                 je    draw_the_number_1
    back_number_1:                               
                                                 inc   si
                                                 inc   cx
                                                 cmp   cx, bp
                                                 jnz   loop_x_number_1

                                                 inc   dx
                                                 mov   cx, bx
                                                 cmp   dx, sp
                                                 jnz   loop_y_number_1

                                                 add   dx, cell_size
                                                 add   sp, cell_size
                                                 sub   dx, 19d
                                                 dec   di
                                                 jnz   draw_numbers_1
                                                 jmp   end_draw_numbers_1

    draw_the_number_1:                           
                                                 int   10h
                                                 jmp   back_number_1

    end_draw_numbers_1:                          


                                                 mov   di, cell_size
                                                 mov   si, 0

                                                 mov   ax, 0
                                                 mov   ax, margin_x
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, 6
                                                 mov   bp, ax

                                                 mov   ax, 0
                                                 mov   ax, margin_y
                                                 add   ax, 8
                                                 mul   di
                                                 sub   ax, 31d
                                                 sub   ax, 19d
                                                 mov   sp, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, 6
                                                 add   ax, 13d
                                                 mov   bx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, 6
                                                 add   ax, 13d
                                                 mov   cx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_y
                                                 add   ax, 8
                                                 mul   di
                                                 sub   ax, 31d
                                                 mov   dx, ax

                                                 mov   al, 3
                                                 mov   ah, 0ch

                                                 mov   di, 8

    draw_numbers_2:                              

    loop_y_number_2:                             

    loop_x_number_2:                             
                                                 cmp   numbers + [si], 1
                                                 je    draw_the_number_2
    back_number_2:                               
                                                 inc   si
                                                 dec   cx
                                                 cmp   cx, bp
                                                 jnz   loop_x_number_2

                                                 dec   dx
                                                 mov   cx, bx
                                                 cmp   dx, sp
                                                 jnz   loop_y_number_2

                                                 sub   dx, cell_size
                                                 sub   sp, cell_size
                                                 add   dx, 19d
                                                 dec   di
                                                 jnz   draw_numbers_2
                                                 jmp   end_draw_numbers_2

    draw_the_number_2:                           
                                                 int   10h
                                                 jmp   back_number_2

    end_draw_numbers_2:                          

                                                 mov   sp, temp_sp

                                                 popa

                                                 ret

draw_numbers endp



    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PROCEDURES USED IN THE CHAT SCREEN:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

chat_window proc

                                                 pusha

                                                 mov   ax, 0600h
                                                 mov   bh, 07
                                                 mov   cx, 0
                                                 mov   dx, 184Fh
                                                 int   10h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 38d
                                                 mov   dh, 00h
                                                 int   10h

                                                 mov   ah, 9
                                                 mov   dx, offset chat_title
                                                 int   21h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 00h
                                                 mov   dh, 01h
                                                 int   10h

                                                 mov   ah, 9
                                                 mov   bh, 0
                                                 mov   al, 45d
                                                 mov   cx, 80d
                                                 mov   bl, 003h
                                                 int   10h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 38d
                                                 mov   dh, 02h
                                                 int   10h

                                                 mov   ah, 9
                                                 mov   dx, offset temp_name
                                                 int   21h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 00h
                                                 mov   dh, 03h
                                                 int   10h

                                                 mov   ah, 9
                                                 mov   bh, 0
                                                 mov   al, 45d
                                                 mov   cx, 80d
                                                 mov   bl, 003h
                                                 int   10h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 00h
                                                 mov   dh, 04h
                                                 int   10h

                                                 mov   ah, 9
                                                 mov   dx, offset dummy1
                                                 int   21h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 32d
                                                 mov   dh, 08h
                                                 int   10h

                                                 mov   ah, 9
                                                 mov   dx, offset dummy2
                                                 int   21h

    chat_end:                                    
                                                 mov   ah, 0
                                                 int   16h

                                                 cmp   ah, 3Dh
                                                 jnz   chat_end

                                                 popa

                                                 ret

chat_window endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PROCEDURES USED IN DRAWING ON THE GAME SCREEN:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Initializes the board pieces in memory.
init_board proc

    ;Before placing any pieces on the board, initialize every location on the board to zero (i.e. empty the board)
                                                 mov   cx, 64d
                                                 mov   bx, offset board

    clear_board:                                 
                                                 mov   [bx], byte ptr 0
                                                 inc   bx
                                                 loop  clear_board

    ;Places the pawns on their initial positions on board, 1 indicates a black pawn and -1 indicates a white pawn.
    ;Pawns fill the second and eighth rows.
                                                 mov   bx, offset board + 8
                                                 mov   cx, 8

    init_pawns:                    
                                   mov   [bx], byte ptr 1d
                                   add   bx, 40d
                                   mov   [bx], byte ptr -1d
                                   sub   bx, 39d
                                   loop  init_pawns

    ;Places the knights on their initial positions on the board, 2 indicates a black knight and -2 indicates a white knight.
                                                 mov   bx, offset board + 1
                                                 mov   cx, 2

    init_knights:                                
                                                 mov   [bx], byte ptr 2
                                                 add   bx, 56d
                                                 mov   [bx], byte ptr -2
                                                 sub   bx, 51d
                                                 loop  init_knights

    ;Places the bishops on their initial positions on the board, 3 indicates a black bishop and -3 indicates a white bishop.
                                                 mov   bx, offset board + 2
                                                 mov   cx, 2

    init_bishops:                                
                                                 mov   [bx], byte ptr 3
                                                 add   bx, 56d
                                                 mov   [bx], byte ptr -3
                                                 sub   bx, 53d
                                                 loop  init_bishops

    ;Places the rooks on their initial positions on the board, 4 indicates a black rook and -4 indicates a white rook.
                                                 mov   bx, offset board
                                                 mov   cx, 2

    init_rooks:                                  
                                                 mov   [bx], byte ptr 4
                                                 add   bx, 56d
                                                 mov   [bx], byte ptr -4
                                                 sub   bx, 49d
                                                 loop  init_rooks

    ;Places the queens on their initial positions on the board, 5 indicates a black queen and 6 indicates a white queen.
                                                 mov   bx, offset board + 3
                                                 mov   [bx], byte ptr 5
                                                 add   bx, 56d
                                                 mov   [bx], byte ptr -5

    ;Places the kings on their initial positions on the board, 6 indicates a black king and -6 indicates a white king.
                                                 mov   bx, offset board + 4
                                                 mov   [bx], byte ptr 6
                                                 add   bx, 56d
                                                 mov   [bx], byte ptr -6

                                                 ret

init_board endp
    ;Notice: magnitudes of the numeric values assigned to the pieces are ordered in the way that the white_pieces/black_pieces arrays are ordered.
    ;This is intentional, and will allow us to access the array positions easily when mapping the board to a drawing.

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Prepares the video mode for displaying the board. INT 10H with AX = 4F02H was used, which sets a VESA compliant video mode that allows for
    ;higher resolution when compared to the traditional 10H interrupts.
init_video_mode proc

                                                 mov   ax, 4F02h
                                                 mov   bx, 107h                                        ;Resolution = 1280x1024, with a 256 color palette
                                                 int   10h

                                                 ret

init_video_mode endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Clears the entire screen (in this case, the dimensions of the screen are 1280x1024).
    ;The screen is set to the color stored in register AL.
clear_screen proc

                                                 mov   ah, 0ch
                                                 mov   cx, 1280d

    loop_x_direction:                            
                                                 mov   dx, 1024d

    loop_y_direction:                            
                                                 int   10h
                                                 dec   dx
                                                 jnz   loop_y_direction

                                                 loop  loop_x_direction

                                                 ret

clear_screen endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

set_board_base proc

                                                 pusha

                                                 mov   bp, cell_size

                                                 mov   ax, 0
                                                 mov   ax, margin_x
                                                 add   ax, 10
                                                 mul   bp
                                                 add   ax, 25d
                                                 mov   di, ax

                                                 mov   ax, 0
                                                 mov   ax, margin_y
                                                 add   ax, 9
                                                 mul   bp
                                                 add   ax, 25d
                                                 mov   si, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 sub   ax, 2
                                                 mul   bp
                                                 sub   ax, 25d
                                                 mov   bx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 sub   ax, 2
                                                 mul   bp
                                                 sub   ax, 25d
                                                 mov   cx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_y
                                                 dec   ax
                                                 mul   bp
                                                 sub   ax, 25d
                                                 mov   dx, ax

                                                 mov   al, 06d                                         ;08d light grey, 06d light brown, 0eh light yellow
                                                 mov   ah, 0ch

    board_y:                                     

    board_x:                                     
                                                 int   10h
                                                 inc   cx
                                                 cmp   cx, di
                                                 jnz   board_x

                                                 mov   cx, bx
                                                 inc   dx
                                                 cmp   dx, si
                                                 jnz   board_y

                                                 popa

                                                 ret

set_board_base endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

set_border proc

                                                 pusha

                                                 mov   cx, 275d
                                                 mov   dx, 125d
                                                 mov   al, 0eh                                         ;4 dark brown
                                                 mov   ah, 0ch

    border_y:                                    

    border_x:                                    
                                                 inc   cx
                                                 cmp   dx,151d
                                                 jb    draw_border
                                                 cmp   dx,750d
                                                 ja    draw_border
                                                 cmp   cx,301d
                                                 jb    draw_border
                                                 cmp   cx,900d
                                                 ja    draw_border
    continue_border:                             
                                                 cmp   cx, 925d
                                                 jnz   border_x

                                                 mov   cx, 275d
                                                 inc   dx
                                                 cmp   dx, 775d
                                                 jnz   border_y

                                                 jmp   end_border

    draw_border:                                 
                                                 int   10h
                                                 jmp   continue_border

    end_border:                                  

                                                 popa

                                                 ret

set_border endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Returns color of the cell specified by SI(x-pos) & DI(y-pos) in AL
get_cell_colour proc

                                                 push  di
    
                                                 add   di, si
                                                 and   di, 1
                                                 mov   al, board_colors[di]
                          
                                                 pop   di

                                                 ret
    
get_cell_colour endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Checks whether or not there was an error when opening a bitmap file containing the image of any piece.
    ;All of the interrupts used to access files set the carry flag if an error occurs, and reset the carry flag if the file is opened successfully.
    ;Hence, checking the carry flag is sufficient to detect errors.
check_file_error proc

                                                 jc    error_handling

                                                 ret

    error_handling:                              
                                                 mov   ah, 9
                                                 mov   dx, offset error_msg
                                                 int   21h
                                                 mov   ax, 4c00h
                                                 int   21h

check_file_error endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Gets the file handle of the bitmap file we wish to access
get_file_handle proc

                                                 mov   ax, 3d00h
                                                 int   21h
                                                 call  check_file_error
                                                 mov   [file_handle], ax

                                                 ret

get_file_handle endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Moves file pointer to the beginning of the file (Read the documentation of the interrupt INT 21H, AH=42H "Seek File").
go_to_file_start proc

                                                 mov   ax, 4200h
                                                 mov   bx, file_handle
                                                 mov   cx, 0
                                                 mov   dx, 0
                                                 int   21h
                                                 call  check_file_error

                                                 ret

go_to_file_start endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Every bitmap file contains a header block that is used to identify the file. We wish to bypass this block, so we use this procedure.
    ;We read the first 14 bytes of the header to extract information about the starting point of the image, then we go to that starting point.
pass_file_header proc

                                                 call  go_to_file_start
                                                 mov   ax, 3f00h
                                                 mov   cx, 14d
                                                 mov   dx, offset bitmap_buffer
                                                 int   21h

    ;Moves file pointer to the beginning of the data we wish to read. Bytes 10d and 12d in the header contain the needed information to position
    ;the file pointer at the starting point of the actual image.
                                                 mov   bx, offset bitmap_buffer
                                                 mov   dx, [bx + 10d]
                                                 mov   cx, [bx + 12d]
                                                 mov   ax, 4200h
                                                 mov   bx, [file_handle]
                                                 int   21h
                                                 call  check_file_error

pass_file_header endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

load_background proc

                                                 pusha

                                                 mov   bx, file_handle
                                                 mov   ah, 3fh
                                                 mov   cx, image_size
                                                 mov   dx, offset bitmap_background_buffer
                                                 int   21h
                                                 mov   bx, offset bitmap_buffer
                                                 add   bx, 1280d





    ;Nested loops which print the bitmap image pixel by pixel
                                                 mov   si, 1280d
                                                 dec   si

    loop_y_background:                           
                                                 mov   di, 1280d
                                                 dec   di

    loop_x_background:                           

    ;Load the color of the current pixel to AL, since AL stored the color when drawing a pixel using INT 10H
                                                 mov   al, byte ptr [bx]
                         
    ;Draws a pixel at the position specified by CX and DX, with color stored in AL.
                                                 push  bx
                                                 mov   ah, 0ch
                                                 mov   bl, 0
                                                 mov   cx, di
                                                 add   cx, 0
                                                 mov   dx, si
                                                 add   dx, 0
                                                 int   10h
                                                 pop   bx

    continue_background_loop:                    
    ;Go to the next pixel.
                                                 dec   bx
                                                 dec   di
                                                 jnz   loop_x_background

                                                 add   bx, 2561d
                                                 dec   si
                                                 jnz   loop_y_background

                                                 popa

                                                 ret

load_background endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;loads the image of a piece, with its picture stored as a bitmap file.
    ;The image will be placed at the cell with row number stored in DI and column number stored in SI.
    ;Note: rows/columns range from 0 to 7, since the chess board has 8 rows and 8 columns.
load_piece proc

    ;Get the actual position of the top left corner of the cell we wish to draw at, and store the coordinates in the x_temp and y_temp variables.
                                                 mov   ax, si
                                                 mul   cell_size
                                                 mov   x_temp, ax

                                                 mov   ax, di
                                                 mul   cell_size
                                                 mov   y_temp, ax
                
    ;Load the image into the bitmap_buffer.
                                                 mov   bx, file_handle
                                                 mov   ah, 3fh
                                                 mov   cx, file_size
                                                 mov   dx, offset bitmap_buffer
                                                 int   21h
                                                 mov   bx, offset bitmap_buffer
                                                 add   bx, 75d

    ;Nested loops which print the bitmap image pixel by pixel
                                                 mov   si, file_width
                                                 dec   si

    loop_y_bitmap:                               
                                                 mov   di, file_width
                                                 dec   di

    loop_x_bitmap:                               

    ;Load the color of the current pixel to AL, since AL stored the color when drawing a pixel using INT 10H
                                                 mov   al, byte ptr [bx]
                                                 cmp   al, 0ffh                                        ;Do not draw any white pixels, to preserve the background color of the board.
                         
                                                 je    continue_bitmap_loop
                         
    ;Draws a pixel at the position specified by CX and DX, with color stored in AL.
                                                 push  bx
                                                 mov   ah, 0ch
                                                 mov   bl, 0
                                                 mov   cx, di
                                                 add   cx, x_temp
                                                 mov   dx, si
                                                 add   dx, y_temp
                                                 int   10h
                                                 pop   bx

    continue_bitmap_loop:                        
    ;Go to the next pixel.
                                                 dec   bx
                                                 dec   di
                                                 jnz   loop_x_bitmap

                                                 add   bx, 151d
                                                 dec   si
                                                 jnz   loop_y_bitmap

                                                 ret

load_piece endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Closes the bitmap file.
close_file proc

                                                 mov   ah, 3Eh
                                                 mov   bx, [file_handle]
                                                 call  check_file_error
                                                 int   21h

                                                 ret

close_file endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

draw_cell_border proc

                                                 pusha

                                                 mov   ax, 0
                                                 mov   bx, 0
                                                 mov   cx, 0
                                                 mov   dx, 0

                                                 inc   di
                                                 inc   si

                                                 mov   bx, cell_size
                                                 mov   cx, si
                                                 mov   dx, di

                                                 mov   ah, 0ch
                                                 mov   al, 00h

                                                 add   bx, cx
    line1:                                       
                                                 
                                                 int   10h
                                                 inc   cx
                                                 cmp   cx, bx
                                                 jnz   line1


                                                 sub   cx, cell_size
                                                 add   dx, cell_size
                                                 dec   dx
    line2:                                       
                                                 int   10h
                                                 inc   cx
                                                 cmp   cx, bx
                                                 jnz   line2

                                                 inc   dx
                                                 sub   cx, cell_size
                                                 sub   dx, cell_size
                                                 mov   bx, dx
                                                 add   bx, cell_size
    line3:                                       
                                                 int   10h
                                                 inc   dx
                                                 cmp   dx, bx
                                                 jnz   line3


                                                 add   cx, cell_size
                                                 dec   cx
                                                 sub   dx, cell_size
    line4:                                       
                                                 int   10h
                                                 inc   dx
                                                 cmp   dx, bx
                                                 jnz   line4


                                                 popa

                                                 ret

draw_cell_border endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

draw_background proc

                                                 pusha

                                                 add   si, 0                                           ;Adjust the column position using the x_margin.
                                                 add   di, 0                                           ;Adjust the row position using the y_margin.
                                                 push  si
                                                 push  di
                                                 call  get_file_handle                                 ;Prepare the file handle for other interrupts
                                                 call  pass_file_header                                ;Move the file pointer to the starting point of the image
                                                 pop   di
                                                 pop   si
                                                 call  load_background                                 ;Draw the image at the rows and columns specified by SI and DI.
                                                 call  close_file                                      ;Close the file

                                                 popa

                                                 ret

draw_background endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Draws a piece
draw_piece proc

                                                 pusha

                                                 add   si, margin_x                                    ;Adjust the column position using the x_margin.
                                                 add   di, margin_y                                    ;Adjust the row position using the y_margin.
                                                 push  si
                                                 push  di
                                                 call  get_file_handle                                 ;Prepare the file handle for other interrupts
                                                 call  pass_file_header                                ;Move the file pointer to the starting point of the image
                                                 pop   di
                                                 pop   si
                                                 call  load_piece                                      ;Draw the image at the rows and columns specified by SI and DI.
                                                 call  close_file                                      ;Close the file
                         
                                                 popa
                         
                                                 ret

draw_piece endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Draws a cell at the row and columns positions specified by SI and DI.
draw_cell proc

    ;Adjust SI and DI for the margins
                                                 push  ax
                                                 push  bx
                                                 push  cx
                                                 push  dx
                                                 push  si
                                                 push  di
                                                 add   si, margin_x
                                                 add   di, margin_y

    ;Calculate and store the actual row and column positions of the upper left corner of each cell, and place them in SI and DI
                                                 mov   ah, 0ch
                                                 push  ax
                                                 mov   ax, si
                                                 mul   cell_size
                                                 mov   si, ax

                                                 mov   ax, di
                                                 mul   cell_size
                                                 mov   di, ax
                         
                                                 pop   ax
                         
    ;Prepare for drawing the cell.
                                                 mov   cx, cell_size
                                                 add   cx, si

    loop_x_cell:                                 
                                                 mov   dx, cell_size

    loop_y_cell:                                 
    ;CX and DX store the row and columns positions for INT 10H.
                                                 add   dx, di
                                                 int   10h

                                                 sub   dx, di
                                                 dec   dx
                                                 jnz   loop_y_cell

                                                 dec   cx
                                                 cmp   cx, si
                                                 jnz   loop_x_cell


                                                 call  draw_cell_border


    ;After drawing the cell, we now wish to draw the piece in the cell (if any).

    ;Get back the original row and column positions (from 0 to 7).
                                                 pop   di
                                                 pop   si
                                      
    ;From SI and DI, get the position of the cell we are drawing in board array, which contains the current state of the board.
                                                 mov   bx, di

    ;Multiplies by 8, we don't need to move 3 to register first in this assembler. We multiply the row number by 8 since each row has 8 positions.
                                                 shl   bx, 3
                                                 add   bx, si
                                                 add   bx, offset board
                                                 mov   ah, [bx]
                                                 mov   bh, 0
                                                 cmp   ah, 0

    ;If the current element in the board array contains 0, we draw no pieces.
    ;If it contains a negative value, we draw a white piece.
    ;If it contains a positive value, we draw a black piece.
                                                 je    finish_draw_cell
                                                 jl    draw_white_piece

    ;Drawing a black piece
    draw_black_piece:                            
                                                 mov   bl, ah
                                                 shl   bl, 1

    ;Move the offset of the file we wish to access and draw to dx
                                                 mov   dx, word ptr [black_pieces + bx]
                                                 call  draw_piece
                                                 jmp   finish_draw_cell

    ;White Mate
    draw_white_piece:                            
                                                 neg   ah
                                                 mov   bl, ah
                                                 shl   bl, 1

    ;Move the offset of the file we wish to access and draw to dx
                                                 mov   dx, word ptr [white_pieces + bx]
                                                 call  draw_piece

    ;Exiting
    finish_draw_cell:                            
                                                 pop   dx
                                                 pop   cx
                                                 pop   bx
                                                 pop   ax

                                                 ret

draw_cell endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Calls draw_cell in a nested loop to display the whole board.
draw_board proc

    ;Position of the first (upper left) cell
                                                 mov   si, 0
                                                 mov   di, 0

    ;Color of the first cell
    ;   mov  al, byte ptr cell_colors

    loop_y_board:                                
                                                 mov   si, 0

    loop_x_board:                                
    ;Draw the current cell
                                                 call  get_cell_colour
    ;   push ax
                                                 call  draw_cell
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
                                                 inc   si
                                                 cmp   si, 8
                                                 jnz   loop_x_board
                         
    ;Before going to the next iteration of the outer loop, reverse the color of the cell
    ;                       cmp  al, byte ptr cell_colors
    ;                       jz   set_dark_color
    ;                       mov  al, byte ptr cell_colors
    ;                       jmp  new_iteration
    ; set_dark_color:
    ;                       mov  al, byte ptr cell_colors + 1
    ;new_iteration:
                                                 inc   di
                                                 cmp   di, 8
                                                 jnz   loop_y_board

                                                 ret

draw_board endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PROCEDURES USED WITHIN THE GAME:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Writes possible moves to memory
recordMove proc

                                                 push  bx
                                                 push  ax


                                                 mov   bh, 0
                                                 mov   bl, directionPtr
                                                 shl   bx, 4d

                                                 shl   currMovePtr, 1
                                                 add   bl, currMovePtr
                                                 shr   currMovePtr, 1

                                                 mov   possibleMoves_DI[bx], di
                                                 mov   possibleMoves_SI[bx], si

    ;inc   currMovePtr

                                                 pop   ax
                                                 pop   bx

                                                 ret

recordMove endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ; Navigates in possible moves array
getNextPossibleMove proc

                                                 push  bx
                                                 push  ax


                                                 mov   bh, 0
                                                 mov   bl, directionPtr
                                                 shl   bx, 4d

                                                 shl   currMovePtr, 1
                                                 add   bl, currMovePtr
                                                 shr   currMovePtr, 1

                                                 mov   di, possibleMoves_DI[bx]
                                                 mov   si, possibleMoves_SI[bx]

                                                 pop   ax
                                                 pop   bx

                                                 ret

getNextPossibleMove endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ; Removes previously selected cells (if any)
removeSelections proc

                                                 mov   directionPtr, 0d
                          
    removeSelections_loop1:                      
                                                 mov   currMovePtr, 0d

    removeSelections_loop2:                      
                                                 mov   si, -1d
                                                 mov   di, -1d

                                                 call  recordMove
                                                 inc   currMovePtr

                                                 cmp   currMovePtr, 8d
                                                 jz    removeSelections_loop2_break

                                   call  getNextPossibleMove
                                   cmp   si, -1d
                                   jz    removeSelections_loop2_break

                                                 call  get_cell_colour
                                                 call  draw_cell

                                                 jmp   removeSelections_loop2

    removeSelections_loop2_break:                

                                                 inc   directionPtr
                                                 cmp   directionPtr, 8d
                                                 jnz   removeSelections_loop1


                                                 mov   directionPtr, -1d
                                                 mov   currMovePtr, -1d

                                                 mov   si, currSelectedPos_SI
                                                 mov   di, currSelectedPos_DI
                                                 mov   al, hover_cell_color
                                                 call  draw_cell


                                                 mov   currSelectedPos_DI, -1d
                                                 mov   currSelectedPos_SI, -1d

                                                 ret

removeSelections endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Moves the piece (if possible) according to the scan codes of keys pressed (A->1E, D->20, W->11, S->1F)
hover proc

                                                 push  cx
                                                 push  dx

    ; Storing current positons [DX,CX]
                                                 mov   cx, si
                                                 mov   dx, di
    
                                   cmp   ah, Left_Arrow
                                   jz    move_left

                                   cmp   ah, Right_Arrow
                                   jz    move_right

                                   cmp   ah, Up_Arrow
                                   jz    move_up

                                   cmp   ah, Down_Arrow
                                   jz    move_down

                                                 jmp   dont_move

    move_left:                                   
                                                 cmp   si, 0
                                                 jz    dont_move
                                                 dec   si
                                                 jmp   redraw

    move_right:                                  
                                                 cmp   si, 7h
                                                 jz    dont_move
                                                 inc   si
                                                 jmp   redraw

    move_up:                                     
                                                 cmp   di, 0h
                                                 jz    dont_move
                                                 dec   di
                                                 jmp   redraw

    move_down:                                   
                                                 cmp   di, 7h
                                                 jz    dont_move
                                                 inc   di
                                                 jmp   redraw

    redraw:                                      
    ; Redraw the prev cell with its original color
                                                 push  si
                                                 push  di
                                                 mov   si, cx
                                                 mov   di, dx
                                                 call  get_cell_colour
                                                 call  draw_cell
    ; Draw hover cell
                                                 pop   di
                                                 pop   si
                                                 mov   al, hover_cell_color
                                                 call  draw_cell

    dont_move:                                   
                                                 pop   dx
                                                 pop   cx

                                                 ret

hover endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Gets pos given SI,DI and puts it in BX
getPos proc

                                                 push  si
                                                 push  di

                                                 shl   di, 3h
                                                 add   di, si

                                                 mov   bx, di

                                                 pop   di
                                                 pop   si

                                                 ret

getPos endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ; puts the current position as the first possible move in all directions
recordCurrPos proc

                                                 push  cx

                                                 mov   cx, 8d

    recordCurrPos_loop:                          
                                                 call  recordMove
                                                 inc   directionPtr
                                                 loop  recordCurrPos_loop

                                                 mov   directionPtr, 0d
                                                 mov   currMovePtr, 1d

                                                 pop   cx

                                                 ret
    
recordCurrPos endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------



    ; ZF=1 -> EMPTY CELL | CF=0 -> PLAYER PIECE\EMPTY CELL  |  CF=1 -> ENEMY PIECE
checkForEnemyPiece PROC
                                                 push  bx
                                                 call  getPos
                                                 cmp   board[bx], 0
                                                 jz    empty_cell

    ; check if the piece is the same color as the player's color
                                                 mov   bh, 0d
                                                 mov   bl, board[bx]
                                                 shl   bx, 8d
                                                 xor   bx, walker                                      ;; if they have the same sign-bit -> 1000H
                                                 shl   bx, 1d                                          ;; moving sign bit to the CF
                                                 jmp   checkForEnemyPiece_end

    empty_cell:                                  
                                                 clc
                                   
    checkForEnemyPiece_end:                      
                                                 pop   bx
                                                 ret

checkForEnemyPiece ENDP



    ; Gets all possible pawn moves
getPawnMoves proc
 
                                                 push  si
                                                 push  ax
                                                 push  di

                                  
                                   cmp   walker, -1d
                                   jnz   getPawnMoves_black

    getPawnMoves_white:                          
                                                 cmp   di, 0d
                                                 jnz   continue_getPawnMoves_white
                                                 jmp   far ptr get_pawn_moves_end

    continue_getPawnMoves_white:                 
                                                 cmp   di, 6d
                                                 jnz   get_other_pawn_moves
                                                 jmp   get_extra_pawn_move
                                   

    getPawnMoves_black:                          
                                                 cmp   di, 7d
                                                 jnz   continue_getPawnMoves_black
                                                 jmp   far ptr get_pawn_moves_end
    continue_getPawnMoves_black:                 
                                                 cmp   di, 1d
                                                 jnz   get_other_pawn_moves


    get_extra_pawn_move:                         
                                                 add   di, walker

                                                 call  checkForEnemyPiece
                                                 jnz   getPawnMoves_possible_takes

                                                 call  getPos
                                                 cmp   board[bx], 0
                                                 jnz   get_other_pawn_moves

                                  
                                                 call  recordMove
                                                 inc   currMovePtr
                                   
                                                 call  draw_cell

    get_other_pawn_moves:                        
                                                 add   di, walker

                                                 call  checkForEnemyPiece
                                                 jnz   getPawnMoves_possible_takes

                                                 call  getPos
                                                 cmp   board[bx], 0
                                                 jnz   getPawnMoves_possible_takes
        
                                                 call  recordMove
                                                 inc   currMovePtr

                                                 call  draw_cell

    getPawnMoves_possible_takes:                 
                                                 pop   di
                                                 push  di
                                                 add   di, walker
                                                 add   si, 1d
                                                 cmp   si, 8d
                                                 jnz   continue_getPawnMoves_possible_takes
                                                 jmp   get_other_possible_take

    continue_getPawnMoves_possible_takes:        
                                                 call  checkForEnemyPiece

                                                 jnc   get_other_possible_take

                                                 mov   currMovePtr, 1d
                                                 mov   directionPtr, 1d

                                                 call  recordMove
                                                 inc   currMovePtr

                                                 mov   al, possible_take_cell_color
                                                 call  draw_cell
                                   
                                   
                                   
    get_other_possible_take:                     
                                                 sub   si, 2d
                                                 cmp   si, -1d
                                                 jnz   continue_getPawnMoves_other_possible_take
                                                 jmp   far ptr get_pawn_moves_end

    continue_getPawnMoves_other_possible_take:   
                                                 call  checkForEnemyPiece

                                                 jnc   get_pawn_moves_end

                                                 mov   currMovePtr, 1d
                                                 mov   directionPtr, 7d

                                                 call  recordMove
                                                 inc   currMovePtr

                                                 mov   al, possible_take_cell_color
                                                 call  draw_cell
    get_pawn_moves_end:                          
                                                 pop   di
                                                 pop   ax
                                                 pop   si

                                                 ret

getPawnMoves endp


getPossibleDiagonalMoves PROC
                                                 push  dx
                                                 push  bp
                                                 push  cx
                                                 push  ax
                                                 push  si
                                                 push  di

                                                 mov   ch, 2                                           ;; no of times we will neg si

                                                 mov   dx, 1d                                          ;; step for si
                                                 mov   bp, -1d                                         ;; step for di

                                                 mov   directionPtr, 1d
                                                 mov   currMovePtr, 1d


            
    getPossibleDiagonalMoves_l1:                 
                                                 mov   cl, 2d
                                  
    getPossibleDiagonalMoves_l2:                 
                                                 add   si, dx
                                                 add   di, bp

                                                 cmp   si, 8d
                                                 jz    getPossibleDiagonalMoves_l2_break2
                                        
                                                 cmp   di, 8d
                                                 jz    getPossibleDiagonalMoves_l2_break2
                                        
                                                 cmp   si, -1d
                                                 jz    getPossibleDiagonalMoves_l2_break2
                                        
                                                 cmp   di, -1d
                                                 jz    getPossibleDiagonalMoves_l2_break2

                                                 call  checkForEnemyPiece
                                                 jnz   getPossibleDiagonalMoves_l2_break

                                                 call  recordMove
                                                 inc   currMovePtr

                                                 mov   al, hover_cell_color
                                                 call  draw_cell
                                                 jmp   getPossibleDiagonalMoves_l2

    getPossibleDiagonalMoves_l2_break:           
                                                 jnc   getPossibleDiagonalMoves_l2_break2
                                        
                                                 call  recordMove
                                         

                                                 mov   al, possible_take_cell_color
                                                 call  draw_cell
    getPossibleDiagonalMoves_l2_break2:          
                                                 add   directionPtr, 2d
                                                 mov   currMovePtr, 1d

                                                 mov   si, currSelectedPos_SI
                                                 mov   di, currSelectedPos_DI

                                                 neg   bp
                                                 dec   cl
                                                 jnz   getPossibleDiagonalMoves_l2

                                                 neg   dx
                                                 neg   bp
                                                 dec   ch
                                                 jnz   getPossibleDiagonalMoves_l1



    getPossibleDiagonalMoves_end:                
                                                 pop   di
                                                 pop   si
                                                 pop   ax
                                                 pop   cx
                                                 pop   bp
                                                 pop   dx

                                                 ret
    
getPossibleDiagonalMoves ENDP




getPossibleVerticalHorizontalMoves PROC

                                                 push  dx
                                                 push  bp
                                                 push  cx
                                                 push  ax
                                                 push  si
                                                 push  di

                                                 mov   ch, 2                                           ;; no of times we will neg si

                                                 mov   dx, 0d                                          ;; step for si
                                                 mov   bp, -1d                                         ;; step for di

                                                 mov   directionPtr, 0d
                                                 mov   currMovePtr, 1d


            
    getPossibleVerticalHorizontalMoves_l1:       
                                                 mov   cl, 2d
                                  
    getPossibleVerticalHorizontalMoves_l2:       
                                                 add   si, dx
                                                 add   di, bp

                                                 cmp   si, 8d
                                                 jz    getPossibleVerticalHorizontalMoves_l2_break2
                                        
                                                 cmp   di, 8d
                                                 jz    getPossibleVerticalHorizontalMoves_l2_break2
                                        
                                                 cmp   si, -1d
                                                 jz    getPossibleVerticalHorizontalMoves_l2_break2
                                        
                                                 cmp   di, -1d
                                                 jz    getPossibleVerticalHorizontalMoves_l2_break2

                                                 call  checkForEnemyPiece
                                                 jnz   getPossibleVerticalHorizontalMoves_l2_break

                                                 call  recordMove
                                                 inc   currMovePtr

                                                 mov   al, hover_cell_color
                                                 call  draw_cell
                                                 jmp   getPossibleVerticalHorizontalMoves_l2

    getPossibleVerticalHorizontalMoves_l2_break: 
                                                 jnc   getPossibleVerticalHorizontalMoves_l2_break2
                                        
                                                 call  recordMove
                                         

                                                 mov   al, possible_take_cell_color
                                                 call  draw_cell
    getPossibleVerticalHorizontalMoves_l2_break2:
                                                 add   directionPtr, 2d
                                                 mov   currMovePtr, 1d

                                                 mov   si, currSelectedPos_SI
                                                 mov   di, currSelectedPos_DI

                                                 neg   bp
                                                 xchg  bp, dx
                                                 dec   cl
                                                 jnz   getPossibleVerticalHorizontalMoves_l2

                
                                                 dec   ch
                                                 jnz   getPossibleVerticalHorizontalMoves_l1



    getPossibleVerticalHorizontalMoves_end:      
                                                 pop   di
                                                 pop   si
                                                 pop   ax
                                                 pop   cx
                                                 pop   bp
                                                 pop   dx

                                                 ret
    
getPossibleVerticalHorizontalMoves ENDP
        

getQueenMoves PROC

                                                 call  getPossibleVerticalHorizontalMoves
                                                 call  getPossibleDiagonalMoves
    
getQueenMoves ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Moves to SI DI the first available position if possible
checkFirstAvailableMove proc

                                                 push  si
                                                 push  di
                                                 push  cx

                                                 mov   cx, 8
                                                 mov   currMovePtr, 1d
                                                 mov   directionPtr, 0d
                          
    first_available_direction:     
                                   call  getNextPossibleMove
                                   cmp   si, -1d
                                   jnz   found_first_available_position
                                   inc   directionPtr
                                   loop first_available_direction

    ; if no moves are available, return currSelectedPos
                                   mov   directionPtr, 0d
                                   mov   currMovePtr, 0d

    found_first_available_position:              
                                                 pop   cx
                                                 pop   di
                                                 pop   si

                                                 ret

checkFirstAvailableMove endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ; I think its pretty clear
drawBorder proc

                                                 push  si
                                                 push  di
                                                 push  bx
                                                 push  cx
                                                 push  dx
                                                 push  bp

                                                 add   si, margin_x
                                                 add   di, margin_y

                                                 mov   ah, 0ch
                                                 push  ax

                                                 mov   ax, si
                                                 mul   cell_size
                                                 mov   si, ax

                                                 mov   ax, di
                                                 mul   cell_size
                                                 mov   di, ax
                         
                                                 pop   ax

                                                 mov   bp, 3d
                                                 mov   dx, 1

                                                 add   dx, di

    line1_1:                                     
                                                 mov   cx, 1

    line1_2:                                     
                                                 add   cx, si
                                                 int   10h
                                                 sub   cx, si

                                                 inc   cx
                                                 cmp   cx, cell_size
                                                 jnz   line1_2

                                                 inc   dx
                                                 dec   bp
                                                 jnz   line1_1

                          
                                                 mov   bp, 3d
                                                 add   cx, si

    line2_1:                                     
                                                 mov   dx, 1

    line2_2:                                     
                                                 add   dx, di
                                                 int   10h
                                                 sub   dx, di

                                                 inc   dx
                                                 cmp   dx, cell_size
                                                 jnz   line2_2

                                                 dec   cx
                                                 dec   bp
                                                 jnz   line2_1
                        
                          
                                                 mov   bp, 3d
                                                 add   dx, di

    line3_1:                                     
                                                 mov   cx, cell_size

    line3_2:                                     
                                                 add   cx, si
                                                 int   10h
                                                 sub   cx, si

                                                 dec   cx
                                                 cmp   cx, 1d
                                                 jnz   line3_2

                                                 dec   dx
                                                 dec   bp
                                                 jnz   line3_1


                                                 mov   bp,3
                                                 add   cx, si

    line4_1:                                     
                                                 mov   dx, cell_size

    line4_2:                                     
                                                 add   dx, di
                                                 int   10h
                                                 sub   dx, di
                                                 dec   dx
                                                 cmp   dx, 1d
                                                 jnz   line4_2

                                                 inc   cx
                                                 dec   bp
                                                 jnz   line4_1
                          

                                                 pop   bp
                                                 pop   dx
                                                 pop   cx
                                                 pop   bx
                                                 pop   di
                                                 pop   si

                                                 ret
    
drawBorder endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ; puts
getFirstSelection proc

                                   call  checkFirstAvailableMove
   
                          
    ; to move the si, di corresponding to directionPtr & currMovPtr that we got from checkFirstAvailableMove
                                                 call  getNextPossibleMove

                                                 mov   al, 00h
                                                 call  drawBorder

    getFirstSelection_end:                       
    
                                                 ret

getFirstSelection endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Changes the positions of selected move and puts them in SI & DI for drawing border
goToNextSelection proc

                                                 push  ax
                                                 push  bx
                                                 push  cx
                                                 push  dx
                                                 push  bp

    ; preserving current positions
                                                 mov   bp, si
                                                 mov   dx, di

    ; preserving current move
                                                 mov   bh, directionPtr
                                                 mov   bl, currMovePtr

    ; Checking which key was pressed
                                   cmp   ah, Left_Arrow
                                   jz    A

                                   cmp   ah, Right_Arrow
                                   jz    D

                                   cmp   ah, Up_Arrow
                                   jz    W

                                   cmp   ah, Down_Arrow
                                   jz    S

                                                 jmp   doNotChangeSelection

    ; a rough implementation of (i+1)%n for both A & D
    A:                             
                                   mov   currMovePtr, 1d
                                   mov   cx, 8d
                                  
    aLoop:                         
                                   dec   directionPtr
                                   cmp   directionPtr, -1d
                                   jz    aLoopReset

    continueLoopA:                               
                                                 call  getNextPossibleMove
                                                 cmp   si, -1d
                                                 jz    next_loopA_line
                                                 jmp   far ptr changeSelection                         ; jump is far down

    next_loopA_line:                             
                                                 loop  aLoop
                                                 jmp   doNotChangeSelection

    aLoopReset:                    
                                   mov   directionPtr, 7d
                                   jmp   continueLoopA


    D:                                           
                                                 mov   cl, 7d
                                                 mov   ch, 8d
                                                 mov   al, directionPtr
                                                 mov   ah, 0d
                                                 mov   currMovePtr, 1d

    dLoop:                                       
                                                 inc   al
                                                 div   ch
                                                 mov   al, ah
                                                 mov   directionPtr, al
    
                                                 call  getNextPossibleMove

                                                 cmp   si, -1d
                                                 jnz   changeSelection

                                                 dec   cl
                                                 jnz   dLoop
                                                 jmp   doNotChangeSelection


    W:                                           
                                                 cmp   currMovePtr, 7
                                                 jz    doNotChangeSelection

                                                 inc   currMovePtr

    ; if a move actually exists, change selection
                                                 call  getNextPossibleMove
                                                 cmp   si, -1d
                                                 jnz   changeSelection
                          
                                                 dec   currMovePtr
                                                 jmp   doNotChangeSelection


    S:                                           
                                                 cmp   currMovePtr, 0
                                                 jz    doNotChangeSelection

                                                 dec   currMovePtr

                                                 call  getNextPossibleMove
                                                 cmp   si, -1d
                                                 jnz   changeSelection

                                                 jmp   doNotChangeSelection


    doNotChangeSelection:                        
    ; resets everything to its original state
                                                 mov   directionPtr, bh
                                                 mov   currMovePtr, bl
                                                 mov   si, bp
                                                 mov   di, dx
                                                 jmp   goToNextSelection_end
                        
    changeSelection:                             
    ; highlighting the previous possible move
                                                 push  si
                                                 push  di
                          
    ;; getting original position back for coloring
                                                 mov   si, bp
                                                 mov   di, dx


    ;; if that position is the "home cell" use the highlighting color
                                                 cmp   si, currSelectedPos_SI
                                                 jnz   continue_change_selection
                                                 cmp   di, currSelectedPos_DI
                                                 jnz   continue_change_selection

                                                 mov   al, highlighted_cell_color
                                                 jmp   goToNextSelection_redraw


    continue_change_selection:                   push  bx
                                                 lea   bx, hover_cell_color
                                                 call  checkForEnemyPiece
                                   
    ;; color it Red if enemy piece exists
    ;; if carry exists, it will go to the next place in memory which stores the Red color
                                                 adc   bx, 0d
                                                 mov   al, [bx]
                                                 pop   bx
                                   
    goToNextSelection_redraw:                    call  draw_cell

   
                                                 pop   di
                                                 pop   si

    goToNextSelection_end:                       
                                                 pop   bp
                                                 pop   dx
                                                 pop   cx
                                                 pop   bx
                                                 pop   ax

                                                 ret

goToNextSelection endp

    ;moves the piece according to DI,SI (nextPos) & currSelectedPos_DI,currSelectedPos_SI (current pos)
movePiece PROC
                                                 cmp   currSelectedPos_DI, -1d
                                                 jnz   start_movePiece
                                                 ret
        
    start_movePiece:                             
    ;; preserving the positions we want to write to
                                                 push  si
                                                 push  di
                                                 push  bx

    ;; moving piece from currPos to nextPos

    ; saving the pos that we will write to
                                                 call  getPos
                                                 push  bx

    ; getting the pos that we will read from
                                   
                                                 call  removeSelections

                                                 call  getPos

    ; checking if a piece is in nextPos
    ; Cl contains the piece we want to move
                                                 mov   cl, board[bx]
                                                 mov   board[bx], 0d                                   ; removing the piece from its currentPos on the board
                                                 cmp   cl, 0d                                          ; checking if the player has taken a piece
                                                 jnz   conitnue_movePiece

    ;;; logic for if piece exists (displaying it next to board)

    conitnue_movePiece:                          
    ;; preparing to write in nextPos
                                                 pop   bx
                                                 mov   board[bx], cl

                                                 call  get_cell_colour
                                                 call  draw_cell

    ;; returning original values to the used registers
                                                 pop   bx
                                                 pop   di
                                                 pop   si

                                                 mov   al, hover_cell_color
                                                 call  draw_cell


    movePiece_end:                               
                                                 mov   currSelectedPos_DI, -1d
                                                 mov   currSelectedPos_SI, -1d
                                                 ret
movePiece ENDP


getPlayerSelection PROC
    ;Listen for keyboard press and change its colour
                                                 cmp   currSelectedPos_DI, -1d
                                                 jz    start
                                                 ret

    start:                                       
                                   
                                                 call  get_cell_colour
                                                 mov   temp_color, al
                          

    ; Checks for keyboard input
                                                 cmp   ax, ax

                                                 mov   ah, 1
                                                 int   16h

                                                 jnz   getPlayerSelection_checkKeyboardInput
                                                 jmp   getPlayerSelection_no_selection_end
    

    getPlayerSelection_checkKeyboardInput:       
    ;Consumes keyboard buffer
                                                 mov   ah, 0
                                                 int   16h

    ; Before moving hover, check if a piece is selected
    ; If one is selected, show all possible moves
                                   cmp   ah, Enter_Key
                                   jz    getPlayerSelection_selection_end

                                                 call  hover

                                                 jmp   getPlayerSelection_no_selection_end

    getPlayerSelection_selection_end:            
                                                 mov   currSelectedPos_SI, si
                                                 mov   currSelectedPos_DI, di

    getPlayerSelection_no_selection_end:         
                                                 ret
getPlayerSelection ENDP



moveInSelections PROC
                                                 cmp   currSelectedPos_DI, -1d
                                                 jnz   showMovesIfNotShown
                                                 ret

    showMovesIfNotShown:                         
                                                 cmp   directionPtr, -1d
                                                 jnz   moveInSelections_checkKeyboardInput
                                                 jmp   show_possible_moves

    moveInSelections_checkKeyboardInput:         

                                                 cmp   ax, ax
                          
                                                 mov   ah, 1
                                                 int   16h

                                                 jz    moveInSelections_go_to_end
                                                 jmp   change_event
    moveInSelections_go_to_end:                  
                                                 jmp   moveInSelections_end
                                   

    show_possible_moves:                         
    ; don't select an empty cell
                                                 call  getPos

                                                 cmp   board[bx], 0d
                                                 jnz   moveInSelections_continue
                                                 mov   currSelectedPos_DI, -1d
                                                 mov   currSelectedPos_DI, -1d
                                                 ret

    moveInSelections_continue:                   
                                                 mov   directionPtr, 0d
                                                 mov   currMovePtr, 0d
                          
                                                 call  recordCurrPos
                          
                                                 mov   al, highlighted_cell_color
                                                 call  draw_cell
                          
    ; moving the color that will be used for selection
                                                 mov   al, hover_cell_color

                                                 mov   ah, board[bx]
                                    
                                                 cmp   ah, 0
                                                 jl    white_piece
                                                 mov   walker, 1d
                                                 neg   ah
                                                 jmp   determine_piece_type

    white_piece:                                 mov   walker, -1d
                                   
    determine_piece_type:                        
                                                 cmp   ah, -1
                                                 jz    pawn
                                   
                                                 cmp   ah, -3d
                                                 jz    bishop

                                                 cmp   ah, -4d
                                                 jz    rook

                                                 cmp   ah, -5d
                                                 jz    queen

                                                 jmp   start_selection
                          

    pawn:                                        
                                                 call  getPawnMoves
                                                 jmp   start_selection

    bishop:                                      
                                                 call  getPossibleDiagonalMoves
                                                 jmp   start_selection

    rook:                                        call  getPossibleVerticalHorizontalMoves
                                                 jmp   start_selection

    queen:                                       
                                                 call  getQueenMoves
                                                 jmp   start_selection


                          
    start_selection:               
                                ;; returns first possible move / currSelectedPos if no moves are available
                                   call  getFirstSelection
                                   ret
                                  


    change_event:                                
    ;Consumes keyboard buffer
                                                 mov   ah, 0
                                                 int   16h

    ; The key is now in ah
    ; Before changing move, checks if:

    ; another key other than Q is pressed
                                   cmp   ah, Enter_Key
                                   jnz   go_to_next_selection


    ; a piece wants to be moved
                                                 cmp   si, currSelectedPos_SI
                                                 jnz   moveSelections_moveSelectedPiece

                                                 cmp   di, currSelectedPos_DI
                                                 jnz   moveSelections_moveSelectedPiece


    ; deselects the cell it is curr on (will be modified)
                                                 call  removeSelections
                                                 jmp   moveInSelections_end

    go_to_next_selection:                        
    ; save current positions

                                                 call  goToNextSelection
 

                                                 mov   al, 00h
                                                 call  drawBorder

    moveInSelections_end:                        
                                                 ret

    moveSelections_moveSelectedPiece:            
                                                 call  movePiece
                                                 ret
moveInSelections ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PROCEDURES USED IN THE GAME SCREEN:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

game_window proc

                                                 call  init_board                                      ;Initialize board
                                                 call  init_video_mode                                 ;Prepare video mode

    ;Clear the screen, in preparation for drawing the board
                                                 mov   al, 14h                                         ;The color by which we will clear the screen (light gray).
                                                 call  clear_screen

                                                 call  draw_board                                      ;Draw the board
                         
                                                 mov   si, 3d
                                                 mov   di, 6d
                                                 mov   al, hover_cell_color
                                                 call  draw_cell

    play_chess:                                  
                                                 call  getPlayerSelection
    
                                                 call  moveInSelections
                                                           
                                                 jmp   play_chess

                                                 ret

game_window endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;TERMINATE PROCEDURE:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

terminate proc

                                                 pusha

                                                 mov   ax, 0600h
                                                 mov   bh, 07
                                                 mov   cx, 0
                                                 mov   dx, 184Fh
                                                 int   10h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 0
                                                 mov   dh, 0
                                                 int   10h

                                                 mov   ah, 4ch
                                                 int   21h

                                                 popa

                                                 ret

terminate endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PROCEDURES USED IN THE MAIN SCREEN:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

main_window proc

                                                 pusha

    main_start:                                  
                                                 mov   ax, 0600h
                                                 mov   bh, 07
                                                 mov   cx, 0
                                                 mov   dx, 184Fh
                                                 int   10h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 1Ah
                                                 mov   dh, 07h
                                                 int   10h

                                                 mov   ah, 9
                                                 mov   dx, offset cmd1
                                                 int   21h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 1Ah
                                                 mov   dh, 0Bh
                                                 int   10h

                                                 mov   ah, 9
                                                 mov   dx, offset cmd2
                                                 int   21h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 1Ah
                                                 mov   dh, 0Fh
                                                 int   10h

                                                 mov   ah, 9
                                                 mov   dx, offset cmd3
                                                 int   21h

                                                 mov   ah, 0
                                                 int   16h

                                                 cmp   ah, 3Bh
                                                 jz    start_chat

                                                 cmp   ah, 3Ch
                                                 jz    start_game

                                                 cmp   ah, 01h
                                                 jz    main_end

                                                 jmp   main_end

    start_chat:                                  
                                                 call  chat_window
                                                 jmp   main_start

    start_game:                                  
                                                 call  game_window
                                                 jmp   main_start

    main_end:                                    
                                                 call  terminate

                                                 popa

                                                 ret

main_window endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PROCEDURES USED IN THE WELCOME SCREEN:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

welcome proc

                                                 pusha

                                                 mov   ax, 0600h
                                                 mov   bh, 07
                                                 mov   cx, 0
                                                 mov   dx, 184Fh
                                                 int   10h

                                                 mov   ah, 2
                                                 mov   bh, 0
                                                 mov   dl, 00d
                                                 mov   dh, 00d
                                                 int   10h

                                                 popa

                                                 ret

welcome endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

test_window proc

                                                 call  init_board
                                                 call  init_video_mode
                                                 call  draw_background
    ;mov   al, 14h
    ;call  clear_screen
    ;call  set_board_base
    ;call  draw_board
    ;call  set_border
    ;call  draw_letters
    ;call  draw_numbers

                                                 hlt

                                                 ret

test_window endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;---------------------------------------------------------------------------------------------------------------------------------------------

main proc far

    ;Initializing the data segment register
                                                 mov   ax, @data
                                                 mov   ds, ax

    ;Setting working directory to the folder containing bitmaps of the pieces
                                                 mov   ah, 3bh
                                                 mov   dx, offset pieces_wd
                                                 int   21h

                                                 call  game_window

main endp
end main