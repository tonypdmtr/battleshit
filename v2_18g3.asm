//version 2.18g3 revised 10-21-08 by Alexandra Holloway <fire@soe>
// saving X in OUTSTRING
//version 2.18g3 revised 05-20-02 by Stuart Norton <stuart@cse>
//      saving a,b,x,y registers in (non-simulator version of) OUTCHAR
//	saving y register in (non-simulator version of) GETCHAR
//	included CONSOLEINT and DUMPREGS (see below)
//	DUMPREGS updated to output CCR
//version 2.17g2 revised on 5-9-1 by Robert Stone <talby@cats.ucsc.edu>
//	gasp was bad, cpp is a better preprocessor.  It looks a little
//	strange, but gets errors reported in the right files on the right
//	lines.
//version 2.17g revised on 4-25-01 by Robert Stone <talby@cats.ucsc.edu>
//	to GNU assembler syntax (mostly).  Simulator support abandoned,
//	ifdefs remain for documentation purposes.
//version 2.17 revised on 7-11-00 by alexandra carey <fire@cse.ucsc.edu>
//   to include LCDINT, a procedure that displays an int to LCD.
//version 2.17 revised on 5-14-00 by CWM to avoid LCD_CMD data clobbering
//version 2.17 revised on 5-12-00 by Cliff McIntire to remove CR at end of
//   OutString
//version 2.17 revised on 2-29-00 by Corey Baker to avoid clobbering of data
//
// Startup Runtime Code for 12c 68hc11 Microcontroller Kit laboratory projects.
// This code is needed when using either the simulator only, or when
// producing files for download to the 12c trainer board.  Sections are
// conditionally assembled depending on whether the target is the simulator
// or trainer board.
// HISTORY:
// //version 1.0 25 Feb 99
//   First version to get students up and running with the development system
//   employing the simulator.  It was not tested with the Trainer Board.
// //version 2.0  8 Feb 99/scp
//   Modified to include the i/o UART procedures in the assembled user code.
//   Procedure      Description
// -------------  ----------------------------------------------------------
//   GETCHAR        Reads a single character from the SCI port.
//   OUTCRLF        Write a carriage-return and line-feed out the SCI port.
//   OUTCHAR        Write a character out the SCI port.
//   OUTSTRING      Writes a null-terminated string out the SCI port
//   SETUPSCI       Setup HC11 UART for 9600bps.
//   WAIT	   Software delay loop with 4.096ms resolution.
//
// //version 2.16 1 May 99/scp
//   Included device drivers to manage output to the LCD:
//   LCDLINE       Writes a null-terminated string to the LCD
//     call with A = 1 --> line1
//               A = 2 --> line2
//               x = pointer to first character of string
//   LCD_CMD        Writes to the LCD Command Register
//   LCD_CHAR       Writes to the LCD Character Array (for display)
//
// //version 2.17   20 May 99/scp (search for "build 17:" to see changes)
//   Added support for user interrupts.  Note that ver2.16 does not support
//   user hooks into the sram image table.  Everything else is otherwise identical.
//   Several minor changes were made involving the simulator that were not flagged.
//           2.17.1 4 June 99/scp
//           added cli to LCD_CMD and LCD_CHAR since interrupts are used in both.

//**************************************************************************
// The following should be the first line in your code when you want to run your
// program from within the simulator:
// $SET simulate
//
// When you are ready to download it to the 12c trainer board, the line should
// read:
// $SETNOT simulate
//
// Basic memory map:
#undef SIMULATE		// sorry, I can't test the simulator, so I'm dropping
			// support for now.  -talby

#define	REGBASE		0x8000	// start of 68HC11's 64-byte register block.
#define	ROMBASE		0x8040	// start of ROM.
#define	RAMBASE		0x1000	// start of user RAM area.
#define	RAMTOP		0x7bc0	// top of user RAM area.

//*************************************************************************
// These equates define i/o devices (as hardware ports) implemented on the 12c
// HC11 Trainer Board
#define	SWITCHES	0x7c00	// switches.
#define	LCD_CMD_REG	0x7c80	// lcd command.
#define	LCD_CHAR_REG	0x7c81	// lcd character.
#define	LEDS		0x7d00	// leds.
#define	DAC		0x7d80	// D/A.
#define	IOCS4		0x7e00	// io expansion port.
#define	IOCS5		0x7e80	//        "
#define	IOCS6		0x7f00	//        "
#define	IOCS7		0x7f80	//        "

#define	NULL		0x00	// end of text/table.
//build 17:
#define	CR		'\r'	// carriage return.
#define	LF		'\n'	// line feed.
#define	ESC		0x1b	// escape character

#define	USER_ISR	0x7bc1	// base of user interrupt jump table.
#define	_GOCODE		0x8040	// beginning of user monitor code.

// build 17:
// Ram isr image table jump addresses. Note the table is ordinal and that some vectors
// are not available to the user.  These are used or reserved for the system and have not
// been mapped from the corresponding ROM table.  See Motorola documentation for discussion
// of these vectors.
//       1       unavailable to user      SCI
#define	ISR_JUMP2	0x7bc5	// SPI
#define	ISR_JUMP3	0x7bc8	// Pulse Accumulator Input
#define	ISR_JUMP4	0x7bcb	// Pulse Accumulator Overflow
//       5       unavailable to user      Timer Overflow
//       6       unavailable to user      Output Compare 5
#define	ISR_JUMP7	0x7bd4	// Output Compare 4
#define	ISR_JUMP8	0x7bd7	// Output Compare 3
#define	ISR_JUMP9	0x7bda	// Output Compare 2
#define	ISR_JUMP10	0x7bde	// Output Compare 1
#define	ISR_JUMP11	0x7be3	// Input Capture 3
#define	ISR_JUMP12	0x7be6	// Input Capture 2
#define	ISR_JUMP13	0x7be9	// Input Capture 1
//       14      unavailable to user      Real Time Interrupt
#define	ISR_JUMP15	0x7bec	// IRQ
//       16      unavailable to user      XIRQ
//       17      unavailable to user      SWI
//       18      unavailable to user      Illegal Opcode
#define	ISR_JUMP19	0x7bf8	// Cop fail
#define	ISR_JUMP20	0x7bfb	// Cop clock fail
//       21      unavailable to user      Reset (found at 0x8040)

//*************************************************************************
// Some of the internal 64 registers are defined here.  Their definitions
// should be self-evident from the Motorola manuals.
#define	BAUD		REGBASE+0x2b	// sci baud register
#define	SCCR1		REGBASE+0x2c	// sci control1 register
#define	SCCR2		REGBASE+0x2d	// sci control2 register
#define	SCSR		REGBASE+0x2e	// sci status register
#define	SCDR		REGBASE+0x2f	// sci data register

//*************************************************************************
// Useful system variables
// These may change if the monitor software is changed.
// O.k. ver2.17//
// Addresses can be found in the linker map file.
#define	_GETCHR		0x8a0a	// char getchr(void)
#define	IRQCOUNT	0x02d5	// 16-bit integer that increments each time IRQ is called
#define	_PUTCHR		0x89e5	// char putchar(char c)
#define	TICSEC		0x02e3	// 16-bit integer that increments once each second.
#define	_WAIT		0x8a37	// software timer 4.096 ms per tick, argument in x-reg.
//build 17:
#define	USERTICK	0x02d7	// unsigned int incremented every 4.096ms by system clock
#define	IRQDEBOUNCE	0x02d3	// 

#ifdef SIMULATE
//*************************************************************************
// 68hc11 interrupt ROM interrupt vector table.  This ordinal table begins
// at 0xffd6 and ends at 0xffff.  Each vector entry is 16 bits and points
// into a user-editable area of RAM.  Although all are shown mapped in the
// simulator, not all are actually mapped in the Microkit.  See RAM isr jump
// table notations above.
//
//                ORG     $FFD6
	.sect .text
	.globl _start
_start:
                dw      USER_ISR        ; sci
                dw      USER_ISR+3t     ; spi
                dw      USER_ISR+6t     ; pulse acc input
                dw      USER_ISR+9t     ; pulse acc overf
                dw      USER_ISR+12t    ; timer overf
                dw      USER_ISR+15t    ; output compare 5
                dw      USER_ISR+18t    ; output compare 4
                dw      USER_ISR+21t    ; output compare 3
                dw      USER_ISR+24t    ; output compare 2
                dw      USER_ISR+27t    ; output compare 1
                dw      USER_ISR+30t    ; input capture 3
                dw      USER_ISR+33t    ; input capture 2
                dw      USER_ISR+36t    ; input capture 1
                dw      USER_ISR+39t    ; real time
                dw      USER_ISR+42t    ; irq
                dw      USER_ISR+45t    ; xirq
                dw      USER_ISR+48t    ; swi
                dw      USER_ISR+51t    ; illegal
                dw      USER_ISR+54t    ; cop fail
                dw      USER_ISR+57t    ; cop clock fail
                dw      _GOCODE         ; reset

//**********************************************************
// Procedure ISRSTUB
//                ORG     $7bff
	.sect .text
	.globl _start
_start:
ISRSTUB:        rti

//**********************************************************
// User ISR vector area.
//
//                ORG     user_isr
	.sect .text
	.globl _start
_start:
                jmp     ISRSTUB         ; sci
                jmp     ISRSTUB         ; spi
                jmp     ISRSTUB         ; pulse acc input
                jmp     ISRSTUB         ; pulse acc overf
                jmp     ISRSTUB         ; timer overf
                jmp     ISRSTUB         ; output compare 5
                jmp     ISRSTUB         ; output compare 4
                jmp     ISRSTUB         ; output compare 3
                jmp     ISRSTUB         ; output compare 2
                jmp     ISRSTUB         ; output compare 1
                jmp     ISRSTUB         ; input capture 3
                jmp     ISRSTUB         ; input capture 2
                jmp     ISRSTUB         ; input capture 1
                jmp     ISRSTUB         ; real time
                jmp     ISRSTUB         ; irq
                jmp     ISRSTUB         ; xirq
                jmp     ISRSTUB         ; swi
                jmp     ISRSTUB         ; illegal opcode
                jmp     ISRSTUB         ; cop fail
                jmp     ISRSTUB         ; cop clock fail
                jmp     ISRSTUB         ; reset

// reset vector starts here:
//                ORG     ROMBASE
	.sect .text
	.globl _start
_start:

// move the internal 64 byte register block to 8000h
                ldaa    #0x08            ; content of init register
                staa    0x103d           ; load init at 0x103d

// These initializations keep the simulator happy.  Loading from an
// uninitialized register (cpu or memeory) will flag an error.  So,
// event though Switches, for example, is really only an input port on
// the Microkit, reading it requires that we initialize it with something.
// This is true of the other input ports as well.
                ldd     #0x0000          ; default
                ldy     #0x0000          ; default
                ldab    #0x00            ; default
                ldaa    #0x00            ; default
                staa    switches        ; i: default switch settings
                staa    leds            ; o: default all-on leds
                staa    lcd_cmd         ; i/o: default
                staa    lcd_char        ; i/o: default
                staa    dac             ; o: default

                ldx     #ramtop         ; set default stack
                txs                     ;
		jsr	setupsci        ; intialize serial port to mimic the microkit.
                jmp     main

//**********************************************************
// Procedure to setup HC11 UART for 9600bps when used with the simulator
// This is called automatically when the simulator is targeted.
// xtal = 8MHz
SETUPSCI:       psha
                ldaa    #0x30
                staa    baud
                ldaa    #0x00
                staa    sccr1
                ldaa    #0x2c
                staa    sccr2
                pula
                rts

#else
//                ORG     RAMBASE
	.sect .text
	.globl _start
_start:
                jmp     main
#endif


//*************************************************************************
// Writes a carriage-return and line-feed out the SCI port
OUTCRLF:        psha
		ldaa    #'\r'		// cr
                jsr     OUTCHAR         // write it out
                ldaa    #'\n'		// lf
                jsr     OUTCHAR         // write it out
                pula
		rts

//**************************************************************************
//* Writes a NULL terminated string out the SCI port
//* Index register x points to first byte of null-terminated string
OUTSTRING:      psha
                pshx
_OUTSTRING0:    ldaa    0,x
                cmpa    #NULL
                beq     _OUTSTRING1
                jsr     OUTCHAR
                inx
                bra     _OUTSTRING0
_OUTSTRING1:    pula
                pulx
//by CWM 5-12-00
//                jsr     OUTCRLF
                rts

//*************************************************************************
// Writes a null-terminated line of text to the Optrex Liquid Crystal Display
// Input: A = 1 --> line1
//        A = 2 --> line2
//        x = pointer to first character of string (null-termineated)
LCDLINE:        psha
		cmpa    #0x01            // which line test
                beq     _LCDLINE1
                ldaa    #0xa8            // line 1 command
                jmp     _LCDLINE2
_LCDLINE1:      ldaa    #0x80            // line 2 command
_LCDLINE2:      jsr     LCD_CMD          // write to command register
_LCDLINE3:      ldaa    0,x
                cmpa    #NULL
                beq     _LCDLINE4
                jsr     LCD_CHAR
                inx
                bra     _LCDLINE3
_LCDLINE4:	pula
                rts
//*************************************************************************
// Writes to the LCD Character Register
// Input: a
LCD_CHAR:       pshx
                pshy
#ifndef SIMULATE
                psha
		pshb
                ldd     #0x0001          // 8.1 ms wait
                cli
                jsr     WAIT
		pulb
//lcd_char0:     LDAA    LCD_CMD
//               ROLA
//               BCS     _lcd_char0
                pula
#endif
                staa    LCD_CHAR_REG
                puly
                pulx

                rts
//**************************************************************************
//* Writes to the LCD Command Register
//* Input: a
LCD_CMD:
                pshx
                pshy
#ifndef SIMULATE
                psha
                pshb // cwm 5-14-00
                ldd     #0x000f          // big wait
                cli
                jsr     WAIT
                pulb // cwm 5-14-00
                pula
#endif
                staa    LCD_CMD_REG
                puly
                pulx
                rts

//**************************************************************************
//* Reads a single character from the SCI port.
//* Returns result in accumulator A
GETCHAR:
#ifdef SIMULATE
 		ldaa    scsr            // status register
                anda    #0x20           // rdrf bit mask
                beq     GETCHAR         // loop if rdrf = 0
                ldaa    SCDR            // read data
_getchar1:      rts
#else
		pshy
                pshb
                jsr     _GETCHR         // calls getchr() in system
                tba
                pulb
		puly
                rts
#endif

//**************************************************************************
//* Write a character out the SCI port
//* Character is in the A accumulator
OUTCHAR:
#ifdef SIMULATE
		pshb
                ldab	SCSR		// load sci status register
                bitb	#0x80		// tdre bit
                beq	OUTCHAR         // loop until tdre = 1
                staa    SCDR            // write character to port
		pulb
                rts
#else
		psha
		pshb
                pshx
		pshy
                tab
                abx
                jsr     _PUTCHR         ;calls putchr() in system
                tba
		puly
                pulx
                pulb
		pula
                rts
#endif

//**************************************************************************
//* LCDINT 
//* By Cliff <mcintire@acm.org> and Alex <fire@cats.ucsc.edu>
//* Displays an unsigned integer to LCD from ACCD
//* Clobbers no registers!
//* Input: D 

_DIVISOR:     .short      0x00
_REMAINDER:   .short      0x00

LCDINT:
//Expects: 16-bit unsigned integer in ACCD
//Returns: nothing
//Notes:  prints ACCD to LCD. If input is negative, prints 0.
    pshx
    pshy
    psha
    pshb
    std     _REMAINDER
    ldd     #0
    cpd     _REMAINDER
    blt     _NOTZERO
    ldaa    #'0'
    jsr     LCD_CHAR
    bra	    _PRINTLOOPEND

_NOTZERO:
//find the greatest divisor
    ldd     #10000
    ldx     #10
_FINDDIV:
    cpd     _REMAINDER
    ble     _ENDFINDDIV
    idiv
    xgdx                // d->quo  x->rem
    ldx     #10
    bra     _FINDDIV

_ENDFINDDIV:
    std     _DIVISOR
    ldd     _REMAINDER
    ldx     _DIVISOR

_PRINTLOOP:
//decrement divisor, get next remainder & quotient
//print each quotient in turn
    idiv
    xgdx
    tba
    adda    #'0'
    jsr     LCD_CHAR
    stx     _REMAINDER

    ldd     _DIVISOR
    ldx     #10
    idiv
    cpx     #0			// exit if quo=0
    beq     _PRINTLOOPEND
    stx     _DIVISOR

    ldd     _REMAINDER
    bra     _PRINTLOOP
_PRINTLOOPEND:
    pulb
    pula
    puly
    pulx
    rts

//**************************************************************************
//* Software time-wasting loop. _WAIT maps to the actual wait() procedure in
//* the monitor, which uses the master system timer to count down an argument
//* variable in the D-Register.  Each decrement occurs at 4.096ms intervals.
//* Input: D -> total delay = D * (4.096E-3) seconds
WAIT:
#ifndef SIMULATE
		pshy
                jsr     _WAIT
		puly
#endif
                rts

#ifdef SIMULATE
//* The simulator is too dumb to know that the 64-byte embedded register block that
//* defaults to 0x1000 when the HC11 boots is re-mapped to 0x8000
//* when the code is run, so it flags an error at load time.  Oddly enough,
//* after running the code once, the simulator will then accept code organized
//* at 0x1000.
//* Hack: locate it just past the 64 byte boundry.
//                ORG     $1040
	.sect .text
	.globl _start
_start:
#endif

/*********************************************************************
* CONSOLEINT
*
* Displays an unsigned integer to the terminal from ACCD
* Based on LCDINT
* By Cliff <mcintire@acm.org> and Alex <fire@cats.ucsc.edu>
* Modified by David van der Bokke
* Clobbers no registers!
* Input: D
**********************************************************************/
	
DIVISOR1:     .short      0x00
REMAINDER1:   .short      0x00

CONSOLEINT:
//Expects: 16-bit unsigned integer in ACCD
//Returns: nothing
//Notes:  prints ACCD to LCD. If input is negative, prints 0.
    pshx
    pshy
    psha
    pshb
    std     REMAINDER1
    ldd     #0
    cpd     REMAINDER1
    blt     notzero1
    ldaa    #0x30
    jsr     OUTCHAR
    bra	    printloopend1

notzero1:
;find the greatest divisor
    ldd     #0x2710      // 10000
    ldx     #0xa         // 10
finddiv1:
    cpd     REMAINDER1
    ble     endfinddiv1
    idiv
    xgdx                //d->quo  x->rem
    ldx     #10
    bra     finddiv1

endfinddiv1:
    std     DIVISOR1
    ldd     REMAINDER1
    ldx     DIVISOR1

printloop1:
//decrement divisor, get next remainder & quotient
//print each quotient in turn
    idiv
    xgdx
    tba
    adda    #0x30
    jsr     OUTCHAR
    stx     REMAINDER1

    ldd     DIVISOR1
    ldx     #0xa
    idiv
    cpx     #0         //exit if quo=0
    beq     printloopend1
    stx     DIVISOR1

    ldd     REMAINDER1
    bra     printloop1
printloopend1:
    pulb
    pula
    puly
    pulx
    rts

//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
//;
//; DUMPREGS (by voltron@cats - Devin Landes)
//; Dumps all registers - D, X, Y, SP, CCR
//; All registers are preserved
//; SP is not correct for the line where DUMPREGS is called,
//;    but relatively speaking it is. 
//;

// put the low nybble of B to the SCI in hex
OUTBLO:
 psha
 tba
 anda #0x0f
 cmpa #0xa
 blt  DIGIT
 suba #0xa
 adda #'a'
 suba #'0'
DIGIT:
 adda #'0'
 jsr  OUTCHAR
 pula
 rts

// put B to the SCI
OUTB:
 pshb
 lsrb
 lsrb
 lsrb
 lsrb
 jsr  OUTBLO
 pulb
 jsr  OUTBLO
 rts

// put D to the SCI
OUTD:
 pshb
 tab
 jsr  OUTB
 pulb
 jsr  OUTB
 rts

// just a helper function, puts ' D=', ' X=', etc.
OUTLABEL:
 psha
 ldaa #' '
 jsr  OUTCHAR
 pula
 jsr  OUTCHAR
 psha
 ldaa #'='
 jsr  OUTCHAR
 pula 
 rts

DUMPREGS:
 pshb
 psha
 pshx
 pshy
 tpa
 psha

 // register contents will be loaded from stack
 // based on offsets:
 // 0(SP): CCR
 // 1(SP): Y (hi)
 // 2(SP): Y (lo)
 // 3(SP): X (hi)
 // 4(SP): X (lo)
 // 5(SP): A
 // 6(SP): B

 tsx

 jsr  OUTCRLF
 ldaa #'D'
 jsr  OUTLABEL
 tsx
 ldaa 5,X
 ldab 6,X
 jsr  OUTD
 
 ldaa #'X'
 jsr  OUTLABEL
 ldd  3,X
 jsr  OUTD

 ldaa #'Y'
 jsr  OUTLABEL
 ldd  1,X
 jsr  OUTD

 ldaa #'S'
 jsr  OUTLABEL
 xgdx
 addd #0x8
 jsr  OUTD

 ldaa #'C'
 jsr  OUTLABEL
 pulb	// B contains CCR now
 jsr  OUTB

 // restore old CCR
 tba
 tap
 // restore other registers
 puly
 pulx
 pula
 pulb
 rts
