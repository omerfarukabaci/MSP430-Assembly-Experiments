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
var1		.word 0x0000
var2		.word 0x0000
counter		.byte 0x00
result		.word 0x0000
			.text

Setup		mov.b #0008h, &var1;
			mov.b #0003h, &var2;

Main		mov &var1, R14
			mov &var2, R13
			push &var1;
			push &var2;
			call #Divide; substract, multiply, divide
			pop R15;

Adder		pop R7
			pop R5;
			pop R6;
			add R5, R6;
			push R6;
			push R7
			ret;

Subtract	pop R7
			pop R5; var2
			pop R6; var1
			sub R5, R6;
			push R6
			push R7
			ret;

Multiply		pop R14; hold address
				pop R5; var2
				pop R6; var1
				mov R5, R7; temp_var2
				mov #4, &counter;
				mov #01h, R8; acc
				mov #0, R9; result

MultiplyLoop	cmp  #0, &counter
				jeq MultiplyEnd
				dec counter;
				and R8, R7;
				cmp R8, R7;
				jeq MultiplyAdd

MultiplyShift	rla R6;
				rla R8;
				mov R5, R7;
				jmp MultiplyLoop

MultiplyAdd		add R6, R9;
				jmp MultiplyShift

MultiplyEnd 	push R9;
				push R14;
				ret;

Divide			pop R14;
				pop R5; divisor
				pop R6; dividend
				mov R5, R7;  	 d
				mov R7, R8;   	 border
				rla R8;	      	 border
				mov #0b, R9;     result1
				mov #0b, R10;    result2
				cmp R5, R6;	 if R6<R5(dividend<divisor), jump to end.
				jl DEnd;
				inc R9;

DWhile1			cmp R8, R6; if R6<R8(dividend<border), jump
				jl DWhile1End;
				rla R7;
				rla R9;
				mov R7, R8;   	 border
				rla R8;	      	 border
				jmp DWhile1;

DWhile1End		cmp #1, R9;;
				jeq DWhile2;
				mov R9, R10;

				sub R7, R6;
DWhile2			cmp R5, R7;  if R7<R5 (d<divisor), jump
				jl DEnd;

DWhile3			cmp R7, R6; if R6>=R7 (d<=dividend), jump
				jge DWhile3End;
				rra R7;
				rra R10;
				jmp DWhile3;

DWhile3End		sub R7, R6;
				add R10, R9;
				jmp DWhile2;

DEnd			push R9
				push R14
				ret;

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
            
