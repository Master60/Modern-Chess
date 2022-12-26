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




Welcome_Mes db 'Welcome To Our Game...$'
 Get_Name    db 'Please Enter Your Name: $'
 User_Name   db  16,?,16 dup('$')
 dummy       db '$'
Error_Mes db 'Please Enter a valid Name (Name must start with English Letter) $'
 Hello  db 'Hello $'
 Last db 'Please press any key to continue$'




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

    temp_name2               db      'Bas', '$'

    ;Dummy text to be displayed
    dummy1                   db      'This window is to be further developed in phase 2, thanks for checking in.', '$'

    dummy2                   db      'Press F3 to exit', '$'

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED FOR PREPARING AND DRAWING THE BOARD:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;An array that will store the current state of the board, each element of the array corresponds to a cell on the board.
    board                    db      64d dup(0)
    
    ;An array that will store the last time at which every piece on the board moved.
    movementTimes_hours      db      64d dup(0)
    movementTimes_seconds    dw      64d dup(0)
    
    conversionNum            db      0
    
    currentTime_hours        db      0
    currentTime_seconds      dw      0

    prevTime_hours           db      0
    prevTime_seconds         dw      0

    moreThan_ThreeSeconds    db      0
    
    
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


    ; Helpful Flags
    outOfBound               db      0d
    startSending             db      0d
    startPosSent             db      0d
    gotOponentStartPos       db      0d
    end_game                 db     -1d
    

    ;; plays that will be sent to the oponent
    startPos_SI              dw      -1d    
    startPos_DI              dw      -1d    

    endPos_SI                dw      -1d
    endPos_DI                dw      -1d
    
    ;; plays that will be received from the oponent
    oponent_startPos_SI      dw      -1d    
    oponent_startPos_DI      dw      -1d    

    oponent_endPos_SI        dw      -1d
    oponent_endPos_DI        dw      -1d

    ; Navigation Buttons
    Left_Arrow               db      4Bh
    Right_Arrow              db      4Dh
    Up_Arrow                 db      48h
    Down_Arrow               db      50h

    Enter_Key                db      28d

    ;The size of each cell on the chessboard.
    cell_size                dw      75d

    ;Horizontal margin is set to 4 cells
    margin_x                 dw      175d

    ;Vertical margin is set to 2 cells (This might be altered later, to clear some space for chatting).
    margin_y                 dw      150d

    ;Cells can have 2 colors: white and gray. The codes of those colors are stored here, and will be used when drawing the board.
    board_colors             db      31d, 28d

    ; Used for highlighting (hover effect)
    highlighted_cell_color   db      14d
    hover_cell_color         db      102d
    ; hover_cell_color         db      170d  -> green helw
    ; hover_cell_color         db      80d   -> purple helw
    ; hover_cell_color         db      183d 
    possible_take_cell_color db      12d
    oponent_move_color       db      147d  ;-> green brdoo 
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

    background_image         db      'bck.bmp', 0
    
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

    piece_to_draw            db      0
    current_captured_piece   db      0
    captured_pieces_white    db      16 dup(0)
    captured_pieces_black    db      16 dup(0)



    ;Variables for check

    Kingpos_si               dw      4d
    Kingpos_di               dw      7d  
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
    status_1                 db 'Game has started', '$'
    status_2                 db 'Cannot move selected piece', '$'
    status_3                 db 'Game has ended', '$'

.code

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;MISCELLANEOUS PROCEDURES:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

convert_BCD_To_Decimal proc
                                                 push  ax
                                                 push  bx
                                                 push  cx

                                                 mov   al, conversionNum
                                                 mov   bl, al
                                                 and   al, 0f0h
                                                 and   bl, 0fh
                                                 shr   al, 4
                                                 mov   cl, 10
                                                 mul   cl
                                                 add   al, bl
                                                 mov   conversionNum, al

                                                 pop   cx
                                                 pop   bx
                                                 pop   ax

                                                 ret
convert_BCD_To_Decimal endp


getCurrentTime proc
                                                 push  ax
                                                 push  cx
                                                 push  dx
                           
                                                 mov   ah, 2
                                                 int   1ah

                                                 mov   currentTime_hours, ch

                                                 mov   conversionNum, cl
                                                 call  convert_BCD_To_Decimal
                                                 mov   cl, conversionNum

                                                 mov   conversionNum, dh
                                                 call  convert_BCD_To_Decimal
                                                 mov   dh, conversionNum

                                                 xor   ah, ah
                                                 mov   al, cl
                                                 mov   ch, 60
                                                 mul   ch
                                                 mov   dl, dh
                                                 xor   dh, dh
                                                 add   ax, dx
                                                 mov   currentTime_seconds, ax

                                                 pop   dx
                                                 pop   cx
                                                 pop   ax

                                                 ret
getCurrentTime endp


compareTimes proc
                                                 push  ax
                                                 push  cx

                                                 mov   cx, currentTime_seconds
                                                 sub   cx, prevTime_seconds
                                                 jbe   differentHour_OrLessThan3
    check_above_3:                               
                                                 cmp   cx, 3
                                                 jb    lessThan3
    moreThan3:                                   
                                                 mov   moreThan_ThreeSeconds, 1
                                                 pop   cx
                                                 pop   ax
                                                 ret
    lessThan3:                                   
                                                 mov   moreThan_ThreeSeconds, 0
                                                 pop   cx
                                                 pop   ax
                                                 ret
    differentHour_OrLessThan3:                   
                                                 mov   al, currentTime_hours
                                                 sub   al, prevTime_hours
                                                 jbe   lessThan3
                                                 cmp   al, 1
                                                 ja    moreThan3
                                                 mov   cx, 3600
                                                 sub   cx, prevTime_seconds
                                                 add   cx, currentTime_seconds
                                                 jmp   check_above_3
compareTimes endp


getPrevTime proc
                                                 push  ax
                                                 push  bx

                                                 mov   al, [movementTimes_hours + bx]
                                                 mov   prevTime_hours, al
                                                 shl   bx, 1
                                                 mov   ax, [movementTimes_seconds + bx]
                                                 mov   prevTime_seconds, ax

                                                 pop   bx
                                                 pop   ax

                                                 ret
getPrevTime endp


updateMovementTimes proc
                                                 push  bx
                                                 push  cx
                              
                                                 mov   byte ptr [bx + movementTimes_hours], 0
                                                 shl   bx, 1
                                                 mov   word ptr [bx + movementTimes_seconds], 0

                                                 mov   bx, dx

                                                 mov   cl, currentTime_hours
                                                 mov   [bx + movementTimes_hours], cl
                                                 
                                                 shl   bx, 1
                                                 
                                                 mov   cx, currentTime_seconds
                                                 mov   [bx + movementTimes_seconds], cx

                                                 pop   cx
                                                 pop   bx
                              
                                                 ret
updateMovementTimes endp


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

display_string proc

pusha



popa

ret

display_string endp

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
                                                 add   ax, margin_x
                                                 add   ax, 31d
                                                 add   ax, 13d
                                                 mov   bp, ax

                                                 mov   ax, 0
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, margin_y
                                                 add   ax, 4
                                                 add   ax, 19d
                                                 mov   sp, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 add   ax, 31d
                                                 mov   bx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 add   ax, 31d
                                                 mov   cx, ax

                                                 mov   ax, 0
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, margin_y
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
                                                 add   ax, margin_x
                                                 add   ax, 31d
                                                 mov   bp, ax

                                                 mov   ax, 0
                                                 add   ax, margin_y
                                                 sub   ax, 4
                                                 sub   ax, 19d
                                                 mov   sp, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 add   ax, 31d
                                                 add   ax, 13d
                                                 mov   bx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 add   ax, 31d
                                                 add   ax, 13d
                                                 mov   cx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_y
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
                                                 add   ax, margin_x
                                                 sub   ax, 6
                                                 mov   bp, ax

                                                 mov   ax, 0
                                                 add   ax, margin_y
                                                 add   ax, 31d
                                                 add   ax, 19d
                                                 mov   sp, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 sub   ax, 6
                                                 sub   ax, 13d
                                                 mov   bx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_x
                                                 sub   ax, 6
                                                 sub   ax, 13d
                                                 mov   cx, ax

                                                 mov   ax, 0
                                                 add   ax, margin_y
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
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, margin_x
                                                 add   ax, 6
                                                 mov   bp, ax

                                                 mov   ax, 0
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, margin_y
                                                 sub   ax, 31d
                                                 sub   ax, 19d
                                                 mov   sp, ax

                                                 mov   ax, 0
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, margin_x
                                                 add   ax, 6
                                                 add   ax, 13d
                                                 mov   bx, ax

                                                 mov   ax, 0
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, margin_x
                                                 add   ax, 6
                                                 add   ax, 13d
                                                 mov   cx, ax

                                                 mov   ax, 0
                                                 add   ax, 8
                                                 mul   di
                                                 add   ax, margin_y
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

    ;Initialize every location on the board array, captured pieces arrays, and timers array to zero (i.e. empty everything related to the board.)
                                                 mov   cx, 64d
                                                 mov   si, offset board
                                                 mov   di, offset movementTimes_hours
                                                 mov   bx, movementTimes_seconds
    clear_board_and_timers:                      
                                                 mov   [si], byte ptr 0
                                                 mov   [di], byte ptr 0
                                                 mov   [bx], word ptr 0
                                                 inc   si
                                                 inc   di
                                                 add   bx, 2
                                                 loop  clear_board_and_timers

                                                 mov   cx, 16
                                                 mov   si, offset captured_pieces_black
                                                 mov   di, offset captured_pieces_white
    clear_captured_pieces:                       
                                                 mov   [si], byte ptr 0
                                                 mov   [di], byte ptr 0
                                                 inc   si
                                                 inc   di
                                                 loop  clear_captured_pieces
    
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

draw_labels proc

pusha

mov cx, 0
mov dx, 0
mov al, 3h
mov ah, 0ch

draw_label1_y:

draw_label1_x:

int 10h
inc cx
cmp cx, 475d
jnz draw_label1_x

inc dx
mov cx, 0
cmp dx, 50d
jnz draw_label1_y


mov cx, 476d
mov dx, 0
mov al, 4h
mov ah, 0ch

draw_label2_y:

draw_label2_x:

int 10h
inc cx
cmp cx, 950d
jnz draw_label2_x

inc dx
mov cx, 476d
cmp dx, 50d
jnz draw_label2_y


mov   ah, 2
mov   bh, 0
mov   dl, 28d
mov   dh, 1d
int   10h

mov   ah, 9
mov   dx, offset temp_name
int   21h


popa

ret

draw_labels endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

set_board_base proc

                                                 pusha

                                                 mov   bp, cell_size

                                                 mov   ax, 0
                                                 mov   ax, 10
                                                 mul   bp
                                                 add   ax, margin_x
                                                 add   ax, 25d
                                                 mov   di, ax

                                                 mov   ax, 0
                                                 mov   ax, 9
                                                 mul   bp
                                                 add   ax, margin_y
                                                 add   ax, 25d
                                                 mov   si, ax

                                                 mov   ax, 0
                                                 mov   bx, 0
                                                 add   ax, 2
                                                 mul   bp
                                                 add   bx, margin_x
                                                 sub   bx, ax
                                                 sub   bx, 25d
                                                 
                                                 mov   ax, 0
                                                 mov   cx, 0
                                                 add   ax, 2
                                                 mul   bp
                                                 add   cx, margin_x
                                                 sub   cx, ax
                                                 sub   cx, 25d

                                                 mov   ax, 0
                                                 mov   dx, 0
                                                 add   ax, 1
                                                 mul   bp
                                                 add   dx, margin_y
                                                 sub   dx, ax
                                                 sub   dx, 25d

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

                                                 mov   cx, 150d ;margin x - 25
                                                 mov   dx, 125d ;margin y - 25
                                                 mov   al, 0eh                                         ;4 dark brown
                                                 mov   ah, 0ch

    border_y:                                    

    border_x:                                    
                                                 inc   cx
                                                 cmp   dx,151d  ;margin y + 1
                                                 jb    draw_border
                                                 cmp   dx,750d  ;margin y + 600
                                                 ja    draw_border
                                                 cmp   cx,176d  ;margin x + 1
                                                 jb    draw_border
                                                 cmp   cx,775d  ;margin x + 600
                                                 ja    draw_border
    continue_border:                             
                                                 cmp   cx, 800d ;margin x + 600 + border width
                                                 jnz   border_x

                                                 mov   cx, 150d ;margin x -25
                                                 inc   dx
                                                 cmp   dx, 775d ;margin y + 600 + border width
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

status_bar proc

pusha

mov cx, 0
mov dx, 850d
mov al, 0h
mov ah, 0ch

draw_status_bar_y:

draw_status_bar_x:

int 10h
inc cx
cmp cx, 950d
jnz draw_status_bar_x

inc dx
mov cx, 0
cmp dx, 1024d
jnz draw_status_bar_y

popa

ret

status_bar endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

update_status proc

pusha

call status_bar

mov   ah, 2
mov   bh, 0
mov   dl, 28d
mov   dh, 56d
int   10h

cmp   bx, 0
jz    start_game_status

cmp   bx, 1
jz    cannot_move_piece_status

cmp   bx, 2
jz    end_game_status

start_game_status:
mov   ah, 9
mov   dx, offset status_1
int   21h
jmp end_status

cannot_move_piece_status:
mov   ah, 9
mov   dx, offset status_2
int   21h
jmp end_status

end_game_status:
mov   ah, 9
mov   dx, offset status_3
int   21h
jmp end_status

end_status:

popa

ret

update_status endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

inline_chat_window proc

pusha

mov cx, 950d
mov dx, 0
mov al, 5h
mov ah, 0ch

draw_inline_chat_y:

draw_inline_chat_x:

int 10h
inc cx
cmp cx, 1280d
jnz draw_inline_chat_x

inc dx
mov cx, 950d
cmp dx, 1024d
jnz draw_inline_chat_y

popa

ret

inline_chat_window endp

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



checkOutOfBounds PROC
                                                 cmp    si, 8d
                                                 jge    checkOutOfBounds_out_of_bounds
                                        
                                                 cmp   di, 8d
                                                 jge    checkOutOfBounds_out_of_bounds
                                        
                                                 cmp   si, -1d
                                                 jle    checkOutOfBounds_out_of_bounds
                                        
                                                 cmp   di, -1d
                                                 jle    checkOutOfBounds_out_of_bounds

                                                 jmp   checkOutOfBounds_in_bounds


                checkOutOfBounds_out_of_bounds:
                                                mov outOfBound, 1d
                                                ret
                checkOutOfBounds_in_bounds:
                                                mov outOfBound, 0d
                                                 ret
                                                 
checkOutOfBounds ENDP

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

    ; load_background proc
    
    ;                                                 pusha
    
    ;                                                 mov   bx, file_handle
    ;                                                mov   ah, 3fh
    ;                                               mov   cx, image_size
    ;                                              mov   dx, offset bitmap_background_buffer
    ;                                             int   21h
    ;                                            mov   bx, offset bitmap_buffer
    ;                                           add   bx, 1280d
    

    
    
    
    ;   ;Nested loops which print the bitmap image pixel by pixel
    ;                                               mov   si, 1280d
    ;                                              dec   si
    
    ;   loop_y_background:
    ;                                               mov   di, 1280d
    ;                                              dec   di
    
    ;   loop_x_background:
    
    ;   ;Load the color of the current pixel to AL, since AL stored the color when drawing a pixel using INT 10H
    ;                                               mov   al, byte ptr [bx]
    
    ; ;Draws a pixel at the position specified by CX and DX, with color stored in AL.
    ;                                            push  bx
    ;                                           mov   ah, 0ch
    ;                                          mov   bl, 0
    ;                                         mov   cx, di
    ;                                        add   cx, 0
    ;                                       mov   dx, si
    ;                                      add   dx, 0
    ;                                     int   10h
    ;                                    pop   bx
    
    ;   continue_background_loop:
    ;  ;Go to the next pixel.
    ;                                              dec   bx
    ;                                             dec   di
    ;                                            jnz   loop_x_background
    
    ;                                                add   bx, 2561d
    ;                                               dec   si
    ;                                              jnz   loop_y_background
    
    ;                                                popa
    
    ;                                                ret
    
    ; load_background endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;loads the image of a piece, with its picture stored as a bitmap file.
    ;The image will be placed at the cell with row number stored in DI and column number stored in SI.
    ;Note: rows/columns range from 0 to 7, since the chess board has 8 rows and 8 columns.
load_piece proc

    ;Get the actual position of the top left corner of the cell we wish to draw at, and store the coordinates in the x_temp and y_temp variables.
                                                 mov   ax, si
                                                 mul   cell_size
                                                 add   ax, margin_x
                                                 mov   x_temp, ax
                                                 

                                                 mov   ax, di
                                                 mul   cell_size
                                                 add   ax, margin_y
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

    ; draw_background proc
    
    ;                                                pusha
    
    ;                                                add   si, 0                                           ;Adjust the column position using the x_margin.
    ;                                               add   di, 0                                           ;Adjust the row position using the y_margin.
    ;                                              push  si
    ;                                             push  di
    ;                                             mov dx, offset background_image
    ;                                            call  get_file_handle                                 ;Prepare the file handle for other interrupts
    ;                                           call  pass_file_header                                ;Move the file pointer to the starting point of the image
    ;                                        pop   di
    ;                                          pop   si
    ;                                         call  load_background                                 ;Draw the image at the rows and columns specified by SI and DI.
    ;                                       call  close_file                                      ;Close the file
    
    ;                                                popa
    
    ;                                                ret

    ; draw_background endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Draws a piece
draw_piece proc

                                                 pusha

                                                 cmp   piece_to_draw, 0
    ;If the current element in the board array contains 0, we draw no pieces.
    ;If it contains a negative value, we draw a white piece.
    ;If it contains a positive value, we draw a black piece.
                                                 je    finish_draw_piece
                                                 jl    draw_white_piece

    ;Drawing a black piece
    draw_black_piece:                            
                                                 mov   bl, piece_to_draw
                                                 shl   bl, 1

    ;Move the offset of the file we wish to access and draw to dx
                                                 mov   dx, word ptr [black_pieces + bx]
                                                 jmp   load_and_draw_piece

    ;Drawing a white piece
    draw_white_piece:                            
                                                 mov   bl, piece_to_draw
                                                 neg   bl
                                                 shl   bl, 1

    ;Move the offset of the file we wish to access and draw to dx
                                                 mov   dx, word ptr [white_pieces + bx]

    load_and_draw_piece:                         
                                                                                     ;Adjust the column position using the x_margin.
                                                                                    ;Adjust the row position using the y_margin.
                                                 push  si
                                                 push  di
                                                 call  get_file_handle                                 ;Prepare the file handle for other interrupts
                                                 call  pass_file_header                                ;Move the file pointer to the starting point of the image
                                                 pop   di
                                                 pop   si
                                                 call  load_piece                                      ;Draw the image at the rows and columns specified by SI and DI.
                                                 call  close_file                                      ;Close the file
                         
    finish_draw_piece:                           
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
                                                 
                                                 

    ;Calculate and store the actual row and column positions of the upper left corner of each cell, and place them in SI and DI
                                                 mov   ah, 0ch
                                                 push  ax

                                                 mov   ax, si
                                                 mul   cell_size
                                                 mov   si, ax
                                                 add   si, margin_x

                                                 mov   ax, di
                                                 mul   cell_size
                                                 mov   di, ax
                                                 add   di, margin_y
                         
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
                                                 mov   bl, [bx + offset board]
                                                 mov   piece_to_draw, bl
                                                 call  draw_piece
    ;Exiting
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

; writes move without any checks (mainly for removeSelections)
writeMove PROC
                                                 push  bx

                                                 mov   bh, 0
                                                 mov   bl, directionPtr
                                                 shl   bx, 4d

                                                 shl   currMovePtr, 1
                                                 add   bl, currMovePtr
                                                 shr   currMovePtr, 1

                                                 mov   possibleMoves_DI[bx], di
                                                 mov   possibleMoves_SI[bx], si

                                                 pop bx
                                                 ret
writeMove ENDP
    ;Writes possible moves to memory

recordMove proc
                                                 push  bx
                                                 push  ax
                                                 
                                                 call checkOutOfBounds

                                                 cmp outOfBound, 1d
                                                 jz  recordMove_dont_record_move

                                                 call checkForEnemyPiece
                                                 jz record_empty_cell
                                                 jc record_enemy_cell
                                                 jmp recordMove_dont_record_move

                                    record_empty_cell:
                                                mov al, hover_cell_color
                                                jmp recordMove_recorded_move
                                                


                                    record_enemy_cell:
                                                mov al, possible_take_cell_color


    recordMove_recorded_move:
                                                 call draw_cell
                                                 call writeMove
                                                 inc currMovePtr
    recordMove_dont_record_move:
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

                                                 call  writeMove
                                                 inc   currMovePtr

                                                 cmp   currMovePtr, 8d
                                                 jz    removeSelections_loop2_break

                                                 call  getNextPossibleMove
                                                 cmp   si, -1d
                                                 jz    removeSelections_loop2_break

    ;; preserving the oponents moves when removing selections
    removeSelections_preserve_oponent_startpos:
                                                 cmp si, oponent_startPos_SI
                                                 jnz removeSelections_preserve_oponent_endpos
                                                 
                                                 cmp di, oponent_startPos_DI
                                                 jnz removeSelections_preserve_oponent_endpos

                                                 jmp removeSelections_preserve_oponent_move
    removeSelections_preserve_oponent_endpos:                                             
                                                 cmp si, oponent_endPos_SI
                                                 jnz removeSelections_not_prev_enemy_move
                                                 
                                                 cmp di, oponent_endPos_DI
                                                 jnz removeSelections_not_prev_enemy_move
       
    removeSelections_preserve_oponent_move:
                                                 mov al, oponent_move_color
                                                 jmp removeSelections_redraw


    removeSelections_not_prev_enemy_move:
                                                 call  get_cell_colour
    removeSelections_redraw:

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

    ;; preserving oponent's prev move when hovering                                            
    hover_preserve_oponent_startpos:
                                                 cmp si, oponent_startPos_SI
                                                 jnz hover_preserve_oponent_endpos
                                                 
                                                 cmp di, oponent_startPos_DI
                                                 jnz hover_preserve_oponent_endpos

                                                 jmp hover_preserve_oponent_move
    hover_preserve_oponent_endpos:                                             
                                                 cmp si, oponent_endPos_SI
                                                 jnz hover_not_prev_enemy_move
                                                 
                                                 cmp di, oponent_endPos_DI
                                                 jnz hover_not_prev_enemy_move
       
    hover_preserve_oponent_move:
                                                 mov al, oponent_move_color
                                                 jmp hover_redraw_prev_cell

    hover_not_prev_enemy_move:
                                                 call  get_cell_colour
    hover_redraw_prev_cell:
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

   

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ; puts the current position as the first possible move in all directions
recordCurrPos proc

                                                 push  cx

                                                 mov   cx, 8d

    recordCurrPos_loop:                          
                                                 call  writeMove
                                                 inc   directionPtr
                                                 loop  recordCurrPos_loop

                                                 mov   directionPtr, 0d
                                                 mov   currMovePtr, 1d

                                                 pop   cx

                                                 ret
    
recordCurrPos endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------


getPawnMoves proc
 
                                                 push  cx
                                                 push  si
                                                 push  di

                                                 mov directionPtr, 0d
                                                 mov currMovePtr, 1d

                                                ; checking if piece is white or black
                                                cmp   walker, -1d
                                                jz    getPawnMoves_start_white
                                                jmp   getPawnMoves_start_black

                
                ;; if this is the first move, check for 2 possible moves
                getPawnMoves_start_white:       
                                                cmp   di, 6d                        ; di=6 means that the white pawn did not move yet  
                                                jnz   getPawnMoves_not_first_move
                                                jmp   getPawnMoves_first_move   

                getPawnMoves_start_black:
                                                cmp   di, 1d                        ; di=6 means that the black pawn did not move yet
                                                jnz   getPawnMoves_not_first_move
                                                
    getPawnMoves_first_move:
                                                 mov cx, 2d
                                                 jmp  getPawnMoves_l1           

    getPawnMoves_not_first_move:
                                                 mov cx, 1d

    getPawnMoves_l1:
                                                 add di, walker
                                                 
                                                 ;; we stop moving forward when we encounter a non-empty cell
                                                 ;; for the pawn, no moves can be done in the forward direction if any piece is there
                                                 call checkForEnemyPiece
                                                 jnz  getPawnMoves_check_for_takes
                                                 
                                                 ; otherwise record the move 
                                                 call recordMove

                                                 ;; recordMove sets the flag outOfBound if move is beyond the board's frame
                                                 cmp outOfBound, 1d
                                                 jz getPawnMoves_check_for_takes

                                                 loop getPawnMoves_l1
                                                 
    getPawnMoves_check_for_takes:
                                                ; resetting si and di
                                                pop di
                                                pop si
                                                push si                                             
                                                push di

                                                mov directionPtr, 1d
                                                mov currMovePtr, 1d

                                                add di, walker
                                                add si, 1d

                                                ;; only record the move if there is an enemy piece
                                                call checkForEnemyPiece             ;;sets the carry flag if there is an enemy piece
                                                jnc  getPawnMoves_check_for_take2

                                                call recordMove

    getPawnMoves_check_for_take2:
                                                sub si, 2d
                                                mov directionPtr, 7d
                                                mov currMovePtr, 1d
                                                ;; same as above, recording only happens if there is an enemy piece
                                                call checkForEnemyPiece
                                                jnc  get_pawn_moves_end

                                                call recordMove

    get_pawn_moves_end:                          
                                                 pop   di
                                                 pop   si
                                                 pop   cx

                                                 ret

getPawnMoves endp


getKnightMoves PROC
                push si                                 
                push di

                mov directionPtr, 0d


                add si, 1d
                add di, -2d
                mov currMovePtr, 1d

                call recordMove

                add si, 1d
                add di, 1d
                mov currMovePtr, 1d
                inc directionPtr

                call recordMove

                
                add di, 2d
                mov currMovePtr, 1d
                inc directionPtr

                call recordMove
                
                add si, -1d
                add di, 1d
                mov currMovePtr, 1d
                inc directionPtr

                call recordMove
                
                add si, -2d
                mov currMovePtr, 1d
                inc directionPtr

                call recordMove

                
                add si, -1d
                add di, -1d
                mov currMovePtr, 1d
                inc directionPtr

                call recordMove

                
                add di, -2d
                mov currMovePtr, 1d
                inc directionPtr

                call recordMove
                
                add si, 1d
                add di, -1d
                mov currMovePtr, 1d
                inc directionPtr

                call recordMove                

                
getKnightMoves_end:
                pop di                                 
                pop si

                ret                                 
getKnightMoves ENDP


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

                                                 
                                                 ;; recording diagonally deals records the moves in the directions 
                                                 ;;(   1,          3,         5,       7)
                                                 ;; Up-Right  Down-Right  Down-Left  Up-Left 
                                                 mov   directionPtr, 1d                                
                                                 mov   currMovePtr, 1d


            
    getPossibleDiagonalMoves_l1:                 
                                                 mov   cl, 2d
                                  
    getPossibleDiagonalMoves_l2:                 
                                                 add   si, dx
                                                 add   di, bp

                                                 ;;   keep recording until:
                                                 ;; 1) we go out of bounds
                                                 ;; 2) encounter a non-empty cell
                                                 call  recordMove
                                                 cmp outOfBound, 1d
                                                 jz  getPossibleDiagonalMoves_l2_break
                                                 
                                                 call checkForEnemyPiece
                                                 jz getPossibleDiagonalMoves_l2       

    getPossibleDiagonalMoves_l2_break:          
                                                 add   directionPtr, 2d
                                                 mov   currMovePtr, 1d

                                                 mov   si, currSelectedPos_SI
                                                 mov   di, currSelectedPos_DI
                                                
                                                 ;; changing up/down diagonal direction
                                                 neg   bp
                                                 dec   cl
                                                 jnz   getPossibleDiagonalMoves_l2
                                                 

                                                 ;; changing left/right diagonal direction
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

                                                 ;;   keep recording until:
                                                 ;; 1) we go out of bounds
                                                 ;; 2) encounter a non-empty cell
                                                 call  recordMove
                                                 cmp outOfBound, 1d
                                                 jz  getPossibleVerticalHorizontalMoves_l2_break
                                                 
                                                 call checkForEnemyPiece
                                                 jz getPossibleVerticalHorizontalMoves_l2 

    ;                                       
    getPossibleVerticalHorizontalMoves_l2_break:
                                                 add    directionPtr, 2d
                                                 mov    currMovePtr, 1d

                                                 mov    si, currSelectedPos_SI
                                                 mov    di, currSelectedPos_DI
                                                 
                                                 ;; rotating 90 degrees clockwise
                                                 neg    bp
                                                 xchg   bp, dx
                                                 dec    cl
                                                 jnz    getPossibleVerticalHorizontalMoves_l2

                
                                                 dec    ch
                                                 jnz    getPossibleVerticalHorizontalMoves_l1



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

                                                 ret
    
getQueenMoves ENDP



getKingMoves PROC
            
            push si
            push di

            mov directionPtr, 0d
            

            dec di 
            mov currMovePtr, 1d
            call recordMove

            inc si
            inc directionPtr
            mov currMovePtr, 1d
            call recordMove

            inc di
            inc directionPtr
            mov currMovePtr, 1d
            call recordMove

            inc di 
            inc directionPtr
            mov currMovePtr, 1d
            call recordMove 

            dec si 
            inc directionPtr
            mov currMovePtr, 1d
            call recordMove
                
            dec si 
            inc directionPtr
            mov currMovePtr, 1d
            call recordMove

            dec di
            inc directionPtr
            mov currMovePtr, 1d
            call recordMove
            
            dec di
            inc directionPtr
            mov currMovePtr, 1d
            call recordMove

            
            
getKingMoves_end:
            pop di
            pop si
            

            ret
getKingMoves ENDP

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
                                                 loop  first_available_direction

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

                                                 

                                                 mov   ah, 0ch
                                                 push  ax

                                                 mov   ax, si
                                                 mul   cell_size
                                                 mov   si, ax
                                                 add   si, margin_x

                                                 mov   ax, di
                                                 mul   cell_size
                                                 mov   di, ax
                                                 add   di, margin_y
                         
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

;initializes the port for serial communication
;; Addreses
; - 3FBh  =>   Line Control Register
; - 3F8h  =>   Transmiting/Receiving || LSB of divisor value
; - 3F9h  =>   MSB of divisor value
initPort PROC

    ;;; set divisor latch Access Bit 
    mov dx, 3FBh
    mov al, 10000000b
    out dx, al


    ;; baud rate
    ;LSB
    mov dx, 3F8h
    mov al, 0Ch
    out dx, al
    
    ;MSB
    mov dx, 3F9h
    mov al, 00h
    out dx, al

    ;;; rest of configuration 
    mov dx, 3FBh
    mov al, 00011011b
    out dx, al

    ret

initPort ENDP




getFirstSelection proc

                                                 ; returns directionPtr and currMovPtr that point to the first availble move
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
    ;; looping through all directions to find one with a possible move
    A:                                           
                                                 ;; setting currMovePtr=1 to find moves that aren't (currSelectedPos_SI, currSelectedPos_DI)
                                                 mov   currMovePtr, 1d
                                                 mov   cx, 7d
                                  
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


    continue_change_selection:                   
                                                 
                                                 push  bx
                                                 lea   bx, hover_cell_color
                                                 call  checkForEnemyPiece
                                   
    ;; color it Red if enemy piece exists
    ;; if carry exists, it will go to the next place in memory which stores the Red color
                                                 adc   bx, 0

    ;; preserving the color of the oponent's prev move
    goToNextSelection_not_prev_enemy_move:
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


draw_captured_piece proc
                                                 pusha
                                                 mov   bl, current_captured_piece

                                                 cmp   bl, 0
                                                 jg    black_piece_captured
    white_piece_captured:                        
                                                 neg   bl
                                                 mov   si, offset captured_pieces_white
                                                 jmp   perpare_captured_piece
    black_piece_captured:                        
                                                 mov   si, offset captured_pieces_black

    perpare_captured_piece:                      
                                                 mov   bh, 0
                                                 cmp   bl, 1
                                                 jnz   not_pawn
    pawn_captured:                               
                                                 mov   bx, 8
    find_pawn_position:                          
                                                 cmp   byte ptr [si + bx], 0
                                                 jz    continue_draw_captured
                                                 inc   bx
                                                 jmp   find_pawn_position
    not_pawn:                                    
                                                 cmp   current_captured_piece, 6
                                                 jz    captured_king
                                                 cmp   current_captured_piece, -6
                                                 jz    captured_king
                                                 sub   bx, 2
    multiply_by_two:                             
                                                 shl   bx, 1
                                                 cmp   byte ptr [bx + si], 0
                                                 jz    continue_draw_captured
                                                 inc   bx
                                                 jmp   continue_draw_captured
    continue_draw_captured:                      
                                                 mov   al, current_captured_piece
                                                 mov   byte ptr [bx + si], al
                                                 mov   ax, bx
                                                 shr   ax, 1
                                                 and   bx, 1
                                                 mov   di, ax
                                                 mov   si, bx
                                                 sub   si, 2

                                                 mov   bl, current_captured_piece
                                                 cmp   bl, 0
                                                 jl    load_and_draw_captured_piece
                                                 add   si, 10
    load_and_draw_captured_piece:                
                                                 mov   piece_to_draw, bl
                                                 call  draw_piece
    ;Exiting
                                                 popa
                                                 ret

    captured_king:                               
                                                 sub   bx, 3
                                                 jmp   multiply_by_two
draw_captured_piece endp

;; will be called in 2 cases:
; 1) Oponent Makes a move
; 2) We make a move to one of the colored oponent cells
removePrevOponentMove PROC
                        push ax
                        push si
                        push di
                        push dx

                        cmp oponent_endPos_DI, -1d
                        jz  removePrevOponentMove_end

                        mov si, oponent_startPos_SI
                        mov di, oponent_startPos_DI
                        call get_cell_colour
                        call draw_cell

                        mov si, oponent_endPos_SI
                        mov di, oponent_endPos_DI
                        call get_cell_colour
                        call draw_cell

                        mov oponent_startPos_DI, -1d                        
                        mov oponent_startPos_SI, -1d                        
                        mov oponent_endPos_DI, -1d                        
                        mov oponent_endPos_SI, -1d                        


    removePrevOponentMove_end:

                        pop dx
                        pop di
                        pop si
                        pop ax
                        ret
    
removePrevOponentMove ENDP


    ;moves the piece according to DI,SI (nextPos) & currSelectedPos_DI,currSelectedPos_SI (current pos)
movePiece PROC
                                                 cmp   currSelectedPos_DI, -1d
                                                 jnz   start_movePiece
                                                 ret
        
    start_movePiece:                             
    ;; preserving the positions we want to write to
                                                 push  dx
                                                 push  bx
                                                 push  di
                                                 push  si

    ;; moving piece from currPos to nextPos

    ; saving the pos that we will write to
                                                 call  getPos
                                                 mov   dx, bx

    ; getting the pos that we will read from
                                                                                                    
                                                


                                                 mov si, currSelectedPos_SI
                                                 mov di, currSelectedPos_DI
                                                 call  getPos

                                                 call  getCurrentTime
                                                 call  getPrevTime
                                                 call  compareTimes
                                                 cmp   moreThan_ThreeSeconds, 1
                                                 jnz   movePiece_end

                                                 call  updateMovementTimes
    ; checking if a piece is in nextPos
    ; Cl contains the piece we want to move
                                                 mov   cl, board[bx]
                                                 mov   byte ptr board[bx], 0d                          ; removing the piece from its currentPos on the board
                                                 
                                                
                                                




                                                 mov   bx, dx
                                                 mov   al, board[bx]
                                                 cmp   al, 0d                                          ; checking if the player has taken a piece
                                                 jz    conitnue_movePiece
                                                 cmp al,6d
                                                 jnz movePiece_capture_piece                                                 
                                                 
                                                 mov end_game,1  


     movePiece_capture_piece:
    ;;; logic for if piece exists (displaying it next to board)


                                                 mov   current_captured_piece, al
                                                 call  draw_captured_piece

    conitnue_movePiece:                          
    ;; preparing to write in nextPos
                                                 call  removeSelections
                                                 mov   bx, dx
                                                 mov   board[bx], cl

                                                 call  get_cell_colour
                                                 call  draw_cell

    movePiece_end:                               
    ;; returning original values to the used registers

                                                ;preserving start pos of our move
                                                 mov startPos_DI, di
                                                 mov startPos_SI, si

                                                ;popping out the new pos (our end pos)
                                                 pop   si
                                                 pop   di
                                                 pop   bx
                                                 pop   dx
                                                ;check to update king's position   
                                                 cmp cl,-6d
                                                 jnz NotKing
                                                 mov Kingpos_si,si
                                                 mov Kingpos_di,di                                     
                                                

                                                ; checking if we can move the piece
    NotKing:                                     cmp   moreThan_ThreeSeconds, 1
                                                 jnz   not_yet

                                                ;preserving new pos (our end pos)
                                                 mov   endPos_SI, si 
                                                 mov   endPos_DI, di                                                

                                                 mov   al, hover_cell_color
                                                 call  draw_cell
    
    ;; removing the oponent's previously colored moves (if it is overwritten)
    movePiece_remove_oponent_startpos:
                                                 cmp si, oponent_startPos_SI
                                                 jnz movePiece_remove_oponent_endpos
                                                 
                                                 cmp di, oponent_startPos_DI
                                                 jnz movePiece_remove_oponent_endpos

                                                 jmp movePiece_remove_oponent_move
    movePiece_remove_oponent_endpos:                                             
                                                 cmp si, oponent_endPos_SI
                                                 jnz movePiece_not_prev_enemy_move
                                                 
                                                 cmp di, oponent_endPos_DI
                                                 jnz movePiece_not_prev_enemy_move
       
    movePiece_remove_oponent_move:
                                                 call  removePrevOponentMove 

    movePiece_not_prev_enemy_move:
                                                 mov   currSelectedPos_DI, -1d   
                                                 mov   currSelectedPos_SI, -1d

                                                 mov startSending, 1d 
                                                 
                                                 ret
    not_yet:                                   
                                                ;; TODO: add status bar message (cannot move this piece yet)
                                                 ret
movePiece ENDP

;Procedures for check

check_king_vertical proc

pusha

                           mov si,Kingpos_si
                            mov di,Kingpos_di 
vertical_up:
         cmp di,0d  
         jz end_vertical_up
         dec di
         call getpos  
         cmp board[bx],0d
         jz vertical_up
         mov cl,board[bx]   ;cl contains the piece in front of the king we've to check if its same color or not and if not check type to see if it can kill the king
         cmp cl,0d
         jb end_vertical_up  ;if cl contains negative then its a white piece so king is safe from vertical up
       ;we've to check if the enemy piece is blck rook,black queen or black king with max distance 2 
         cmp cl,4d
         jz AlertPlayer
         cmp cl,5d 
         jz AlertPlayer
         cmp cl,6d
         jnz end_vertical_up
         mov ax, Kingpos_di
         sub ax, di
         cmp ax,2d
         jbe AlertPlayer
         jmp end_vertical_up


end_vertical_up:

          mov di,Kingpos_di 
           
vertical_down:
         cmp di,7d  
         jz end_vertical_down
         inc di
         call getpos  
         cmp board[bx],0d
         jz vertical_down
         mov cl,board[bx]   ;cl contains the piece behind of the king we've to check if its same color or not and if not check type to see if it can kill the king
         cmp cl,0d
         jb end_vertical_down  ;if cl contains negative then its a white piece so king is safe from vertical down
       ;we've to check if the enemy piece is black rook,black queen or black king with max distance 2 
         cmp cl,4d
         jz AlertPlayer
         cmp cl,5d 
         jz AlertPlayer
         cmp cl,6d
         jnz end_vertical_down
         sub di, Kingpos_di
         cmp di,2d
         jbe AlertPlayer
         jmp end_vertical_down


end_vertical_down:
          popa
          ret


AlertPlayer:
mov dl, 'h'
mov ah,2
int 21h
;display message
popa


ret
check_king_vertical ENDP   


check_king_horizontal proc

pusha

                           mov si,Kingpos_si
                           mov di,Kingpos_di 
horizontal_left:
         cmp si,0d  
         jz end_horizontal_left
         dec si
         call getpos  
         cmp board[bx],0d
         jz horizontal_left
         mov cl,board[bx]   ;cl contains the piece left to the king we've to check if its same color or not and if not check type to see if it can kill the king
         cmp cl,0d
         jb end_horizontal_left  ;if cl contains negative then its a white piece so king is safe from horizontal left
       ;we've to check if the enemy piece is blck rook,black queen or black king with max distance 2 
         cmp cl,4d
         jz AlertPlayerH
         cmp cl,5d 
         jz AlertPlayerH
         cmp cl,6d
         jnz end_horizontal_left
         mov ax, Kingpos_si
         sub ax, si
         cmp ax,2d
         jbe AlertPlayerH
         jmp end_horizontal_left


end_horizontal_left:

          mov si,Kingpos_si 
           
horizontal_right:
         cmp si,7d  
         jz end_horizontal_right
         inc si
         call getpos  
         cmp board[bx],0d
         jz horizontal_right
         mov cl,board[bx]   ;cl contains the piece right to the king we've to check if its same color or not and if not check type to see if it can kill the king
         cmp cl,0d
         jb end_horizontal_right  ;if cl contains negative then its a white piece so king is safe from horizontal right
       ;we've to check if the enemy piece is black rook,black queen or black king with max distance 2 
         cmp cl,4d
         jz AlertPlayerH
         cmp cl,5d 
         jz AlertPlayerH
         cmp cl,6d
         jnz end_horizontal_right
         sub si, Kingpos_si
         cmp si,2d
         jbe AlertPlayerH
         jmp end_horizontal_right


end_horizontal_right:
          popa
          ret


AlertPlayerH:
mov dl, 'h'
mov ah,2
int 21h
;display message
popa
ret


check_king_horizontal ENDP            



















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
                                                 cmp   ah, -1d
                                                 jz    pawn

                                                 cmp   ah, -2d
                                                 jz    knight
                                   
                                                 cmp   ah, -3d
                                                 jz    bishop

                                                 cmp   ah, -4d
                                                 jz    rook

                                                 cmp   ah, -5d
                                                 jz    queen

                                                 cmp   ah, -6d
                                                 jz    king

                                                 jmp   start_selection
                          

    pawn:                                        
                                                 call   getPawnMoves
                                                 jmp    start_selection

    knight: 
                                                 call   getKnightMoves
                                                 jmp    start_selection
    bishop:                                      
                                                 call   getPossibleDiagonalMoves
                                                 jmp    start_selection

    rook:                                        call   getPossibleVerticalHorizontalMoves
                                                 jmp    start_selection

    queen:                                       
                                                 call  getQueenMoves
                                                 jmp   start_selection

    king:                                        
                                                 call getKingMoves
                                                 jmp start_selection
                          
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


;; Data Format AL = DI_0_SI  where di and si are 3 bits
; compresses the data in DI,SI to AL
compressData PROC

                            mov bx, di   ;; di is in bl
                            mov ax, si  ;;  si is in al 

                            push cx

                            mov cx, 7d
                            sub cx, bx
                            xchg bx,cx

                            pop cx
                            

                            shl al, 3   
                            mov ah, bl

                            shr ax, 3

                            ; push dx
                            ; mov dl, al
                            ; mov ah, 2
                            ; int 21h
                            ; pop dx
                            
                            ret
compressData ENDP




deCompressData PROC
                            push ax
                            push bx
                            mov bh, 0d
                            
                            ;; getting di
                            mov ah, 0d
                            shl ax, 3d
                            mov bl, ah
                            mov di, bx
                            
                            ;; getting si
                            shr al, 3
                            mov bl, al
                            mov si, bx

                            pop bx
                            pop ax
deCompressData ENDP


sendMoveToOponent PROC
                            push ax
                            push bx
                            push dx 

                            cmp  startSending, 0d
                            jz   sendMoveToOponent_end

                            ;; check if THR is empty
                            mov dx, 3FDh
                            In  al, dx
                            and al, 00100000b
                            jz  sendMoveToOponent_end


                            ;; check if start pos has already been sent
                            cmp  startPosSent, 1d
                            jz   sendMoveToOponent_send_endpos

                            ; push dx
                            ; push ax
                            ; mov dl, 'h'
                            ; mov ah, 2
                            ; int 21h
                            ; pop ax
                            ; pop dx
                            
                            mov dx, 3F8h
                            mov si, startPos_SI
                            mov di, startPos_DI
                            call compressData
                            out dx, al
                            
                            ;; setting startPosSent flag so that we don't send it again
                            mov startPosSent, 1d
                            jmp sendMoveToOponent_end                          
    

    sendMoveToOponent_send_endpos:
                           
                            mov dx, 3F8h
                            mov si, endPos_SI
                            mov di, endPos_DI
                            call compressData
                            out dx, al

                            ;; resetting flags after both positions have been sent
                            mov startSending, 0d
                            mov startPosSent, 0d


    sendMoveToOponent_end:                           
                            pop dx
                            pop bx
                            pop ax

                            ret
    
sendMoveToOponent ENDP




showOponentMove PROC
                push ax
                push si
                push di

                mov al, oponent_move_color

                mov si, oponent_startPos_SI
                mov di, oponent_startPos_DI

                call getPos

                mov cl, board[bx]
                mov board[bx], 0d

                call draw_cell

                mov si, oponent_endPos_SI
                mov di, oponent_endPos_DI

                call getPos
                mov  ch, board[bx]

                cmp ch, 0
                jz  showOponentMove_continue

                cmp ch, -6d
                jnz  showOponentMove_draw_captured_piece
                ; jmp showOponentMove_draw_captured_piece


                
showOponentMove_end_game:
                ;; TODO: Talla3 el message eno l game 5eles ya hamadaaa 
                mov end_game, 1

showOponentMove_draw_captured_piece:
                ;; TODO: Talla3 el message eno ettakel ya hamadaaa 
                mov current_captured_piece, ch
                call draw_captured_piece

showOponentMove_continue:

                mov board[bx], cl

                call draw_cell

                pop di
                pop si
                pop ax

                ret

showOponentMove ENDP


listenForOponentMove PROC
                            push dx
                            push bx
                            push ax
                            push si
                            push di
                            

                            mov dx, 3FDh
                            In  al, dx
                            and al, 1d
                            jz listenForOponentMove_end

                            mov dx, 3F8h
                            In  al, dx

                            cmp gotOponentStartPos, 1d
                            jz  listenForOponentMove_get_oponent_endpos

                            call removePrevOponentMove

                            call deCompressData

                            mov oponent_startPos_DI, di
                            mov oponent_startPos_SI, si

                            mov gotOponentStartPos, 1d
                            jmp listenForOponentMove_end



    listenForOponentMove_get_oponent_endpos:

                            call deCompressData

                            mov oponent_endPos_DI, di
                            mov oponent_endPos_SI, si

                            mov gotOponentStartPos, 0d

                            call showOponentMove
                            

    listenForOponentMove_end:
                            pop di
                            pop si
                            pop ax
                            pop bx
                            pop dx

                            ret
listenForOponentMove ENDP



    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PROCEDURES USED IN THE GAME SCREEN:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

game_window proc

                                                 call  init_board                                      ;Initialize board
                                                 call  init_video_mode                                 ;Prepare video mode

    ;Clear the screen, in preparation for drawing the board
                                                 mov   al, 14h                                         ;The color by which we will clear the screen (light gray).
                                                 call  clear_screen


                                                 ;call set_board_base


                                                 call  draw_board                                      ;Draw the board


                                                 ;call set_border
                                                 ;call draw_letters
                                                 ;call draw_numbers

                         
                                                 mov   si, 3d
                                                 mov   di, 6d
                                                 mov   al, hover_cell_color
                                                 call  draw_cell

    play_chess:                                  
                                                 call  getPlayerSelection
    
                                                 call  moveInSelections

                                                 call  sendMoveToOponent

                                                 call  listenForOponentMove

                                                 call check_king_vertical
                                                 call check_king_horizontal

                                                 cmp end_game, 1d       
                                                 jnz   play_chess

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



identification_window proc

pusha
GetName:
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


mov dh,1
 mov dl,28
 mov ah,2
 int 10h
 mov dx, offset Welcome_Mes
 mov ah,9
 int 21h
 
 mov dh,5
 mov dl,0
 mov ah,2
 int 10h
 mov dx, offset Get_Name
 mov ah,9
 int 21h

 mov ah,0AH
 mov dx,offset User_Name
 int 21h


 
   
   
mov al, User_Name+2
 Check1:
 cmp al,41h
 jb Error
 cmp al,80h
 ja Error
 jmp Done
   
   
   
   
Error:
    mov dh,7
 mov dl,0
 mov ah,2
 int 10h 
 mov dx, offset Error_Mes
 mov ah,9
 int 21h 
 mov ah,00H
 int 16h

;mov ah,0
;int 10h
jmp GetName 
 
 
Done:
 mov dh,7
 mov dl,32
 mov ah,2
 int 10h
mov dx, offset Hello
 mov ah,9
 int 21h 
  
mov dx, offset User_Name+2
 mov ah,9
 int 21h  
 mov dh,8
 mov dl,28
 mov ah,2
 int 10h
mov dx, offset Last
 mov ah,9
 int 21h  
 
 mov ah,00H
 int 16h

call main_window 

popa

ret

identification_window endp



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
call identification_window
                                                 ;call  init_board
                                                 ;call  init_video_mode
    ;call  draw_background
    ;mov   al, 14h
    ;call  clear_screen
    ;call  draw_labels
    ;call  set_board_base
    ;call  draw_board
    ;call  set_border
    ;call  draw_letters
    ;call  draw_numbers
    ;call  status_bar

    ;mov   bx, 0
    ;call  update_status
    ;call  inline_chat_window
;ctrl k u uncomment
;ctrl k c comment
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

                                                 call  initPort

    ;Setting working directory to the folder containing bitmaps of the pieces
                                                 mov   ah, 3bh
                                                 mov   dx, offset pieces_wd
                                                 int   21h

                                                 call  game_window

main endp
end main