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


			.data
x			.byte 0x00
w			.byte 0x00
seed		.byte 0x6f
result		.byte 0x00
			.text

init_INT	bis.b	#020h, &P2IE
			and.b	#0DFh, &P2SEL
			and.b	#0DFh, &P2SEL2
			bis.b	#020h, &P2IES
			clr		&P2IFG
			eint

Setup		mov 	#digits, R8
			mov.b   #0, &P1OUT
			mov.b   #0FFh, &P1DIR
			mov.b   #0, &P2OUT
			mov.b   #00Fh, &P2DIR

PrintX		mov.b	x, R7
			and.b	#07fh, R7
digit3
			cmp		#064h, R7
			jl 		digit2
			add 	#1, R8
			mov.b 	#1, &P2OUT
			mov.b 	@R8, &P1OUT
			mov.b	#0, &P1OUT
			mov		#digits, R8
			sub.b	#100, R7

digit2 		cmp		#00ah, R7
			jl		show2
			sub.b	#10, R7
			add		#1, R8
			jmp 	digit2

show2		mov.b 	#2, &P2OUT
			mov.b 	@R8, &P1OUT
			mov.b	#0, &P1OUT
			mov		#digits, R8

digit1		cmp		#0h, R7
			jeq		show1
			sub.b	#1, R7
			add		#1, R8
			jmp 	digit1

show1		mov.b 	#4, &P2OUT
			mov.b 	@R8, &P1OUT
			mov.b	#0, &P1OUT
			mov		#digits, R8

			jmp PrintX

MSW
			dint
			push 	#x
			call 	#Square; result is in R11
			mov.b 	R11, x; mov the result to the value of x means x = square(x)
			add.b 	seed, w; w = w + seed
			add.b 	w, x; x = x + w
			call 	#Shift4R; shift x four times right result in R10
			call 	#Shift4L; shift x four times left result in R9
			bis.b 	R9, R10; x<<4 | x>>4
			mov.b 	R10, x; x = x<<4 | x>>4
			eint
			ret

Shift4R
			mov.b 	x, R10
			clrc
			rrc.b 	R10
			clrc
			rrc.b 	R10
			clrc
			rrc.b 	R10
			clrc
			rrc.b 	R10; R10 = x>>4
			ret

Shift4L
			mov.b 	x, R9
			rla.b 	R9
			rla.b 	R9
			rla.b 	R9
			rla.b 	R9; R9 = x<<4
			ret

Square
			pop 	R14; hold address
			pop 	R9; hold x address
			mov 	@R9, R10
			mov		#0, R11
SqLoop
			cmp 	#0, R10
			jz		SqEnd
			add 	@R9, R11
			dec 	R10
			jmp 	SqLoop

SqEnd
			push 	R11; push result
			push 	R14; push adress
			ret;


ISR			dint
			call #MSW
			eint
			reti

			.data
digits		.byte  00111111b, 00000110b, 01011011b, 01001111b, 01100110b, 01101101b, 01111101b, 00000111b, 01111111b, 01100111b
lastDigit
                                            

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
            .sect	".int03"
            .short  ISR
