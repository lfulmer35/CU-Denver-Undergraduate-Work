TITLE fulmerhw5.asm

; Author:  Lucas Fulmer
; Date:  16 March 2018
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

call ClearRegisters				;// clears registers
startHere:						;//displaying the menu and receiving the user's input
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
cmp useroption, 3
jne opt4
call clrscr
movzx ecx, thestringlen
call option3
jmp starthere

opt4:
cmp useroption, 4
jne opt5
call clrscr
movzx ecx, thestringlen
call option4
jmp starthere

opt5:
cmp useroption, 5
jne opt6
movzx ecx, thestringlen
call option5
jmp starthere

opt6:
cmp useroption, 6
jne oops
jmp quitit

oops:							;//if user enters something other than '1 - 6'
push edx
mov edx, offset errormessage
call writestring
call crlf
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
push edx							;//saving the address of the string
mov edx, offset option1prompt
call writestring
pop edx
call readstring
mov byte ptr [ebx], al				;//length of user entered string, now in thestringlen
ret
option1 endp


COMMENT !
Description: Option2 proc changes all letters to lower case.
Receives: theString
Returns: theString in lower case
Requires: ecx for looping, edx for the string
!

option2 proc uses edx ebx
mov esi, 0
L2:
mov al, byte ptr [edx+esi]			;//taking one letter at a time
cmp al, 41h							;//comparing to 'A'
jb keepgoing
cmp al, 5ah							;//comparing to 'Z'
ja keepgoing
or al, 20h							;//changing letter to lowercase
mov byte ptr [edx+esi], al			;//moving lowercase letter back into string
keepgoing:
inc esi
loop L2
ret
option2 endp

COMMENT !
Description: Option3 removes all non-letters from the string
Receives: theString
Returns: theString in edx
Requires: theString in edx
!
option3 proc uses edx ebx
.data
tempString byte maxlength dup(0)	;//creating a temp string to store usable letters
iterator word 0h

.code
mov edi, offset tempString
mov esi, 0
L3:
mov al, byte ptr [edx+esi]
cmp al, 41h					;//if less than 'a', we keepgoing. otherwise continue
jb keepgoing
cmp al, 5Ah					;//if didn't jump to keepgoing, check if below or equal 'z', if yes jump to storeit
jbe storeit
cmp al, 61h					;//if not below 'a' and is above 'z', check if below 'A'. if so jump to keepgoing
jb keepgoing
cmp al, 7Ah					;//if above 'A' and below 'Z' storeit. otherwise continue to keepgoing
ja keepgoing

storeit:					;//putting the usable letters into "tempString"
mov [edi], al
inc di
inc iterator

keepgoing:						;//continuing to move through "theString"
mov byte ptr[edx + esi], al
inc esi
loop L3

mov esi, 0
movzx ecx, thestringlen
mov edi, offset tempString

replace:						;//now replacing contents of "theString" with "tempString"
mov al, [edi]
mov byte ptr[edx + esi], al
inc esi
inc di
loop replace
mov edi, 0
mov esi, 0
ret
option3 endp


COMMENT !
Description: Option4 checks whether the string is a palindrome 
Receives: theString 
Returns: N/A
Requires: theString in edx
!

option4 proc uses ecx ebx edx
.data
reversestring byte maxlength dup(0)		;//creating a string for comparison after making all letters lowercase
holdstring byte maxlength dup(0)		;//creating a string to hold our original string
notpal byte "Not a palindrome", 0h
printpal byte "Your string is a palindrome", 0h

.code
mov edi, offset holdstring
mov esi, 0
L4a:									;//this loop stores the original string
mov al, byte ptr[edx + esi]
mov [edi], al
inc di
inc esi
loop L4a

push edi								;//pushing the original string to stack
mov edi, offset reversestring
push eax
movzx ecx, thestringlen
call option2							;//option4 is not case sensitive
pop eax
movzx ecx, thestringlen
mov esi, 0
L4b:									;//this loop stores the lowercase string
mov al, byte ptr[edx + esi]
mov[edi], al
inc di
inc esi
loop L4b

mov esi, 0
movzx ecx, thestringlen				;//resetting the counter
invert:
mov al, [edi-1]						;//beginning at the end of the string 
cmp [edx+esi], al					;//compare jne to end and print "Not a palindrome"
jne notapal
dec di								;//moving backwards through "reverse string"
inc esi								;//moving forward through "theString"
loop invert

push edx
mov edx, offset printpal			;//printing "Yes" if the string is a palindrome
call clrscr
call writestring
pop edx
mov edi, 0
mov byte ptr [edx+esi], 0h
mov esi, 0
call crlf
jmp quit

notapal:						;//if not a palindrome
push edx
mov edx, offset notpal			;//printing "not a palindrome"
call clrscr
call writestring
call crlf
pop edx

quit:							;//now we have to restore the original string and quit the proc
pop edi
mov edi, offset holdstring
mov esi, 0
movzx ecx, thestringlen
restorestring:					;//restoring the original string 
mov al, byte ptr[edi + esi]
mov[edx], al
inc edx
inc esi
loop restorestring

call waitmsg
ret
option4 endp

COMMENT !
Description: Option5 prints "theString" to the console
Receives: "theString"
Returns: N/A
Requires: "theString" in edx
!

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
call crlf
call waitmsg
ret
option5 endp


END main