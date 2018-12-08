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
dividend		.byte	0x00
divisor			.byte	0x00
valc			.byte	0x00
vald			.byte	0x00
				.text

ModulusStart	mov 	&dividend,R15;
				mov 	&divisor,&valc;
				mov 	R15,&vald;
				rra 	R15; to compare with A/2.

While1			cmp 	&valc,R15; if(valc>dividend) jl works
				jl 		While2;
				rla 	&valc;
				jmp 	While1;

While2			cmp 	&divisor,&vald; if(divisor>vald) jl works
				jl 		ModulusEnd;
				cmp 	&valc,&vald;
				jge 	Wherever; if(vald>=valc) go to Wherever
				rra 	&valc;
				jmp 	While2;

Wherever		sub 	&valc,&vald;
				rra 	&valc;
				jmp 	While2;

ModulusEnd		ret;


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
