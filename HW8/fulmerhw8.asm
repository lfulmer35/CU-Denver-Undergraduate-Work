TITLE fulmerhw8.asm

;// Author:  Lucas Fulmer
;// Date:  25 April 2018

;// Description: This program conducts two main functions. 
;// 1. The program uses a recursive version of Euclid's algorithm for finding the greatest common divisor (GCD).
;//	   Additionally, it displays if the GCD is a prime number.

;// 2. The program creates a 5x5 matrix of random letters. It then finds the number of words contained in the 
;//    matrix(word = 5 letters, two of which are vowels).
;// ====================================================================================

Include Irvine32.inc 

;//Macros
ClearEAX textequ <mov eax, 0>
ClearEBX textequ <mov ebx, 0>
ClearECX textequ <mov ecx, 0>
ClearEDX textequ <mov edx, 0>
ClearESI textequ <mov esi, 0>
ClearEDI textequ <mov edi, 0>
move textequ <mov>
maxlength equ 1000

.data
menuprompt byte '1. Find GCD', 0ah, 0dh,
'2. Matrix of words', 0ah, 0dh,
'3. Exit', 0ah, 0dh, 0h
errorprompt byte 'Invalid choice', 0ah, 0dh, 0h

.code
main proc

;//PROTOTYPES----------
findGDC PROTO
euclid PROTO, val1:dword, val2:dword
fillArray PROTO, GCD : dword
wordMatrix PROTO
findWords PROTO, matrixPtr : ptr byte
clearregisters PROTO


call randomize									;//seeding the random number generator
menu:
invoke clearregisters								;//clearing all registers
move edx, offset menuprompt
call writestring
call readdec

opt1:
cmp al, 1
ja opt2
invoke findGDC
jmp menu

opt2:
cmp al, 2
ja opt3
invoke wordMatrix
jmp menu

opt3:
cmp al, 3
ja oops
jmp quitit

oops:
move edx, offset errorprompt
call writestring
call waitmsg
jmp menu

quitit:
ret
main endp






;//Procedures below-------------------------------------------------

findGDC proc

;//Description: This proc takes two integers from the user and call's Euclid's algorithm
;//Receives: Two integers from the user
;//Returns: The LCD of the two integers
;//Requires: N/A

.data
aPrompt byte 'Enter the first number:', 0h
bPrompt byte 'Enter the second number: ', 0h
output byte 'Number #1  Number#2  GCD  GCD Prime?', 0ah, 0dh, 
'------------------------------------------', 0ah, 0dh, 0h
goagain byte 'Do you wish to enter another pair (Y/N)?', 0ah, 0dh, 0h
aNum DWORD ?
bNum dword ?
GDC dword ?
userchoice byte ?
space byte '        ', 0h

.code

GDCloop:
move eax, 0
move edx, offset aPrompt
call writestring
call readdec												;//getting the two integers from the user
move aNum, eax
move eax, 0
move edx, offset bPrompt
call writestring
call readdec
move bNum, eax

move edx, offset output										;//displaying in format specified in assignment
call writestring
move eax, aNum
call writedec
move edx, offset space
call writestring
move eax, bNum
call writedec
call writestring
invoke euclid, aNum, bNum									;//find the GCD


move edx, offset goagain
call writestring
call readchar
cmp al, 'y'
je GDCloop
cmp al, 'Y'
je GDCloop
cmp al, 'n'
je quitit
cmp al, 'N'
je quitit


quitit:
ret
findGDC endp

;//------------------------------------------------

euclid proc, val1:dword, val2 : dword

;//Description: Uses a recursive version of Euclid's algorithm to find the LCD. It also invokes the function to find if the LCD is prime.
;//Receives: N/A
;//Returns: LCD
;//Requires: Two values from the user.


.data
space2 byte '     ', 0h
.code
move eax, val1
cmp eax, val2
jb val2greater										;//finding the larger of the two values
je done												;//subtracting the smaller from the larger
sub eax, val2
move val1, eax
invoke euclid, val1, val2							;//recursively calling the proc
ret

val2greater:
sub val2, eax
invoke euclid, val1, val2							;//recursively calling the proc 
ret

done:
call writedec										;//after recursive call, the GCD is in EAX
move val1, eax
move edx, offset space2
call writestring
invoke fillArray, val1								;//checking for prime
call crlf

ret
euclid endp

;//----------------------------------------------

fillArray proc, GCD : dword
;//Description: This proc creates an array of integers in order to find if a number is prime. A version of the algorithm used in HW7.
;//Receives: N/A
;//Returns: Array of integers for Eratosthanes Sieve.
;//Requires: The GCD from previous proc.

.data
primeArray word maxlength dup(0)
isprime byte 'Yes', 0ah, 0dh, 0h
nope byte 'No', 0ah, 0dh, 0h

.code
push esi
move ecx, 0
move esi, offset primeArray;//putting pointer to our array of primes into esi
fillArrayloop:
move eax, ecx
add ax, 2
move[esi + 2 * ecx], ax
inc ecx
cmp eax, GCD								;//making sure we are not exceeding GCD
jb fillArrayloop
pop esi
push esi

move ecx, 0
move esi, offset primeArray
push edx

checkPrimeloop:								;//variation of the prime algorithm from HW7
move edx, 0
move ax, word ptr GCD						;//put GCD into ax for division

cmp [esi+2*ecx], ax							;//make sure that our loop is <= GCD
jae prime
move bx, word ptr [esi+2*ecx]				;//divisor
div bx
cmp edx, 0									;//if remainder is 0, GCD is not prime
je notprime
inc ecx
jmp checkprimeloop

prime:
pop esi
move edx, offset isprime
call writestring
jmp theend

notprime:
pop esi
move edx, offset nope
call writestring


theend:
pop edx
ret
fillArray endp


;//------------------------------------------


wordMatrix proc
;//Description: This proc builds a letter matrix. Each entry has a 50/50 chance of being a vowel. It then displays the matrix, and calls a word-finding function.
;//Receives: N/A
;//Returns: Displays the word matrix in the console.
;//Requires: N/A

.data
letterArray byte 5 dup(0)
rowsize = ($- letterArray)
byte 5 dup(0)
byte 5 dup(0)
byte 5 dup(0)
byte 5 dup(0)
vowelArray byte 'A', 'E', 'I', 'O', 'U', 0h					;//'Y' is not considered a vowel for this program
consonentArray byte 'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z', 0h
matrixIs byte 'The matrix is:', 0ah, 0dh, 0h

.code
move esi, offset letterArray
push esi
move ecx, 25

fillMatrixloop:
move eax, 2										;//50% chance of finding a vowel
call randomrange
cmp al, 0
je addVowel										;//if we need a vowel, jump to addVowel
move edi, offset consonentArray
move eax, 21
call randomrange
move bl, byte ptr [edi + eax]
move byte ptr [esi], bl
inc esi
loop fillMatrixloop

addVowel:	
cmp ecx, 0										;//Don't want an infinite loop
je donewithArray
move edi, offset vowelArray
move eax, 5
call randomrange
move bl, byte ptr [edi + eax]
move byte ptr[esi], bl
inc esi
loop fillMatrixloop

donewithArray:
pop esi
push esi
move edx, offset matrixIs
call writestring
call crlf
move edx, 5
move ecx, 25

displayLoop:								;//Displaying the matrix
dec edx
move al, byte ptr [esi]
call writechar
move al, ' '
call writechar
inc esi
cmp edx, 0
je refill
loop displayLoop

refill:										;//refilling edx for our counter
cmp ecx, 0
je stopLoop
move edx, 5
call crlf
loop displayLoop

stopLoop:									;//once the matrix is displayed, find the words
pop esi
invoke findWords, ADDR letterArray
call crlf

ret
wordMatrix endp


findWords proc, matrixPtr: ptr byte
.data
noWords byte 'No words were found.', 0ah, 0dh, 0h
yesWords byte 'The words is/are:', 0ah, 0dh, 0h
separate byte ', ', 0h
vowelCount byte 0
wordCount byte 0
tempWord byte 5 dup(0), 0h
rowCount byte 0
rowindex byte 1

.code
move esi, matrixPtr
push esi

begin:											;// counter the total number of words checked
move vowelCount, 0
move ebx, 0
move edi, offset tempWord
move ecx, 0
cmp rowCount, 5
jb checkcolumns
cmp rowCount, 10
jb continue2
cmp rowCount, 11
jb continue3
cmp rowCount, 12
jb continue4
jmp finished

checkcolumns:									;//checking columns first
move al, byte ptr [esi+ebx]
move byte ptr [edi], al
add ebx, 5
inc edi
inc ecx
cmp ecx, 5
je checkVowels
jmp checkcolumns

checkVowels:									;//checking for vowels in each word
dec edi
cmp byte ptr [edi], 'A'
je countit
cmp byte ptr [edi], 'E'
je countit
cmp byte ptr [edi], 'I'
je countit
cmp byte ptr[edi], 'O'
je countit
cmp byte ptr [edi], 'U'
je countit
loop checkVowels
jmp checkWord

countit:										;//counting the number of vowels in each word, only words with exactly 2 vowels are displayed
inc vowelCount
cmp ecx, 0
je checkWord
loop checkVowels

checkWord:										;//checking to see if only 2 vowels, if yes print
cmp vowelCount, 2
je isWord

continue1:
inc esi
inc rowCount
jmp begin

continue2:
pop esi
push esi
cmp rowCount, 5
je checkrows
move eax, 5										;//using multipliction for indexing
mul rowindex
move ebx, eax
inc rowindex


checkRows:										;//now checking the five rows
move al, byte ptr[esi + ebx]
move byte ptr[edi], al
inc ebx
inc edi
inc ecx
cmp ecx, 5
je checkVowels
jmp checkRows

continue3:
pop esi
push esi


checkdiagonal:									;//checking topleft to bottom right diagonal
move al, byte ptr[esi + ebx]
move byte ptr[edi], al
add ebx, 6
inc edi
inc ecx
cmp ecx, 5
je checkVowels
jmp checkdiagonal

continue4:
pop esi
push esi
move ebx, 4

diag2:											;//checking top right to bottom left diagonal
move al, byte ptr[esi+ebx]
move byte ptr [edi], al
add ebx, 4
inc edi
inc ecx
cmp ecx, 5
je checkVowels
jmp diag2


isWord:													;//words come here to be printed
cmp wordCount, 0
ja here
move edx, offset yesWords
call writestring

here:
inc wordCount
cmp wordCount, 1
jbe printWord
move edx, offset separate
call writestring

printWord:
move edx, offset tempWord
call writestring

jmp continue1

finished:											;//if no words were found, print noWords
cmp wordCount, 0
ja done
move edx, offset noWords


done:
call crlf
move rowCount, 0
move wordCount, 0
move rowindex, 1
ret
findWords endp


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