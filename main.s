;****************** main.s ***************
; Program written by: ***Jeremy Mattson**update this***
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016 
; Section ***Tuesday 1-2***update this***
; Instructor: ***Ramesh Yerraballi**update this***
; Lab number: 2
; Brief description of the program
; The overall objective of this system an interactive alarm
; Hardware connections
;  PF4 is switch input  (1 means SW1 is not pressed, 0 means SW1 is pressed)
;  PF3 is LED output (1 activates green LED) 
; The specific operation of this system 
;    1) Make PF3 an output and make PF4 an input (enable PUR for PF4). 
;    2) The system starts with the LED OFF (make PF3 =0). 
;    3) Delay for about 100 ms
;    4) If the switch is pressed (PF4 is 0), then toggle the LED once, else turn the LED OFF. 
;    5) Repeat steps 3 and 4 over and over

GPIO_PORTF_DATA_R       EQU   0x400253FC
GPIO_PORTF_DIR_R        EQU   0x40025400
GPIO_PORTF_AFSEL_R      EQU   0x40025420
GPIO_PORTF_PUR_R        EQU   0x40025510
GPIO_PORTF_DEN_R        EQU   0x4002551C
GPIO_PORTF_AMSEL_R      EQU   0x40025528
GPIO_PORTF_PCTL_R       EQU   0x4002552C
GPIO_PORTF_CR_R    		EQU   0x40025524
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
GPIO_PORTF_LOCK_R  		EQU   0x40025520
GPIO_LOCK_KEY      		EQU   0x4C4F434B

       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
	LDR R0, =SYSCTL_RCGCGPIO_R ;get clock address
	MOV R1, #0x20;on key
	STR R1, [R0] ; turn on F Clock
	LDR R10, =0x0 ;wait..
	LDR R10, =0x0 ;wait..
	
	LDR R0, =GPIO_PORTF_LOCK_R ;get lock address
	LDR R1, =GPIO_LOCK_KEY ;get unlock key
	STR R1, [R0] ;Unlock 
	
	LDR R0, =GPIO_PORTF_CR_R
	MOV R1, #0x1F ; allow changes to PF4-0
	STRB R1, [R0]
	
	LDR R0, =GPIO_PORTF_AMSEL_R
	MOV R1, #0x00 ; disable analog function
	STRB R1, [R0]
	
	LDR R0, =GPIO_PORTF_PCTL_R
	MOV R1, #0x00 ; GPIO clear bit PCTL
	STR R1, [R0]
	
	LDR R0, =GPIO_PORTF_DIR_R
	MOV R1, #0x0E	 ;PF4, PF0 input
	STRB R1, [R0]  ;and PF3, 2, 1 output
	
	LDR R0, =GPIO_PORTF_AFSEL_R
	MOV R1, #0x00 ; no alternate function
	STRB R1, [R0]  ; 
	
	LDR R0, =GPIO_PORTF_PUR_R
	MOV R1, #0x10 ; enable pullup resistors on PF4, PF0
	STRB R1, [R0]
	
	LDR R0, =GPIO_PORTF_DEN_R
	MOV R1, #0x1F ; enable digital pins PF4-PF0
	STRB R1, [R0]
	
	MOV R3, #0; LED OFF
	MOV R4, #1; SWITCH
	
;   Registers that shouldn't be changed
	LDR R0, =GPIO_PORTF_DATA_R
	;R11 the 'timer' value
	MOV R11, #0x3FFF
	MOV R11, R11, LSL #6
	
loop  ;wait until PF4 switch is pressed
	BL  checkPF4pressed
	BNE turnon	;if on
	B   loop	;else continue loop
	
turnoff
	AND R3, #0x00
	STR R3, [R0]
	
	BL  waitstart
	B   loop
	
turnon
	ORR R3, R1, #0x08
	STR R3, [R0]
	
	BL   waitstart
    B    turnoff

waitstart
	MOV R9, R11;
	MOV R8, #1
waitloop		
	SUBS R9, R8
	BNE waitloop ;until R9 = 0, R9--
	BX	LR

;If PF4 is press this will move 1 in R9 or 0 otherwise
checkPF4pressed
	
	LDR R1, [R0] ;value of Port F Registers
	AND R4, R1, #0x10 ;and bit 4 for PF4
	CMP R4, #0x10 ;check if PF4 button is pressed.  If bit is 0 then it is pressed.
	BEQ PF4notpressed
	
	MOVS R9, #1
	BX  LR  ;else return with R9 = 0
PF4notpressed
	MOVS R9, #0
	BX  LR  
;end check if PF4 pressed


       ALIGN      ; make sure the end of this section is aligned
       END        ; end of file
       