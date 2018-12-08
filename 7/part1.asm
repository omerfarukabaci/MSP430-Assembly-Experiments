;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

Setup			clr.b		&P1IN
				clr.b		&P1IFG
				clr.b		&P1IES
				clr.b		&P2IN
				clr.b		&P2IES
				clr.b		&P2SEL

				clr.b		&P1OUT
				clr.b		&P1DIR
				clr.b		&P2OUT
				clr.b		&P2DIR

				mov.b	#0ffh, &P1DIR
				mov.b	#0c0h, &P2DIR
				mov		#string, R8
				call	#initLCD

Main			mov.b	#080h, &P2OUT

DisplayChar		mov.b	@R8, R9
				mov.b	R9, &P1OUT
				call	#triggerEN
				rla	R9
				rla	R9
				rla	R9
				rla	R9
				mov.b	R9, &P1OUT
				call	#triggerEN
				call	#delay

				mov.b	@R8, R10
				cmp		#0dh, R10
				jeq		NextLine
				inc		R8
				mov.b	@R8, R10
				cmp		#0, R10
				jeq		Finish
				jmp		DisplayChar

NextLine		mov.b	#000h, &P2OUT
				mov.b	#11000000b,&P1OUT; set ddram address to 40h
				call	#triggerEN
				mov.b	#00000000b,&P1OUT; and go to second line
				call	#triggerEN
				call	#delay
				mov.b	#080h, &P2OUT
				inc	R8
				jmp	DisplayChar

Finish			jmp	Finish

initLCD			mov.b	#000h, &P2OUT
				call	#delay
				mov.b	#00110000b, &P1OUT
				call	#triggerEN
				call	#delay
				mov.b	#00110000b, &P1OUT
				call	#triggerEN
				call	#delay
				mov.b	#00110000b, &P1OUT
				call	#triggerEN
				call	#delay
				mov.b	#00100000b, &P1OUT; 8-bit -> 4-bit
				call	#triggerEN
				call	#delay

				mov.b	#00100000b, &P1OUT
				call	#triggerEN
				mov.b	#10000000b, &P1OUT; 2 lines, 5x8 dot font
				call	#triggerEN
				call	#delay

				mov.b	#00000000b, &P1OUT
				call	#triggerEN
				mov.b	#10000000b, &P1OUT; set d, c, b = 0
				call	#triggerEN
				call	#delay

				mov.b	#00000000b, &P1OUT
				call	#triggerEN
				mov.b	#00010000b, &P1OUT; clear display
				call	#triggerEN
				call	#delay

				mov.b	#00000000b, &P1OUT
				call	#triggerEN
				mov.b	#01100000b, &P1OUT; enter mode
				call	#triggerEN
				call	#delay


				mov.b	#00000000b, &P1OUT
				call	#triggerEN
				mov.b	#11000000b, &P1OUT; open display
				call	#triggerEN
				call	#delay

				ret

delay			mov.w	#000Ah, r14
L2				mov.w	#0C35h, r15
L1				dec.w	r15
				jnz	L1
				dec.w	r14
				jnz	L2
				ret

triggerEN		bis.b	#01000000b, &P2OUT
				bic.b	#01000000b, &P2OUT
				ret

;at the bottom
				.data
string			.byte	"kaybetmeyi sevmem",0dh,"26",00h
endString

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
