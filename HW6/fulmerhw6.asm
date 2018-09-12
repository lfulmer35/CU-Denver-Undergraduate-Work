TITLE fulmerhw6.asm

; Author:  Lucas Fulmer
; Date:  6 April 2018

; Description: This program uses a Caesar cypher to encrypt and decrypt words or phrases
; ====================================================================================

Include Irvine32.inc 

;//Macros
ClearEAX textequ <mov eax, 0>
ClearEBX textequ <mov ebx, 0>
ClearECX textequ <mov ecx, 0>
ClearEDX textequ <mov edx, 0>
ClearESI textequ <mov esi, 0>
ClearEDI textequ <mov edi, 0>
move textequ <mov>
maxLength = 51d

.data

UserOption byte 0h
theKey byte maxLength dup (0)
secretMessage byte maxLength dup(0)
errormessage byte 'You have entered an invalid option. Please try again.', 0Ah, 0Dh, 0h


.code
main PROC

call ClearRegisters				;// clears registers. Taken from Assignment 5
move edx, offset theKey
move ecx, maxLength
call getKey						;//Takes a key from the user prior to allowing them to encrypt/decrypt


menuLoop:
move esi, offset useroption
call displayMenu

cmp useroption, 1
jne option2
move edx, offset theKey
move ecx, maxLength
call getKey
jmp menuLoop

option2:
cmp useroption, 2
jne option3
move ecx, maxLength
move edx, offset secretMessage
call getMessage
move esi, offset secretMessage
call upperCase
move esi, offset secretMessage
call removeNonLetter
jmp menuLoop

option3:
cmp useroption, 3
jne option4
move edx, offset secretMessage		;//pointing edx at secretMessage
move esi, offset theKey				;//pointing esi at theKey
call encryptIt
jmp menuLoop

option4:
cmp useroption, 4
jne option5
move edx, offset secretMessage
move esi, offset theKey
call decryptIt
jmp menuLoop

option5:
cmp useroption, 5
jne option6
move edx, offset secretMessage
call printIt
jmp menuLoop

option6:
cmp useroption, 6
jne oops
jmp quitit

oops:
move edx, offset errorMessage
call writestring
call waitmsg
jmp menuLoop

quitit:
exit
main endp


;// Procedures
;// ===============================================================
displayMenu proc

COMMENT !
Description: This proc simply displays the menu and takes the user's input
Receives: Decimal input from the user
Returns : This proc returns the useroption input
Requires: N/A
!

.data
Menuprompt byte 'MAIN MENU', 0ah, 0dh,
'==========', 0ah, 0dh,
'1. Enter a new key. ', 0ah, 0dh,
'2. Enter a phrase for encryption/decryption. ', 0ah, 0dh,
'3. Encrypt message. ', 0ah, 0dh,
'4. Decrypt a phrase. ', 0ah, 0dh,
'5. Print message.', 0ah, 0dh,
'6. Exit: ', 0ah, 0dh, 0h
.code
call clrscr
move edx, offset Menuprompt
call writestring
call readDec
move byte ptr [esi], al
call clrscr

ret
displayMenu endp


;//--------------------------------

getKey proc

COMMENT !
Description: This proc reads in the user entered key
Receives : String from the user
Returns : Returns updated key via offset in EDX
Requires : offset of theKey must be in EDX
!

.data
keyPrompt byte "Please enter the key you would like to use: ", 0ah, 0dh, 0h
noKey byte 'You did not enter anything, Silly...', 0ah, 0dh, 0h

.code
check1:
call clrscr
push edx
move edx, offset keyprompt
call writestring
pop edx
call readstring
cmp al, 0
je invalid1
ja end1

invalid1:
push edx
move edx, offset noKey
call writestring
pop edx
call waitmsg
jmp check1

end1:
call clrscr
ret
getKey endp

;//------------------------------------------------

getMessage proc

COMMENT !
Description: This proc allows the user to enter a message to be encrypted or decrypted
Receives : String input from the user
Returns : This proc returns the offset of secretMessage in EDX
Requires : offset of secretMessage must be in EDX
!

.data
messageprompt byte 'Enter message: ', 0ah, 0dh, 0h
nomessage byte "You didn't enter anything, silly...", 0ah, 0dh, 0h

.code
messageloop:
call clrscr
push edx
move edx, offset messageprompt
call writestring
pop edx
call readstring
cmp al, 0
je invalid2
ja end2

invalid2:
push edx
move edx, offset nomessage
call writestring
pop edx
call waitmsg
jmp messageloop

end2:
call clrscr
ret
getMessage endp


;//-----------------------------------

encryptIt proc;//uses edx esi

COMMENT !
Description: This proc encrypts the user's message
Receives : N/A
Returns : This proc returns the newly encrypted or decrypted message
Requires : offset of secretMessage in EDX and offset of theKey in ESI
!

.data

.code
push esi
encryptloop:
cmp byte ptr [edx], 0
je end3
cmp byte ptr[esi], 0
je resetKey
ja keepencrypting

resetKey:					;//got the idea of this from Yves. resets theKey by starting at the original offset
pop esi
push esi

keepencrypting:
movzx eax, byte ptr [esi]
move ebx, 1Ah				;//preparing for division/modulus
div bl
add byte ptr [edx], ah
cmp byte ptr[edx], 'Z'
jbe capitalLetter
movzx eax, byte ptr[edx]
sub al, 'Z'
add al, '@'
move byte ptr[edx], al

capitalLetter:
inc esi
inc edx
jmp encryptloop

end3:
pop esi
ret
encryptIt endp


;//-----------------------------------------

decryptIt proc

COMMENT !
Description: This proc decrypts the user's message
Receives : N/A
Returns : This proc returns secretMessage using the offset in edx
Requires : offset of secretMessge in EDX and offset of theKey in ESI
!

.data
.code
push esi
decryptLoop:
cmp byte ptr [edx], 0
je end4
cmp byte ptr[esi], 0
je resetKey2
ja keepdecrypting

resetKey2:
pop esi
push esi					;//got the idea of this from Yves. resets theKey by restoring the original offset

keepdecrypting:
movzx eax, byte ptr[esi]
move ebx, 1Ah				;//prepping for division/mod
div bl	
sub byte ptr[edx], ah		;//subtracting the remainder
cmp byte ptr[edx], 41h		;//if it's equal or above 'A'
jae capitalLetter2
movzx eax, byte ptr[edx]	
mov ebx, 41h				;//otherwise subtract from 'A' and negate to give us a negative value
sub bl, al
neg bl
add bl, 5Bh					;//Then add the negative value to 'Z' to get back to the original position
move byte ptr[edx], bl

capitalLetter2:
inc esi
inc edx
jmp decryptLoop

end4:
pop esi
ret
decryptIt endp

;//----------------------------------------

printIt proc

COMMENT !
Description: This proc prints the encrypted or decrypted secretMessage
Receives : N/A
Returns : N/A
Requires : the offset of secretMessage in EDX
!

.data
.code
move esi, 1				;//using esi as a counter
printLoop:
cmp byte ptr[edx], 0	;//if null terminator
je end5
cmp esi, 5				;//if we have printed five letters, then print a space
jbe print
move al, ' '
call writechar
move esi, 1				;//reset for next five letters

print:						;//otherwise continue printing letters
move al, byte ptr [edx]
call writechar
inc edx
inc esi
jmp printLoop

end5:
call crlf
call waitmsg
ret
printIt endp


;//----------------------------------------------


upperCase proc

COMMENT !
Description: This proc converts all letters to uppercase
Receives : N/A
Returns : The word or phrase in all uppercase letters
Requires : offset of secretMessage in ESI
!
.data
.code
uppercaseLoop:
cmp byte ptr [esi], 0
je end6
cmp byte ptr [esi], 'a'
je toUpper
ja keepGoing
jb disregard
keepGoing:
cmp byte ptr [esi], 'z'			;//ensuring that we capture only the lowercase letters
ja disregard
toUpper:
sub byte ptr[esi], 20h			;//subtracting 20h from the ASCII value
disregard:
inc esi
jmp uppercaseLoop

end6:
ret
upperCase endp


;//-------------------------------


removeNonLetter proc uses edx esi

COMMENT !
Description: This proc removes all elements of a string that are not letters
Receives : N / A
Returns : The word or phrase with no spaces or special characters
Requires : offset of secretMessage in ESI
!

.data
tempMessage byte maxLength dup(0)

.code
mov edx, offset tempMessage
push edx
push esi

getLetter:
cmp byte ptr [esi], 0
je complete
cmp byte ptr[esi], 41h			;//if less than 'A', we keepgoing. otherwise continue
jb keepgoing
cmp byte ptr[esi], 5Ah			;//if didn't jump to keepgoing, check if below or equal 'z', if yes jump to storeit
jbe storeit
cmp byte ptr[esi], 61h			;//if not below 'a' and is above 'z', check if below 'A'. if so jump to keepgoing
jb keepgoing
cmp byte ptr[esi], 7Ah			;//if above 'a' and below 'z' storeit. otherwise continue to keepgoing
ja keepgoing

storeit:
move al, byte ptr [esi]
move byte ptr [edx], al
inc edx

keepgoing:
inc esi						;//moving to next letter
jmp getLetter

complete:					;//moving back to the beginning of each string
move ecx, maxLength
pop esi
pop edx
push esi

clearMessage:
move byte ptr[esi], 0		;//removing the original message in secretMessage which contained special characters
inc esi
loop clearMessage

pop esi						;//resetting the positions again
push esi
push edx

newMessage:					;//moving the value in our tempMessage into secretMessage
cmp byte ptr[edx], 0
je newMessageEnd
move al, byte ptr[edx]
move byte ptr[esi], al
inc esi
inc edx
jmp newMessage

newMessageEnd:
pop edx
pop esi
move ecx, maxLength

clearTemp:
move byte ptr[edx], 0				;//deleting the tempMessage
inc edx
loop clearTemp

ret
removeNonLetter endp

ClearRegisters proc
;//This proc was taken from assignment 5

cleareax
clearebx
clearecx
clearedx
clearesi
clearedi

ret
ClearRegisters ENDP
end main