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
    ;VARIABLES USED IN THE IDENTIFICATION WINDOW:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    Welcome_Mes              db      'Welcome To Our Game...$'
    Get_Name                 db      'Please Enter Your Name: $'
    dummy                    db      '$'
    Error_Mes                db      'Please Enter a valid Name (Name must start with English Letter) $'
    Hello                    db      'Hello $'
    Last                     db      'Please press any key to continue$'

    temppp                   db     '?'
    current_player           db      1

    request                  db      'A player sent you a game invitation', '$'

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED IN THE MAIN MENU:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Three command messages to be displayed at the main menu
    cmd1                     db      'To start chatting press F1', '$'

    cmd2                     db      'To start the game press F2', '$'

    cmd3                     db      'To end the program press ESC', '$'

    border                   db      '--------------------------------------------------------------------------------', '$'

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED IN THE CHAT MENU:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Chat screen title
    chat_title               db      'Chat', '$'

    ;Name of the other player (to be modified in phase 2)
    temp_name                db      'Mero', '$'

    temp_name2               db      'Bas', '$'

    User_Name                db      16,?,16 dup('$')
    Opponent_Name            db      16,?,16 dup('$')
    Opponent_Name_Count      db      0


    ;Dummy text to be displayed
    dummy1                   db      'This window is to be further developed in phase 2, thanks for checking in.', '$'

    dummy2                   db      'Press F3 to exit', '$'

    test1                    db      'This is a message from me to you','$'

    ICursor_Y                DB      0D
    ICursor_X                DB      0D
    OCursor_X                DB      42D
    OCursor_Y                DB      0D
    VLine                    db      '#'

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;VARIABLES USED FOR PREPARING AND DRAWING THE BOARD:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;An array that will store the current state of the board, each element of the array corresponds to a cell on the board.
    board                    db      64d dup(0)
    
    ;An array that will store the last time at which every piece on the board moved.
    movementTimes_hours      db      64d dup(0)
    movementTimes_seconds    dw      64d dup(0)
    free_pieces              db      64 dup(1)
    time_differences         db      64 dup(4)
    
    waitingTime_white        dw      4
    waitingTime_black        dw      4
    
    conversionNum            db      0
    
    currentTime_hours        db      0
    currentTime_seconds      dw      0

    prevTime_hours           db      0
    prevTime_seconds         dw      0

    moreThan_WaitingTime     db      0
    timeDifference           db      0
    
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


    ; Step unit (-1 for white & 1 for black)
    walker                   dw      ?

    ;; player pieces
    pKing                    db      -6d
    pQueen                   db      -5d
    pRook                    db      -4d
    pBishop                  db      -3d
    pKnight                  db      -2d
    pPawn                    db      -1d

    oponentKing              db      6d
    oponentQueen             db      5d
    oponentRook              db      4d
    oponentBishop            db      3d
    oponentKnight            db      2d
    oponentPawn              db      1d

    ; Keeps track of the possible move that the player is currently selecting and are used to write the moves to memory in "recordMove"
    directionPtr             db      -1d
    currMovePtr              db      -1d

    ; the position (containing a piece) that the player is currently selecting
    currSelectedPos_SI       dw      -1d
    currSelectedPos_DI       dw      -1d
    currHoverPos_SI          dw      -1d
    currHoverPos_DI          dw      -1d

    ; Helpful Flags
    outOfBound               db      0d
    startSending             db      0d
    startPosSent             db      0d
    gotOponentStartPos       db      0d
    end_game                 db      -1d
    king_in_danger           db      0d
    killedOpKing             db      0d
    

    checked_up               db      0d
    checked_down             db      0d
    checked_right            db      0d
    checked_left             db      0d
    checked_upright          db      0d
    checked_upleft           db      0d
    checked_downright        db      0d
    checked_downleft         db      0d

    ;Variables for check
    Kingpos_si               dw      4d
    Kingpos_di               dw      7d

    startSignal              db      0ffh
    endgameSignal            db      0

    blackPlayer              db      1

    sentChar                 db      -1d


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

    oponent_checkpos_SI      dw      -1d
    oponent_checkpos_DI      dw      -1d

    ; Navigation Buttons
    Left_Arrow               db      4Bh
    Right_Arrow              db      4Dh
    Up_Arrow                 db      48h
    Down_Arrow               db      50h

    Enter_Key                db      0fh

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
    oponent_move_color       db      147d                                                                                       ;-> green brdoo
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

                             timers  label byte

    timer_1                  db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0
                             db      0,0,0,1,1,1,0,0,0

    timer_2                  db      1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1
                             db      1,1,0,0,0,0,0,0,0
                             db      1,1,0,0,0,0,0,0,0
                             db      1,1,0,0,0,0,0,0,0
                             db      1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1

    timer_3                  db      1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      0,0,0,0,0,0,0,1,1
                             db      1,1,1,1,1,1,1,1,1
                             db      1,1,1,1,1,1,1,1,1

    timer_p                  db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0
                             db      0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
                             db      0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
                             db      0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
                             db      0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0
                             db      0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0
                             db      1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1
                             db      1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1
                             db      1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1
                             db      0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0
                             db      0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
                             db      0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
                             db      0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
                             db      0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
                             db      0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0
                             db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;MISCELLANEOUS VARIABLES:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

    temp_sp                  dw      ?

    status_1                 db      'Game has started', '$'
    status_2                 db      'Cannot move selected piece', '$'
    status_3                 db      'Game has ended', '$'
    status_4                 db      'King is Checked!!', '$'
    status_5                 db      'A piece was eaten!', '$'

.code

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;MISCELLANEOUS PROCEDURES:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

getCurrentTime proc

                                                push  ax
                                                push  cx
                                                push  dx
                           
                                                mov   ah, 2ch
                                                int   21h

                                                mov   currentTime_hours, ch

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

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;description
genRandomPos PROC
                                                push  ax
                                                push  bx
                                                push  cx
                                                push  dx

                                                mov   ah, 2ch
                                                int   21h

                                                mov   dl, 0

                                                and   dh, 31d
                                                add   dh, 16d
                                                
                                                shr   dx, 8d


                                                mov   si, dx
                                                

                                                pop   dx
                                                pop   cx
                                                pop   bx
                                                pop   ax

                                                ret
genRandomPos ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

compareTimes proc

                                                push  ax
                                                push  cx
                                                push  dx

                                                mov   cx, currentTime_seconds
                                                sub   cx, prevTime_seconds
                                                jbe   differentHour
    check_above_WaitingTime:                    
                                                cmp   byte ptr board[bx], 0
                                                jg    black_piece_check
    white_piece_check:                          
                                                mov   dx, waitingTime_white
                                                jmp   compare_times
    black_piece_check:                          
                                                mov   dx, waitingTime_black

    compare_times:                              
                                                mov   timeDifference, cl
                                                cmp   cx, dx
                                                jb    lessThan_WaitingTime
    moreThan_Waiting:                           
                                                mov   moreThan_WaitingTime, 1
                                                pop   dx
                                                pop   cx
                                                pop   ax

                                                ret
    lessThan_WaitingTime:                       
                                                mov   moreThan_WaitingTime, 0
                                                pop   dx
                                                pop   cx
                                                pop   ax

                                                ret
    differentHour:                              
                                                mov   al, currentTime_hours
                                                sub   al, prevTime_hours
                                                jbe   lessThan_WaitingTime
                                                cmp   al, 1
                                                ja    moreThan_Waiting
                                                mov   cx, 3600
                                                sub   cx, prevTime_seconds
                                                add   cx, currentTime_seconds
                                                jmp   check_above_WaitingTime

compareTimes endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

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

    ;---------------------------------------------------------------------------------------------------------------------------------------------

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

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;sets carry flag
setcarry proc

                                                push  ax
    
                                                mov   ax, 0ffffh
                                                shl   ax, 1d

                                                pop   ax
                                                ret

setcarry endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

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

                                                mov   al, 0fh                                        ;3
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

                                                mov   al, 0fh
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

    ;---------------------------------------------------------------------------------------------------------------------------------------------

draw_letters_inverted proc

                                                pusha

                                                mov   temp_sp, sp

                                                mov   di, cell_size
                                                mov   si, 0

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_x
                                                sub   ax, 31d
                                                mov   bp, ax

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_y
                                                add   ax, 4
                                                add   ax, 19d
                                                mov   sp, ax

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_x
                                                sub   ax, 31d
                                                sub   ax, 13d
                                                mov   bx, ax

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_x
                                                sub   ax, 31d
                                                sub   ax, 13d
                                                mov   cx, ax

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_y
                                                add   ax, 4
                                                mov   dx, ax

                                                mov   al, 0fh                                        ;3
                                                mov   ah, 0ch

                                                mov   di, 8

    draw_letters_1_inverted:                    

    loop_y_letter_1_inverted:                   

    loop_x_letter_1_inverted:                   
                                                cmp   letters + [si], 1
                                                je    draw_the_letter_1_inverted
    back_1_inverted:                            
                                                inc   si
                                                inc   cx
                                                cmp   cx, bp
                                                jnz   loop_x_letter_1_inverted

                                                inc   dx
                                                mov   cx, bx
                                                cmp   dx, sp
                                                jnz   loop_y_letter_1_inverted

                                                sub   cx, cell_size
                                                sub   bp, cell_size
                                                sub   bx, cell_size
                                                sub   dx, 19d
                                                dec   di
                                                jnz   draw_letters_1_inverted
                                                jmp   end_draw_letters_1_inverted

    draw_the_letter_1_inverted:                 
                                                int   10h
                                                jmp   back_1_inverted

    end_draw_letters_1_inverted:                


                                                mov   di, cell_size
                                                mov   si, 0

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_x
                                                sub   ax, 31d
                                                sub   ax, 13d
                                                mov   bp, ax

                                                mov   ax, 0
                                                add   ax, margin_y
                                                sub   ax, 4
                                                sub   ax, 19d
                                                mov   sp, ax

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_x
                                                sub   ax, 31d
                                                mov   bx, ax

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_x
                                                sub   ax, 31d
                                                mov   cx, ax

                                                mov   ax, 0
                                                add   ax, margin_y
                                                sub   ax, 4
                                                mov   dx, ax

                                                mov   al, 0fh
                                                mov   ah, 0ch

                                                mov   di, 8

    draw_letters_2_inverted:                    

    loop_y_letter_2_inverted:                   

    loop_x_letter_2_inverted:                   
                                                cmp   letters + [si], 1
                                                je    draw_the_letter_2_inverted
    back_2_inverted:                            
                                                inc   si
                                                dec   cx
                                                cmp   cx, bp
                                                jnz   loop_x_letter_2_inverted

                                                dec   dx
                                                mov   cx, bx
                                                cmp   dx, sp
                                                jnz   loop_y_letter_2_inverted

                                                sub   cx, cell_size
                                                sub   bp, cell_size
                                                sub   bx, cell_size
                                                add   dx, 19d
                                                dec   di
                                                jnz   draw_letters_2_inverted
                                                jmp   end_draw_letters_2_inverted

    draw_the_letter_2_inverted:                 
                                                int   10h
                                                jmp   back_2_inverted

    end_draw_letters_2_inverted:                

                                                mov   sp, temp_sp

                                                popa

                                                mov   temp_sp, di

                                                ret

draw_letters_inverted endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

draw_timer_1 proc

                                                pusha

                                                add   di, 33d
                                                add   si, 31d

                                                mov   bp, di
                                                mov   bx, si

                                                add   bp, 09d
                                                add   bx, 13d

                                                mov   cx, di
                                                mov   dx, si
                                                mov   al, 04h
                                                mov   ah, 0ch

                                                mov   si, 0

    timer_1_y:                                  
    timer_1_x:                                  
                                                cmp   timer_1 + [si],1
                                                je    draw_the_timer_1
    back_from_timer_1:                          
                                                inc   si
                                                inc   cx
                                                cmp   cx, bp
                                                jnz   timer_1_x
                                                mov   cx, di
                                                inc   dx
                                                cmp   dx, bx
                                                jnz   timer_1_y

                                                jmp   end_timer_1

    draw_the_timer_1:                           
                                                int   10h
                                                jmp   back_from_timer_1

    end_timer_1:                                

                                                popa

                                                ret

draw_timer_1 endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

draw_timer_2 proc

                                                pusha

                                                add   di, 33d
                                                add   si, 31d

                                                mov   bp, di
                                                mov   bx, si

                                                add   bp, 09d
                                                add   bx, 13d

                                                mov   cx, di
                                                mov   dx, si
                                                mov   al, 04h
                                                mov   ah, 0ch

                                                mov   si, 0

    timer_2_y:                                  
    timer_2_x:                                  
                                                cmp   timer_2 + [si],1
                                                je    draw_the_timer_2
    back_from_timer_2:                          
                                                inc   si
                                                inc   cx
                                                cmp   cx, bp
                                                jnz   timer_2_x
                                                mov   cx, di
                                                inc   dx
                                                cmp   dx, bx
                                                jnz   timer_2_y

                                                jmp   end_timer_2

    draw_the_timer_2:                           
                                                int   10h
                                                jmp   back_from_timer_2

    end_timer_2:                                

                                                popa

                                                ret

draw_timer_2 endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

draw_timer_3 proc

                                                pusha

                                                add   di, 33d
                                                add   si, 31d

                                                mov   bp, di
                                                mov   bx, si

                                                add   bp, 09d
                                                add   bx, 13d

                                                mov   cx, di
                                                mov   dx, si
                                                mov   al, 04h
                                                mov   ah, 0ch

                                                mov   si, 0

    timer_3_y:                                  
    timer_3_x:                                  
                                                cmp   timer_3 + [si],1
                                                je    draw_the_timer_3
    back_from_timer_3:                          
                                                inc   si
                                                inc   cx
                                                cmp   cx, bp
                                                jnz   timer_3_x
                                                mov   cx, di
                                                inc   dx
                                                cmp   dx, bx
                                                jnz   timer_3_y

                                                jmp   end_timer_3

    draw_the_timer_3:                           
                                                int   10h
                                                jmp   back_from_timer_3

    end_timer_3:                                

                                                popa

                                                ret

draw_timer_3 endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

draw_timer_p proc

                                                pusha

                                                add   di, 22d
                                                add   si, 22d

                                                mov   bp, di
                                                mov   bx, si

                                                add   bp, 31d
                                                add   bx, 31d

                                                mov   cx, di
                                                mov   dx, si
                                                mov   al, 04h
                                                mov   ah, 0ch

                                                mov   si, 0

    timer_p_y:                                  
    timer_p_x:                                  
                                                cmp   timer_p + [si], 1
                                                je    draw_the_timer_p
    back_from_timer_p:                          
                                                inc   si
                                                inc   cx
                                                cmp   cx, bp
                                                jnz   timer_p_x
                                                mov   cx, di
                                                inc   dx
                                                cmp   dx, bx
                                                jnz   timer_p_y

                                                jmp   end_timer_p

    draw_the_timer_p:                           
                                                int   10h
                                                jmp   back_from_timer_p

    end_timer_p:                                

                                                popa

                                                ret

draw_timer_p endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

draw_numbers proc

                                                pusha

                                                mov   temp_sp, sp

                                                mov   di, cell_size
                                                mov   si, 0

                                                mov   ax, 0
                                                add   ax, margin_x
                                                sub   ax, 6
                                                add   ax, 1
                                                mov   bp, ax

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_y
                                                sub   ax, 31d
                                                mov   sp, ax

                                                mov   ax, 0
                                                add   ax, margin_x
                                                sub   ax, 6
                                                sub   ax, 13d
                                                add   ax, 1
                                                mov   bx, ax

                                                mov   ax, 0
                                                add   ax, margin_x
                                                sub   ax, 6
                                                sub   ax, 13d
                                                add   ax, 1
                                                mov   cx, ax

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_y
                                                sub   ax, 31d
                                                sub   ax, 19d
                                                mov   dx, ax

                                                mov   al, 0fh
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

                                                sub   dx, cell_size
                                                sub   sp, cell_size
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

                                                mov   al, 0fh
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

draw_numbers_inverted proc

                                                pusha

                                                mov   temp_sp, sp

                                                mov   di, cell_size
                                                mov   si, 0

                                                mov   ax, 0
                                                add   ax, margin_x
                                                sub   ax, 6
                                                add   ax, 1
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
                                                add   ax, 1
                                                mov   bx, ax

                                                mov   ax, 0
                                                add   ax, margin_x
                                                sub   ax, 6
                                                sub   ax, 13d
                                                add   ax, 1
                                                mov   cx, ax

                                                mov   ax, 0
                                                add   ax, margin_y
                                                add   ax, 31d
                                                mov   dx, ax

                                                mov   al, 0fh
                                                mov   ah, 0ch

                                                mov   di, 8

    draw_numbers_1_inverted:                    

    loop_y_number_1_inverted:                   

    loop_x_number_1_inverted:                   
                                                cmp   numbers + [si], 1
                                                je    draw_the_number_1_inverted
    back_number_1_inverted:                     
                                                inc   si
                                                inc   cx
                                                cmp   cx, bp
                                                jnz   loop_x_number_1_inverted

                                                inc   dx
                                                mov   cx, bx
                                                cmp   dx, sp
                                                jnz   loop_y_number_1_inverted

                                                add   dx, cell_size
                                                add   sp, cell_size
                                                sub   dx, 19d
                                                dec   di
                                                jnz   draw_numbers_1_inverted
                                                jmp   end_draw_numbers_1_inverted

    draw_the_number_1_inverted:                 
                                                int   10h
                                                jmp   back_number_1_inverted

    end_draw_numbers_1_inverted:                


                                                mov   di, cell_size
                                                mov   si, 0

                                                mov   ax, 0
                                                add   ax, 8
                                                mul   di
                                                add   ax, margin_x
                                                add   ax, 6
                                                mov   bp, ax

                                                mov   ax, 0
                                                add   ax, margin_y
                                                add   ax, 31d
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
                                                add   ax, margin_y
                                                add   ax, 31d
                                                add   ax, 19d
                                                mov   dx, ax

                                                mov   al, 0fh
                                                mov   ah, 0ch

                                                mov   di, 8

    draw_numbers_2_inverted:                    

    loop_y_number_2_inverted:                   

    loop_x_number_2_inverted:                   
                                                cmp   numbers + [si], 1
                                                je    draw_the_number_2_inverted
    back_number_2_inverted:                     
                                                inc   si
                                                dec   cx
                                                cmp   cx, bp
                                                jnz   loop_x_number_2_inverted

                                                dec   dx
                                                mov   cx, bx
                                                cmp   dx, sp
                                                jnz   loop_y_number_2_inverted

                                                add   dx, cell_size
                                                add   sp, cell_size
                                                add   dx, 19d
                                                dec   di
                                                jnz   draw_numbers_2_inverted
                                                jmp   end_draw_numbers_2_inverted

    draw_the_number_2_inverted:                 
                                                int   10h
                                                jmp   back_number_2_inverted

    end_draw_numbers_2_inverted:                

                                                mov   sp, temp_sp

                                                popa

                                                ret

draw_numbers_inverted endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

input_move_down proc
                                                mov   ICursor_X,1d
                                                inc   ICursor_Y

                                                mov   AH,2
                                                mov   DL,ICursor_X
                                                MOV   DH,ICursor_Y
                                                int   10h
                                                ret
input_move_down endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

inline_input_move_down proc
                                                mov   ICursor_X,120d
                                                inc   ICursor_Y

                                                mov   AH,2
                                                mov   DL,ICursor_X
                                                MOV   DH,ICursor_Y
                                                int   10h
                                                ret
inline_input_move_down endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

output_move_down proc
                                                mov   OCursor_X,41d
                                                inc   OCursor_Y

                                                mov   AH,2
                                                mov   DL,OCursor_X
                                                MOV   DH,OCursor_Y
                                                int   10h
                                                ret
output_move_down endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

inline_output_move_down proc
                                                mov   OCursor_X,120d
                                                inc   OCursor_Y

                                                mov   AH,2
                                                mov   DL,OCursor_X
                                                MOV   DH,OCursor_Y
                                                int   10h
                                                ret
inline_output_move_down endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

inializeScreen proc

                                                mov   ah,0
                                                mov   al,3h
                                                int   10h

                                                mov   ah,2
                                                mov   dl,39
                                                mov   dh,0
                                                mov   cx,25
    lp:                                         
                                                mov   ah, 2
                                                int   10h
                                                mov   dl,'#'
                                                int   21h
                                                mov   dl,39
                                                inc   dh
                                                LOOP  lp


                                                mov   ah,2
                                                mov   dl,40
                                                mov   dh,0
                                                mov   cx,25
    lp2:                                        
                                                mov   ah, 2
                                                int   10h
                                                mov   dl,'#'
                                                int   21h
                                                mov   dl,40
                                                inc   dh
                                                LOOP  lp2



    ;                                             mov   ah,2
    ;                                             mov   dl,40
    ;                                             mov   dh,0
    ;                                             mov   cx,25
    ; lp2:
    ;                                             mov   ah, 2
    ;                                             int   10h
    ;                                             mov   dl,'#'
    ;                                             int   21h
    ;                                             mov   dl,40
    ;                                             inc   dh
    ;                                             LOOP  lp2


                                                mov   ICursor_X, 1
                                                mov   ICursor_Y, 0

                                                mov   AH,2
                                                mov   DL, ICursor_X
                                                MOV   DH, ICursor_Y
                                                int   10h


                                                mov   OCursor_X, 42d
                                                mov   OCursor_Y, 0


                                                ret

inializeScreen endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

input_scroll_up proc
                                                pusha
                                                
                                                mov   ICursor_X, 1d
                                                dec   ICursor_Y

                                                mov   AH,2
                                                mov   DL, ICursor_X
                                                MOV   DH, ICursor_Y
                                                int   10h

                                                mov   al,1d                                          ; function 6
                                                mov   ah,6h
                                                mov   bh,07h                                         ; normal video attribute
                                                mov   cl,0d                                          ; upper left X
                                                mov   ch,0d                                          ; upper left Y
                                                mov   dl,37d                                         ; lower right X
                                                mov   dh,24d                                         ; lower right Y
                                                int   10h
                                               

                                                popa
                                                ret
input_scroll_up endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------
inline_chat_window proc

                                                pusha

                                                mov   al, 00h
                                                mov   ah, 0ch

                                                mov   cx, 950d

                                                cmp   bp, 0
                                                jz    inline_chat_window_w0
                                                mov   dx, 512d
                                                mov   bx, 1024d
                                                jmp draw_inline_chat_y

                inline_chat_window_w0:
                                                mov   dx, 0
                                                mov bx,   512d

    draw_inline_chat_y:                         

    draw_inline_chat_x:                         

                                                int   10h
                                                inc   cx
                                                cmp   cx, 1280d
                                                jnz   draw_inline_chat_x

                                                inc   dx
                                                mov   cx, 950d
                                                cmp   dx, bx
                                                jnz   draw_inline_chat_y

    mov cx,950d
    mov dx,512d
    mov al,1ch
    mov ah,0ch
    draw_separation:
    int 10h
    inc cx
    cmp cx,1280d
    jnz draw_separation

                                                popa

                                                ret

inline_chat_window endp


inline_input_scroll_up proc
                                                pusha
                                                mov bp, 0
                                                call inline_chat_window

                                                mov   ICursor_Y,1D
                                                mov   ICursor_X,120D

                                                mov   AH,2
                                                mov   DL, ICursor_X
                                                MOV   DH, ICursor_Y
                                                int   10h
                                                
                                                popa
                                                ret
inline_input_scroll_up endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

output_scroll_up proc
                                                pusha
                                                
                                                mov   OCursor_X, 42d
                                                dec   OCursor_Y

                                                mov   AH,2
                                                mov   DL, OCursor_X
                                                MOV   DH, OCursor_Y
                                                int   10h
                                                
                                                mov   al,1h                                          ; function 6
                                                mov   ah,6h
                                                mov   bh,07h                                         ; normal video attribute
                                                mov   ch,0                                           ; upper left Y
                                                mov   cl,42d                                         ; upper left X
                                                mov   dh,24d                                         ; lower right Y
                                                mov   dl,79d                                         ; lower right X
                                                int   10h
                                                
                                                popa
                                                ret
output_scroll_up endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

inline_output_scroll_up proc
                                                pusha
                                                mov bp, 1
                                                call inline_chat_window

                                                mov   OCursor_X,120D
                                                mov   OCursor_Y,33D 

                                                mov   AH,2
                                                mov   DL, OCursor_X
                                                MOV   DH, OCursor_Y
                                                int   10h

                                                popa
                                                ret
inline_output_scroll_up endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

intializePort proc

                                                mov   dx,3fbh                                        ;line control register
                                                mov   al,10000000b                                   ;set divisor latch access bit
                                                out   dx,al                                          ;out it

                                                mov   dx,3f8h
                                                mov   al,0ch
                                                out   dx,al

                                                mov   dx,3f9h
                                                mov   al,00h
                                                out   dx,al

                                                mov   dx,3fbh
                                                mov   al,00011011b
                                                out   dx,al

                                                ret

intializePort endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

WRITEINPUT PROC
                                                cmp   ICursor_X,38d
                                                jnz   WRITEINPUT_check_key_pressed
                                                call  input_move_down

                                                cmp   ICursor_Y,25d
                                                jb    WRITEINPUT_check_key_pressed
                                            
                                                call  input_scroll_up
                                                jmp   WRITEINPUT_check_key_pressed
                                                
    WRITEINPUT_check_key_pressed:               
                                                cmp   al, 8h
                                                je    WRITEINPUT_backspace
                                                CMP   AL,13d
                                                JE    IENTER

                                                mov   AH,2
                                                mov   DL,ICursor_X
                                                MOV   DH,ICursor_Y
                                                int   10h

                                                mov   ah,2
                                                mov   dl,AL
                                                int   21h
                                                INC   ICursor_X
                                                RET

    WRITEINPUT_backspace:                       
                                                
                                                cmp   ICursor_X, 1
                                                jne   WRITEINPUT_backspace_continue
                                                
                                                cmp   ICursor_Y, 0
                                                jne   WRITEINPUT_backspace_continue2

                                                ret

    WRITEINPUT_backspace_continue2:             
                                                mov   ICursor_X, 39d
                                                dec   ICursor_Y
                                                            
            
    WRITEINPUT_backspace_continue:              
                                                dec   ICursor_X
                                                mov   AH,2
                                                mov   DL,ICursor_X
                                                MOV   DH,ICursor_Y
                                                int   10h

                                                mov   dl, 0
                                                mov   ah, 2
                                                int   21h

                                                mov   AH,2
                                                mov   DL,ICursor_X
                                                MOV   DH,ICursor_Y
                                                int   10h
                                                ret
    IENTER:                                     
                                                CALL  input_move_down
                                                cmp   ICursor_Y, 25d

                                                jnz   WRITEINPUT_end

                                                call  input_scroll_up
                                                
    WRITEINPUT_end:                             
                                                RET

WRITEINPUT ENDP

;---------------------------------------------------------------------------------------------------------------------------------------------

console_log MACRO haga
    push  dx
    push  ax

    mov dl, haga
    mov ah, 2

    int 21h

    pop ax
    pop dx

ENDM

INLINE_WRITEINPUT PROC
                                                pusha

                                                cmp   ICursor_X,158d
                                                jnz   INLINE_WRITEINPUT_check_key_pressed
                                                call  inline_input_move_down

                                                cmp   ICursor_Y,31d
                                                jb    INLINE_WRITEINPUT_check_key_pressed
                                                
                                                call  inline_input_scroll_up
                                                jmp   INLINE_WRITEINPUT_check_key_pressed
                                                
    INLINE_WRITEINPUT_check_key_pressed:        
                                                cmp   al, 8h
                                                je    INLINE_WRITEINPUT_backspace
                                                CMP   AL,13d
                                                JE    INLINE_IENTER

                                                mov   AH,2
                                                mov   DL,ICursor_X
                                                MOV   DH,ICursor_Y
                                                int   10h

                                                mov   ah,2
                                                mov   dl,AL
                                                int   21h
                                                INC   ICursor_X
                                                popa
                                                RET

    INLINE_WRITEINPUT_backspace:                
                                                
                                                cmp ICursor_X, 120d
                                                jne INLINE_WRITEINPUT_backspace_continue
                                                
                                                cmp ICursor_Y, 1
                                                jne INLINE_WRITEINPUT_backspace_continue2
                                                popa
                                                ret

            INLINE_WRITEINPUT_backspace_continue2:
                                                mov ICursor_X, 158d
                                                dec ICursor_Y
                                                            
            
    INLINE_WRITEINPUT_backspace_continue:       
                                                dec   ICursor_X
                                                mov   AH,2
                                                mov   DL,ICursor_X
                                                MOV   DH,ICursor_Y
                                                int   10h

                                                mov   dl, 0
                                                mov   ah, 2
                                                int   21h

                                                mov   AH,2
                                                mov   DL,ICursor_X
                                                MOV   DH,ICursor_Y
                                                int   10h
                                                popa
                                                ret
    INLINE_IENTER:                              
                                                CALL  inline_input_move_down
                                                cmp   ICursor_Y, 31d

                                                jnz   INLINE_WRITEINPUT_end

                                                call  inline_input_scroll_up
                                                
    INLINE_WRITEINPUT_end:                      

                                                popa
                                                RET

INLINE_WRITEINPUT ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------


    ;description
resetEverything PROC
    ; Keeps track of the possible move that the player is currently selecting and are used to write the moves to memory in "recordMove"
                                                mov   directionPtr       , -1d
                                                mov   currMovePtr        , -1d

    ; the position (containing a piece) that the player is currently selecting
                                                mov   currSelectedPos_SI , -1d
                                                mov   currSelectedPos_DI , -1d
                                                mov   currHoverPos_SI , -1d
                                                mov   currHoverPos_DI , -1d
    
    ; Helpful Flags
                                                mov   outOfBound         , 0d
                                                mov   startSending       , 0d
                                                mov   startPosSent       , 0d
                                                mov   gotOponentStartPos , 0d
                                                mov   end_game           , -1d
                                                mov   king_in_danger     , 0d
                                                mov   killedOpKing       , 0d
    

                                                mov   checked_up         , 0d
                                                mov   checked_down       , 0d
                                                mov   checked_right      , 0d
                                                mov   checked_left       , 0d
                                                mov   checked_upright    , 0d
                                                mov   checked_upleft     , 0d
                                                mov   checked_downright  , 0d
                                                mov   checked_downleft   , 0d

    ;Variables for check

                                                cmp   blackPlayer, 1
                                                jz    reset_black

                                                mov   Kingpos_si         , 4d
                                                mov   Kingpos_di         , 7d
                                                jmp   reset_everything_continue

    reset_black:                                
    
                                                mov   Kingpos_si         , 3d
                                                mov   Kingpos_di         , 7d

    reset_everything_continue:                  

    ;; plays that will be sent to the oponent
                                                mov   startPos_SI        , -1d
                                                mov   startPos_DI        , -1d

                                                mov   endPos_SI          , -1d
                                                mov   endPos_DI          , -1d
    
    ;; plays that will be received from the oponent
                                                mov   oponent_startPos_SI, -1d
                                                mov   oponent_startPos_DI, -1d

                                                mov   oponent_endPos_SI  , -1d
                                                mov   oponent_endPos_DI  , -1d

                                                mov   oponent_checkpos_SI, -1d
                                                mov   oponent_checkpos_DI, -1d

                                                mov   Opponent_Name_Count, 0

    ; Navigation Buttons
                                                mov   Left_Arrow         , 4Bh
                                                mov   Right_Arrow        , 4Dh
                                                mov   Up_Arrow           , 48h
                                                mov   Down_Arrow         , 50h

                                                ret

resetEverything ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

WRITEOUTPUT PROC
                                                cmp   OCursor_X, 79d
                                                jnz   WRITEOUTPUT_check_key_pressed
                                                call  output_move_down

                                                cmp   OCursor_Y, 25d
                                                jb    WRITEOUTPUT_check_key_pressed
                                            
                                                call  output_scroll_up
                                                jmp   WRITEOUTPUT_check_key_pressed
                                                
    WRITEOUTPUT_check_key_pressed:              
                                                cmp   al, 8h
                                                je    WRITEOUTPUT_backspace
                                                cmp   al, 0
                                                je    WRITEOUTPUT_backspace

                                                CMP   AL,1Ch
                                                JE    OENTER

                                                mov   AH,2
                                                mov   DL, OCursor_X
                                                MOV   DH, OCursor_Y
                                                int   10h

                                                mov   ah,2
                                                mov   dl,AL
                                                int   21h
                                                INC   OCursor_X
                                                RET


    WRITEOUTPUT_backspace:                      
                                                
                                                cmp   OCursor_X, 42d
                                                jne   WRITEOUTPUT_backspace_continue
                                                
                                                cmp   OCursor_Y, 0
                                                jne   WRITEOUTPUT_backspace_continue2

                                                ret

    WRITEOUTPUT_backspace_continue2:            
                                                mov   OCursor_X, 79d
                                                dec   OCursor_Y
            
            
    WRITEOUTPUT_backspace_continue:             
                                                dec   OCursor_X
                                                mov   AH,2
                                                mov   DL, OCursor_X
                                                MOV   DH, OCursor_Y
                                                int   10h

                                                mov   dl, 0
                                                mov   ah, 2
                                                int   21h

                                                mov   AH,2
                                                mov   DL, OCursor_X
                                                MOV   DH, OCursor_Y
                                                int   10h
                                                ret
    OENTER:                                     
                                                CALL  output_move_down
                                                cmp   OCursor_Y, 25d

                                                jnz   WRITEOUTPUT_end

                                                call  output_scroll_up
                                                
    WRITEOUTPUT_end:                            
                                                RET

WRITEOUTPUT ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

INLINE_WRITEOUTPUT PROC
                                                pusha
                                                cmp   OCursor_X, 158d
                                                jnz   INLINE_WRITEOUTPUT_check_key_pressed
                                                call  inline_output_move_down

                                                cmp   OCursor_Y, 63d
                                                jb    INLINE_WRITEOUTPUT_check_key_pressed          
                                                call  inline_output_scroll_up
                                                
                                                jmp   INLINE_WRITEOUTPUT_check_key_pressed
                                                
    INLINE_WRITEOUTPUT_check_key_pressed:       
                                                cmp   al, 0fdh
                                                je    INLINE_WRITEOUTPUT_backspace

                                                CMP   AL, 1Ch
                                                JE    INLINE_OENTER

                                                mov   AH,2
                                                mov   DL, OCursor_X
                                                MOV   DH, OCursor_Y
                                                int   10h

                                                mov   ah,2
                                                mov   dl,AL
                                                int   21h
                                                INC   OCursor_X
                                                popa
                                                RET


    INLINE_WRITEOUTPUT_backspace:               
                                                
                                                cmp   OCursor_X, 120d
                                                jne   INLINE_WRITEOUTPUT_backspace_continue
                                                
                                                cmp   OCursor_Y, 33d
                                                jne   INLINE_WRITEOUTPUT_backspace_continue2
                                                popa
                                                ret

    INLINE_WRITEOUTPUT_backspace_continue2:     
                                                mov   OCursor_X, 158d
                                                dec   OCursor_Y
            
            
    INLINE_WRITEOUTPUT_backspace_continue:      
                                                dec   OCursor_X
                                                mov   AH,2
                                                mov   DL, OCursor_X
                                                MOV   DH, OCursor_Y
                                                int   10h

                                                mov   dl, 0
                                                mov   ah, 2
                                                int   21h

                                                mov   AH,2
                                                mov   DL, OCursor_X
                                                MOV   DH, OCursor_Y
                                                int   10h
                                                popa
                                                ret
    INLINE_OENTER:                              
                                                CALL  inline_output_move_down
                                                cmp   OCursor_Y, 63d

                                                jnz   INLINE_WRITEOUTPUT_end

                                                call inline_output_scroll_up
                                                
    INLINE_WRITEOUTPUT_end:                     
                                                popa
                                                RET

INLINE_WRITEOUTPUT ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

SENDKEY PROC

                                                cmp al, 0
                                                jnz  sendkey_normal_continue1
                                                mov al, 0fdh
                                                jmp sendkey_normal
                    sendkey_normal_continue1:                            
                                                cmp al, 8d
                                                jnz  sendkey_normal_continue2
                                                mov al, 0fdh
                                                jmp sendkey_normal
                    sendkey_normal_continue2:
                                                cmp   al, 13d
                                                jnz   sendkey_normal
                                                mov   al , 1Ch
                    sendkey_normal:                             
                                                MOV   DX,3F8H
                                                OUT   DX,AL
                                                RET

SENDKEY ENDP

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

    ;description
sendPowerupPos PROC
                                                mov   bx, offset board
                                                call  genRandomPos
                                                add   bx, si
                                                mov   byte ptr [bx], 'p'
                                                sub   bx, offset board

    ; push ax
    ; push dx
    ; mov  dl, bl
    ; mov  ah, 2
    ; int  21h
    ; pop  dx
    ; pop  ax

    sendPowerupPos_rep:                         
                                                mov   dx, 3FDh
                                                In    al, dx
                                                and   al, 00100000b
                                                jz    sendPowerupPos_rep

                                                mov   dx, 3F8h
                                                mov   al, bl
                                                out   dx, al


                                                ret
sendPowerupPos ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;description
receivePowerupPos PROC
                                                
    receivePowerupPos_rep:                      
                                                mov   dx, 3FDh
                                                In    al, dx
                                                and   al, 1d
                                                jz    receivePowerupPos_rep

                                                mov   dx, 3F8h
                                                In    al, dx

                                                mov   bh, 0
                                                mov   bl, al

    ; push ax
    ; push dx
    ; mov  dl, bl
    ; mov  ah, 2
    ; int  21h
    ; pop  dx
    ; pop  ax


                                                mov   cx, 63d
                                                sub   cx, bx
                                                xchg  bx, cx

                                                add   bx, offset board
                                                
                                                
                                                mov   byte ptr [bx], 'p'

                                                ret
    
receivePowerupPos ENDP

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
    
    

    ;Places the knights on their initial positions on the board, 2 indicates a black knight and -2 indicates a white knight.
                                                mov   bx, offset board + 1
                                                mov   cx, 2

    init_knights:                               
                                                mov   al, oponentKnight
                                                mov   [bx], al
                                                add   bx, 56d
                                                mov   al, pKnight
                                                mov   [bx], al
                                                sub   bx, 51d
                                                loop  init_knights

    ;Places the bishops on their initial positions on the board, 3 indicates a black bishop and -3 indicates a white bishop.
                                                mov   bx, offset board + 2
                                                mov   cx, 2

    init_bishops:                               
                                                mov   al, oponentBishop
                                                mov   [bx], al
                                                add   bx, 56d
                                                mov   al, pBishop
                                                mov   [bx], al
                                                sub   bx, 53d
                                                loop  init_bishops

    ;Places the rooks on their initial positions on the board, 4 indicates a black rook and -4 indicates a white rook.
                                                mov   bx, offset board
                                                mov   cx, 2

    init_rooks:                                 
                                                mov   al, oponentRook
                                                mov   [bx],  al
                                                add   bx, 56d
                                                mov   al, pRook
                                                mov   [bx], al
                                                sub   bx, 49d
                                                loop  init_rooks

    ;Places the queens on their initial positions on the board, 5 indicates a black queen and 6 indicates a white queen.
                                                mov   bx, offset board + 3
                                                add   bl, blackPlayer
                                                mov   al, oponentQueen
                                                mov   [bx], al
                                                add   bx, 56d
                                                mov   al, pQueen
                                                mov   [bx], al

    ;Places the kings on their initial positions on the board, 6 indicates a black king and -6 indicates a white king.
                                                mov   bx, offset board + 4
                                                sub   bl, blackPlayer
                                                mov   al, oponentKing
                                                mov   [bx], al
                                                add   bx, 56d
                                                mov   al, pKing
                                                mov   [bx], al

                                                cmp   blackPlayer, 0d
                                                jnz   receive_pos
                                                

                                                call  sendPowerupPos
                                                jmp   init_board_end

    receive_pos:                                
                                                call  receivePowerupPos

    init_board_end:                             
    ;Places the pawns on their initial positions on board, 1 indicates a black pawn and -1 indicates a white pawn.
    ;Pawns fill the second and eighth rows.
                                                mov   bx, offset board + 8
                                                mov   cx, 8

    init_pawns:                                 
                                                mov   al, oponentPawn
                                                mov   [bx], al
                                                add   bx, 40d
                                                mov   al, pPawn
                                                mov   [bx],  al
                                                sub   bx, 39d
                                                loop  init_pawns

                                                ret

init_board endp
    ;Notice: magnitudes of the numeric values assigned to the pieces are ordered in the way that the white_pieces/black_pieces arrays are ordered.
    ;This is intentional, and will allow us to access the array positions easily when mapping the board to a drawing.

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Prepares the video mode for displaying the board. INT 10H with AX = 4F02H was used, which sets a VESA compliant video mode that allows for
    ;higher resolution when compared to the traditional 10H interrupts.
init_video_mode proc

                                                mov   ax, 4F02h
                                                mov   bx, 107h                                       ;Resolution = 1280x1024, with a 256 color palette
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

                                                mov   cx, 0
                                                mov   dx, 0
                                                mov   al, 0fh
                                                mov   ah, 0ch

    draw_label1_y:                              

    draw_label1_x:                              

                                                int   10h
                                                inc   cx
                                                cmp   cx, 475d
                                                jnz   draw_label1_x

                                                inc   dx
                                                mov   cx, 0
                                                cmp   dx, 50d
                                                jnz   draw_label1_y


                                                mov   cx, 476d
                                                mov   dx, 0
                                                mov   al, 00h
                                                mov   ah, 0ch

    draw_label2_y:                              

    draw_label2_x:                              

                                                int   10h
                                                inc   cx
                                                cmp   cx, 950d
                                                jnz   draw_label2_x

                                                inc   dx
                                                mov   cx, 476d
                                                cmp   dx, 50d
                                                jnz   draw_label2_y

cmp blackPlayer,1
jne draw_white_name

                                                mov   ah, 2
                                                mov   bh, 0
                                                mov   dl, 28d
                                                mov   dh, 1d
                                                int   10h

                                                ;mov   ah, 9
                                                ;mov   dx, offset Opponent_Name + 2
                                                ;int   21h

                                                mov   ah, 2
                                                xor   al, al
                                                mov   bh, 0
                                                mov   dl, 89d
                                                mov   dh, 1d
                                                int   10h

                                                mov   ah, 9
                                                mov   dx, offset User_Name + 2
                                                int   21h

                                                jmp end_labels

draw_white_name:

                                                mov   ah, 2
                                                mov   bh, 0
                                                mov   dl, 28d
                                                mov   dh, 1d
                                                int   10h

                                                mov   ah, 9
                                                mov   dx, offset User_Name + 2
                                                int   21h

                                                mov   ah, 2
                                                xor   al, al
                                                mov   bh, 0
                                                mov   dl, 89d
                                                mov   dh, 1d
                                                int   10h

                                                ;mov   ah, 9
                                                ;mov   dx, offset Opponent_Name + 2
                                                ;int   21h

                                                end_labels:

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

                                                mov   al, 13h                                        ;08d light grey, 06d light brown, 0eh light yellow
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

                                                mov   cx, 150d                                       ;margin x - 25
                                                mov   dx, 125d                                       ;margin y - 25
                                                mov   al, 16h                                        ;4 dark brown
                                                mov   ah, 0ch

    border_y:                                   

    border_x:                                   
                                                inc   cx
                                                cmp   dx,151d                                        ;margin y + 1
                                                jb    draw_border
                                                cmp   dx,750d                                        ;margin y + 600
                                                ja    draw_border
                                                cmp   cx,176d                                        ;margin x + 1
                                                jb    draw_border
                                                cmp   cx,775d                                        ;margin x + 600
                                                ja    draw_border
    continue_border:                            
                                                cmp   cx, 800d                                       ;margin x + 600 + border width
                                                jnz   border_x

                                                mov   cx, 150d                                       ;margin x -25
                                                inc   dx
                                                cmp   dx, 775d                                       ;margin y + 600 + border width
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

                                                mov   cx, 0
                                                mov   dx, 850d
                                                mov   al, 0h
                                                mov   ah, 0ch

    draw_status_bar_y:                          

    draw_status_bar_x:                          

                                                int   10h
                                                inc   cx
                                                cmp   cx, 950d
                                                jnz   draw_status_bar_x

                                                inc   dx
                                                mov   cx, 0
                                                cmp   dx, 1024d
                                                jnz   draw_status_bar_y

                                                popa

                                                ret

status_bar endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

update_status proc

                                                pusha

                                                call  status_bar

                                                mov   ah, 2
                                                mov   bh, 0
                                                mov   dl, 40d
                                                mov   dh, 56d
                                                int   10h

                                                cmp   king_in_danger, 1
                                                jz    check

                                                cmp   bx, 0
                                                jz    start_game_status

                                                cmp   bx, 1
                                                jz    cannot_move_piece_status

                                                cmp   bx, 2
                                                jz    end_game_status
                                                
                                                cmp   bx, 3
                                                jz    piece_taken
                                                jmp   end_status

    start_game_status:                          
                                                mov   ah, 9
                                                mov   dx, offset status_1
                                                int   21h
                                                jmp   end_status

    cannot_move_piece_status:                   
                                                mov   ah, 9
                                                mov   dx, offset status_2
                                                int   21h
                                                jmp   end_status

    piece_taken:                                
                                                mov   ah, 9
                                                mov   dx, offset status_5
                                                int   21h
                                                jmp   end_status

    end_game_status:                            
                                                mov   ah, 9
                                                mov   dx, offset status_3
                                                int   21h
                                                jmp   end_status

    check:                                      
                                                mov   ah, 9
                                                mov   dx, offset status_4
                                                int   21h

    end_status:                                 

                                                popa

                                                ret

update_status endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------


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
                                                cmp   si, 8d
                                                jge   checkOutOfBounds_out_of_bounds
                                        
                                                cmp   di, 8d
                                                jge   checkOutOfBounds_out_of_bounds
                                        
                                                cmp   si, -1d
                                                jle   checkOutOfBounds_out_of_bounds
                                        
                                                cmp   di, -1d
                                                jle   checkOutOfBounds_out_of_bounds

                                                jmp   checkOutOfBounds_in_bounds


    checkOutOfBounds_out_of_bounds:             
                                                mov   outOfBound, 1d
                                                ret
    checkOutOfBounds_in_bounds:                 
                                                mov   outOfBound, 0d
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
                                                int   21h
                                                mov   dx, offset error_msg
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

                                                ret

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

                                                mov   ax, di
                                                mul   cell_size
                                                add   ax, margin_y
                                                mov   y_temp, ax

                                                cmp   si, 0
                                                jl    overflow_negative_x
                                                jmp   check_overflow_x

    overflow_negative_x:                        
                                                neg   si
                                                mov   ax, si
                                                mul   cell_size
                                                push  bx
                                                mov   bx, margin_x
                                                sub   bx, ax
                                                mov   ax, bx
                                                pop   bx
                                                sub   ax, 25d
                                                mov   x_temp, ax
                                                jmp   end_overflow_x

    check_overflow_x:                           
                                                cmp   si, 7
                                                ja    overflow_positive_x
                                                mov   ax, si
                                                mul   cell_size
                                                add   ax, margin_x
                                                mov   x_temp, ax
                                                jmp   end_overflow_x

    overflow_positive_x:                        
                                                mov   ax, si
                                                mul   cell_size
                                                add   ax, margin_x
                                                add   ax, 25d
                                                mov   x_temp, ax
                                                jmp   end_overflow_x

    end_overflow_x:                             
                
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
                                                cmp   al, 0ffh                                       ;Do not draw any white pixels, to preserve the background color of the board.
                         
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
                                                call  get_file_handle                                ;Prepare the file handle for other interrupts
                                                call  pass_file_header                               ;Move the file pointer to the starting point of the image
                                                pop   di
                                                pop   si
                                                call  load_piece                                     ;Draw the image at the rows and columns specified by SI and DI.
                                                call  close_file                                     ;Close the file
                         
    finish_draw_piece:                          
                                                popa
                                                ret

draw_piece endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    
draw_jail proc

                                                pusha

                                                mov   ah, 0ch
                                                mov   al, 0d
                                                
                                                mov   cx, si
                                                add   cx, cell_size

                                                mov   dx, di
                                                add   dx, cell_size
                                                mov   bx, dx

                                                
    loop_x_jail:                                
                                                mov   dx, bx
    loop_y_jail:                                
                                                int   10h
                                                dec   dx
                                                cmp   dx, di
                                                jnz   loop_y_jail
                                                sub   cx, 5
                                                cmp   cx, si
                                                jnz   loop_x_jail
                                                
                                                popa
                                                ret

draw_jail endp
    
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

                                                cmp   si, currHoverPos_SI
                                                jnz   draw_cell__check_if_selected_pos

                                                cmp   di, currHoverPos_DI
                                                jnz   draw_cell__check_if_selected_pos

                                                mov   al, hover_cell_color
                                                jmp   draw_cell__continue

    draw_cell__check_if_selected_pos:           
                                                cmp   si, currSelectedPos_SI
                                                jnz   draw_cell__continue
                                                cmp   di, currSelectedPos_DI
                                                jnz   draw_cell__continue
    ; call  draw_border
                                                mov   al, highlighted_cell_color

    draw_cell__continue:                        
                                                 
                                                 

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
                                                mov   cx, si
                                                mov   dx, di
                                                
                                                pop   di
                                                pop   si
                                      
    ;From SI and DI, get the position of the cell we are drawing in board array, which contains the current state of the board.
                                                mov   bx, di

    ;Multiplies by 8, we don't need to move 3 to register first in this assembler. We multiply the row number by 8 since each row has 8 positions.
                                                shl   bx, 3
                                                add   bx, si
                                                mov   al, byte ptr [bx + offset board]

                                                cmp   al, 'p'
                                                jz    draw_powerup

                                                mov   piece_to_draw, al
                                                call  draw_piece

                                                jmp   check_for_jail

    draw_powerup:                               

                                                push  si
                                                push  di

                                                mov   si, dx
                                                mov   di, cx
                                                call  draw_timer_p

                                                pop   di
                                                pop   si

    check_for_jail:                             

    ;If the piece cannot move, draw a jail.
                                                push  si
                                                push  di
                                                cmp   free_pieces[bx], 1
                                                jz    exit_draw_cell
                                                
                                                mov   si, cx
                                                mov   di, dx
                                                call  draw_jail
                                                xchg  si, di

                                                mov   cl, board[bx]
                                                cmp   cl, 0
                                                jl    white_piece_jailed
                                                mov   cx, waitingTime_black
                                                jmp   prepare_timer

    white_piece_jailed:                         
                                                mov   cx, waitingTime_white

    prepare_timer:                              

                                                cmp   cx, 4
                                                je    draw_timer_3secs

    draw_timer_2secs:                           

                                                cmp   time_differences[bx], 1
                                                jz    draw_2

                                                cmp   time_differences[bx], 2
                                                jz    draw_1

                                                jmp   exit_draw_cell

    draw_timer_3secs:                           
                                                cmp   time_differences[bx], 1
                                                jz    draw_3
                                                cmp   time_differences[bx], 2
                                                jz    draw_2
                                                cmp   time_differences[bx], 3
                                                jz    draw_1

                                                jmp   exit_draw_cell

    draw_3:                                     
                                                call  draw_timer_3
                                                jmp   exit_draw_cell
    draw_2:                                     
                                                call  draw_timer_2
                                                jmp   exit_draw_cell

    draw_1:                                     
                                                call  draw_timer_1
    
    exit_draw_cell:                             
    ;Exiting
                                                pop   di
                                                pop   si
                                                pop   dx
                                                pop   cx
                                                pop   bx
                                                pop   ax

                                                ret

draw_cell endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

update_FreePieces proc

                                                pusha
                                                
                                                call  getCurrentTime
                                                mov   bx, 0
                                                mov   cx, 64d
    update_free:                                
                                                call  getPrevTime
                                                call  compareTimes
                                                mov   al, moreThan_WaitingTime
                                                cmp   al, free_pieces[bx]
                                                jnz   change_status
    continue_free_loop:                         
                                                cmp   moreThan_WaitingTime, 1
                                                jz    next_iteration

                                                mov   al, timeDifference
                                                cmp   al, time_differences[bx]
                                                jz    next_iteration
                                                mov   time_differences[bx], al
                                                
                                                push  bx
                                                mov   dl, bl
                                                shr   bl, 3
                                                and   dl, 00000111b
                                                mov   dh, 0
                                                mov   bh, 0

                                                mov   si, dx
                                                mov   di, bx
                                                call  get_cell_colour
                                                call  draw_cell
                                                pop   bx
                                                
    next_iteration:                             
                                                inc   bx
                                                loop  update_free
                                                jmp   end_free_pieces
    change_status:                              
                                                mov   free_pieces[bx], al
    redraw_cell:                                
                                                push  bx
                                                mov   dl, bl
                                                shr   bl, 3
                                                and   dl, 00000111b
                                                mov   dh, 0
                                                mov   bh, 0

                                                mov   si, dx
                                                mov   di, bx
                                                call  get_cell_colour
                                                call  draw_cell
                                                pop   bx
                                                jmp   continue_free_loop

    end_free_pieces:                            
                                                popa
                                                
                                                ret

update_FreePieces endp

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

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ; ZF=1 -> EMPTY CELL | CF=0 -> PLAYER PIECE\EMPTY CELL  |  CF=1 -> ENEMY PIECE
checkForEnemyPiece PROC
                                                push  bx
                                                call  getPos
                                                cmp   board[bx], 0
                                                jz    empty_cell
                                                cmp   board[bx], 'p'
                                                jz    empty_cell

    ; check if the piece is the same color as the player's color
                                                
                                                mov   bl, board[bx]
                                                mov   bh, blackPlayer
                                                not   bh
                                                shl   bh, 7
                                                xor   bl, bh
                                                rcl   bl, 1d                                         ;; moving sign bit to the CF
                                                jmp   checkForEnemyPiece_end

    empty_cell:                                 
                                                clc
                                   
    checkForEnemyPiece_end:                     
                                                pop   bx
                                                ret

checkForEnemyPiece ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

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

                                                pop   bx
                                                ret
writeMove ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Writes possible moves to memory

recordMove proc
                                                push  bx
                                                push  ax
                                                 
                                                call  checkOutOfBounds

                                                cmp   outOfBound, 1d
                                                jz    recordMove_dont_record_move

                                                call  checkForEnemyPiece
                                                jz    record_empty_cell
                                                jc    record_enemy_cell
                                                jmp   recordMove_dont_record_move

    record_empty_cell:                          
                                                mov   al, hover_cell_color
                                                jmp   recordMove_recorded_move
                                                


    record_enemy_cell:                          
                                                mov   al, possible_take_cell_color


    recordMove_recorded_move:                   
                                                call  draw_cell
                                                call  writeMove
                                                inc   currMovePtr
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
                                                cmp   si, oponent_startPos_SI
                                                jnz   removeSelections_preserve_oponent_endpos
                                                 
                                                cmp   di, oponent_startPos_DI
                                                jnz   removeSelections_preserve_oponent_endpos

                                                jmp   removeSelections_preserve_oponent_move
    removeSelections_preserve_oponent_endpos:   
                                                cmp   si, oponent_endPos_SI
                                                jnz   removeSelections_not_prev_enemy_move
                                                 
                                                cmp   di, oponent_endPos_DI
                                                jnz   removeSelections_not_prev_enemy_move
       
    removeSelections_preserve_oponent_move:     
                                                mov   al, oponent_move_color
                                                jmp   removeSelections_redraw


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

                                                mov   currHoverPos_SI, si
                                                mov   currHoverPos_DI, di

                                                mov   currSelectedPos_DI, -1d
                                                mov   currSelectedPos_SI, -1d
                                                
                                                mov   al, hover_cell_color
                                                call  draw_cell


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
                                                cmp   si, oponent_startPos_SI
                                                jnz   hover_preserve_oponent_endpos
                                                 
                                                cmp   di, oponent_startPos_DI
                                                jnz   hover_preserve_oponent_endpos

                                                jmp   hover_preserve_oponent_move
    hover_preserve_oponent_endpos:              
                                                cmp   si, oponent_endPos_SI
                                                jnz   hover_not_prev_enemy_move
                                                 
                                                cmp   di, oponent_endPos_DI
                                                jnz   hover_not_prev_enemy_move
       
    hover_preserve_oponent_move:                
                                                mov   al, oponent_move_color
                                                jmp   hover_redraw_prev_cell

    hover_not_prev_enemy_move:                  
                                                call  get_cell_colour
    hover_redraw_prev_cell:                     
                                                mov   currHoverPos_SI, -1d
                                                mov   currHoverPos_DI, -1d
                                                call  draw_cell

    ; Draw hover cell
                                                pop   di
                                                pop   si
                                                mov   al, hover_cell_color
                                                call  draw_cell
                                                mov   currHoverPos_SI, si
                                                mov   currHoverPos_DI, di

    dont_move:                                  
                                                pop   dx
                                                pop   cx

                                                ret

hover endp

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

                                                mov   directionPtr, 0d
                                                mov   currMovePtr, 1d

    ; ; checking if piece is white or black
    ;                                             cmp   walker, -1d
    ;                                             jz    getPawnMoves_start_white
    ;                                             jmp   getPawnMoves_start_black

                
    ;; if this is the first move, check for 2 possible moves
    getPawnMoves_start_white:                   
                                                cmp   di, 6d                                         ; di=6 means that the white pawn did not move yet
                                                jnz   getPawnMoves_not_first_move
                                                jmp   getPawnMoves_first_move
                                                
    getPawnMoves_first_move:                    
                                                mov   cx, 2d
                                                jmp   getPawnMoves_l1

    getPawnMoves_not_first_move:                
                                                mov   cx, 1d

    getPawnMoves_l1:                            
                                                add   di, walker
                                                 
    ;; we stop moving forward when we encounter a non-empty cell
    ;; for the pawn, no moves can be done in the forward direction if any piece is there
                                                call  checkForEnemyPiece
                                                jnz   getPawnMoves_check_for_takes
                                                 
    ; otherwise record the move
                                                call  recordMove

    ;; recordMove sets the flag outOfBound if move is beyond the board's frame
                                                cmp   outOfBound, 1d
                                                jz    getPawnMoves_check_for_takes

                                                loop  getPawnMoves_l1
                                                 
    getPawnMoves_check_for_takes:               
    ; resetting si and di
                                                pop   di
                                                pop   si
                                                push  si
                                                push  di

                                                mov   directionPtr, 1d
                                                mov   currMovePtr, 1d

                                                add   di, walker
                                                add   si, 1d

    ;; only record the move if there is an enemy piece
                                                call  checkForEnemyPiece                             ;;sets the carry flag if there is an enemy piece
                                                jnc   getPawnMoves_check_for_take2

                                                call  recordMove

    getPawnMoves_check_for_take2:               
                                                sub   si, 2d
                                                mov   directionPtr, 7d
                                                mov   currMovePtr, 1d
    ;; same as above, recording only happens if there is an enemy piece
                                                call  checkForEnemyPiece
                                                jnc   get_pawn_moves_end

                                                call  recordMove

    get_pawn_moves_end:                         
                                                pop   di
                                                pop   si
                                                pop   cx

                                                ret

getPawnMoves endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

getKnightMoves PROC
                                                push  si
                                                push  di

                                                mov   directionPtr, 0d


                                                add   si, 1d
                                                add   di, -2d
                                                mov   currMovePtr, 1d

                                                call  recordMove

                                                add   si, 1d
                                                add   di, 1d
                                                mov   currMovePtr, 1d
                                                inc   directionPtr

                                                call  recordMove

                
                                                add   di, 2d
                                                mov   currMovePtr, 1d
                                                inc   directionPtr

                                                call  recordMove
                
                                                add   si, -1d
                                                add   di, 1d
                                                mov   currMovePtr, 1d
                                                inc   directionPtr

                                                call  recordMove
                
                                                add   si, -2d
                                                mov   currMovePtr, 1d
                                                inc   directionPtr

                                                call  recordMove

                
                                                add   si, -1d
                                                add   di, -1d
                                                mov   currMovePtr, 1d
                                                inc   directionPtr

                                                call  recordMove

                
                                                add   di, -2d
                                                mov   currMovePtr, 1d
                                                inc   directionPtr

                                                call  recordMove
                
                                                add   si, 1d
                                                add   di, -1d
                                                mov   currMovePtr, 1d
                                                inc   directionPtr

                                                call  recordMove

                
    getKnightMoves_end:                         
                                                pop   di
                                                pop   si

                                                ret
getKnightMoves ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

getPossibleDiagonalMoves PROC
                                                push  dx
                                                push  bp
                                                push  cx
                                                push  ax
                                                push  si
                                                push  di

                                                mov   ch, 2                                          ;; no of times we will neg si

                                                mov   dx, 1d                                         ;; step for si
                                                mov   bp, -1d                                        ;; step for di

                                                 
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
                                                cmp   outOfBound, 1d
                                                jz    getPossibleDiagonalMoves_l2_break
                                                 
                                                call  checkForEnemyPiece
                                                jz    getPossibleDiagonalMoves_l2

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

    ;---------------------------------------------------------------------------------------------------------------------------------------------

getPossibleVerticalHorizontalMoves PROC

                                                push  dx
                                                push  bp
                                                push  cx
                                                push  ax
                                                push  si
                                                push  di

                                                mov   ch, 2                                          ;; no of times we will neg si

                                                mov   dx, 0d                                         ;; step for si
                                                mov   bp, -1d                                        ;; step for di

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
                                                cmp   outOfBound, 1d
                                                jz    getPossibleVerticalHorizontalMoves_l2_break
                                                 
                                                call  checkForEnemyPiece
                                                jz    getPossibleVerticalHorizontalMoves_l2

    ;
    getPossibleVerticalHorizontalMoves_l2_break:
                                                add   directionPtr, 2d
                                                mov   currMovePtr, 1d

                                                mov   si, currSelectedPos_SI
                                                mov   di, currSelectedPos_DI
                                                 
    ;; rotating 90 degrees clockwise
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
        
    ;---------------------------------------------------------------------------------------------------------------------------------------------

getQueenMoves PROC

                                                call  getPossibleVerticalHorizontalMoves
                                                call  getPossibleDiagonalMoves

                                                ret
    
getQueenMoves ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

getKingMoves PROC
            
                                                push  si
                                                push  di

                                                mov   directionPtr, 0d
            

                                                dec   di
                                                mov   currMovePtr, 1d
                                                call  recordMove

                                                inc   si
                                                inc   directionPtr
                                                mov   currMovePtr, 1d
                                                call  recordMove

                                                inc   di
                                                inc   directionPtr
                                                mov   currMovePtr, 1d
                                                call  recordMove

                                                inc   di
                                                inc   directionPtr
                                                mov   currMovePtr, 1d
                                                call  recordMove

                                                dec   si
                                                inc   directionPtr
                                                mov   currMovePtr, 1d
                                                call  recordMove
                
                                                dec   si
                                                inc   directionPtr
                                                mov   currMovePtr, 1d
                                                call  recordMove

                                                dec   di
                                                inc   directionPtr
                                                mov   currMovePtr, 1d
                                                call  recordMove
            
                                                dec   di
                                                inc   directionPtr
                                                mov   currMovePtr, 1d
                                                call  recordMove

            
            
    getKingMoves_end:                           
                                                pop   di
                                                pop   si
            

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
                                                mov   dx, 3FBh
                                                mov   al, 10000000b
                                                out   dx, al


    ;; baud rate
    ;LSB
                                                mov   dx, 3F8h
                                                mov   al, 0Ch
                                                out   dx, al
    
    ;MSB
                                                mov   dx, 3F9h
                                                mov   al, 00h
                                                out   dx, al

    ;;; rest of configuration
                                                mov   dx, 3FBh
                                                mov   al, 00011011b
                                                out   dx, al

                                                ret

initPort ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

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
                                                jmp   far ptr changeSelection                        ; jump is far down

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
                                   
    goToNextSelection_redraw:                   call  draw_cell

   
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

    ;---------------------------------------------------------------------------------------------------------------------------------------------

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

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;; will be called in 2 cases:
    ; 1) Oponent Makes a move
    ; 2) We make a move to one of the colored oponent cells
removePrevOponentMove PROC
                                                push  ax
                                                push  si
                                                push  di
                                                push  dx

                                                cmp   oponent_endPos_DI, -1d
                                                jz    removePrevOponentMove_end

                                                mov   si, oponent_startPos_SI
                                                mov   di, oponent_startPos_DI
                                                call  get_cell_colour
                                                call  draw_cell

                                                mov   si, oponent_endPos_SI
                                                mov   di, oponent_endPos_DI
                                                call  get_cell_colour
                                                call  draw_cell

                                                mov   oponent_startPos_DI, -1d
                                                mov   oponent_startPos_SI, -1d
                                                mov   oponent_endPos_DI, -1d
                                                mov   oponent_endPos_SI, -1d


    removePrevOponentMove_end:                  

                                                pop   dx
                                                pop   di
                                                pop   si
                                                pop   ax
                                                ret
    
removePrevOponentMove ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

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
                                                                                                    
                                                mov   si, currSelectedPos_SI
                                                mov   di, currSelectedPos_DI
                                                
                                                call  getPos

                                                cmp   free_pieces[bx], 1
                                                jnz   movePiece_end

                                                call  updateMovementTimes
    ; checking if a piece is in nextPos
    ; Cl contains the piece we want to move
                                                mov   cl, board[bx]
                                                mov   byte ptr board[bx], 0d                         ; removing the piece from its currentPos on the board

                                                mov   bp, bx

                                                mov   bx, dx
                                                mov   al, board[bx]
                                                cmp   al, 0d                                         ; checking if the player has taken a piece
                                                jz    conitnue_movePiece

                                                cmp   al, 'p'
                                                jz    activate_powerup

                                                cmp   al, oponentKing
                                                jnz   movePiece_capture_piece
                                                 
                                                mov   killedOpKing, 1


    movePiece_capture_piece:                    
    ;;; logic for if piece exists (displaying it next to board)
                                                mov   current_captured_piece, al
                                                call  draw_captured_piece
                                                jmp   conitnue_movePiece

    activate_powerup:                           
                                                cmp   cl, 0
                                                jl    white_powerup

                                                dec   waitingTime_black

                                                jmp   conitnue_movePiece

    white_powerup:                              
                                                dec   waitingTime_white


    conitnue_movePiece:                         
    ;; preparing to write in nextPos
                                                call  removeSelections
                                                mov   bx, dx
                                                mov   board[bx], cl
                                                
                                                mov   currHoverPos_SI, -1d
                                                mov   currHoverPos_DI, -1d

                                                call  get_cell_colour
                                                call  draw_cell

    movePiece_end:                              
    ;; returning original values to the used registers

    ;preserving start pos of our move
                                                mov   startPos_DI, di
                                                mov   startPos_SI, si

    ;popping out the new pos (our end pos)
                                                pop   si
                                                pop   di
                                                pop   bx
                                                pop   dx
    ;check to update king's position
                                                cmp   cl, pKing
                                                jnz   NotKing
                                                mov   Kingpos_si,si
                                                mov   Kingpos_di,di
                                                mov   king_in_danger, 0d
                                                call  update_status

    ; push  dx
    ; push  ax
    ; mov   dl, 's'
    ; mov   ah, 2
    ; int   21h
    ; pop   ax
    ; pop   dx
    ; push dx
    ; push ax
    ; mov dl, king_in_danger
    ; mov ah, 2
    ; int 21h
    ; pop ax
    ; pop dx
                                                

    ; checking if we can move the piece
    NotKing:                                    cmp   free_pieces[bx], 1
                                                jnz   not_yet

    ;preserving new pos (our end pos)
                                                mov   endPos_SI, si
                                                mov   endPos_DI, di

                                                mov   currHoverPos_SI, si
                                                mov   currHoverPos_DI, di

                                                ; mov   al, hover_cell_color
                                                call  draw_cell

                                                call  status_bar
    
    ;; removing the oponent's previously colored moves (if it is overwritten)
    movePiece_remove_oponent_startpos:          
                                                cmp   si, oponent_startPos_SI
                                                jnz   movePiece_remove_oponent_endpos
                                                 
                                                cmp   di, oponent_startPos_DI
                                                jnz   movePiece_remove_oponent_endpos

                                                jmp   movePiece_remove_oponent_move
    movePiece_remove_oponent_endpos:            
                                                cmp   si, oponent_endPos_SI
                                                jnz   movePiece_not_prev_enemy_move
                                                 
                                                cmp   di, oponent_endPos_DI
                                                jnz   movePiece_not_prev_enemy_move
       
    movePiece_remove_oponent_move:              
                                                call  removePrevOponentMove

    movePiece_not_prev_enemy_move:              
                                                mov   currSelectedPos_DI, -1d
                                                mov   currSelectedPos_SI, -1d

                                                mov   currHoverPos_SI, si
                                                mov   currHoverPos_DI, di

                                                mov   startSending, 1d
                                                 
                                                ret
    not_yet:                                    
    ;; TODO: add status bar message (cannot move this piece yet)

                                                push  bx
                                                mov   bx, 1
                                                call  update_status
                                                pop   bx
                                                ret
movePiece ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;Procedures for check

    ;description
    ;description
resetCheckFlags PROC
                                                mov   checked_up, 0d
                                                mov   checked_down, 0d
                                                mov   checked_left, 0d
                                                mov   checked_right, 0d
                                                mov   checked_upright, 0d
                                                mov   checked_upleft, 0d
                                                mov   checked_downright, 0d
                                                mov   checked_downleft, 0d

                                                ret
resetCheckFlags ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

reInitializeFlags PROC
                                                cmp   checked_up, 0
                                                jz    reInitializeFlags_end
                    
                                                cmp   checked_down, 0
                                                jz    reInitializeFlags_end

                                                cmp   checked_left, 0
                                                jz    reInitializeFlags_end

                                                cmp   checked_right, 0
                                                jz    reInitializeFlags_end

    ; cmp checked_upright, 0
    ; jz  reInitializeFlags_end

    ; cmp checked_upleft, 0
    ; jz  reInitializeFlags_end

    ; cmp checked_downright, 0
    ; jz  reInitializeFlags_end


                                                call  resetCheckFlags

    reInitializeFlags_end:                      
                                                ret
reInitializeFlags ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

MOVE_CURSOR PROC
    
                                                MOV   AH,3H
                                                MOV   BH,0
                                                INT   10H

                                                inc   cx
                                                MOV   AH,2
                                                INT   10H

                                                RET
MOVE_CURSOR ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;debugging purposes
print PROC
                                                push  ax
                                                push  dx
                                                push  bx

                                                mov   dl, '1'
                                                mov   ah, 2
                                                int   21h

                                                call  MOVE_CURSOR

                                                push  bx
                                                pop   dx
                                                pop   ax

                                                ret
print ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

check_king_vertical proc

                                                pusha

                                                cmp   king_in_danger, 1d
                                                jnz   check_king_vertical_continue0

                                                jmp   far ptr check_king_vertical_end
    check_king_vertical_continue0:              
                                                mov   si, Kingpos_si
                                                mov   di, Kingpos_di

                                                cmp   checked_up, 1d
                                                jnz   vertical_up
                                                cmp   checked_down,1d
                                                jz    check_king_vertical_continue1
                                                jmp   far ptr vertical_down

    vertical_up:                                
                                                cmp   di,0d
                                                jz    end_vertical_up
                                                dec   di
                                                call  getpos
                                                cmp   board[bx],0d
                                                jz    vertical_up
                                                mov   cl,board[bx]                                   ;cl contains the piece in front of the king we've to check if its same color or not and if not check type to see if it can kill the king
                                                cmp   cl,0d
                                                jb    end_vertical_up                                ;if cl contains negative then its a white piece so king is safe from vertical up
    ;we've to check if the enemy piece is blck rook,black queen or black king with max distance 2
                                                cmp   cl, oponentRook
                                                jz    AlertPlayer
                                                cmp   cl, oponentQueen
                                                jz    AlertPlayer
                                                cmp   cl, oponentKing
                                                jnz   end_vertical_up
                                                mov   ax, Kingpos_di
                                                sub   ax, di
                                                cmp   ax,1d
                                                jbe   AlertPlayer
                                                
    end_vertical_up:                            

                                                mov   di,Kingpos_di
                                                mov   checked_up, 1d
                                                popa
                                                ret
    check_king_vertical_continue1:              
                                                jmp   check_king_vertical_end
                                                  
    vertical_down:                              
                                                cmp   di,7d
                                                jz    end_vertical_down
                                                inc   di
                                                call  getpos
                                                cmp   board[bx],0d
                                                jz    vertical_down
                                                mov   cl,board[bx]                                   ;cl contains the piece behind of the king we've to check if its same color or not and if not check type to see if it can kill the king
                                                cmp   cl,0d
                                                jb    end_vertical_down                              ;if cl contains negative then its a white piece so king is safe from vertical down
    ;we've to check if the enemy piece is black rook,black queen or black king with max distance 2
                                                cmp   cl, oponentRook
                                                jz    AlertPlayer
                                                cmp   cl, oponentQueen
                                                jz    AlertPlayer
                                                cmp   cl, oponentKing
                                                jnz   end_vertical_down
                                                mov   ax, di
                                                sub   ax, Kingpos_di
                                                cmp   ax, 1d
                                                jbe   AlertPlayer
                                                

    end_vertical_down:                          
                                                mov   checked_down, 1d
    ; call resetCheckFlags
                                                popa
                                                ret


    AlertPlayer:                                
    ; call print

                                                call  resetCheckFlags

                                                mov   oponent_checkpos_DI, di
                                                mov   oponent_checkpos_SI, si

                                                mov   king_in_danger, 1d
                                                call  update_status
    ; push  dx
    ; push  ax
    ; mov   dl, king_in_danger
    ; mov   ah, 2
    ; int   21h
    ; pop   ax
    ; pop   dx
    ;display message
    check_king_vertical_end:                    
                                                popa


                                                ret
check_king_vertical ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

check_king_horizontal proc

                                                pusha

                                                cmp   king_in_danger, 1d
                                                jnz   check_king_horizontal_continue0

                                                jmp   far ptr check_king_horizontal_end
    check_king_horizontal_continue0:            
                                                mov   si, Kingpos_si
                                                mov   di, Kingpos_di

                                                cmp   checked_down, 1d
                                                jz    check_king_horizontal_continue2
    ; call print
                                                jmp   far ptr check_king_horizontal_end

    ;check_king_horizontal_continue1:
    ; cmp checked_down, 0d
    ; jnz check_king_horizontal_continue2
    ; jmp far ptr check_king_horizontal_end

    check_king_horizontal_continue2:            
                                                cmp   checked_left, 1d
                                                jnz   horizontal_left
                                                cmp   checked_right,1d
                                                jz    check_king_horizontal_continue3
                                                jmp   far ptr horizontal_right

    horizontal_left:                            
    ; call print
                                                cmp   si,0d
                                                jz    end_horizontal_left
                                                dec   si
                                                call  getpos
                                                cmp   board[bx],0d
                                                jz    horizontal_left
                                                mov   cl,board[bx]                                   ;cl contains the piece left to the king we've to check if its same color or not and if not check type to see if it can kill the king
                                                cmp   cl,0d
                                                jb    end_horizontal_left                            ;if cl contains negative then its a white piece so king is safe from horizontal left
    ;we've to check if the enemy piece is blck rook,black queen or black king with max distance 2
                                                cmp   cl, oponentRook
                                                jz    AlertPlayerH
                                                cmp   cl, oponentQueen
                                                jz    AlertPlayerH
                                                cmp   cl, oponentKing
                                                jnz   end_horizontal_left
                                                mov   ax, Kingpos_si
                                                sub   ax, si
                                                cmp   ax,1d
                                                jbe   AlertPlayerH
                                                
                                                


    end_horizontal_left:                        
    ; mov   si,Kingpos_si
                                                mov   checked_left, 1d
                                                popa
                                                ret
    check_king_horizontal_continue3:            

                                                jmp   check_king_horizontal_end
    horizontal_right:                           
    ; call print
                                                cmp   si,7d
                                                jz    end_horizontal_right
                                                inc   si
                                                call  getpos
                                                cmp   board[bx],0d
                                                jz    horizontal_right
                                                mov   cl,board[bx]                                   ;cl contains the piece right to the king we've to check if its same color or not and if not check type to see if it can kill the king
                                                cmp   cl,0d
                                                jb    end_horizontal_right                           ;if cl contains negative then its a white piece so king is safe from horizontal right
    ;we've to check if the enemy piece is black rook,black queen or black king with max distance 2
                                                cmp   cl, oponentRook
                                                jz    AlertPlayerH
                                                cmp   cl, oponentQueen
                                                jz    AlertPlayerH
                                                cmp   cl, oponentKing
                                                jnz   end_horizontal_right
                                                mov   ax, si
                                                sub   ax, Kingpos_si
                                                cmp   ax,1d
                                                jbe   AlertPlayerH
                                                


    end_horizontal_right:                       
                                                mov   checked_right, 1d
    ; call resetCheckFlags
                                                popa
                                                ret


    AlertPlayerH:                               
    ; call print
                                                call  resetCheckFlags
                                                mov   king_in_danger, 1d
                                                call  update_status

                                                mov   oponent_checkpos_DI, di
                                                mov   oponent_checkpos_SI, si

    ; push  dx
    ; push  ax
    ; mov   dl, king_in_danger
    ; mov   ah, 2
    ; int   21h
    ; pop   ax
    ; pop   dx
    ;display message
    check_king_horizontal_end:                  
                                                popa
                                                
                                                ret


check_king_horizontal ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

check_up_diagonals PROC
                                                push  ax
                                                push  bx
                                                push  cx
                                                push  dx
                                                push  si
                                                push  di

                                                cmp   king_in_danger, 1d
                                                jnz   check_up_diagonals_continue0

                                                jmp   far ptr check_up_diagonals_end

    check_up_diagonals_continue0:               
                                                mov   si, Kingpos_si
                                                mov   di, Kingpos_di
    ;                                                 cmp checked_left, 1d
    ;                                                 jz  check_up_diagonals_continue
    ;                                                 jmp far ptr check_up_diagonals_end
    ; check_up_diagonals_continue1:
                                                cmp   checked_right, 1d
                                                jz    check_up_diagonals_continue1
                                                jmp   far ptr check_up_diagonals_end
    check_up_diagonals_continue1:               
                                                cmp   checked_upright, 1d
                                                jnz   check_upright

                                                cmp   checked_upleft, 1d
                                                jnz   check_upleft

                                                jmp   far ptr check_up_diagonals_end


    check_upright:                              cmp   si, 7d
                                                jz    check_upright_end
                                                cmp   di, 0d
                                                jz    check_upright_end

                                                inc   si
                                                dec   di
                                                call  getPos

                                                mov   cl, board[bx]
                                                cmp   cl,0
                                                jz    check_upright

                                                cmp   cl, 0
                                                jb    check_upright_end

                                                cmp   cl, oponentBishop
                                                jnz   check_up_diagonals_continue3
                                                jmp   far ptr check_updiagonals_Alert
    check_up_diagonals_continue3:               
                                                cmp   cl, oponentQueen
                                                jnz   check_up_diagonals_continue4
                                                jmp   check_updiagonals_Alert
    check_up_diagonals_continue4:               
                                                cmp   cl, oponentPawn
                                                jnz   check_up_diagonals_king0
                                                jmp   check_up_diagonals_pawn0

    check_up_diagonals_king0:                   
                                                cmp   cl, oponentKing
                                                jnz   check_upright_end
    check_up_diagonals_pawn0:                   
                                                mov   ax, si
                                                sub   ax, Kingpos_si
                                                cmp   ax, 1d
                                                jnz   check_upright_end

                                                mov   ax, Kingpos_di
                                                sub   ax, di
                                                cmp   ax, 1d
                                                jnz   check_upright_end

                                                jmp   check_updiagonals_Alert

    check_upright_end:                          
                                                mov   checked_upright, 1d
                                                jmp   check_up_diagonals_end



    check_upleft:                               
                                                cmp   si, 0d
                                                jz    check_upleft_end
                                                cmp   di, 0d
                                                jz    check_upleft_end

                                                dec   si
                                                dec   di
                                                call  getPos

                                                mov   cl, board[bx]
                                                cmp   cl,0
                                                jz    check_upleft

                                                cmp   cl, 0
                                                jb    check_upleft_end

                                                cmp   cl, oponentBishop
                                                jz    check_updiagonals_Alert

                                                cmp   cl, oponentQueen
                                                jz    check_updiagonals_Alert

                                                cmp   cl, oponentPawn
                                                jnz   check_up_diagonals_king
                                                jmp   check_up_diagonals_pawn

    check_up_diagonals_king:                    
                                                cmp   cl, oponentKing
                                                jnz   check_upleft_end
    check_up_diagonals_pawn:                    
                                                mov   ax, Kingpos_si
                                                sub   ax, si
                                                cmp   ax, 1d
                                                jnz   check_upleft_end

                                                mov   ax, Kingpos_di
                                                sub   ax, di
                                                cmp   ax, 1d
                                                jnz   check_upleft_end

                                                jmp   check_updiagonals_Alert

    check_upleft_end:                           
                                                mov   checked_upleft, 1d
    ; call resetCheckFlags
                                                jmp   check_up_diagonals_end

    check_updiagonals_Alert:                    
                                                call  resetCheckFlags
                                                mov   king_in_danger, 1d
                                                call  update_status
                                                mov   oponent_checkpos_DI, di
                                                mov   oponent_checkpos_SI, si
    ; push  dx
    ; push  ax
    ; mov   dl, king_in_danger
    ; mov   ah, 2
    ; int   21h
    ; pop   ax
    ; pop   dx
    check_up_diagonals_end:                     
                                                pop   di
                                                pop   si
                                                pop   dx
                                                pop   cx
                                                pop   bx
                                                pop   ax

                                                ret
check_up_diagonals ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

check_down_diagonals PROC
                                                push  ax
                                                push  bx
                                                push  cx
                                                push  dx
                                                push  si
                                                push  di

                                                cmp   king_in_danger, 1d
                                                jnz   check_down_diagonals_continue0

                                                jmp   far ptr check_down_diagonals_end

    check_down_diagonals_continue0:             
                                                mov   si, Kingpos_si
                                                mov   di, Kingpos_di

                                                cmp   checked_upleft, 1d
                                                jz    check_down_diagonals_continue1
                                                jmp   far ptr check_down_diagonals_end
    check_down_diagonals_continue1:             
                                                cmp   checked_downright, 1d
                                                jnz   check_downright

                                                cmp   checked_downleft,1d
                                                jz    check_down_diagonals_continue5
                                                jmp   far ptr check_downleft


    check_downright:                            cmp   si, 7d
                                                jz    check_downright_end
                                                cmp   di, 7d
                                                jz    check_downright_end

                                                inc   si
                                                inc   di
                                                call  getPos

                                                mov   cl, board[bx]
                                                cmp   cl,0
                                                jz    check_downright

                                                cmp   cl, 0
                                                jb    check_downright_end

                                                cmp   cl, oponentBishop
                                                jnz   check_down_diagonals_continue3
                                                jmp   far ptr check_downdiagonals_Alert
    check_down_diagonals_continue3:             
                                                cmp   cl, oponentQueen
                                                jnz   check_down_diagonals_continue4
                                                jmp   check_downdiagonals_Alert
    check_down_diagonals_continue4:             
                                                
                                                cmp   cl, oponentKing
                                                jnz   check_downright_end

                                                mov   ax, si
                                                sub   ax, Kingpos_si
                                                cmp   ax, 1d
                                                jnz   check_downright_end

                                                mov   ax, di
                                                sub   ax, Kingpos_di
                                                cmp   ax, 1d
                                                jnz   check_downright_end

                                                jmp   check_downdiagonals_Alert

    check_downright_end:                        
                                                mov   checked_downright, 1d
                                                jmp   check_down_diagonals_end

    check_down_diagonals_continue5:             
                                                jmp   check_down_diagonals_end



    check_downleft:                             
                                                cmp   si, 0d
                                                jz    check_downleft_end
                                                cmp   di, 7d
                                                jz    check_downleft_end

                                                dec   si
                                                inc   di
                                                call  getPos

                                                mov   cl, board[bx]
                                                cmp   cl,0
                                                jz    check_downleft

                                                cmp   cl, 0
                                                jb    check_downleft_end

                                                cmp   cl, oponentBishop
                                                jz    check_downdiagonals_Alert

                                                cmp   cl, oponentQueen
                                                jz    check_downdiagonals_Alert

                                                cmp   cl, oponentKing
                                                jnz   check_downleft_end

                                                mov   ax, Kingpos_si
                                                sub   ax, si
                                                cmp   ax, 1d
                                                jnz   check_downleft_end

                                                mov   ax, di
                                                sub   ax, Kingpos_di
                                                cmp   ax, 1d
                                                jnz   check_downleft_end

                                                jmp   check_downdiagonals_Alert

    check_downleft_end:                         
                                                mov   checked_downleft, 1d
    ; call resetCheckFlags
                                                jmp   check_down_diagonals_end

    check_downdiagonals_Alert:                  
                                                call  resetCheckFlags
                                                mov   king_in_danger, 1d
                                                call  update_status
                                                mov   oponent_checkpos_DI, di
                                                mov   oponent_checkpos_SI, si
    ; push  dx
    ; push  ax
    ; mov   dl, king_in_danger
    ; mov   ah, 2
    ; int   21h
    ; pop   ax
    ; pop   dx
    check_down_diagonals_end:                   
                                                pop   di
                                                pop   si
                                                pop   dx
                                                pop   cx
                                                pop   bx
                                                pop   ax

                                                ret
check_down_diagonals ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

check_knight PROC
                                                push  ax
                                                push  bx
                                                push  si
                                                push  di

                                                mov   al, oponentKnight


                                                cmp   king_in_danger, 1d
                                                jnz   check_knight_continue_func

                                                jmp   far ptr check_knight_end

    check_knight_continue_func:                 
                                                cmp   checked_downleft, 1d
                                                jz    check_knight_continue_func2

                                                jmp   far ptr check_knight_end

    check_knight_continue_func2:                
                                                mov   si, Kingpos_si
                                                mov   di, Kingpos_di


                                                add   si, 1d
                                                add   di, -2d

                                                call  getPos
                                                cmp   board[bx], al
                                                jnz   check_knight_continue0
                                                jmp   far ptr check_knight_Alert

    check_knight_continue0:                     
                                                add   si, 1d
                                                add   di, 1d

                                                call  getPos
                                                cmp   board[bx], al
                                                jnz   check_knight_continue1
                                                jmp   far ptr check_knight_Alert

    check_knight_continue1:                     
                
                                                add   di, 2d
                                                
                                                call  getPos
                                                cmp   board[bx], al
                                                jnz   check_knight_continue2
                                                jmp   far ptr check_knight_Alert

    check_knight_continue2:                     
                
                                                add   si, -1d
                                                add   di, 1d
                                                
                                                call  getPos
                                                cmp   board[bx], al
                                                jnz   check_knight_continue3
                                                jmp   far ptr check_knight_Alert

    check_knight_continue3:                     
                
                                                add   si, -2d
                                                
                                                call  getPos
                                                cmp   board[bx], al
                                                jnz   check_knight_continue4
                                                jmp   far ptr check_knight_Alert

    check_knight_continue4:                     

                
                                                add   si, -1d
                                                add   di, -1d
                                                
                                                call  getPos
                                                cmp   board[bx], al
                                                jnz   check_knight_continue5
                                                jmp   far ptr check_knight_Alert

    check_knight_continue5:                     

                
                                                add   di, -2d
                                                
                                                call  getPos
                                                cmp   board[bx], al
                                                jnz   check_knight_continue6
                                                jmp   far ptr check_knight_Alert

    check_knight_continue6:                     
                
                                                add   si, 1d
                                                add   di, -1d
                                                
                                                call  getPos
                                                cmp   board[bx], al
                                                jnz   check_knight_not_found
                                                jmp   far ptr check_knight_Alert

    check_knight_not_found:                     
                                                call  resetCheckFlags
                                                jmp   check_knight_end
                                            

    check_knight_Alert:                         
                                                call  resetCheckFlags
                                                mov   king_in_danger, 1d
                                                call  update_status
                                                mov   oponent_checkpos_DI, di
                                                mov   oponent_checkpos_SI, si
    ; push  dx
    ; push  ax
    ; mov   dl, king_in_danger
    ; mov   ah, 2
    ; int   21h
    ; pop   ax
    ; pop   dx
                                                
                
    check_knight_end:                           
    ; call resetCheckFlags
                                                pop   di
                                                pop   si
                                                pop   bx
                                                pop   ax

                                                ret
           
check_knight ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

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
                                                mov   currHoverPos_SI,  -1d
                                                mov   currHoverPos_DI,  -1d
                                                mov   currSelectedPos_SI, si
                                                mov   currSelectedPos_DI, di

    getPlayerSelection_no_selection_end:        
                                                ret

getPlayerSelection ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

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


                                                cmp   blackPlayer, 0
                                                jz    moveInSelections_white_player
                                                jmp   moveInSelections_black_player

    moveInSelections_white_player:              
                                                cmp   board[bx], 0d
                                                jl    moveInSelections_continue
                                                mov   currSelectedPos_DI, -1d
                                                mov   currSelectedPos_DI, -1d
                                                ret

    moveInSelections_black_player:              
                                                cmp   board[bx], 0d
                                                jg    moveInSelections_continue
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
                                    
    ; cmp   ah, 0
    ; jl    white_piece
    ; mov   walker, 1d
    ; neg   ah
    ; jmp   determine_piece_type

    white_piece:                                mov   walker, -1d
                                   
    determine_piece_type:                       
                                                cmp   ah, pPawn
                                                jz    pawn

                                                cmp   ah, pKnight
                                                jz    knight
                                   
                                                cmp   ah, pBishop
                                                jz    bishop

                                                cmp   ah, pRook
                                                jz    rook

                                                cmp   ah, pQueen
                                                jz    queen

                                                cmp   ah, pKing
                                                jz    king

                                                jmp   start_selection
                          

    pawn:                                       
                                                call  getPawnMoves
                                                jmp   start_selection

    knight:                                     
                                                call  getKnightMoves
                                                jmp   start_selection
    bishop:                                     
                                                call  getPossibleDiagonalMoves
                                                jmp   start_selection

    rook:                                       call  getPossibleVerticalHorizontalMoves
                                                jmp   start_selection

    queen:                                      
                                                call  getQueenMoves
                                                jmp   start_selection

    king:                                       
                                                call  getKingMoves
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

    ;; Data Format AL = D_00_I_SI  where di and si are 3 bits
    ; compresses the data in DI,SI to AL
compressData PROC

                                                mov   bx, di                                         ;; di is in bl
                                                mov   ax, si                                         ;;  si is in al

                                                push  cx

                                                mov   cx, 7d
                                                sub   cx, bx
                                                xchg  bx,cx

                                                mov   cx, 7d
                                                sub   cx, ax
                                                xchg  ax,cx

                                                pop   cx
                            

                                                shl   al, 5
                                                mov   ah, bl
                                                shr   ax, 1
                                                shl   ah, 2

                                                shr   ax, 4

                            
                                                ret
compressData ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

deCompressData PROC
                                                push  ax
                                                push  bx
                                                mov   bh, 0d
                            
    ;; getting di
                                                mov   ah, 0d
                                                shl   ax, 2d
                                                shl   al, 2d
                                                shl   ax, 1
                                                mov   bl, ah
                                                mov   di, bx
                            
    ;; getting si
                                                shr   al, 5
                                                mov   bl, al
                                                mov   si, bx

                                                pop   bx
                                                pop   ax
                                                
                                                ret
deCompressData ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

sendMoveToOponent PROC
                                                push  ax
                                                push  bx
                                                push  dx

                                                cmp   startSending, 0d
                                                jz    sendMoveToOponent_end

    ;; check if THR is empty
                                                mov   dx, 3FDh
                                                In    al, dx
                                                and   al, 00100000b
                                                jz    sendMoveToOponent_end


    ;; check if start pos has already been sent
                                                cmp   startPosSent, 1d
                                                jz    sendMoveToOponent_send_endpos

    ; push dx
    ; push ax
    ; mov dl, 'h'
    ; mov ah, 2
    ; int 21h
    ; pop ax
    ; pop dx
                            
                                                mov   dx, 3F8h
                                                mov   si, startPos_SI
                                                mov   di, startPos_DI
                                                call  compressData
                                                out   dx, al
                            
    ;; setting startPosSent flag so that we don't send it again
                                                mov   startPosSent, 1d
                                                jmp   sendMoveToOponent_end
    

    sendMoveToOponent_send_endpos:              
                           
                                                mov   dx, 3F8h
                                                mov   si, endPos_SI
                                                mov   di, endPos_DI
                                                call  compressData
                                                out   dx, al

    ;; resetting flags after both positions have been sent
                                                mov   startSending, 0d
                                                mov   startPosSent, 0d
                                                
                                                cmp   killedOpKing, 1d
                                                jnz   sendMoveToOponent_end

                                                mov   end_game, 1


    sendMoveToOponent_end:                      
                                                pop   dx
                                                pop   bx
                                                pop   ax

                                                ret
    
sendMoveToOponent ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

showOponentMove PROC
                                                push  ax
                                                push  si
                                                push  di

                                                mov   al, oponent_move_color

                                                mov   si, oponent_startPos_SI
                                                mov   di, oponent_startPos_DI

                                                cmp   si, oponent_checkpos_SI
                                                jnz   showOponentMove_continue0

                                                cmp   di, oponent_checkpos_dI
                                                jnz   showOponentMove_continue0

                                                mov   king_in_danger,0d
                                                call  update_status
    ; push  ax
    ; push  dx
    ; mov   dl,'s'
    ; mov   ah,2
    ; int   21h
    ; pop   dx
    ; pop   ax

    showOponentMove_continue0:                  

                                                call  getPos

                                                mov   cl, board[bx]
                                                mov   board[bx], 0d

                                                call  draw_cell

                                                mov   si, oponent_endPos_SI
                                                mov   di, oponent_endPos_DI

                                                call  getPos
                                                mov   ch, board[bx]

                                                cmp   ch, 0
                                                jz    showOponentMove_continue

                                                cmp   ch, 'p'
                                                jz    showOponentMove_continue

                                                cmp   ch, pKing
                                                jnz   showOponentMove_draw_captured_piece



    ; jmp showOponentMove_draw_captured_piece


                
    showOponentMove_end_game:                   
    ;; TODO: Talla3 el message eno l game 5eles ya hamadaaa
                                                mov   end_game, 1

    showOponentMove_draw_captured_piece:        
    ;; TODO: Talla3 el message eno ettakel ya hamadaaa
                                                mov   current_captured_piece, ch
                                                call  draw_captured_piece
                                                push  bx
                                                mov   bx, 3
                                                call  update_status
                                                pop   bx

    showOponentMove_continue:                   

                                                mov   board[bx], cl

                                                call  draw_cell

                                                pop   di
                                                pop   si
                                                pop   ax

                                                ret

showOponentMove ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

listenForOponentMove PROC
                                                push  dx
                                                push  bx
                                                push  ax
                                                push  si
                                                push  di
                            

                                                mov   dx, 3FDh
                                                In    al, dx
                                                and   al, 1d
                                                jz    listenForOponentMove_end

                                                mov   dx, 3F8h
                                                In    al, dx

                                                mov   bl, al
                                                and   bl, 00110000b
                                                jz    listenForOponentMove_not_chat_signal

                                                mov   sentChar, al
                                                jmp   listenForOponentMove_end


    listenForOponentMove_not_chat_signal:       
                                                cmp   gotOponentStartPos, 1d
                                                jz    listenForOponentMove_get_oponent_endpos

                                                call  removePrevOponentMove

                                                call  deCompressData

                                                mov   oponent_startPos_DI, di
                                                mov   oponent_startPos_SI, si

                                                mov   gotOponentStartPos, 1d
                                                jmp   listenForOponentMove_end



    listenForOponentMove_get_oponent_endpos:    

                                                call  deCompressData

                                                mov   oponent_endPos_DI, di
                                                mov   oponent_endPos_SI, si

                                                mov   gotOponentStartPos, 0d

                                                call  showOponentMove
                            

    listenForOponentMove_end:                   
                                                pop   di
                                                pop   si
                                                pop   ax
                                                pop   bx
                                                pop   dx

                                                ret
listenForOponentMove ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;description
setPieceColors PROC
                                                cmp   blackPlayer, 0d
                                                jnz   setPieceColors_black
                                                ret

    setPieceColors_black:                       
    ;; player pieces
                                                mov   pKing, 6d
                                                mov   pQueen, 5d
                                                mov   pRook, 4d
                                                mov   pBishop, 3d
                                                mov   pKnight, 2d
                                                mov   pPawn, 1d


    ;; oponent pieces
                                                mov   oponentKing  ,-6d
                                                mov   oponentQueen ,-5d
                                                mov   oponentRook  ,-4d
                                                mov   oponentBishop,-3d
                                                mov   oponentKnight,-2d
                                                mov   oponentPawn  ,-1d

                                                ret
setPieceColors ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------

sendStartSignal PROC
                                                push  ax
                                                push  bx
                                                push  dx

    ;; check if THR is empty
    try_to_sendStartSignal:                     
                                                mov   dx, 3FDh
                                                In    al, dx
                                                and   al, 00100000b
                                                jz    try_to_sendStartSignal
            
                                                mov   dx, 3F8h
                                                mov   al, startSignal
                                                out   dx, al
                    
                                                pop   dx
                                                pop   bx
                                                pop   ax

                                                ret
sendStartSignal ENDP

    ;---------------------------------------------------------------------------------------------------------------------------------------------
    ;PROCEDURES USED IN THE GAME SCREEN:
    ;---------------------------------------------------------------------------------------------------------------------------------------------

inline_chat proc

                                                pusha

    ;inline_chat_window_2_check_for_input:

                                                
    ;CHECK IF THERE IS A KEY PRESSESD SEND TO THE OTHER USER
                                                cmp   ax, ax
                                                MOV   AH,01h
                                                INT   16H

    ;JZ   inline_chat_window_2_check_sent_key
                                                JZ    inline_chat_window_2_check_sent_key

                                                cmp   ah, Left_Arrow
                                                jnz   inline_chat_window2_continue1
                                                jmp   inline_EXIT
    inline_chat_window2_continue1:              
                                                cmp   ah, Right_Arrow
                                                jnz   inline_chat_window2_continue2
                                                jmp   inline_EXIT

    inline_chat_window2_continue2:              
                                                cmp   ah, Up_Arrow
                                                jnz   inline_chat_window2_continue3
                                                jmp   inline_EXIT

    inline_chat_window2_continue3:              
                                                cmp   ah, Down_Arrow
                                                jnz   inline_chat_window2_continue4
                                                jmp   inline_EXIT

    inline_chat_window2_continue4:              
                                                cmp   ah, Enter_Key
                                                jnz   inline_chat_window2_continue
                                                jmp   inline_EXIT

    inline_chat_window2_continue:               
                                                MOV   AH,00
                                                INT   16H
                                                
                                               
                                                call  INLINE_WRITEINPUT
                                                CALL  SENDKEY
                                                


    inline_chat_window_2_check_sent_key:        
    ;CHECK STATE IF THERE IS DATA RECIVED
    ;IF THERE IS NO DATA RECIVED
                                               
    ;                                             MOV   DX,3FDH
    ;                                             IN    AL,DX
    ;                                             AND   AL,1
    ;                                             JZ    inline_EXIT
    ; ;IF THERE IS DATA RECIVED
    ; ;RECIVE DATA AND CALL WRITE IN OUTPUT PROC
    ;                                             MOV   DX,03F8H
    ;                                             IN    AL,DX

    ;                                             mov   bl, al
    ;                                             and   bl, 00011000b
    ;                                             jnz    inline_chatting

    ;                                             mov   s

                                                cmp   sentChar, -1D
                                                jnz   inline_chatting
                                                jmp   inline_EXIT

                            
    inline_chatting:                            
                                                mov   al, sentChar
                                                mov   sentChar, -1d

                                                CALL  INLINE_WRITEOUTPUT
                                                           
                 
    inline_EXIT:                                
                                                popa

                                                ret

inline_chat endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

game_window proc

    ; mov   end_game, 1
    ; call initPort
                                                call  resetEverything
                                                call  setPieceColors
                                                call  init_video_mode                                ;Prepare video mode
    ;Clear the screen, in preparation for drawing the board
                                                mov   al, 14h                                        ;The color by which we will clear the screen (light gray).
                                                call  clear_screen
                                                call  init_board                                     ;Initialize board

                                                call  draw_labels

                                                call  set_board_base


                                                call  draw_board                                     ;Draw the board


                                                call  set_border

                                                cmp  blackPlayer, 0
                                                jz  draw_whites_stuff

                                                call  draw_letters_inverted
                                                call  draw_numbers_inverted
                                                jmp  game_window_continue

                        draw_whites_stuff:
                                                call  draw_letters
                                                call  draw_numbers


                        game_window_continue:
                                                call  status_bar

                                                
                                                call inline_input_scroll_up
                                                call inline_output_scroll_up
                                                

                                                mov   ICursor_Y,1D
                                                mov   ICursor_X,120D
                                                mov   OCursor_X,120D
                                                mov   OCursor_Y,33D

                                                mov   ah, 2
                                                mov   bh, 0
                                                mov   dl, ICursor_X
                                                mov   dh, ICursor_Y
                                                int   10h

    ; mov ah, 9
    ; mov dx, offset test1
    ; int 21h

    ; mov ah, 2
    ; mov bh, 0
    ; mov dl, 120d
    ; mov dh, 2d
    ; int 10h

    ; mov ah, 9
    ; mov dx, offset test1
    ; int 21h

    ; mov ah, 2
    ; mov bh, 0
    ; mov dl, OCursor_X
    ; mov dh, OCursor_Y
    ; int 10h

    ; mov ah, 9
    ; mov dx, offset test1
    ; int 21h

    ; mov ah, 2
    ; mov bh, 0
    ; mov dl, 157d
    ; mov dh, 30d
    ; int 10h

    ; mov ah, 9
    ; mov bh, 0
    ; mov al, 44h
    ; mov cx, 1
    ; mov bl, 0fah
    ; int 10h

    ; call intializePort
                         
                                                mov   si, 3d
                                                mov   di, 6d

                                                mov   currHoverPos_SI, si
                                                mov   currHoverPos_DI, di

                                                mov   al, hover_cell_color
                                                call  draw_cell

    play_chess:                                 
                                                call  getPlayerSelection
    
                                                call  moveInSelections

                                                call  sendMoveToOponent

                                                call  listenForOponentMove

                                                call  update_FreePieces

                                                call  inline_chat

                                                call  check_king_vertical
                                                call  check_king_horizontal
                                                call  check_up_diagonals
                                                call  check_down_diagonals
                                                call  check_knight
                                                
    ; cmp king_in_danger, 1
    ; jnz test_continue
    ; push ax
    ; push dx
    ; mov dl, king_in_danger
    ; mov ah,2
    ; int 21h
    ; pop dx
    ; pop ax
    test_continue:                              
                                                cmp   end_game, 1
                                                jnz   play_chess

                                                mov   bx,2
                                                call  update_status

    wait_for_any_key:                           
                                                cmp   ax, ax
                                                mov   ah, 1
                                                int   16h
                                                jz    wait_for_any_key

                                                mov   ah, 0
                                                int   16h

                                                mov   ah, 0
                                                mov   al, 3
                                                int   10h
                                                
                                                
                                                ret

game_window endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

    ;description
checkForStartSignal PROC
                                                push  dx
                                                push  bx
                                                push  ax
                                                push  si
                                                push  di
                            

                                                mov   dx, 3FDh
                                                In    al, dx
                                                and   al, 1d
                                                jz    checkForStartSignal_end

                                                mov   dx, 3F8h
                                                In    al, dx

                                                cmp   al, startSignal
                                                jnz   checkForStartSignal_Opponent_Name

                                                pop   di
                                                pop   si
                                                pop   ax
                                                pop   bx
                                                pop   dx
                                                
                                                mov   blackPlayer, 1                                 ;
                                                call  game_window
                                                ret

        checkForStartSignal_Opponent_Name:
                                                mov bh, 0
                                                mov bl, Opponent_Name_Count
                                                mov Opponent_Name[bx+2], al
                                                inc Opponent_Name_Count

    checkForStartSignal_end:                    
                                                pop   di
                                                pop   si
                                                pop   ax
                                                pop   bx
                                                pop   dx

    ;; call main_window
                                                ret

checkForStartSignal ENDP

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



chat_window_2 proc

                                                pusha

                                                call  inializeScreen
    ;call  initPort
	
    ;CODE
    chat_window_2_check_for_input:              

                                                
    ;CHECK IF THERE IS A KEY PRESSESD SEND TO THE OTHER USER
                                                cmp   ax, ax
                                                MOV   AH,01h
                                                INT   16H
                                                JZ    chat_window_2_check_sent_key
                                                MOV   AH,00
                                                INT   16H
                                                CMP   AL,1BH
                                                JE    EXIT
                                                CMP   AH,3Ch
                                                JNZ   chat_window2_continue
                                                JMP   chat_window2_go_to_game

    chat_window2_continue:                      
                                                call  WRITEINPUT
                                                CALL  SENDKEY
                                                jmp   chat_window_2_check_sent_key
    chat_window2_go_to_game:                    
                                                mov   blackPlayer, 0
                                                call  sendStartSignal
                                                call  input_scroll_up
                                                call  output_scroll_up

                                                popa

                                                call  game_window
                                                ret


    chat_window_2_check_sent_key:               
    ;CHECK STATE IF THERE IS DATA RECIVED
    ;IF THERE IS NO DATA RECIVED
                                               
                                                MOV   DX,3FDH
                                                IN    AL,DX
                                                AND   AL,1
                                                JZ    chat_window_2_check_for_input
    ;IF THERE IS DATA RECIVED
    ;RECIVE DATA AND CALL WRITE IN OUTPUT PROC
                                                MOV   DX,03F8H
                                                IN    AL,DX

                                                cmp   al, startSignal
                                                jnz   chatting

    ; call sendStartSignal
                                                call  input_scroll_up
                                                call  output_scroll_up

                                                popa
                                                
                                                mov   blackPlayer, 1
                                                call  game_window

                                                ret
                            
    chatting:                                   
                                                CALL  WRITEOUTPUT
                                                
                                                JMP   chat_window_2_check_for_input
    ;END CODE
	           
                 
                 
    EXIT:                                       
                                                call  input_scroll_up
                                                call  output_scroll_up

                                                popa

                                                ret

chat_window_2 endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------

display_notification proc

                                                pusha

                                                mov   ah, 2
                                                mov   bh, 0
                                                mov   dl, 20d
                                                mov   dh, 23d
                                                int   10h

                                                mov   ah, 9
                                                mov   dx, offset request
                                                int   21h

                                                popa

                                                ret

display_notification endp

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

                                                mov   ah, 2
                                                mov   bh, 0
                                                mov   dl, 00d
                                                mov   dh, 21d
                                                int   10h

                                                mov   ah, 9
                                                mov   dx, offset border
                                                int   21h

                                                call  display_notification
                                                
    checkForSelection:                          
                                                call  checkForStartSignal
                                                


                                                cmp   ax, ax
                                                mov   ah, 1
                                                int   16h

                                                jz    checkForSelection


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
                                                call  chat_window_2
                                                jmp   main_start

    start_game:                                 
                                                popa
                                                mov   blackPlayer, 0
                                                call  sendStartSignal
                                                call  game_window
                                                jmp   main_start

    main_end:                                   
                                                call  terminate

                                                popa

                                                ret

main_window endp

    ;---------------------------------------------------------------------------------------------------------------------------------------------


;description
sendUsername PROC
                                                pusha 
                                                mov bh, 0
                                                mov bl, User_Name[2]
                                                
                                                mov ch, 0
                                                mov cl, User_Name[1] 
                                                mov  temppp, cl

                                               
    ;; check if THR is empty
    try_to_sendUsername:                     
                                                mov   dx, 3FDh
                                                In    al, dx
                                                and   al, 00100000b
                                                jz    try_to_sendUsername
            
                                                mov   dx, 3F8h
                                                mov   al, [bx]
                                                out   dx, al

                                                loop try_to_sendUsername 
                                           

                                                popa
                                                ret
sendUsername ENDP


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


                                                mov   dh,1
                                                mov   dl,28
                                                mov   ah,2
                                                int   10h
                                                mov   dx, offset Welcome_Mes
                                                mov   ah,9
                                                int   21h
 
                                                mov   dh,5
                                                mov   dl,0
                                                mov   ah,2
                                                int   10h
                                                mov   dx, offset Get_Name
                                                mov   ah,9
                                                int   21h

                                                mov   ah,0AH
                                                mov   dx,offset User_Name
                                                int   21h


 
   
   
                                                mov   al, User_Name+2
    Check1:                                     
                                                cmp   al,41h
                                                jb    Error
                                                cmp   al,80h
                                                ja    Error
                                                jmp   Done
   
   
   
   
    Error:                                      
                                                mov   dh,7
                                                mov   dl,0
                                                mov   ah,2
                                                int   10h
                                                mov   dx, offset Error_Mes
                                                mov   ah,9
                                                int   21h
                                                mov   ah,00H
                                                int   16h

    ;mov ah,0
    ;int 10h
                                                jmp   GetName
 
 
    Done:                                       
                                                mov   dh,7
                                                mov   dl,32
                                                mov   ah,2
                                                int   10h
                                                mov   dx, offset Hello
                                                mov   ah,9
                                                int   21h
  
                                                mov   dx, offset User_Name+2
                                                mov   ah,9
                                                int   21h
                                                mov   dh,8
                                                mov   dl,28
                                                mov   ah,2
                                                int   10h
                                                mov   dx, offset Last
                                                mov   ah,9
                                                int   21h

                                                call sendUsername
 
                                                mov   ah,00H
                                                int   16h

                                                popa

                                                call  main_window

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
    ;call identification_window
    ;call  sendStartSignal
    ;call  resetEverything
    ;call  setPieceColors
    ;call  init_board
                                                call  init_video_mode
                                                mov   al, 14h
                                                call  clear_screen
    ;call  draw_labels
    ;call  set_board_base
    ;call  draw_board
    ;call  set_border
    ;call  draw_letters
    ;call  draw_numbers
    ;call  status_bar

    ;mov   di, 100d
    ;mov   si, 100d
    ;call  draw_timer_3


    ;mov   bx, 0
    ;call  update_status
    ;mov   ah,00H
    ;int   16h
    ;mov   bx,1
    ;call  update_status
                                                call  inline_chat_window
                                                call  intializePort

                                                mov   ICursor_Y,1D
                                                mov   ICursor_X,120D
                                                mov   OCursor_X,120D
                                                mov   OCursor_Y,33D

                                                mov   ah, 2
                                                mov   bh, 0
                                                mov   dl, ICursor_X
                                                mov   dh, ICursor_Y
                                                int   10h

    loopdeloop:                                 
                                                call  inline_chat
                                                jmp   loopdeloop

    ;ctrl k u uncomment
    ;ctrl k c comment
    ;hlt

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

                                                call  identification_window

main endp
end main