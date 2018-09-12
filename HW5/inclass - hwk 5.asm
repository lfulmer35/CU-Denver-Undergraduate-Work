TITLE inclassMENU.asm
; Author:  Diane Yoha
; Date:  7 March 2018
; Description: This program presents a menu allowing the user to pick a menu option
;              which then performs a given task.
; 1.  The user enters a string of less than 50 characters.
; 2.  The entered string is converted to upper case.
; 3.  The entered string has all non - letter elements removed.
; 4.  Is the entered string a palindrome.
; 5.  Print the string.
; 6.  Exit
; ====================================================================================

Include Irvine32.inc 

;//Macros
ClearEAX textequ <mov eax, 0>
ClearEBX textequ <mov ebx, 0>
ClearECX textequ <mov ecx, 0>
ClearEDX textequ <mov edx, 0>
ClearESI textequ <mov esi, 0>
ClearEDI textequ <mov edi, 0>
maxLength = 51d

.data
Menuprompt1 byte 'MAIN MENU', 0Ah, 0Dh,
'==========', 0Ah, 0Dh,
'1. Enter a String:', 0Ah, 0Dh,
'2. Convert all elements to lower case: ',0Ah, 0Dh,
'3. Remove all non-letter elements: ',0Ah, 0Dh,
'4. Determine if the string is a palindrome: ',0Ah, 0Dh,
'5. Display the string: ',0Ah, 0Dh,
'6. Exit: ',0Ah, 0Dh, 0h
UserOption byte 0h
theString byte maxLength dup(0)
theStringLen byte 0
errormessage byte 'You have entered an invalid option. Please try again.', 0Ah, 0Dh, 0h


.code
main PROC

call ClearRegisters          ;// clears registers
startHere:
call clrscr
mov edx, offset menuprompt1
call WriteString
call readhex
mov useroption, al

mov edx, offset theString
mov ecx, lengthof theString
opt1:
cmp useroption, 1
jne opt2
call clrscr
mov ebx, offset thestringlen
call option1
jmp starthere

opt2:
cmp useroption, 2
jne opt3
call clrscr
movzx ecx, thestringlen
call option2
jmp starthere
opt3:
opt5:
cmp useroption, 5
jne opt6
call option5
jmp starthere
opt6:
cmp useroption, 6
jne oops
jmp quitit
oops:
push edx
mov edx, offset errormessage
call writestring
call waitmsg
pop edx
jmp starthere

quitit:
exit
main ENDP
;// Procedures
;// ===============================================================
ClearRegisters Proc
;// Description:  Clears the registers EAX, EBX, ECX, EDX, ESI, EDI
;// Requires:  Nothing
;// Returns:  Nothing, but all registers will be cleared.

cleareax
clearebx
clearecx
clearedx
clearesi
clearedi

ret
ClearRegisters ENDP
;// ---------------------------------------------------------------
option1 proc uses edx ecx
.data
option1prompt byte 'Please enter a string of characters (50 or less): ', 0Ah, 0Dh, '--->', 0h

.code
push edx       ;//saving the address of the string
mov edx, offset option1prompt
call writestring
pop edx

;//add procedure to clear string (loop through and place zeros)

call readstring
mov byte ptr [ebx], al     ;//length of user entered string, now in thestringlen

ret
option1 endp

option2 proc uses edx ebx
L2:
mov al, byte ptr [edx+esi]
cmp al, 41h
jb keepgoing
cmp al, 5ah
ja keepgoing
or al, 20h     ;//could use add al, 20h
mov byte ptr [edx+esi], al
keepgoing:
inc esi
loop L2
ret
option2 endp

option5 proc uses edx 
.data
option5prompt byte 'The String is: ', 0h
.code
call clrscr
push edx
mov edx, offset option5prompt
call writestring
pop edx
call writestring
call waitmsg
ret
option5 endp


END main

