#include <v2_18g3.asm>

	.sect .data
READY:                  .byte	0
FLEET:                  .byte	0
PLAYER:                 .byte	1
MASK:                   .byte	0
ROW:                    .byte	0
COL:                    .byte	0
KEY:                    .byte	5
boardRows:              .byte	4
boardCols:              .byte	4
p1shits:                .byte	0
p2shits:                .byte	0
p1board:                .space	16
p2board:                .space	16
filler:                 .asciz	"                "
title:                  .asciz	"   BATTLESHIT   "
subtitle:               .asciz	" A crappy game. "
p1:                     .asciz	"    Player 1    "
p2:                     .asciz	"    Player 2    "
place:                  .asciz	"Place a shit.   "
enter:                  .asciz  "Enter coords.   "
shoot:                  .asciz	"Shoot a shit.   "
over:                   .asciz	"   Game over.   "
invalid:                .asciz	"invalid position"
occupied:               .asciz	"already occupied"
available:              .asciz	"   Nice shit!   "
hit:                    .asciz	"      hit!      "
miss:                   .asciz	"miss...         "
win:                    .asciz	"You're the shit."
loss:                   .asciz	"You're crappy.  "

DEBUGinterrupt:         .asciz  "\nINTERRUPTION DETECTED\n"
DEBUGbegin:             .asciz	"Begin\n"
DEBUGstrategize:        .asciz	"Strategizing...\n"
DEBUGfirst:             .asciz	"    -1st ship placed\n"
DEBUGsecond:            .asciz	"    -2nd ship placed\n"
DEBUGthird:             .asciz	"    -3rd ship placed\n"
DEBUGfourth:            .asciz	"    -4th ship placed\n"
DEBUGgetCoord:          .asciz  "Getting coordinates...\n    -waiting for input...\n"
DEBUGgotCoord:          .asciz  "    -input received\n    -mapping to board position...\n"
DEBUGgotError:          .asciz  "    -ERROR detected: invalid input received\n"
DEBUGmask:              .asciz  "    -current mask: "
DEBUGrow:               .asciz	"    -current row:  "
DEBUGcol:               .asciz	"    -current col:  "
DEBUGgotRow:            .asciz	"    -ROW: "
DEBUGgotCol:            .asciz	"    -COL: "
DEBUGgotKey:            .asciz	"    -KEY: "
DEBUGplaceShit:         .asciz  "Placing shits...\n"
DEBUGplaceError:        .asciz  "    -ERROR detected: invalid shit position (already taken)\n"
DEBUGswitch:            .asciz	"Switching players...\n"
DEBUGfire:              .asciz  "Firing at shits...\n"
DEBUGshootP1:           .asciz  "    -shooting at player 1\n"
DEBUGshootP2:           .asciz  "    -shooting at player 2\n"
DEBUGhit:               .asciz  "    -hit\n"
DEBUGmiss:              .asciz  "    -miss\n"
DEBUGupdate:            .asciz  "Updating the fleets...\n"
DEBUGshits:             .asciz  "    -shits: "
DEBUGfleet:             .asciz  "    -fleet status: "
DEBUGinit:              .asciz  "    -detected p1 initial setup, suppressing p2 status\n"
DEBUGstatus:            .asciz  "    -indicating fleet status\n"
DEBUGcheck:             .asciz  "Checking for a winner...\n"
DEBUGalive:             .asciz  "    -alive\n"
DEBUGdead:              .asciz  "    -DEAD!\n"
DEBUGwait:              .asciz  "Waiting through a delay...\n"
DEBUGdone:              .asciz  "Finish\n"

	.sect .text
interrupt:
	psha                                            //backup registers
	ldaa	#1					//set ready bit
	staa	READY					//
                                                                                                        pshx
													ldx #DEBUGinterrupt
													jsr OUTSTRING
                                                                                                        pulx
        pula                                            //restore registers
rti
	
main:
                                                                                                        pshx
													ldx #DEBUGbegin
													jsr OUTSTRING
                                                                                                        pulx
	ldx	#interrupt				//set interrupt
	stx 	ISR_JUMP15				//
	ldaa	#0					//clear lights
	coma						//
	staa 	LEDS					//
	coma						//
	ldx	#title					//print message
	ldaa	#1					//
	jsr 	LCDLINE					//
	ldx	#subtitle				//
	ldaa	#2					//
	jsr 	LCDLINE					//
	jsr	delay					//	

strategize:
                                                                                                        pshx
													ldx #DEBUGstrategize
													jsr OUTSTRING
                                                                                                        pulx
	ldx	#p1					//print message
	ldaa	#1					//
	jsr 	LCDLINE					//
	jsr	delay					//
	jsr	placeShit				//position p1 shits
                                                                                                        pshx
													ldx #DEBUGfirst
													jsr OUTSTRING
                                                                                                        pulx
	ldx	#available				//print message
	ldaa	#2					//
	jsr 	LCDLINE					//
        jsr     delay                                   //
	jsr	placeShit				//
                                                                                                        pshx
													ldx #DEBUGsecond
													jsr OUTSTRING
                                                                                                        pulx
	ldx	#available				//print message
	ldaa	#2					//
	jsr 	LCDLINE					//
        jsr     delay                                   //
	jsr	placeShit				//
                                                                                                        pshx
													ldx #DEBUGthird
													jsr OUTSTRING
                                                                                                        pulx
	ldx	#available				//print message
	ldaa	#2					//
	jsr 	LCDLINE					//
        jsr     delay                                   //
	jsr	placeShit				//
                                                                                                        pshx
													ldx #DEBUGfourth
													jsr OUTSTRING
                                                                                                        pulx
	ldx	#available				//print message
	ldaa	#2					//
	jsr 	LCDLINE					//
        jsr     delay                                   //
		
	jsr	switchPlayer				//
	jsr	placeShit				//position p2 shits
                                                                                                        pshx
													ldx #DEBUGfirst
													jsr OUTSTRING
                                                                                                        pulx
	ldx	#available				//print message
	ldaa	#2					//
	jsr 	LCDLINE					//
        jsr     delay                                   //
	jsr	placeShit				//
                                                                                                        pshx
													ldx #DEBUGsecond
													jsr OUTSTRING
                                                                                                        pulx
	ldx	#available				//print message
	ldaa	#2					//
	jsr 	LCDLINE					//
        jsr     delay                                   //
	jsr	placeShit				//
                                                                                                        pshx
													ldx #DEBUGthird
													jsr OUTSTRING
                                                                                                        pulx
	ldx	#available				//print message
	ldaa	#2					//
	jsr 	LCDLINE					//
        jsr     delay                                   //
	jsr	placeShit				//
                                                                                                        pshx
													ldx #DEBUGfourth
													jsr OUTSTRING
                                                                                                        pulx
	ldx	#available				//print message
	ldaa	#2					//
	jsr 	LCDLINE					//
        jsr     delay                                   //
        jsr     switchPlayer                            //randomly choose first shooter
	
gameLoop:
	jsr	firePiss				//guess
	jsr	checkWin				//check
	jsr	switchPlayer				//switch
	bra	gameLoop				//

getCoord:
	psha						//backup registers
	pshb						//
	pshx						//
	pshy						//
        ldx     #enter                                  //print message
        ldaa    #2                                      //
        jsr     LCDLINE                                 //
                                                                                                        pshx
                                                                                                        ldx #DEBUGgetCoord
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
        ldaa	#0					//clear submission
	staa	READY					//
	getCoordInput:					//
                                                                                                        //pshx
                                                                                                        //ldx #DEBUGloop
                                                                                                        //jsr OUTSTRING
                                                                                                        //pulx
		ldab	SWITCHES			//get input
		ldaa	READY				//check for submission
		beq	getCoordInput			//
                                                                                                        pshx
                                                                                                        ldx #DEBUGgotCoord
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
	ldaa	#0					//clear submission
	staa	READY					//
	ldaa	#5					//   row 4: ---x----
	staa	ROW					//          1234(p2)
	ldaa	#8					//start at: ---x----
	staa	MASK					//
	getCoordRow:					//
		ldaa	ROW				//move to next switch/row
		deca					//
		beq	getCoordError			//min row = 1
		staa	ROW				//
                                                                                                        //psha
                                                                                                        //pshx
                                                                                                        //ldx #DEBUGrow
                                                                                                        //jsr OUTSTRING
                                                                                                        //ldaa ROW
                                                                                                        //adda #48
                                                                                                        //jsr OUTCHAR
                                                                                                        //jsr OUTCRLF
                                                                                                        //pulx
                                                                                                        //pula
		ldaa	MASK				//shift mask left
		lsla					//
		beq	getCoordError			//min row = binary 256 = binary 0 w/ carry
		staa	MASK				//
                                                                                                        //psha
                                                                                                        //pshb
                                                                                                        //pshx
                                                                                                        //ldx #DEBUGmask
													//jsr OUTSTRING
													//ldaa #0
													//ldab MASK
													//jsr CONSOLEINT
													//jsr OUTCRLF
													//pulx
                                                                                                        //pulb
                                                                                                        //pula
		bitb	MASK				//apply mask
		
		beq	getCoordRow			//detect row
	getCoordGotRow:					//
                                                                                                        //psha
                                                                                                        //pshx
                                                                                                        //ldx #DEBUGgotRow
                                                                                                        //jsr OUTSTRING
                                                                                                        //ldaa ROW
                                                                                                        //adda #48
                                                                                                        //jsr OUTCHAR
                                                                                                        //jsr OUTCRLF
                                                                                                        //pulx
                                                                                                        //pula
		ldaa	#4				//   col 4: -------x
		staa	COL				//          (p1)1234
		ldaa	#1				//start at: -------x
		staa	MASK				//
	getCoordCol:					//
		bitb	MASK				//apply mask
		bne	getCoordGotCol			//detect col
		ldaa	COL				//move to next switch/row
		deca					//
		ble	getCoordError			//min col = 1
                staa    COL                             //
                                                                                                        //psha
                                                                                                        //pshx
                                                                                                        //ldx #DEBUGcol
                                                                                                        //jsr OUTSTRING
                                                                                                        //ldaa COL
                                                                                                        //adda #48
                                                                                                        //jsr OUTCHAR
                                                                                                        //jsr OUTCRLF
                                                                                                        //pulx
                                                                                                        //pula
                ldaa    MASK                            //
		lsla					//shift mask left
		cmpa	#16				//min col = binary 16
		beq	getCoordError			//detect invalid col
		staa	MASK				//
                                                                                                        //psha
                                                                                                        //pshb
                                                                                                        //pshx
                                                                                                        //ldx #DEBUGmask
													//jsr OUTSTRING
													//ldaa #0
													//ldab MASK
													//jsr CONSOLEINT
													//jsr OUTCRLF
													//pulx
                                                                                                        //pulb
                                                                                                        //pula
		bra	getCoordCol			//
	getCoordGotCol:					//
                                                                                                        //psha
                                                                                                        //pshx
                                                                                                        //ldx #DEBUGgotCol
                                                                                                        //jsr OUTSTRING
                                                                                                        //ldaa COL
                                                                                                        //adda #48
                                                                                                        //jsr OUTCHAR
																										//jsr OUTCRLF
                                                                                                        //pulx
                                                                                                        //pula
		ldaa	ROW				//KEY = 4(ROW-1)+(COL-1) = 4ROW+COL-5
		tab					//a = ROW
		lsla					//a = 2ROW
		lsla					//a = 4ROW
		ldab	COL				//
		aba					//a = 4ROW+COL
		suba	#5				//a = KEY
		staa	KEY				//
                                                                                                        //psha
                                                                                                        //pshx
                                                                                                        //ldx #DEBUGgotKey
                                                                                                        //jsr OUTSTRING
                                                                                                        //ldaa KEY
                                                                                                        //adda #48
                                                                                                        //jsr OUTCHAR
                                                                                                        //jsr OUTCRLF
                                                                                                        //pulx
                                                                                                        //pula
	puly						//restore registers
        pulx                                            //
	pulb						//
	pula						//
rts							//
	getCoordError:					//
                                                                                                        pshx
                                                                                                        ldx #DEBUGgotError
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldx	#invalid			//print message
		ldaa	#2				//
		jsr 	LCDLINE				//
		jsr	delay				//
                puly                                    //restore registers
                pulx                                    //
                pulb                                    //
                pula                                    //
		bra	getCoord			//try again
	
placeShit:
	psha						//backup registers
	pshb						//
	pshx						//
	pshy						//
        ldx     #place                                  //print message
        ldaa    #2                                      //
        jsr     LCDLINE                                 //
                                                                                                        pshx
                                                                                                        ldx #DEBUGplaceShit
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
	ldaa	PLAYER					//select correct board
	cmpa	#2					//
	beq	placeShitP2				//
	placeShitP1:					//
                                                                                                        pshx
                                                                                                        ldx #p1
                                                                                                        jsr OUTSTRING
                                                                                                        jsr OUTCRLF
                                                                                                        pulx
		ldx	#p1board			//load p1 board
		bra	placeShitOnBoard		//
	placeShitP2:                                    //
                                                                                                        pshx
                                                                                                        ldx #p2
                                                                                                        jsr OUTSTRING
                                                                                                        jsr OUTCRLF
                                                                                                        pulx
		ldx	#p2board			//load p2 board
	placeShitOnBoard:				//
		jsr	getCoord			//get position
                                                                                                        psha
                                                                                                        pshx
                                                                                                        ldx #DEBUGgotRow
                                                                                                        jsr OUTSTRING
                                                                                                        ldaa ROW
                                                                                                        adda #48
                                                                                                        jsr OUTCHAR
                                                                                                        jsr OUTCRLF
                                                                                                        ldx #DEBUGgotCol
                                                                                                        jsr OUTSTRING
                                                                                                        ldaa COL
                                                                                                        adda #48
                                                                                                        jsr OUTCHAR
                                                                                                        jsr OUTCRLF
                                                                                                        ldx #DEBUGgotKey
                                                                                                        jsr OUTSTRING
                                                                                                        ldaa KEY
                                                                                                        adda #48
                                                                                                        jsr OUTCHAR
                                                                                                        jsr OUTCRLF
                                                                                                        pulx
                                                                                                        pula
		ldab	KEY				//
		abx					//
		ldaa	0, X				//make sure a shit isnt already there
		bne	placeShitTaken			//
		ldaa	#1				//place shit
		staa	0, X				//
                ldaa    PLAYER                          //add shit for the right player
                cmpa    #2                              //
                beq     placeShitForP2                  //
        placeShitForP1:                                 //p1
                ldaa    p1shits                         //
                inca                                    //
                staa    p1shits                         //
                bra     placeShitDone                   //
        placeShitForP2:                                 //p2
                ldaa    p2shits                         //
                inca                                    //
                staa    p2shits                         //
        placeShitDone:                                  //
                jsr	updateFleet                     //
	puly						//restore registers
        pulx                                            //
	pulb						//
	pula						//
rts							//
	placeShitTaken:					//
                                                                                                        pshx
                                                                                                        ldx #DEBUGplaceError
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldx	#occupied			//print message
		ldaa	#2				//
		jsr 	LCDLINE				//
                puly                                    //restore registers
                pulx                                    //
                pulb                                    //
                pula                                    //
		bra	placeShit			//
		
	
switchPlayer:
	psha						//backup registers
	pshb						//
	pshx						//
	pshy						//
                                                                                                        pshx
                                                                                                        ldx #DEBUGswitch
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
	ldaa	PLAYER					//get current player
	tab						//
	inca						//a = next player
	decb						//b = prev player
	cmpa	#3					//
	bge	switchPlayerPrev			//decide how to toggle based on current player
	switchPlayerNext:				//
                                                                                                        pshx
                                                                                                        ldx #p2
                                                                                                        jsr OUTSTRING
                                                                                                        jsr OUTCRLF
                                                                                                        pulx
		staa	PLAYER				//change player
		ldx	#p2				//change player indicator
		ldaa	#1				//
		jsr 	LCDLINE				//
		jsr	delay				//
                bra     switchPlayerDone                /
	switchPlayerPrev:				//
                                                                                                        pshx
                                                                                                        ldx #p1
                                                                                                        jsr OUTSTRING
                                                                                                        jsr OUTCRLF
                                                                                                        pulx
		stab	PLAYER				//change player
		ldx	#p1				//change player indicator
		ldaa	#1				//
		jsr 	LCDLINE				//
		jsr	delay				//
        switchPlayerDone:                               //
	puly						//restore registers
        pulx                                            //
	pulb						//
	pula						//
rts

firePiss:
	psha						//backup registers
	pshb						//
	pshx						//
	pshy						//
                                                                                                        pshx
                                                                                                        ldx #DEBUGfire
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
        ldx     #shoot                                  //
        ldaa    #2                                      //
        jsr     LCDLINE                                 //
	jsr	getCoord				//get where to fire
	ldaa	PLAYER					//detect who is shooting/getting shot at
	cmpa	#1					//
	beq	firePissP2				//
	firePissP1:					//shooting at player 1
                                                                                                        pshx
                                                                                                        ldx #DEBUGshootP1
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldx	#p1board				//check if hit
		ldab	KEY				//
		abx					//
		ldaa	0, X				//
		beq	firePissP2Miss			//
		bra	firePissP2Hit			//
	firePissP2:					//shooting at player 2
                                                                                                        pshx
                                                                                                        ldx #DEBUGshootP2
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldx	#p2board			//
		ldab	KEY				//
		abx					//
		ldaa	0, X				//
		beq	firePissP1Miss			//
	firePissP1Hit:					//hit for player 1
                                                                                                        pshx
                                                                                                        ldx #DEBUGhit
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldaa	#0				//remove sunken shit
		staa	0, X				//
		ldaa	p2shits				//decrease count of p2 shits
		deca					//
		staa	p2shits				//
		jsr	updateFleet			//change fleet indicator
		ldx	#hit				//print message
		ldaa	#2				//
		jsr 	LCDLINE				//
		jsr	delay				//
		bra	firePissDone			//
	firePissP1Miss:					//player 1 misses
                                                                                                        pshx
                                                                                                        ldx #DEBUGmiss
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldx	#miss				//print message
		ldaa	#2				//
		jsr 	LCDLINE				//
		bra	firePissDone			//
	firePissP2Hit:					//hit for player 2
                                                                                                        pshx
                                                                                                        ldx #DEBUGhit
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldaa	#0				//remove sunken shit
		staa	0, X				//
		ldaa	p1shits				//decrease count of p1 shits
		deca					//
		staa	p1shits				//
		jsr	updateFleet			//change fleet indicator
		ldx	#hit				//print message
		ldaa	#2				//
		jsr 	LCDLINE				//
		bra	firePissDone			//
	firePissP2Miss:					//player 2 misses
                                                                                                        pshx
                                                                                                        ldx #DEBUGhit
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldx	#miss				//print message
		ldaa	#2				//
		jsr 	LCDLINE				//
	firePissDone:					//
	puly						//restore registers
        pulx                                            //
	pulb						//
	pula						//
rts

updateFleet:
	psha						//backup registers
	pshb						//
	pshx						//
	pshy						//
                                                                                                        pshx
                                                                                                        ldx #DEBUGupdate
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
	ldaa	#1					//a = fleet indicator
	ldab	p1shits					//b = player 1 shits
                                                                                                        psha
                                                                                                        pshb
                                                                                                        pshx
                                                                                                        ldx #p1
                                                                                                        jsr OUTSTRING
                                                                                                        jsr OUTCRLF
                                                                                                        ldx #DEBUGshits
													jsr OUTSTRING
													ldaa #0
													ldab p1shits
													jsr CONSOLEINT
													jsr OUTCRLF
                                                                                                        pulx
                                                                                                        pulb
                                                                                                        pula
	updateFleetP1:					//
		decb					//for each shit
		beq	updateFleetP1Done		//detect end of fleet
                ble     checkWin                        //catch game over
                                                                                                        //        blt     updateFleetFix                  //
		lsla					//make room
		inca					//add to fleet
		bra	updateFleetP1			//
                                                                                                        //updateFleetFix:                                 //avoid incorrect status by storing 0 mask
                                                                                                        //        ldaa    #0                              //
	updateFleetP1Done:				//
                lsla					//offset p1 so as not to block p2
                lsla					//
                lsla					//
                lsla					//
		staa	FLEET				//
                ldaa    #1                              //reset status for next player
                                                                                                        //ldaa    FLEET                           //
                                                                                                        psha
                                                                                                        pshb
                                                                                                        pshx
                                                                                                        ldx #DEBUGfleet
													jsr OUTSTRING
													ldaa #0
													ldab FLEET
													jsr CONSOLEINT
													jsr OUTCRLF
													pulx
                                                                                                        pulb
                                                                                                        pula
		ldab	p2shits				//switch players
                                                                                                        psha
                                                                                                        pshb
                                                                                                        pshx
                                                                                                        ldx #p2
                                                                                                        jsr OUTSTRING
                                                                                                        jsr OUTCRLF
                                                                                                        ldx #DEBUGshits
													jsr OUTSTRING
													ldaa #0
													ldab p2shits
													jsr CONSOLEINT
													jsr OUTCRLF
                                                                                                        pulx
                                                                                                        pulb
                                                                                                        pula
                cmpb    #0
                bne     updateFleetP2                   //
                                                                                                        pshx
                                                                                                        ldx #DEBUGinit
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
                incb                                    //avoid problems in initial placement
                deca                                    //
	updateFleetP2:					//
		decb					//
		ble	updateFleetP2Done		//
		lsla					//
		inca					//
		bra	updateFleetP2			//
	updateFleetP2Done:				//
		oraa	FLEET				//combine p1 & p2
		staa	FLEET				//
                                                                                                        psha
                                                                                                        pshb
                                                                                                        pshx
                                                                                                        ldx #DEBUGfleet
													jsr OUTSTRING
													ldaa #0
													ldab FLEET
													jsr CONSOLEINT
													jsr OUTCRLF
													pulx
                                                                                                        pulb
                                                                                                        pula
	updateFleetLights:				//
                                                                                                        pshx
                                                                                                        ldx #DEBUGstatus
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		coma					//display updated fleet
		staa 	LEDS				//
		coma					//
	puly						//restore registers
        pulx                                            //
	pulb						//
	pula						//
rts

checkWin:
	psha						//backup registers
	pshb						//
	pshx						//
	pshy						//
                                                                                                        pshx
                                                                                                        ldx #DEBUGcheck
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
	ldab	#0					//b = key counter
	ldx	#p1board				//x = addr. of current key
                                                                                                        pshx
                                                                                                        ldx #p1
                                                                                                        jsr OUTSTRING
                                                                                                        jsr OUTCRLF
                                                                                                        pulx
	checkWinP1:					//
		ldaa	0, X				//
		bne	checkWinP1Alive			//stop as soon as 1 shit is detected
		incb					//
		cmpb	#16				//4 rows x 4 cols = 16 positions to check
		beq	checkWinP1Dead			//detect p2 victory
		inx					//
		bra	checkWinP1			//
	checkWinP1Alive:				//
                                                                                                        pshx
                                                                                                        ldx #DEBUGalive
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldab	#0				//reset counter
		ldx	#p2board			//switch player
                                                                                                        pshx
                                                                                                        ldx #p2
                                                                                                        jsr OUTSTRING
                                                                                                        jsr OUTCRLF
                                                                                                        pulx
	checkWinP2:					//
		ldaa	0, X				//
		bne	checkWinP2Alive			//stop as soon as 1 shit is detected
		incb					//
		cmpb	#16				//4 rows x 4 cols = 16 positions to check
		beq	checkWinP2Dead			//detect p1 victory
		inx					//
		bra	checkWinP2			//
	checkWinP1Dead:					//
                                                                                                        pshx
                                                                                                        ldx #DEBUGdead
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldx	#p1				//print message
		ldaa	#1				//
		jsr 	LCDLINE				//
		ldx	#loss				//
		ldaa	#2				//
		jsr 	LCDLINE				//
		jsr	delay				//
		ldx	#p2				//print message
		ldaa	#1				//
		jsr 	LCDLINE				//
		ldx	#win				//
		ldaa	#2				//
		jsr 	LCDLINE				//
		bra	gameOver			//
	checkWinP2Dead:					//
                                                                                                        pshx
                                                                                                        ldx #DEBUGdead
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
		ldx	#p2				//print message
		ldaa	#1				//
		jsr 	LCDLINE				//
		ldx	#loss				//
		ldaa	#2				//
		jsr 	LCDLINE				//
		jsr	delay				//
		ldx	#p1				//print message
		ldaa	#1				//
		jsr 	LCDLINE				//
		ldx	#win				//
		ldaa	#2				//
		jsr 	LCDLINE				//
		bra	gameOver			//
	checkWinP2Alive:				//both players are still alive
                                                                                                        pshx
                                                                                                        ldx #DEBUGalive
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
	puly						//restore registers
        pulx                                            //
	pulb						//
	pula						//
rts

delay:
	psha						//backup registers
	pshb						//
	pshx						//
	pshy						//
                                                                                                        pshx
                                                                                                        ldx #DEBUGwait
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
	ldd	#0x80					//3 seconds
	jsr	WAIT					//
	jsr	WAIT					//
	jsr	WAIT					//
	jsr	WAIT					//
	jsr	WAIT					//
	jsr	WAIT					//
	puly						//restore registers
        pulx                                            //
	pulb						//
	pula						//
rts

gameOver:
                                                                                                        pshx
                                                                                                        ldx #DEBUGdone
                                                                                                        jsr OUTSTRING
                                                                                                        pulx
	ldx	#title					//print message
	ldaa	#1					//
	jsr 	LCDLINE					//
	ldx	#over					//
	ldaa	#2					//
	jsr 	LCDLINE					//
	jsr	delay					//
	gameOverAtEnd:					//
		ldaa	READY				//wait for submission to restart
		bne	main				//
		ldd	#0x80				//.5 second delay
		jsr	WAIT				//
		bra	gameOverAtEnd			//
