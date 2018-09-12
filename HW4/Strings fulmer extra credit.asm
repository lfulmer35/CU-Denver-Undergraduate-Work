TITLE Strings.asm
COMMENT !
Description:  This program prompts the user to enter an integer (n). 
It then prints (n) number of random strings to the screen.

Author: Lucas Fulmer
Creation Date 6 March 2018
!

Include Irvine32.inc

cleareax textequ <mov eax, 0>
clearedx textequ <mov edx, 0>
clearecx textequ <mov ecx, 0>
clearebx textequ <mov ebx, 0>
move textequ <mov>


.data

.code
main Proc
cleareax
clearedx
clearecx
clearebx

call Randomize				;//seeding random number generator
call EnterInt				;//gets number of strings from the user
call Rstr					;//generates (n) number of random strings
call crlf
call WaitMsg

exit
main ENDP

;// Procedures
EnterInt Proc 
Comment !
Description:	Get n(number of random strings to print) from user.  
Receives:		Integer from the user
Returns:		EAX returns the number the user entered.   
Requires:		N/A  
!

.data
prompt1 byte "Please enter the number of strings you would like generated from 1 to 20.", 0ah, 0dh, 0h


.code
ifInvalid:					;//creating a loop to ensure valid input from user
move edx, offset prompt1	;//necessary for writeSring
call WriteString			;//writing our prompt to the screen
call crlf
call ReadInt				;//reading the user entered integer
cmp eax, 21					;//comparing to make sure the user entered a valid number
jae ifInvalid				;//jumping back to beginning of proc if input is above or equal to 21

ret
EnterInt ENDP
;//***************************************************

Rstr PROC

;//Description:		Generates (n) number of random strings.
;//Receives:		Returned value of EAX from Proc EnterInt
;//Returns:			N/A
;//Requires:		User entered integer, ECX for writing string, and seeded random number generator

.data

numStrings DWORD ?
StrArray byte 32 dup(0), 0h		;//array for storing random string

.code

move numStrings, eax		;//moving the user entered number into variable
move ecx, numStrings		;//passing value of (n) into ECX for counter

buildArrayLoop:				;//loop for building space for each array of strings
move eax, 25
call RandomRange			;//generating a random number for the size of the string from 0 to 25
add eax, 7					;//adding 7 to random number making possible numbers 7 to 32
push ecx					;//saving ecx value for outer loop
move ecx, eax				;//storing number of random letters for inner loop
move edx, offset StrArray	;//for storing the randomly generated array
move esi, edx				;//storing in esi for indexing the array

randStrLoop:				;//loop for building random strings
move eax, 26				;//for 26 letters in alphabet
call RandomRange			;//choosing a number from 0 to 26
add eax, 'A'				;//minimum value is 'A'
move byte ptr [esi], al		;//putting random letter into position (esi -> edx)
inc esi						;//increment for direct offset
loop randStrLoop

move eax, 15
call RandomRange
add eax, 1
call SetTextColor
call WriteString			;//printing string to screen
call crlf
move ecx, 32
move esi, edx				;//these two lines reset our index and counter so that we can fully erase the previous string

eraseString:
move byte ptr [esi], 0		;//setting each element in the array to 0
inc esi
loop eraseString

pop ecx						;//resetting ecx to for outer loop
loop buildArrayLoop			;//looping back to beginning of proc
move eax, 15
call SetTextColor

ret
Rstr ENDP
;//***************************************************


END main