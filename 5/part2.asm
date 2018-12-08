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
init_INT
			bis.b 	#040h, &P2IE;
			and.b 	#0BFh, &P2SEL
			and.b 	#0BFh, &P2SEL2; ask asisstant

			bis.b 	#040h, &P2IES
			clr 	&P2IFG
			eint

Setup		mov		#001h, &P2DIR
			mov		#001h, &P2OUT
			mov		#000h, &P1OUT
			mov 	#0FFh, &P1DIR
			mov		#000h, R8

SetDisplay
			mov		#letters, R6
			mov		#digits, R7;

DisplayLetter
			cmp		#lastDigit, R7
			jge		SetDisplay
			cmp 	#lastLetter, R6
			jge		SetDisplay

			mov.b	@R6, &P1OUT
			inc		R6
			call    #Delay
			cmp		#001h, R8
			jeq		DisplayOrder

			inc		R7


			jmp 	DisplayLetter


DisplayOrder
			mov.b	@R7, &P1OUT
			cmp		#000h, R8
			jeq		DisplayLetter
			jmp 	DisplayOrder

Delay
			mov.w   #0Ah ,R14
L2       	mov.w   #07A00h ,R15
L1       	dec.w   R15
			jnz     L1
			dec.w   R14
			jnz     L2
			ret

ISR
			dint
			mov.b	@R7, &P1OUT       				; disable  interrupts
			xor		#001h, R8
			clr 	&P2IFG          ; clear  the  flag
         	eint       				; enable  interrupts
         	reti       				; return  from  ISR


;digit array


digits		.byte  00000110b, 01011011b, 01001111b, 01100110b, 01101101b, 01111101b, 00000111b, 01111111b
lastDigit

;letter array

letters		.byte  01110111b, 00111001b, 01110110b, 00110000b, 00111000b, 00111000b, 01111001b, 00101101b
lastLetter

                                            

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
			.sect ".int03"
			.short ISR
