TITLE: reorder.asm
COMMENT !
Program Description: This program creates an array of 3 - double word elements and then re-orders them.
It uses direct offset and XCHG to accomplish this.

Author: Lucas Fulmer
Creation Date: 16 Feb 2017
!

INCLUDE Irvine32.inc
clearEAX TEXTEQU <mov EAX, 0>	;//macro to clear registers
clearECX TEXTEQU <mov ECX, 0>
clearEBX TEXTEQU <mov EBX, 0>
move TEXTEQU <mov>				;//creating macro


.data
;//defining variables
arrayD DWORD 32, 51, 12		;//creating DWORD size array which we will then re-order


.code
main PROC
clearEAX					;//clearing registers
clearEBX
clearECX

move EAX, arrayD
move EBX, [arrayD+4]
move ECX, [arrayD+8]
XCHG EAX, ECX				;//swapping registers that contain array values
move arrayD, EAX			;//moving 12d into first position of array
move [arrayD+8], ECX		;//moving 32d into last position of array

call DumpRegs

exit
main ENDP
END main