                    #ROM      *
                    #Uses     v2_18g3.inc

;*******************************************************************************
                    #DATA
;*******************************************************************************

ready               fcb       0
FLEET               fcb       0
PLAYER              fcb       1
MASK                fcb       0
ROW                 fcb       0
COL                 fcb       0
KEY                 fcb       5
boardRows           fcb       4
boardCols           fcb       4
p1ships             fcb       0
p2ships             fcb       0
p1board             rmb       16
p2board             rmb       16
filler              fcs       '                '
title               fcs       '   BATTLESHIP   '
subtitle            fcs       ' A crappy game. '
p1                  fcs       '    Player 1    '
p2                  fcs       '    Player 2    '
place               fcs       'Place a ship.   '
enter               fcs       'Enter coords.   '
shoot               fcs       'Shoot a ship.   '
over                fcs       '   Game over.   '
invalid             fcs       'invalid position'
occupied            fcs       'already occupied'
available           fcs       '   Nice ship!   '
hit                 fcs       '      hit!      '
miss                fcs       'miss...         '
win                 fcs       "You're the ship."
loss                fcs       "You're crappy.  "

DEBUGinterrupt      fcs       LF,'INTERRUPTION DETECTED',LF
DEBUGbegin          fcs       'Begin',LF
DEBUGstrategize     fcs       'Strategizing...',LF
DEBUGfirst          fcs       '    -1st ship placed',LF
DEBUGsecond         fcs       '    -2nd ship placed',LF
DEBUGthird          fcs       '    -3rd ship placed',LF
DEBUGfourth         fcs       '    -4th ship placed',LF
DEBUGgetCoord       fcs       'Getting coordinates...',LF,'    -waiting for input...',LF
DEBUGgotCoord       fcs       '    -input received',LF,'    -mapping to board position...',LF
DEBUGgotError       fcs       '    -ERROR detected: invalid input received',LF
DEBUGmask           fcs       '    -current mask: '
DEBUGrow            fcs       '    -current row:  '
DEBUGcol            fcs       '    -current col:  '
DEBUGgotRow         fcs       '    -ROW: '
DEBUGgotCol         fcs       '    -COL: '
DEBUGgotKey         fcs       '    -KEY: '
DEBUGplaceShit      fcs       'Placing ships...',LF
DEBUGplaceError     fcs       '    -ERROR detected: invalid ship position (already taken)',LF
DEBUGswitch         fcs       'Switching players...',LF
DEBUGfire           fcs       'Firing at ships...',LF
DEBUGshootP1        fcs       '    -shooting at player 1',LF
DEBUGshootP2        fcs       '    -shooting at player 2',LF
DEBUGhit            fcs       '    -hit',LF
DEBUGmiss           fcs       '    -miss',LF
DEBUGupdate         fcs       'Updating the fleets...',LF
DEBUGships          fcs       '    -ships: '
DEBUGfleet          fcs       '    -fleet status: '
DEBUGinit           fcs       '    -detected p1 initial setup, suppressing p2 status',LF
DEBUGstatus         fcs       '    -indicating fleet status',LF
DEBUGcheck          fcs       'Checking for a winner...',LF
DEBUGalive          fcs       '    -alive',LF
DEBUGdead           fcs       '    -DEAD!',LF
DEBUGwait           fcs       'Waiting through a delay...',LF
DEBUGdone           fcs       'Finish',LF

;*******************************************************************************
                    #ROM
;*******************************************************************************

interrupt           proc
                    lda       #1                  ; set ready bit
                    sta       ready
                    @print    #DEBUGinterrupt
                    rti

;*******************************************************************************

Main                proc
                    @print    #DEBUGbegin
                    ldx       #interrupt          ; set interrupt
                    stx       ISR_JUMP15
                    clra                          ; clear lights
                    coma
                    sta       leds
                    @print    1,#title
                    @print    2,#subtitle
                    jsr       Delay
          ;-------------------------------------- ;strategize
                    @print    #DEBUGstrategize
                    @print    1,#p1
                    jsr       Delay
                    jsr       placeShit           ; position p1 ships
                    @print    #DEBUGfirst
                    @print    2,#available
                    jsr       Delay
                    jsr       placeShit
                    @print    #DEBUGsecond
                    @print    2,#available
                    jsr       Delay
                    jsr       placeShit
                    @print    #DEBUGthird
                    @print    2,#available
                    jsr       Delay
                    jsr       placeShit
                    @print    #DEBUGfourth
                    @print    2,#available
                    jsr       Delay

                    jsr       switchPlayer
                    jsr       placeShit           ; position p2 ships
                    @print    #DEBUGfirst
                    @print    2,#available
                    jsr       Delay
                    jsr       placeShit
                    @print    #DEBUGsecond
                    @print    2,#available
                    jsr       Delay
                    jsr       placeShit
                    @print    #DEBUGthird
                    @print    2,#available
                    jsr       Delay
                    jsr       placeShit
                    @print    #DEBUGfourth
                    @print    2,#available
                    jsr       Delay
                    jsr       switchPlayer        ; randomly choose first shooter

GameLoop@@          jsr       firePiss            ; guess
                    jsr       checkWin            ; check
                    jsr       switchPlayer        ; switch
                    bra       GameLoop@@

;*******************************************************************************

getCoord            proc
Loop@@              push
                    @print    2,#enter
                    @print    #DEBUGgetCoord
                    clr       ready               ; clear submission
Input@@            ;@print    #DEBUGloop
                    ldb       switches            ; get input
                    lda       ready               ; check for submission
                    beq       Input@@
                    @print    #DEBUGgotCoord
                    clr       ready               ; clear submission
                    lda       #5                  ; row 4: ---x----
                    sta       ROW                 ; 1234(p2)
                    lda       #8                  ; start at: ---x----
                    sta       MASK
Row@@               lda       ROW                 ; move to next switch/row
                    deca
                    beq       Fail@@              ; min row = 1
                    sta       ROW
;                   @print    #DEBUGrow
;                   psha
;                   lda       ROW
;                   adda      #'0'
;                   @putc
;                   pula
;                   @crlf
                    lda       MASK                ; shift mask left
                    lsla
                    beq       Fail@@              ; min row = binary 256 = binary 0 w/ carry
                    sta       MASK
;                   @print    #DEBUGmask
;                   pshd
;                   clra
;                   ldb       MASK
;                   jsr       CONSOLEINT
;                   puld
;                   @crlf
                    bitb      MASK                ; apply mask
                    beq       Row@@               ; detect row
          ;-------------------------------------- ; getCoordGotRow
;                   @print    #DEBUGgotRow
;                   psha
;                   lda       ROW
;                   adda      #'0'
;                   @putc
;                   pula
;                   @crlf
                    lda       #4                  ; col 4: -------x
                    sta       COL                 ; (p1)1234
                    lda       #1                  ; start at: -------x
                    sta       MASK
Col@@               bitb      MASK                ; apply mask
                    bne       GotCol@@            ; detect col
                    lda       COL                 ; move to next switch/row
                    deca
                    ble       Fail@@              ; min col = 1
                    sta       COL
;                   @print    #DEBUGcol
;                   psha
;                   lda       COL
;                   adda      #'0'
;                   @putc
;                   pula
;                   @crlf
                    lda       MASK
                    lsla                          ; shift mask left
                    cmpa      #16                 ; min col = binary 16
                    beq       Fail@@              ; detect invalid col
                    sta       MASK
;                   pshd
;                   @print    #DEBUGmask
;                   clra
;                   ldb       MASK
;                   jsr       CONSOLEINT
;                   puld
;                   @crlf
                    bra       Col@@
GotCol@@
;                   @print    #DEBUGgotCol
;                   psha
;                   lda       COL
;                   adda      #'0'
;                   @putc
;                   pula
;                   @crlf
                    lda       ROW                 ; KEY = 4(ROW-1)+(COL-1) = 4ROW+COL-5
                    tab                           ; a = ROW
                    lsla:2                        ; a = 4ROW
                    ldb       COL
                    aba                           ; a = 4ROW+COL
                    suba      #5                  ; a = KEY
                    sta       KEY
;                   @print    #DEBUGgotKey
;                   psha
;                   lda       KEY
;                   adda      #'0'
;                   @putc
;                   pula
;                   @crlf
                    pull
                    rts

Fail@@              @print    #DEBUGgotError
                    @print    2,#invalid
                    jsr       Delay
                    pull
                    jmp       Loop@@              ; try again

;*******************************************************************************

placeShit           proc
Loop@@              push
                    @print    2,#place
                    @print    #DEBUGplaceShit
                    lda       PLAYER              ; select correct board
                    cmpa      #2
                    beq       _1@@
          ;--------------------------------------
                    @print    #p1
                    @crlf
                    ldx       #p1board            ; load p1 board
                    bra       OnBoard@@
          ;--------------------------------------
_1@@                @print    #p2
                    @crlf
                    ldx       #p2board            ; load p2 board
          ;--------------------------------------
OnBoard@@           jsr       getCoord            ; get position
                    psha
                    @print    #DEBUGgotRow
                    lda       ROW
                    adda      #'0'
                    @putc
                    @crlf
                    @print    #DEBUGgotCol
                    lda       COL
                    adda      #'0'
                    @putc
                    @crlf
                    @print    #DEBUGgotKey
                    lda       KEY
                    adda      #'0'
                    @putc
                    @crlf
                    pula
                    ldb       KEY
                    abx
                    lda       ,x                  ; make sure a ship isnt already there
                    bne       ShitTaken@@
                    lda       #1                  ; place ship
                    sta       ,x
                    lda       PLAYER              ; add ship for the right player
                    cmpa      #2
                    beq       _2@@
          ;-------------------------------------- ; p1
                    lda       p1ships
                    inca
                    sta       p1ships
                    bra       Done@@
          ;-------------------------------------- ; p2
_2@@                lda       p2ships
                    inca
                    sta       p2ships
          ;--------------------------------------
Done@@              jsr       updateFleet
                    pull
                    rts

ShitTaken@@         @print    #DEBUGplaceError
                    @print    2,#occupied
                    pull
                    jmp       Loop@@

;*******************************************************************************

switchPlayer        proc
                    push
                    @print    #DEBUGswitch
                    lda       PLAYER              ; get current player
                    tab
                    inca                          ; a = next player
                    decb                          ; b = prev player
                    cmpa      #3
                    bge       Prev@@              ; decide how to toggle based on current player
          ;-------------------------------------- ; switchPlayerNext
                    @print    #p2
                    @crlf
                    sta       PLAYER              ; change player
                    @print    1,#p2               ; change player indicator
                    jsr       Delay
                    bra       Done@@              ; /
          ;--------------------------------------
Prev@@              @print    #p1
                    @crlf
                    stb       PLAYER              ; change player
                    @print    1,#p1               ; change player indicator
                    jsr       Delay
          ;--------------------------------------
Done@@              pull
                    rts

;*******************************************************************************

firePiss            proc
                    push
                    @print    #DEBUGfire
                    @print    2,#shoot
                    jsr       getCoord            ; get where to fire
                    lda       PLAYER              ; detect who is shooting/getting shot at
                    cmpa      #1
                    beq       _1@@
          ;-------------------------------------- ; shooting at player 1
                    @print    #DEBUGshootP1
                    ldx       #p1board            ; check if hit
                    ldb       KEY
                    abx
                    lda       ,x
                    beq       _4@@
                    bra       _3@@
_1@@      ;-------------------------------------- ; shooting at player 2
                    @print    #DEBUGshootP2
                    ldx       #p2board
                    ldb       KEY
                    abx
                    lda       ,x
                    beq       _2@@
          ;-------------------------------------- ; hit for player 1
                    @print    #DEBUGhit
                    clr       ,x                  ; remove sunken ship
                    lda       p2ships             ; decrease count of p2 ships
                    deca
                    sta       p2ships
                    bsr       updateFleet         ; change fleet indicator
                    @print    2,#hit
                    jsr       Delay
                    bra       Done@@
_2@@      ;-------------------------------------- ; player 1 misses
                    @print    #DEBUGmiss
                    @print    2,#miss
                    bra       Done@@
_3@@      ;-------------------------------------- ; hit for player 2
                    @print    #DEBUGhit
                    clr       ,x                  ; remove sunken ship
                    lda       p1ships             ; decrease count of p1 ships
                    deca
                    sta       p1ships
                    bsr       updateFleet         ; change fleet indicator
                    @print    2,#hit
                    bra       Done@@
          ;-------------------------------------- ; player 2 misses
_4@@                @print    #DEBUGhit
                    @print    2,#miss
          ;--------------------------------------
Done@@              pull
                    rts

;*******************************************************************************

updateFleet         proc
                    push
                    @print    #DEBUGupdate
                    lda       #1                  ; a = fleet indicator
                    ldb       p1ships             ; b = player 1 ships
                    @print    #p1
                    @crlf
                    @print    #DEBUGships
                    pshd
                    clra
                    ldb       p1ships
                    jsr       CONSOLEINT
                    puld
                    @crlf
Loop@@              decb                          ; for each ship
                    beq       Done@@              ; detect end of fleet
                    jle       checkWin            ; catch game over
;                   blt       _1@@
                    lsla                          ; make room
                    inca                          ; add to fleet
                    bra       Loop@@

;_1@@               clra                          ; avoid incorrect status by storing 0 mask
Done@@              lsla:4                        ; offset p1 so as not to block p2
                    sta       FLEET
                    lda       #1                  ; reset status for next player
;                   lda       FLEET
                    @print    #DEBUGfleet
                    psha
                    clra
                    ldb       FLEET
                    jsr       CONSOLEINT
                    pula
                    @crlf
                    ldb       p2ships             ; switch players
                    @print    #p2
                    @crlf
                    @print    #DEBUGships
                    pshd
                    clra
                    ldb       p2ships
                    jsr       CONSOLEINT
                    puld
                    @crlf
                    tstb
                    bne       _1@@
                    @print    #DEBUGinit
                    incb                          ; avoid problems in initial placement
                    deca
_1@@                decb
                    ble       _2@@
                    lsla
                    inca
                    bra       _1@@
_2@@                ora       FLEET               ; combine p1 & p2
                    sta       FLEET
                    pshd
                    @print    #DEBUGfleet
                    clra
                    ldb       FLEET
                    jsr       CONSOLEINT
                    @crlf
                    puld
          ;-------------------------------------- ; update fleet lights
                    @print    #DEBUGstatus
                    coma                          ; display updated fleet
                    sta       leds
                    pull
                    rts

;*******************************************************************************

checkWin            proc
                    push
                    @print    #DEBUGcheck
                    clrb                          ; b = key counter
                    @print    #p1
                    @crlf
                    ldx       #p1board            ; x = addr. of current key
Loop@@              lda       ,x
                    bne       _1@@                ; stop as soon as 1 ship is detected
                    incb
                    cmpb      #16                 ; 4 rows x 4 cols = 16 positions to check
                    beq       checkWinP1Dead      ; detect p2 victory
                    inx
                    bra       Loop@@

_1@@                @print    #DEBUGalive
                    @print    #p2
                    @crlf
                    ldx       #p2board            ; switch player
                    clrb                          ; reset counter
_2@@                lda       ,x
                    bne       _3@@                ; stop as soon as 1 ship is detected
                    incb
                    cmpb      #16                 ; 4 rows x 4 cols = 16 positions to check
                    beq       checkWinP2Dead      ; detect p1 victory
                    inx
                    bra       _2@@
          ;-------------------------------------- ; both players are still alive
_3@@                @print    #DEBUGalive
                    pull
                    rts

;*******************************************************************************

checkWinP1Dead      proc
                    @print    #DEBUGdead
                    @print    1,#p1
                    @print    2,#loss
                    bsr       Delay
                    @print    1,#p2
                    @print    2,#win
                    bra       gameOver

;*******************************************************************************

checkWinP2Dead      proc
                    @print    #DEBUGdead
                    @print    1,#p2
                    @print    2,#loss
                    bsr       Delay
                    @print    1,#p1
                    @print    2,#win
                    bra       gameOver

;*******************************************************************************

Delay               proc
                    @print    #DEBUGwait
                    @wait     #3000               ; 3 seconds
                    rts

;*******************************************************************************

gameOver            proc
                    @print    #DEBUGdone
                    @print    1,#title
                    @print    2,#over
                    bsr       Delay
Loop@@              lda       ready               ; wait for submission to restart
                    jne       Main
                    @wait     #500                ; .5 second delay
                    bra       Loop@@
