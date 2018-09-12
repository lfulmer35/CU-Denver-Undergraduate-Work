TITLE fulmerhw7.asm

; Author:  Lucas Fulmer
; Date:  18 April 2018

; Description: This program calculates the number of prime numbers from 2 to n, and 
; displays them. It uses a version of Eratosthenes Sieve to compute the primes.
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
arrayMax equ 1000

.data
n dword 1000
primeArray word arraymax dup(0)
exitprompt byte 'Press q to quit or space to continue.', 0h

.code
main proc

;//Prototypes---------------------------------------
fillArray PROTO, arrayPtr: ptr word, arraylength : dword
displaymenu PROTO
findPrimes PROTO, arrayPtr : ptr word, arraylength : dword
displayPrimes PROTO, arrayPtr : ptr word, arraylength : dword



invoke fillArray, ADDR primeArray, n
invoke findPrimes, ADDR primeArray, n
invoke displayPrimes, ADDR primeArray, n
menuloop:
call crlf
invoke displaymenu
move n, eax
invoke fillArray, ADDR primeArray, n
invoke findPrimes, ADDR primeArray, n
invoke displayPrimes, ADDR primeArray, n
move edx, offset exitprompt
call writestring
call readchar
cmp al, 'q'
je quitit
cmp al, 'Q'
je quitit
jmp menuloop



quitit:
main endp





;//Procedures---------------------------------------
fillArray proc, arrayPtr : ptr word, arraylength : dword
.code
push esi
move ecx, 0
move esi, arrayPtr							;//putting pointer to our array of primes into esi
fillArrayloop:
	move eax, ecx
	add ax, 2
	move [esi+2*ecx], ax					
	inc ecx
	cmp eax, arraylength					;//making sure we are not exceeding the value of 'n' entered by the user
	jb fillArrayloop
pop esi

ret
fillArray endp



displayPrimes proc, arrayPtr: ptr word, arraylength : dword

;//Description: This proc displays all prime numbers and displays the total number of primes
;//Receives: N/A
;//Returns: Outputs number of primes and outputs each individual prime to the consol
;//Requires: Must pass the primeArray and user-entered value of 'n'

.data
numprimes byte 0									;//for keeping track of the number of primes
thereare byte 'There are ', 0h
primesbetween byte ' primes between 2 and n (n = ', 0h
lines byte '-------------------------------------------------', 0ah, 0dh, 0h
rownum byte 2
colnum byte 0
stop byte 0

.code
push esi
dec arraylength
move esi, arrayPtr
move ecx, arraylength
move ebx, 0

L1:
move ax, [esi+2*ebx]								;//moving through each element in the primeArray
cmp ax, -1											;//non-primes are set to -1
jne isprime
inc ebx
jmp end2

isprime:											;//incrememnting our prime number total
inc numprimes
inc ebx

end2:
loop L1
move eax, 0
call clrscr

move edx, offset thereare							;//making the display pretty
call writestring
move al, numprimes
call writedec
move edx, offset primesbetween
call writestring
inc arraylength
move eax, arraylength
call writedec
dec arraylength
move al, ')'
call writechar
call crlf
move edx, offset lines
call writestring

move ebx, 0

displayprimenums:									;//This loop will actually display all of the prime numbers
move ax, [esi+2*ebx]
cmp ax, -1
je dontdisplay										;//skipping the non-prime numbers
	
move dh, rownum										;//this ensures the required spacing for the assignment
move dl, colnum
call gotoxy
call writedec
inc stop
cmp stop, 5
je newline

add colnum, 5			
inc ebx

jmp check

newline:											;//moving to the next line for display
call crlf
sub colnum, 25
inc rownum
move stop, 0
move dh, rownum
move dl, colnum
call gotoxy
add colnum, 5
inc ebx
jmp check

dontdisplay:
inc ebx

check:
cmp ebx, arraylength
jb displayprimenums

move colnum, 0
move rownum, 2
move stop, 0
move numprimes, 0
pop esi
call crlf
call waitmsg


ret
displayPrimes endp




displaymenu proc
;//Description: Simple menu which allows the user to chose the value of 'n.'
;//Receives: Decimal input from user
;//Returns: Value of 'n' in EAX
;//Requires: N/A

.data
prompt byte 'Enter a number from 2 to 1000 ---->', 0h

.code
push edx
L1:
move edx, offset prompt
call writestring
call readdec
cmp eax, 2
jb L1
cmp eax, 1000
ja L1
pop edx

ret
displaymenu endp


;//--------------------

findPrimes proc, arrayPtr: ptr word, arraylength : dword
;//Description: This proc calculates all primes in the range [2,1000]. 
;//Receives: N/A
;//Returns: Pointer to the array of primes
;//Requires: Two parameters 1. ADDR of primeArray 2. n (entered by user)



;//The basis for this algorithm was found online at github/johnnykv

.code
push esi
move esi, arrayPtr
move ecx, 0

L1:											;//this loop will inc our divisor
move ebx, ecx
inc ebx
cmp word ptr [esi+2*ecx], -1				;//all non-prime numbers will be set to -1
jne L2
continue1:
inc ecx
cmp ecx, arraylength
jb L1
jmp end1

L2:											;//this loop increments our dividend
cmp word ptr [esi+2*ebx], -1				;//all non-prime numbers will be set to -1
jne L3
continue2:
inc ebx
cmp ebx, arraylength
jb L2
jmp continue1

L3:											;//This loop is checking to see if the number is actually prime
move edx, 0
move eax, 0
move ax, [esi+2*ebx]
div word ptr [esi+2*ecx]
cmp edx, 0									;//if remainder is 0, the number is not prime
je remove	
jmp continue2

remove:
mov word ptr [esi+2*ebx], -1				;//setting all non-primes equal to -1
jmp continue2


end1:
pop esi
ret
findPrimes endp

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