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
counter	.byte	0x00;
		.text

Setup 	bis.b #11111111b,&P1DIR;
		bic.b #11111111b,&P1OUT;
		bis.b #00000000b,&P2DIR;
		bic.b #00000110b,&P2IN;

Start	bit.b #00000100b,&P2IN;
		jnz Divide;
		bit.b #00000010b,&P2IN;
		jnz Incr;
		jmp Start;

Divide	rra.b &counter;
		mov.b &counter,&P1OUT;
		jmp Wait;

Incr	inc.b &counter;
		mov.b &counter,&P1OUT;

Wait 	mov.w #050000,R15;
L1 		dec.w R15;
 		jnz L1;

Hold2	bit.b #00000100b,&P2IN;
		jz Hold;
		jmp Hold2;

Hold	bit.b #00000010b,&P2IN;
		jz Wait2;
		jmp Hold;

Wait2	mov.w #050000,R15;
L2 		dec.w R15;
 		jnz L2;
 		jmp Start;

                                            

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
            
