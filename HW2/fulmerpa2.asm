TITLE: fulmerpa2.asm
COMMENT !
Program Description: This program stores a factorial value into a register.
Additionally it causes EDX register to overflow and ECX to set the carry flag.
Lastly, the program computes the number of seconds in a day.

Author: Lucas Fulmer
Creation Date: 2 Feb 2017
!

INCLUDE Irvine32.inc

;//using macros for part 3
seconds EQU 24*60*60		
SECONDS_IN_DAY TEXTEQU <move EDX, seconds>

move TEXTEQU <mov>				;//creating macro


.data
;//defining variables
product WORD 5040d					;//5040d is the product of 2*3*4*5*6*7
overFlow SDWORD +2147483647			;//variable for overflow in part 2
overflow2 SDWORD +1
cFlag DWORD 0FFFFFFFFh				;//variable to set carry flag in ECX
cFlag2 DWORD 1h

.code
main PROC

;//Part 1
move AX, 0	
move AX, product

;//Part 2
move EDX, 0
move ECX, 0
move EDX, overFlow			;//overflow is the largest signed interger that can be represented in 32-bits
add EDX, overFlow2			;//adding decimal 1

move ECX, cFlag				;//largest unsigned interger
add ECX, cFlag2				;//adding 1h causing carry


;//Part 3
move EDX, 0					;//resetting EDX register for part 3
SECONDS_IN_DAY				;//moving the value 24*60*60 into EDX

call DumpRegs

exit
main ENDP
END main