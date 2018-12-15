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
random		.space 128
w			.byte 0x00
seed		.byte 0x6f
result		.byte 0x00
flag		.byte 0x00
			.text

init_INT	bis.b	#020h, &P2IE
			and.b	#0DFh, &P2SEL
			and.b	#0DFh, &P2SEL2
			bis.b	#020h, &P2IES
			clr		&P2IFG
			eint

Setup		mov		#random, R5
			mov		#0, flag

Main		mov 	#random, R12
			cmp		#1, flag
			jeq		rangen
			jmp 	Main

rangen
			mov		#128, R13
loop		cmp 	#0, R13
			jeq		loopend
			call 	#MSW

modloop
			cmp		#08h, x
			jl		saveran
			sub.b	#8, x
			jmp 	modloop

saveran
			cmp.b	#08h, x
			jeq		fix
			mov.b	x, R7
			mov.b	R7, 0(R12)
			inc		R12
			jmp 	loop
loopend		mov		#0, flag
			jmp 	Main

MSW
			call 	#Square; result is in R11
			mov.b 	R11, x; mov the result to the value of x means x = square(x)
			add.b 	seed, w; w = w + seed
			add.b 	w, x; x = x + w
			call 	#Shift4R; shift x four times right result in R10
			call 	#Shift4L; shift x four times left result in R9
			bis.b 	R9, R10; x<<4 | x>>4
			mov.b 	R10, x; x = x<<4 | x>>4
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
			mov 	x, R10
			mov		#0, R11
SqLoop
			cmp 	#0, R10
			jz		SqEnd
			add 	x, R11
			dec 	R10
			jmp 	SqLoop

SqEnd
			ret;


ISR			dint
			bis.b 	#01h, flag
			clr		&P2IFG
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
            .sect	".int03"
            .short  ISR
