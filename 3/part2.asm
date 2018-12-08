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
primes			.space	100
array1			.space 	100
array2			.space	100
dividend		.word	0x0000
divisor			.word	0x0000
valc			.word	0x0000
vald			.word	0x0000
compareUntil	.word	0x0000
counter			.byte	0x00
				.text


Start			mov 	#0002h,&dividend;
				mov		#primes,R10;

FindAllPrime	cmp 	#050,&counter
				jeq 	End; if(counter==50) jump to End
				mov 	#0002h,&divisor;
				mov 	&dividend, &compareUntil;
				rra 	&compareUntil;


FindOnePrime	cmp 	&divisor,&compareUntil;
				jge 	AddPrime;  if(divisor>compareUntil) jmp to AddPrime
				mov 	#0000h,&valc;
				mov 	#0000h,&vald;
				call 	#ModulusStart;
				cmp 	#0000h,&vald;
				jeq 	NotPrime;
				inc.b 	&divisor;
				jmp 	FindOnePrime


NotPrime		inc.b	&dividend;
				jmp 	FindAllPrime;

AddPrime		mov 	&dividend, counter(R10);
				inc.b 	&dividend;
				inc.b 	&counter;
				jmp		FindAllPrime;


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


End

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
