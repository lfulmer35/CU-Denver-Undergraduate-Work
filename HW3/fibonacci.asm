TITLE: reorder.asm
COMMENT !
Program Description: This program creates a fibonacci series {0,1,1,2,3,5,8} 
using an array. It then stores the last four values into the register EBX

Author: Lucas Fulmer
Creation Date: 18 Feb 2017
!

INCLUDE Irvine32.inc
clearEAX TEXTEQU <mov EAX, 0>	;//macro to clear registers
clearECX TEXTEQU <mov ECX, 0>
clearEBX TEXTEQU <mov EBX, 0>
move TEXTEQU <mov>				;//creating macro


.data
;//defining variables
fibArray BYTE 0, 1, 5 DUP(0)		;//creating BYTE size array to create a fibanocci series
fibinc BYTE 0						;//variable for adding an incremented interger

;//0,1,1,2,3,5,8

.code
main PROC
clearEBX					;//clearing register
clearEAX

move al, fibArray			;//al = 0
add al, [fibArray+1]		;//al = 1
move [fibArray+2], al		;//fibArray[2] = 1

add al, [fibArray+2]		;//al = 2
move [fibArray+3], al		;//fibArray[3] = 2

move al, [fibArray+2]		;//al = 2
add al, [fibArray+3]		;//al = 3
move [fibArray+4], al		;//fib[4] = 3

move al, [fibArray+3]		;//al = 2
add al, [fibArray+4]		;//al = 5
move [fibArray+5], al		;//fib[5] = 5

move al, [fibArray+4]		;//al = 3
add al, [fibArray+5]		;//al = 8
move [fibArray+6], al		;//fib[6] = 8

;//Now we fill the register 4 Bytes using fib[3] - fib[6]
move EBX, DWORD PTR [fibArray+3]		;//EBX = 08050302


call DumpRegs

exit
main ENDP
END main