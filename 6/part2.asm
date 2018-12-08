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
;------------------------------------------------------------------------------
            	.data
seconds			.byte 00h
centiseconds	.byte 00h
				.text

init_INT	bis.b #040h, &P2IE
			and.b #0bfh, &P2SEL
			and.b #0bfh, &P2SEL2

			bis.b #040h, &P2IES
			clr &P2IFG
			eint

        	mov		#digits, R6
        	mov		#digits, R7
        	mov		#digits, R8
        	mov		#digits, R9
        	mov		#0, R10
mainlo		cmp #1, R10
			jeq zerofy

			mov.b   #0, &P1OUT
			mov.b   #0FFh, &P1DIR
            mov.b   #0, &P2OUT
			bis.b   #00Fh, &P2DIR

			mov		#100d, &TACCR0
			mov		#0000000000001100b, &TACCTL0
			mov		#0000001011010000b, &TACTL

			mov.b	#8, &P2OUT
			mov.b 	@R6, &P1OUT
			mov.b	#0, &P1OUT

			mov.b	#4, &P2OUT
			mov.b	@R7, &P1OUT
			mov.b	#0, &P1OUT

			mov.b	#2, &P2OUT
			mov.b 	@R8, &P1OUT
			mov.b	#0, &P1OUT

			mov.b	#1, &P2OUT
			mov.b	@R9, &P1OUT
			mov.b	#0, &P1OUT

			cmp 	#0, TAR
			jeq		incsec
			jmp mainlo

incsec
			inc		R6
			cmp		#lastDigit, R6
			jeq		incsec2
			jmp 	mainlo

incsec2		inc 	R7
			mov		#digits, R6
			cmp		#lastDigit, R7
			jnz		mainlo
			mov		#digits, R7

incsec3		inc 	R8
			mov		#digits, R7
			cmp		#lastDigit, R8
			jnz		mainlo
			mov		#digits, R8

incsec4		inc 	R9
			mov		#digits, R8
			cmp		#lastDigit, R9
			jnz		mainlo
			mov		#digits, R9
			jmp 	mainlo


zerofy		mov		#digits, R6
        	mov		#digits, R7
        	mov		#digits, R8
        	mov		#digits, R9
        	mov #0, TAR
        	mov		#0, R10
        	jmp mainlo


digits		.byte  00111111b, 00000110b, 01011011b, 01001111b, 01100110b, 01101101b, 01111101b, 00000111b, 01111111b, 01100111b
lastDigit

ISR
			dint
			xor #001h, R10
			clr &P2IFG
			eint
			reti

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
            .sect  ".int03"
            .short ISR

