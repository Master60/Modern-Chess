    ;Writes possible moves to memory
recordMove PROC
                                   push    bx
                                   push    ax

                                   mov     al, directionPtr
                                   mov     bl, 14d                           ; directionPtr * 7 * 2
                                   mov     bh, 0

                                   mul     bl
                                   mov     bl, al

                                   shl     currMovePtr,1
                                   add     bl, currMovePtr
                                   shr     currMovePtr, 1

                                   mov     possibleMoves_DI[bx], di
                                   mov     possibleMoves_SI[bx], si

    ;inc   currMovePtr

                                   pop     ax
                                   pop     bx
                                   ret
recordMove ENDP

    ; puts the current position as the first possible move in all directions
recordCurrPos PROC
                                   push    cx

                                   mov     cx, 8d
    recordCurrPos_loop:            
                                   call    recordMove
                                   inc     directionPtr

                                   loop    recordCurrPos_loop

                                   mov     directionPtr, 0d
                                   mov     currMovePtr, 1d

                                   pop     cx

                                   ret
    
recordCurrPos ENDP
    ; Navigates in possible moves array
getNextPossibleMove PROC
                                   push    bx
                                   push    ax

                                   mov     al, directionPtr
                                   mov     bl, 14d                           ; directionPtr * 7 * 2
                                   mov     bh, 0

                                   mul     bl
                                   mov     bl, al

                                   shl     currMovePtr,1
                                   add     bl, currMovePtr
                                   shr     currMovePtr, 1

                                   mov     di, possibleMoves_DI[bx]
                                   mov     si, possibleMoves_SI[bx]

                                   pop     ax
                                   pop     bx
                                   ret
getNextPossibleMove ENDP



    ;Changes the positions of selected move and puts them in SI & DI for drawing border
goToNextSelection PROC

                                   push    ax
                                   push    bx
                                   push    cx
                                   push    dx
                                   push    bp

    ; preserving current positions
                                   mov     bp, si
                                   mov     dx, di
    ; preserving current move
                                   mov     bh, directionPtr
                                   mov     bl, currMovePtr


    ; Checking which key was pressed
                                   cmp     ah, 1Eh
                                   jz      A

                                   cmp     ah, 20h
                                   jz      D

                                   cmp     ah, 11h
                                   jz      W

                                   cmp     ah, 1Fh
                                   jz      S

                                   jmp     doNotChangeSelection


    ; a rough implementation of (i+1)%n for both A & D
    A:                             
                                   mov     currMovePtr,1d
                                   mov     cx, 7d
    aLoop:                         
                                   dec     directionPtr
                                   cmp     directionPtr, -1d
                                   jz      aLoopReset
    continueLoopA:                 
                                   call    getNextPossibleMove
                                   cmp     si, -1d
                                   jz      next_loopA_line
                                   jmp     far ptr changeSelection           ; jump is far down
    next_loopA_line:               loop    aLoop
                                   jmp     doNotChangeSelection
    aLoopReset:                    
                                   mov     directionPtr, 7d
                                   jmp     continueLoopA


    D:                             
                                   mov     cl, 7d
                                   mov     ch, 8d
                                   mov     al, directionPtr
                                   mov     ah, 0d
                                   mov     currMovePtr, 1d
    dLoop:                         
                                   inc     al
                                   div     ch
                                   mov     al,ah
                                   mov     directionPtr, al
    
                                   call    getNextPossibleMove

                                   cmp     si, -1d
                                   jnz     changeSelection

                                   dec     cl
                                   jnz     dLoop
                                   jmp     doNotChangeSelection

    W:                             
                                   cmp     currMovePtr, 6
                                   jz      doNotChangeSelection

                                   inc     currMovePtr

    ; if a move actually exists, change selection
                                   call    getNextPossibleMove
                                   cmp     si, -1d
                                   jnz     changeSelection
                          
                                   dec     currMovePtr
                                   jmp     doNotChangeSelection

    S:                             
                                   cmp     currMovePtr, 0
                                   jz      doNotChangeSelection

                                   dec     currMovePtr

                                   call    getNextPossibleMove
                                   cmp     si, -1d
                                   jnz     changeSelection

                                   jmp     doNotChangeSelection


    doNotChangeSelection:          
    ; resets everything to its original state
                                   mov     directionPtr, bh
                                   mov     currMovePtr, bl
                                   mov     si, bp
                                   mov     di, dx
                                   jmp     goToNextSelection_end
                        
    changeSelection:               
    ; highlighting the previous possible move
                                   push    si
                                   push    di
                          
                                   mov     si, bp
                                   mov     di, dx

                                   mov     al, highlighted_cell_color
                                   call    draw_cell

                                   pop     di
                                   pop     si
                          

    goToNextSelection_end:         
                                   pop     bp
                                   pop     dx
                                   pop     cx
                                   pop     bx
                                   pop     ax
                                   ret
goToNextSelection ENDP


    ;Moves to SI DI the first available position if possible
checkFirstAvailableMove PROC
                                   push    si
                                   push    di
                                   push    cx

                                   mov     cx, 8
                                   mov     currMovePtr, 0d
                                   mov     directionPtr, 0d
                          
    first_available_direction:     
                                   call    getNextPossibleMove
                                   cmp     si, -1d
                                   jnz     found_first_available_position
                                   inc     directionPtr
                                   cmp     directionPtr, 8d
                                   jnz     first_available_direction



    ; to let us know if there aren't any available positions
                                   mov     directionPtr, -1d
                                   mov     currMovePtr, -1d


    found_first_available_position:
                                   pop     cx
                                   pop     di
                                   pop     si
                                   ret
checkFirstAvailableMove ENDP

    ; puts
getFirstSelection PROC
                                   call    checkFirstAvailableMove
                                   cmp     directionPtr, -1d
                                   jz      getFirstSelection_end
                          
    ; to move the si, di corresponding to directionPtr & currMovPtr that we got from checkFirstAvailableMove
                                   call    getNextPossibleMove

                                   mov     al,00h
                                   call    drawBorder


    getFirstSelection_end:         ret
getFirstSelection ENDP

    ; Removes previously selected cells (if any)
removeSelections PROC
                                   push    si
                                   push    di


                                   mov     directionPtr, 0d
                          
    removeSelections_loop1:        
                                   mov     currMovePtr, 0d
    removeSelections_loop2:        
                                   mov     si, -1d
                                   mov     di, -1d

                                   call    recordMove
                                   inc     currMovePtr

                                   cmp     currMovePtr, 7d
                                   jz      removeSelections_loop2_break

                                   call    getNextPossibleMove
                                   cmp     si,-1
                                   jz      removeSelections_loop2_break

                                   call    get_cell_colour
                                   call    draw_cell

                                   jmp     removeSelections_loop2

    removeSelections_loop2_break:  
                                   inc     directionPtr
                                   cmp     directionPtr, 8d
                                   jnz     removeSelections_loop1


                                   mov     directionPtr, 0d
                                   mov     currMovePtr, 0d

                                   pop     di
                                   pop     si
                                   ret
removeSelections ENDP

    ; Gets all possible pawn moves
getPawnMoves PROC
                                   push    di
                                   push    ax

                                   add     di, walker
        
                                   call    recordMove
                                   inc     currMovePtr

                                   mov     al, highlighted_cell_color
                                   call    draw_cell

                                   cmp     walker, -1
                                   jz      white
                                   jmp     black



    white:                         cmp     di, 5d
                                   jnz     gotPawnMoves

                                   add     di, walker

                                   call    recordMove
    
                                   call    draw_cell
                                   jmp     gotPawnMoves
    

    black:                         cmp     di, 2d
                                   jnz     gotPawnMoves

                                   add     di, walker
                                   call    recordMove

                                   call    draw_cell

    gotPawnMoves:                  pop     ax
                                   pop     di
                                   ret

getPawnMoves ENDP