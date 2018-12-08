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

SetupP1 	bis.b #0f0h,&P1DIR ; P1.0 output
SetupP2		bis.b #00fh,&P2DIR ; P2 output
			xor.b #0e0h,&P1OUT ;
			xor.b #007h,&P2OUT ;
Mainloop
			call #Wait;
Step1		xor.b #020h,&P1OUT ;
			xor.b #004h,&P2OUT ;
			call #Wait;

Step2		xor.b #040h,&P1OUT ;
			xor.b #002h,&P2OUT ;
			call #Wait;

Step3		xor.b #080h,&P1OUT ;
			xor.b #001h,&P2OUT ;
			call #Wait;

Step4		xor.b #0e0h,&P1OUT ;
			xor.b #007h,&P2OUT ;
			jmp Mainloop ;

Wait 		mov.w #01000000,R15 ; Delay t o R15
L1			dec.w R15 ; Decrement R15
			jnz L1 ; Delay o ve r?
			ret ;

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
            
