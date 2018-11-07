TITLE fulmerEXAM2.asm

; Author:  Lucas Fulmer
; Date:  13 April 2018

; Description: This program is a version of the game Hangman.
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

.data
wordArray byte 13 dup(0)				;//variable that will be passed into various procs and will contain dashes and letters
wordguesscount byte 3
letterguesscount byte 10
playagain byte 'Would you like to play again?', 0ah, 0dh,
'1. Yes', 0ah, 0dh,
'2. No', 0h
didwin byte 0

.code
main PROC

gameLoop :
call ClearRegisters				;//clears registers. Taken from Assignment 5
call randomize					;//seeding the random number generator
call displayrules				;//displaying the rules of the game
call displayMenu				;//intro menu for game
cmp al, 2
je quitit

call clrscr
movzx ecx, letterguesscount		;//keeping track of the number of letter guesses
mov ah, wordguesscount			;//keeping track of the number of word guesses
move edi, offset wordArray		;//
call getWord
call playgame

push edx
move edx, offset playagain
call writestring
pop edx
call readdec
cmp al, 2
je quitit

jmp gameLoop

quitit:
exit
main endp


;// Procedures
;// ===============================================================




displayRules proc

;// Description: This proc simply displays the rules of the game
;// Receives: N / A
;// Returns: N / A
;// Requires: N / A

.data
rulesprompt byte "Rules of the game:", 0ah, 0dh,
"You have 10 chances to guess letters and ",
"3 chances to guess the word.", 0ah, 0dh, 0h

.code
push edx
move edx, offset rulesprompt
call writestring
call crlf
pop edx
call waitmsg
ret
displayRules endp

;//----------------------------------------

displayMenu proc

;// Description: This proc simply displays the menu and takes the user's input
;// Receives: Decimal input from the user
;// Returns: This proc returns the useroption input
;// Requires: N / A

.data
Menuprompt byte 'MAIN MENU', 0ah, 0dh,
'==========', 0ah, 0dh,
'1. Play Hangman. ', 0ah, 0dh,
'2. Exit. ', 0ah, 0dh, 0h

.code
call clrscr
move edx, offset Menuprompt
call writestring
call readDec

ret
displayMenu endp


;//--------------------------------

getWord proc

;// Description: This proc chooses a random word from the available list
;// Receives: N / A
;// Returns: Returns the secret word's offset in ESI and length of the word in EBX
;// Requires: N / A

.data
string0 byte "kiwi", 0h
string1 byte "canoe", 0h
string2 byte "doberman", 0h
string3 byte "puppy", 0h
string4 byte "banana", 0h
string5 byte "orange", 0h
string6 byte "frigate", 0h
string7 byte "ketchup", 0h
string8 byte "postal", 0h
string9 byte "basket", 0h
string10 byte "cabinet", 0h
string11 byte "mutt", 0h
string12 byte "machine", 0h
string13 byte "mississippian", 0h
string14 byte "destroyer", 0h
string15 byte "zoomies", 0h
string16 byte "body", 0h
string17 byte "boolean", 0h
string18 byte "algebra", 0h
string19 byte "stinks", 0h

.code
push eax
move eax, 200
call randomrange					;//random range of 0-200
add eax, 1							;//adding one, making the random range 1 - 201
move bl, 13h						;//divding by 19d to "mod" our random number
DIV bl								;//ah now holds the remainder or "mod" of the random number

opt1:
cmp ah, 1
ja opt2
move esi, offset string1
move ebx, lengthof string1
jmp end1

opt2:
cmp ah, 2
ja opt3
move esi, offset string2
move ebx, lengthof string2
jmp end1

opt3:
cmp ah, 3
ja opt4
move esi, offset string3
move ebx, lengthof string3
jmp end1

opt4:
cmp ah, 4
ja opt5
move esi, offset string4
move ebx, lengthof string4
jmp end1

opt5:
cmp ah, 5
ja opt6
move esi, offset string5
move ebx, lengthof string5
jmp end1

opt6:
cmp ah, 6
ja opt7
move esi, offset string6
move ebx, lengthof string6
jmp end1

opt7:
cmp ah, 7
ja opt8
move esi, offset string7
move ebx, lengthof string7
jmp end1

opt8:
cmp ah, 8
ja opt9
move esi, offset string8
move ebx, lengthof string7
jmp end1

opt9:
cmp ah, 9
ja opt10
move esi, offset string9
move ebx, lengthof string9
jmp end1

opt10:
cmp ah, 10
ja opt11
move esi, offset string10
move ebx, lengthof string10
jmp end1

opt11:
cmp ah, 11
ja opt12
move esi, offset string11
move ebx, lengthof string11
jmp end1

opt12:
cmp ah, 12
ja opt13
move esi, offset string12
move ebx, lengthof string12
jmp end1

opt13:
cmp ah, 13
ja opt14
move esi, offset string13
move ebx, lengthof string13
jmp end1

opt14:
cmp ah, 14
ja opt15
move esi, offset string14
move ebx, lengthof string14
jmp end1

opt15:
cmp ah, 15
ja opt16
move esi, offset string15
move ebx, lengthof string15
jmp end1

opt16:
cmp ah, 16
ja opt17
move esi, offset string16
move ebx, lengthof string16
jmp end1

opt17:
cmp ah, 17
ja opt18
move esi, offset string17
move ebx, lengthof string17
jmp end1

opt18:
cmp ah, 18
ja opt19
move esi, offset string18
move ebx, lengthof string18
jmp end1

opt19:
move esi, offset string19
move ebx, lengthof string19

end1:
push ecx
move ecx, ebx
push esi
move esi, 0
dashLoop:
move byte ptr [edi+esi], '_'
inc esi
loop dashLoop

dec ebx
pop esi
pop ecx
pop eax
ret
getWord endp

;//------------------------------------------------

playGame proc

;// Description: This proc is the main driver for the game.It makes the necessary function
;// Receives: Takes user's input on whether to guess a letter or the word
;// Returns: Win or lose
;// Requires: N/A

.data
guessChoice byte "Do you wish to guess a letter or the whole word: (1 for letter 2 for word)", 0h
youWin byte "That is correct. You win!", 0dh, 0ah, 0h
youLose byte "You are out of guesses. You lose.", 0ah, 0dh, 0h

.code
call clrscr
call secretword
gameloop:
cmp ecx, 499
je winnerwinner
cmp ah, 0
je loser
cmp ecx, 0
je loser

choiceloop:
call crlf
push edx
move edx, offset guessChoice
call writestring
pop edx
push eax
call readDec
call crlf

cmp al, 1
jne wordchoice	
pop eax
call guessLetter						;//allow user to guess a single letter
jmp endGuess

wordchoice:
cmp al, 2
jne choiceloop	
pop eax
call guessWord							;//allow user to guess the full word

endGuess:

loop gameloop

;//need code here
winnerwinner:
call crlf
push edx
move edx, offset youWin
call writestring
pop edx
call waitmsg
jmp quitit

loser:
call crlf
push edx
move edx, offset youlose
call writestring
pop edx
call waitmsg

quitit:
ret
playGame endp


;//-----------------------------------

guessLetter proc


;//Description: This proc displays the word with underscores for all letters that have not been guessed
;//Receives : Letter input from the user
;//Returns : Returns the secret word with any correctly guessed letters
;//Requires: offset of secret word in EDI, offset of random string in ESI, and number of available guesses in ECX


.data
letterprompt byte "Guess a letter: ", 0h
remainingGuesses byte " letter guesses left)", 0h

.code
;// need to compare for win

push ecx
push esi
move ecx, ebx
call crlf
move edx, offset letterprompt
call writestring
call readchar
call writechar
call crlf
cmp al, 61h								;//comparing to lowercase
jae check
add al, 20h								;//if capital, make lowercase

check:
cmp al, [esi]
je match
inc esi
inc edi
loop check

jmp nomatches

match:
move [edi], al
inc esi
inc edi
cmp ecx, 0
je donechecking
loop check

nomatches:

donechecking:
move ecx, ebx
resetedi:
dec edi
loop resetedi
pop esi
pop ecx

call secretWord
move al, '('
call writechar
push eax
move eax, ecx
sub eax, 1
call writedec
move edx, offset remainingguesses
call writestring
call crlf
pop eax

ret
guessLetter endp

;//-------------------------------------

guessWord proc

;// Description: Allows the user to guess the secret word
;// Receives: User entered word
;// Returns: Correct or Incorrect response. Returns the number of guesses remaining
;// Requires: Offset of secret word in EDI, offset of random string in ESI, 

.data
wordGuess byte 'Guess a word: ', 0h
nope byte 'That is incorrect - ', 0h
guessesremaining byte ' word guesses remaining.', 0h
userGuess byte 13 dup(0), 0h

.code
push eax
push ecx
push esi
push ebx
push edx
move edx, offset wordGuess
call writestring
pop edx
push edx
move edx, offset userguess
inc ebx
move ecx, ebx
dec ebx
call readstring


checkword:
move al, [edx]						;//if any of the letters do not match, dec AH by one
cmp byte ptr [esi], al
jne nogood
inc esi
inc edx
loop checkword

pop edx
pop ebx
pop esi
pop ecx
pop eax
jmp win

nogood:
pop edx
pop ebx
pop esi
pop ecx
pop eax

push edx
move edx, offset nope
call writestring
pop edx
sub ah, 1
push eax
movzx eax, ah
call writedec

push edx
move edx, offset guessesremaining
call writestring
pop edx
pop eax
jmp endwordguess

win:
call checkWin

endwordguess:

ret
guessWord endp


;//-------------------------------------

secretWord proc

;//Description: This proc displays the secret word in the form of dashes and correctly guessed letters
;//Receives: N/A
;//Returns: The secret word with dashes and letters
;//Requires: The offset of the secret word in EDI and the length in EBX


.data
prefix byte 'Word: ', 0h

.code
push ecx
push edi
push ebx

move edx, offset prefix
call writestring
move ecx, ebx
writeWord:
move al, byte ptr[edi]
call writechar
move al, ' '
call writechar
inc edi
loop writeWord

pop ebx
pop edi
pop ecx

ret
secretWord endp

;//----------------------------------------


checkWin proc

;//Description: Sets winning condition.
;//Recieves: N/A
;//Returns: Value of 500 in ecx
;//Requires: N/A

.data
.code
move ecx, 500
ret
checkWin endp

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