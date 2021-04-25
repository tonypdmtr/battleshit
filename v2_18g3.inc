;*******************************************************************************
; version 2.18g3 revised 10-21-08 by Alexandra Holloway <fire@soe>
; saving X in OUTSTRING
; version 2.18g3 revised 05-20-02 by Stuart Norton <stuart@cse>
; saving a,b,x,y registers in (non-simulator version of) OutChar
; saving y register in (non-simulator version of) GETCHAR
; included CONSOLEINT and DUMPREGS (see below)
; DUMPREGS updated to output CCR
; version 2.17g2 revised on 5-9-1 by Robert Stone <talby@cats.ucsc.edu>
; gasp was bad, cpp is a better preprocessor.  It looks a little
; strange, but gets errors reported in the right files on the right
; lines.
; version 2.17g revised on 4-25-01 by Robert Stone <talby@cats.ucsc.edu>
; to GNU assembler syntax (mostly).  Simulator support abandoned,
; #ifdef's remain for documentation purposes.
; version 2.17 revised on 7-11-00 by alexandra carey <fire@cse.ucsc.edu>
; to include LCDINT, a procedure that displays an int to LCD.
; version 2.17 revised on 5-14-00 by CWM to avoid LCD_CMD data clobbering
; version 2.17 revised on 5-12-00 by Cliff McIntire to remove CR at end of
; OutString
; version 2.17 revised on 2-29-00 by Corey Baker to avoid clobbering of data
;
; Startup Runtime Code for 12c 68hc11 Microcontroller Kit laboratory projects.
; This code is needed when using either the simulator only, or when
; producing files for download to the 12c trainer board.  Sections are
; conditionally assembled depending on whether the target is the simulator
; or trainer board.
; HISTORY:
; version 1.0 25 Feb 99
; First version to get students up and running with the development system
; employing the simulator.  It was not tested with the Trainer Board.
; version 2.0  8 Feb 99/scp
; Modified to include the i/o UART procedures in the assembled user code.
; Procedure      Description
; -------------  ----------------------------------------------------------
; GetChar        Reads a single character from the SCI port.
; OutCRLF        Write a carriage-return and line-feed out the SCI port.
; OutChar        Write a character out the SCI port.
; OutString      Writes a null-terminated string out the SCI port
; SetupSCI       Setup HC11 UART for 9600bps.
; Wait           Software delay loop with 4.096ms resolution.
;
; version 2.16 1 May 99/scp
; Included device drivers to manage output to the LCD:
; LCDLINE       Writes a null-terminated string to the LCD
; call with A = 1 --> line1
; A = 2 --> line2
; x = pointer to first character of string
; LCD_CMD        Writes to the LCD Command Register
; LCD_CHAR       Writes to the LCD Character Array (for display)
;
; version 2.17   20 May 99/scp (search for "build 17:" to see changes)
; Added support for user interrupts.  Note that ver2.16 does not support
; user hooks into the sram image table.  Everything else is otherwise identical.
; Several minor changes were made involving the simulator that were not flagged.
; 2.17.1 4 June 99/scp
; added cli to LCD_CMD and LCD_CHAR since interrupts are used in both.

;**************************************************************************
; The following should be the first line in your code when you want to run your
; program from within the simulator:
; SIMULATE          def       1
;
; When you are ready to download it to the 12c trainer board, the line should
; read:
; $SETNOT SIMULATE
;
; Basic memory map:

REGS                equ       0x8000              ; start of 68HC11's 64-byte register block.
ROMBASE             equ       0x8040              ; start of ROM.
RAMBASE             equ       0x1000              ; start of user RAM area.
XINIT               equ       0x103d              ; reset INIT localtion
STACKTOP            equ       0x7bc0              ; top of user RAM area.

;*******************************************************************************
; Macros
;*******************************************************************************

putc                macro     [char]
                    mset      #
          #ifnb ~1~
                    psha
                    lda       ~1~
          #endif
                    !jsr      OutChar
          #ifnb ~1~
                    pula
          #endif
                    endm
;-------------------------------------------------------------------------------
print               macro     msg
                    mset      #','
                    pshx
          #if :n = 1
                    ldx       ~1~
                    jsr       OutString
          #else
                    ldx       ~2~
                    jsr       Line~#1~
          #endif
                    pulx
                    endm
;-------------------------------------------------------------------------------
crlf                macro
                    jsr       OutCRLF
                    endm
;-------------------------------------------------------------------------------
wait                macro     msec
                    pshd
                    ldd       #~#1~*1000/4096
                    !jsr      Wait
                    puld
                    endm
;-------------------------------------------------------------------------------
asciz               macro
                    mset      #
                    fcs       ~1~
                    #size     ~label~
                    endm
;-------------------------------------------------------------------------------
space               macro
                    mset      #
                    rmb       ~1~
                    #size     ~label~
                    endm

;*******************************************************************************
; These equates define i/o devices (as hardware ports) implemented on the 12c
; HC11 Trainer Board

switches            equ       0x7c00              ; switches
LCD_CMD_REG         equ       0x7c80              ; LCD command
LCD_CHAR_REG        equ       0x7c81              ; LCD character
leds                equ       0x7d00              ; LEDs
          #ifdef SIMULATE
dac                 equ       0x7d80              ; D/A
          #endif
; build 17:
CR                  equ       13                  ; Carriage Return
LF                  equ       10                  ; Line Feed

USER_ISR            equ       0x7bc1              ; base of user interrupt jump table

; build 17:
; Ram isr image table jump addresses. Note the table is ordinal and that some vectors
; are not available to the user.  These are used or reserved for the system and have not
; been mapped from the corresponding ROM table.  See Motorola documentation for discussion
; of these vectors.
                    #temp     USER_ISR
                    next      :temp,3             ; 1       unavailable to user      SCI
                    next      :temp,3             ; SPI
                    next      :temp,3             ; Pulse Accumulator Input
                    next      :temp,3             ; Pulse Accumulator Overflow
                    next      :temp,3             ; 5       unavailable to user      Timer Overflow
                    next      :temp,3             ; 6       unavailable to user      Output Compare 5
                    next      :temp,3             ; Output Compare 4
                    next      :temp,3             ; Output Compare 3
                    next      :temp,3             ; Output Compare 2
                    next      :temp,3             ; Output Compare 1
                    next      :temp,3             ; Input Capture 3
                    next      :temp,3             ; Input Capture 2
                    next      :temp,3             ; Input Capture 1
                    next      :temp,3             ; 14      unavailable to user      Real Time Interrupt
ISR_JUMP15          next      :temp,3             ; IRQ
                    next      :temp,3             ; 16      unavailable to user      XIRQ
                    next      :temp,3             ; 17      unavailable to user      SWI
                    next      :temp,3             ; 18      unavailable to user      Illegal Opcode
                    next      :temp,3             ; Cop fail
                    next      :temp,3             ; Cop clock fail
                    next      :temp,3             ; 21      unavailable to user      Reset (found at 0x8040)

;*******************************************************************************
; Some of the internal 64 registers are defined here.  Their definitions
; should be self-evident from the Motorola manuals.

BAUD                equ       REGS+0x2b           ; SCI baud register
SCCR1               equ       REGS+0x2c           ; SCI control1 register
SCCR2               equ       REGS+0x2d           ; SCI control2 register
SCSR                equ       REGS+0x2e           ; SCI status register
SCDR                equ       REGS+0x2f           ; SCI data register

;*******************************************************************************
; Useful system variables
; These may change if the monitor software is changed.
; O.k. ver2.17;
; Addresses can be found in the linker map file.

#ifndef SIMULATE
_GETCHR             equ       0x8a0a              ; char getchr(void)
_PUTCHR             equ       0x89e5              ; char putchar(char c)
#endif
_WAIT               equ       0x8a37              ; software timer 4.096 ms per tick, argument in x-reg.
; build 17:

#ifdef SIMULATE
;*************************************************************************
; 68hc11 interrupt ROM interrupt vector table.  This ordinal table begins
; at 0xffd6 and ends at 0xffff.  Each vector entry is 16 bits and points
; into a user-editable area of RAM.  Although all are shown mapped in the
; simulator, not all are actually mapped in the Microkit.  See RAM isr jump
; table notations above.

;*******************************************************************************
                    #VECTORS  $FFD6
;*******************************************************************************

                    dw        USER_ISR            ; sci
                    dw        USER_ISR+3          ; spi
                    dw        USER_ISR+6          ; pulse acc input
                    dw        USER_ISR+9          ; pulse acc overf
                    dw        USER_ISR+12         ; timer overf
                    dw        USER_ISR+15         ; output compare 5
                    dw        USER_ISR+18         ; output compare 4
                    dw        USER_ISR+21         ; output compare 3
                    dw        USER_ISR+24         ; output compare 2
                    dw        USER_ISR+27         ; output compare 1
                    dw        USER_ISR+30         ; input capture 3
                    dw        USER_ISR+33         ; input capture 2
                    dw        USER_ISR+36         ; input capture 1
                    dw        USER_ISR+39         ; real time
                    dw        USER_ISR+42         ; irq
                    dw        USER_ISR+45         ; xirq
                    dw        USER_ISR+48         ; swi
                    dw        USER_ISR+51         ; illegal
                    dw        USER_ISR+54         ; cop fail
                    dw        USER_ISR+57         ; cop clock fail
                    dw        Start               ; reset

;*******************************************************************************
; Procedure ISRSTUB
;*******************************************************************************
                    #ROM
;*******************************************************************************

ISRSTUB             proc
                    !...
                    rti

;**********************************************************
; User ISR vector area.

;*******************************************************************************
                    #ROM      USER_ISR
;*******************************************************************************

                    !jmp      ISRSTUB             ; SCI
                    !jmp      ISRSTUB             ; SPI
                    !jmp      ISRSTUB             ; pulse acc input
                    !jmp      ISRSTUB             ; pulse acc overf
                    !jmp      ISRSTUB             ; timer overf
                    !jmp      ISRSTUB             ; output compare 5
                    !jmp      ISRSTUB             ; output compare 4
                    !jmp      ISRSTUB             ; output compare 3
                    !jmp      ISRSTUB             ; output compare 2
                    !jmp      ISRSTUB             ; output compare 1
                    !jmp      ISRSTUB             ; input capture 3
                    !jmp      ISRSTUB             ; input capture 2
                    !jmp      ISRSTUB             ; input capture 1
                    !jmp      ISRSTUB             ; real time
                    !jmp      ISRSTUB             ; irq
                    !jmp      ISRSTUB             ; xirq
                    !jmp      ISRSTUB             ; swi
                    !jmp      ISRSTUB             ; illegal opcode
                    !jmp      ISRSTUB             ; COP fail
                    !jmp      ISRSTUB             ; COP clock fail
                    !jmp      ISRSTUB             ; reset

; reset vector starts here:
;*******************************************************************************
                    #ROM      ROMBASE
;*******************************************************************************

Start               proc
; move the internal 64 byte register block to 8000h
                    lda       #0x08               ; content of INIT register
                    sta       XINIT               ; load init at 0x103d

; These initializations keep the simulator happy.  Loading from an
; uninitialized register (cpu or memeory) will flag an error.  So,
; event though Switches, for example, is really only an input port on
; the Microkit, reading it requires that we initialize it with something.
; This is true of the other input ports as well.
                    clrd
                    clry
                    clrd
                    sta       switches            ; i: default switch settings
                    sta       leds                ; o: default all-on leds
                    sta       LCD_CMD_REG         ; i/o: default
                    sta       LCD_CHAR_REG        ; i/o: default
                    sta       dac                 ; o: default

                    ldx       #STACKTOP           ; set default stack
                    txs
                    bsr       SetupSCI            ; intialize serial port to mimic the microkit.
                    jmp       Main

;*******************************************************************************
; Procedure to setup HC11 UART for 9600bps when used with the simulator
; This is called automatically when the simulator is targeted.
; xtal = 8MHz

SetupSCI            proc
                    psha
                    lda       #0x30
                    sta       BAUD
                    clr       SCCR1
                    lda       #0x2c
                    sta       SCCR2
                    pula
                    rts
#else
_start              jmp       Main
#endif
;*************************************************************************
; Writes a carriage-return and line-feed out the SCI port

OutCRLF             proc
                    @putc     #CR                 ; write CR out
                    @putc     #LF                 ; write LF out
                    rts

;**************************************************************************
; Writes a NULL terminated string out the SCI port
; Index register x points to first byte of null-terminated string

OutString           proc
                    psha
                    pshx
Loop@@              lda       ,x
                    beq       Done@@
                    @putc
                    inx
                    bra       Loop@@
Done@@              pula
                    pulx
;                   @crlf                         ; by CWM 5-12-00
                    rts

;*******************************************************************************

Line1               proc
                    psha
                    lda       #1
                    bsr       LCDLINE
                    pula
                    rts

;*******************************************************************************

Line2               proc
                    psha
                    lda       #2
                    bsr       LCDLINE
                    pula
                    rts

;*******************************************************************************
; Purpose: Write a null-terminated line of text to the Optrex Liquid Crystal Display
; Input  : A = line to write (1..2)
;        : X = pointer to first character of string (null-termineated)

LCDLINE             proc
                    psha
                    cmpa      #1                  ; which line test
                    beq       _1@@
                    lda       #0xa8               ; line 1 command
                    bra       _2@@
_1@@                lda       #0x80               ; line 2 command
_2@@                bsr       LCD_CMD             ; write to command register
Loop@@              lda       ,x
                    beq       Done@@
                    bsr       LCD_CHAR
                    inx
                    bra       Loop@@
Done@@              pula
                    rts

;*******************************************************************************
; Writes to the LCD Character Register
; Input: a

LCD_CHAR            proc
                    pshx
                    pshy
          #ifndef SIMULATE
                    pshd
                    cli
                    @wait     #8                  ; 8.1 ms wait
;Loop@@             lda       LCD_CMD_REG
;                   rola
;                   bcs       Loop@@
                    puld
          #endif
                    sta       LCD_CHAR_REG
                    puly
                    pulx
                    rts

;*******************************************************************************
; Writes to the LCD Command Register
; Input: a

LCD_CMD             proc
                    pshx
                    pshy
          #ifndef SIMULATE
                    pshd                          ; cwm 5-14-00
                    cli
                    @wait     #61                 ; big wait
                    puld                          ; cwm 5-14-00
          #endif
                    sta       LCD_CMD_REG
                    puly
                    pulx
                    rts

;*******************************************************************************
; Write a character out the SCI port
; Character is in the A accumulator

OutChar             proc
          #ifdef SIMULATE
                    pshb
Loop@@              ldb       SCSR                ; load sci status register
                    bitb      #0x80               ; tdre bit
                    beq       Loop@@              ; loop until tdre = 1
                    sta       SCDR                ; write character to port
                    pulb
          #else
                    push
                    tab
                    abx
                    jsr       _PUTCHR             ; calls putchr() in system
                    tba
                    pull
          #endif
                    rts

;**************************************************************************
; LCDINT
; By Cliff <mcintire@acm.org> and Alex <fire@cats.ucsc.edu>
; Displays an unsigned integer to LCD from ACCD
; Clobbers no registers!
; Input: D

_DIVISOR            dw        00
_REMAINDER          dw        00

;*******************************************************************************
; Expects: 16-bit unsigned integer in ACCD
; Returns: nothing
; Note(s): prints ACCD to LCD. If input is negative, prints 0.

LCDINT              proc
                    push
                    std       _REMAINDER
                    clrd
                    cpd       _REMAINDER
                    blt       NotZero@@
                    lda       #'0'
                    bsr       LCD_CHAR
                    bra       Done@@
NotZero@@ ;-------------------------------------- ; find the greatest divisor
                    ldd       #10000
                    ldx       #10
Loop@@              cpd       _REMAINDER
                    ble       _1@@
                    idiv
                    xgdx                          ; d->quo x->rem
                    ldx       #10
                    bra       Loop@@
_1@@                std       _DIVISOR
                    ldd       _REMAINDER
                    ldx       _DIVISOR
PLoop@@   ;--------------------------------------
          ; decrement divisor, get next remainder & quotient
          ; print each quotient in turn
          ;--------------------------------------
                    idiv
                    xgdx
                    tba
                    adda      #'0'
                    !jsr      LCD_CHAR
                    stx       _REMAINDER

                    ldd       _DIVISOR
                    ldx       #10
                    idiv
                    cpx       #0                  ; exit if quo=0
                    beq       Done@@
                    stx       _DIVISOR

                    ldd       _REMAINDER
                    bra       PLoop@@

Done@@              pull
                    rts

;*******************************************************************************
; Software time-wasting loop. _WAIT maps to the actual wait() procedure in
; the monitor, which uses the master system timer to count down an argument
; variable in the D-Register.  Each decrement occurs at 4.096ms intervals.
; Input: D -> total delay = D * (4.096E-3) seconds

Wait                proc
          #ifndef SIMULATE
                    pshy
                    jsr       _WAIT
                    puly
          #endif
                    rts

;*******************************************************************************
; CONSOLEINT
;
; Displays an unsigned integer to the terminal from ACCD
; Based on LCDINT
; By Cliff <mcintire@acm.org> and Alex <fire@cats.ucsc.edu>
; Modified by David van der Bokke
; Clobbers no registers!
; Input: D

DIVISOR1            dw        0
REMAINDER1          dw        0

;*******************************************************************************
; Expects: 16-bit unsigned integer in ACCD
; Returns: nothing
; Notes:  prints ACCD to LCD. If input is negative, prints 0.

CONSOLEINT          proc
                    push
                    std       REMAINDER1
                    clrd
                    cpd       REMAINDER1
                    blt       _1@@
                    @putc     #'0'
                    bra       Done@@
_1@@      ;-------------------------------------- ; find the greatest divisor
                    ldd       #10000
                    ldx       #10
Loop@@              cpd       REMAINDER1
                    ble       _2@@
                    idiv
                    xgdx                          ; d->quo x->rem
                    ldx       #10
                    bra       Loop@@
_2@@                std       DIVISOR1
                    ldd       REMAINDER1
                    ldx       DIVISOR1
PLoop@@   ;--------------------------------------
          ; decrement divisor, get next remainder & quotient
          ; print each quotient in turn
          ;--------------------------------------
                    idiv
                    xgdx
                    tba
                    adda      #'0'
                    @putc
                    stx       REMAINDER1

                    ldd       DIVISOR1
                    ldx       #10
                    idiv
                    cpx       #0                  ; exit if quo=0
                    beq       Done@@
                    stx       DIVISOR1

                    ldd       REMAINDER1
                    bra       PLoop@@

Done@@              pull
                    rts

;*******************************************************************************
; DUMPREGS (by voltron@cats - Devin Landes)
; Dumps all registers - D, X, Y, SP, CCR
; All registers are preserved
; SP is not correct for the line where DUMPREGS is called,
;    but relatively speaking it is.

;*******************************************************************************
; put B to the SCI

OUTB                proc
                    pshb
                    lsrb:4
                    bsr       OUTBLO
                    pulb
;                   bra       OUTBLO

;*******************************************************************************
; put the low nibble of B to the SCI in hex

OUTBLO              proc
                    psha
                    tba
                    anda      #0x0f
                    cmpa      #10
                    blt       _@@
                    adda      #'a'-'0'-10
_@@                 adda      #'0'
                    @putc
                    pula
                    rts

;*******************************************************************************
; put D to the SCI

OUTD                proc
                    pshb
                    tab
                    bsr       OUTB
                    pulb
                    bra       OUTB

;*******************************************************************************
; just a helper function, puts ' D=', ' X=', etc.

OUTLABEL            proc
                    @putc     #' '
                    @putc
                    @putc     #'='
                    rts

;*******************************************************************************
                    #Exit
;*******************************************************************************

                    #spauto

DUMPREGS            proc
                    pshy      reg_y@@
                    pshx      reg_x@@
                    pshd      reg_d@@
                    #ais
                    tpa
                    psha      ccr@@
          ;--------------------------------------
          ; register contents will be loaded from stack
          ; based on offsets:
          ; 0(SP): CCR
          ; 1(SP): Y (hi)
          ; 2(SP): Y (lo)
          ; 3(SP): X (hi)
          ; 4(SP): X (lo)
          ; 5(SP): A
          ; 6(SP): B
          ;--------------------------------------
                    @crlf
                    lda       #'D'
                    bsr       OUTLABEL
                    tsx
                    ldd       reg_d@@,spx
                    bsr       OUTD

                    lda       #'X'
                    bsr       OUTLABEL
                    ldd       reg_x@@,spx
                    bsr       OUTD

                    lda       #'Y'
                    bsr       OUTLABEL
                    ldd       reg_y@@,spx
                    bsr       OUTD

                    lda       #'S'
                    bsr       OUTLABEL
                    xgdx
                    addd      #:sp+1              ;WAS: 8
                    bsr       OUTD

                    lda       #'C'
                    bsr       OUTLABEL
          #iftos ccr@@
                    pulb                          ; B contains CCR now
          #else
                    tsx
                    ldb       ccr@@,spx
          #endif
                    bsr       OUTB
          ;-------------------------------------- ; restore old CCR
                    tba
                    tap
          ;-------------------------------------- ; restore other registers
          #ifnz :ais
                    ins::ais
          #endif
                    pull
                    rts

;*******************************************************************************
; Reads a single character from the SCI port.
; Returns result in accumulator A

GetChar             proc
          #ifdef SIMULATE
Loop@@              lda       SCSR                ; status register
                    anda      #0x20               ; rdrf bit mask
                    beq       Loop@@              ; loop if rdrf = 0
                    lda       SCDR                ; read data
          #else
                    pshy
                    pshb
                    jsr       _GETCHR             ; calls getchr() in system
                    tba
                    pulb
                    puly
          #endif
                    rts
