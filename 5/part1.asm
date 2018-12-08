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
Setup
			mov.b	#0,&P1OUT
			mov.b   #0FFh,&P1DIR
			mov.b	#001h,&P2DIR
			mov.b	#001h,&P2OUT
SetDisplay
			mov.w	#digits,R6

Display
			mov.b	@R6,&P1OUT
			inc.w   R6
			call    #Delay

			cmp 	#lastDigit, R6
			jeq		SetDisplay
			jmp 	Display

Delay
			mov.w   #0Ah ,R14
L2       	mov.w   #07A00h ,R15
L1       	dec.w   R15
			jnz     L1
			dec.w   R14
			jnz     L2
			ret

End 		nop

;digit array

digits		.byte  00111111b, 00000110b, 01011011b, 01001111b, 01100110b, 01101101b, 01111101b, 00000111b, 01111111b, 01101111b
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
            
