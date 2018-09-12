TITLE fulmerExam3.asm

;// Author:  Lucas Fulmer
;// Date:  7 May 2018

;// Description: This program creates a version of the game "Connect Four." This program
;// specifically creates "connect three" game. It uses a multidimensional array in row-major
;// order for the purposes of the game board. It has three versions of the game:
;// 1. Player vs. Player
;// 2. Player vs. Computer
;// 3. Computer vs. Computer
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

.data
menuprompt byte '1. Player 1 vs. Player 2', 0ah, 0dh,
'2. Player 1 vs. Computer 1', 0ah, 0dh,
'3. Computer 1 vs. Computer 2', 0ah, 0dh,
'4. Exit', 0ah, 0dh, 0h
errorprompt byte 'Invalid choice', 0ah, 0dh, 0h
rulesprompt byte 'Rules of Connect 3: Drop a colored piece into the board. The piece will go into the lowest available slot.', 0ah, 0dh,
'The first player to connect three pieces horizontally, vertically, or diagonally wins.', 0ah, 0dh, 0h
checkboard byte 4 dup(0)
byte 4 dup(0)
byte 4 dup(0)
byte 4 dup(0)
pwins DWORD 0
p1loss DWORD 0
p1draw DWORD 0
winprompt byte 'Wins: ', 0h
lossprompt byte 'Losses: ', 0h
drawprompt byte 'Draws: ', 0h

.code
main proc

;//PROTOTYPES----------
displayBoard PROTO, input : byte, turn : byte, boolBoard : ptr byte
playervplayer PROTO, boolBoard : ptr byte, wins : DWORD, loss : DWORD, draw : DWORD
playervcomputer PROTO, boolBoard : ptr byte, wins : DWORD, loss : DWORD, draw : DWORD
computervcomputer PROTO, boolBoard : ptr byte
computerChoice PROTO, compchoice: byte
placeColor PROTO, input:byte, isfull:DWORD, boolBoard : ptr byte, colorturn : byte
checkwin PROTO, boolBoard : ptr byte, didwin : DWORD
cleanBoard PROTO, boolBoard : ptr byte
clearregisters PROTO

call randomize										;//seeding the random number generator for computer players
move edx, offset rulesprompt
call writestring
call waitmsg
call clrscr

menu:
invoke clearregisters								;//clearing all registers
invoke displayBoard, 0, 0, ADDR checkboard
call crlf
move edx, offset winprompt							;//displaying the number of wins
call writestring
move eax, pwins
call writedec
call crlf
move edx, offset lossprompt							;//displaying the number of losses
call writestring
move eax, p1loss
call writedec
call crlf
move edx, offset drawprompt							;//displaying the number of draws
call writestring
move eax, p1draw
call writedec
call crlf
move edx, offset menuprompt
call writestring
call readdec

opt1:
cmp al, 1
ja opt2
invoke playervplayer, ADDR checkboard, offset pwins, offset p1loss, offset p1draw
invoke cleanBoard, ADDR checkboard
jmp menu

opt2:
cmp al, 2
ja opt3
invoke playervcomputer, ADDR checkboard, offset pwins, offset p1loss, offset p1draw
invoke cleanBoard, ADDR checkboard
jmp menu

opt3:
cmp al, 3
ja opt4
invoke computervcomputer, ADDR checkboard
invoke cleanBoard, ADDR checkboard
jmp menu

opt4:
cmp al, 4
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

displayBoard proc, input : byte, turn :byte, boolBoard : ptr byte

;//Description: This proc displays the game board. It uses two arrays, one of which contains number values for the purpose of keeping track of player moves.
;//Receives: User's input is passed via the game procs
;//Returns: The gameboard to the console.
;//Requires: User's input and turn (who's turn it is) passed via the gameplay procs

.data
boardArray byte 4 dup('	')
rowsize = ($ - boardArray)
byte 4 dup('	')
byte 4 dup('	')
byte 4 dup('	')
horizontalBoard byte '---------------------------------', 0ah, 0dh, 0h
header byte '    1       2       3       4', 0h
dividers byte '|', 0h



.code

begin:
move ecx, 4
move esi, offset boardArray
move edi, boolBoard
move ebx, 12									;//the rows/columns are multiples of 4, so 12 will take us to the lowest row each time
push esi
move edx, offset header
call writestring

outerloop:										;//traversing vertically
call crlf
pop esi
push esi
move ebx, 0
move edx, offset horizontalboard
call writestring
cmp ecx, 0
je done
move al, dividers
call writechar
dec ecx

boardloop:										;//traversing horizontally through the array
move al, byte ptr [edi]
inc edi
cmp al, 1
je placeblue
cmp al, 2
je placeyellow

keepgoing:										;//traversing horizontally through the array
move al, byte ptr [esi]
call writechar
move eax, 15 +(0*16)							;//ensures that we keep white on black
call settextcolor
inc esi
inc ebx
move al, dividers
call writechar
cmp ebx, 4
je outerloop
jmp boardloop

placeblue:										;//if we find a '1' in the check array, we make it blue
move eax, 0 + (1*16)
call settextcolor
jmp keepgoing

placeyellow:									;//if we find '2' in the check array, we make it yellow
move eax, 0 +(14*16)
call settextcolor
jmp keepgoing


done:
pop esi
ret
displayBoard endp


;//----------------------------------

playervplayer proc, boolBoard : ptr byte, wins : DWORD, loss : DWORD, draw : DWORD

;//Description: This proc is the main driver for the player vs player option
;//Receives: Checkboard full of boolean values
;//Returns: Winner of the game
;//Requires: Input from users

.data
p1first byte "Player1 goes first.", 0ah, 0dh, 0h
p2first byte 'Player2 goes first.', 0ah, 0dh, 0h
p1turn byte "Player 1's turn.", 0ah, 0dh, 0h
p2turn byte "Player 2's turn.", 0ah, 0dh, 0h
p2wins byte 'Player2 wins.', 0ah, 0dh, 0h
p1wins byte 'Player1 wins. ', 0ah, 0dh, 0h
tie3 byte 'The game is a tie.', 0ah, 0dh, 0h
columnisfull3 byte 'The column is full.', 0ah, 0dh, 0h
invalidchoice3 byte 'You have entered an invalid option.', 0ah, 0dh, 0h
userinput byte 0
whogoesfirst3 byte 0
theturn3 byte 0
fullcolumn3 byte 0
whowins3 DWORD 0
colorchoice3 byte 1

.code
move ax, 500											;//randomly deciding who goes first
call randomrange
move bl, 2
div bl
move theturn3, ah
cmp theturn3, 1
jne p2
call clrscr
move edx, offset p1first							;//Player 1 goes first
call writestring
jmp goagain

p2 :												;//Player 2 is first
call clrscr
move edx, offset p2first
call writestring

goagain :											;//Displaying the board and seeing who's turn it is
call crlf
invoke displayBoard, 0, 0, boolBoard
cmp theturn3, 1
je player1goes

skip :												;//Player 2's turn
inc theturn3
move edx, offset p2turn
call writestring
call readdec
jmp takeinput

player1goes :										;//Player 1's turn
dec theturn3
move edx, offset p1turn
call writestring
call readdec

takeinput :											;//placing the user's choice on the board
cmp al, 1
jne opt2
move userinput, al
invoke placeColor, userinput, offset fullcolumn3, boolBoard, colorchoice3
jmp nextturn

opt2 :
cmp al, 2
jne opt3
move userinput, al
invoke placeColor, userinput, offset fullcolumn3, boolBoard, colorchoice3
jmp nextturn

opt3 :
cmp al, 3
jne opt4
move userinput, al
invoke placeColor, userinput, offset fullcolumn3, boolBoard, colorchoice3
jmp nextturn

opt4 :
cmp al, 4
jne oops
move userinput, al
invoke placeColor, userinput, offset fullcolumn3, boolBoard, colorchoice3
jmp nextturn

oops :
move edx, offset invalidchoice3
call writestring
xor theturn3, 1
jmp goagain

nextturn :												;//changing the color for the next turn
cmp colorchoice3, 1
je goyellow
dec colorchoice3
jmp keepgoing
goyellow :
inc colorchoice3

keepgoing :												;//making sure that the column isn't full
cmp fullcolumn3, 1
jne notfull
xor colorchoice3, 11b									;//if it's full, flip the bits on the color and the turn

xor theturn3, 1
move edx, offset columnisfull3
call writestring
move fullcolumn3, 0
jmp goagain

notfull :												;//if it's not full, check to see if anyone wins
invoke checkWin, boolBoard, offset whowins3
cmp whowins3, 0
jne gameover
call clrscr
jmp goagain

gameover :												;//win, lose, or draw
call clrscr
invoke displayBoard, 0, 0, boolBoard
cmp theturn3, 0
jne p2winner
cmp whowins3, 3
je tiegame
move edx, offset p1wins
call writestring
move edi, wins
add byte ptr [edi], 1
jmp endit

p2winner :
cmp whowins3, 3
je tiegame
move edx, offset p2wins
call writestring
move edi, loss
add byte ptr[edi], 1
jmp endit

tiegame :
move edx, offset tie3
call writestring
move edi, draw
add byte ptr[edi], 1

endit :
move whowins3, 0
move theturn3, 0
move colorchoice3, 1
call waitmsg
call clrscr
ret
playervplayer endp


;//----------------------------------

playervcomputer proc, boolBoard : ptr byte, wins : DWORD, loss : DWORD, draw : DWORD

;//Description: This proc is the driver for the player vs computer game
;//Recieves: Receives input from the user
;//Returns: Winner of the game
;//Requires: The boolean board to keep track of the spaces

.data
promptcomputerfirst byte "Computer goes first.", 0ah, 0dh ,0h
promptplayerfirst byte 'Player goes first.', 0ah, 0dh, 0h
playerturn byte "Player's turn.", 0ah, 0dh, 0h
computerturn byte "Computer's turn.", 0ah, 0dh, 0h
computerwins byte 'Player2 wins.', 0ah, 0dh, 0h
playerwins byte 'Player1 wins. ', 0ah, 0dh, 0h
tie byte 'The game is a tie.', 0ah, 0dh, 0h
columnisfull byte 'The column is full.', 0ah, 0dh, 0h
invalidchoice byte 'You have entered an invalid option.', 0ah, 0dh, 0h
computerinput byte 0
whogoesfirst byte 0
theturn byte 0
fullcolumn byte 0
whowins DWORD 0
colorchoice byte 1

.code

move ax, 500											;//randamly deciding who goes first
call randomrange
move bl, 2
div bl
move theturn, ah
cmp theturn, 1
jne p2
call clrscr
move edx, offset promptplayerfirst
call writestring
jmp goagain

p2:													;//computer goes first
call clrscr
move edx, offset promptcomputerfirst
call writestring

goagain:											;//player goes first
call crlf
invoke displayBoard, 0, 0, boolBoard
cmp theturn, 1
je playergoes
skip:
inc theturn
invoke computerChoice, computerinput
move computerinput, ah
move al, computerinput
move edx, offset computerturn
call writestring
push eax
move eax, 2000										;//2-second delay for the computer's turn
call delay
pop eax
jmp takeinput

playergoes:
dec theturn
move edx, offset playerturn
call writestring
call readdec

takeinput:											;//putting the pieces on the board
cmp al, 1
jne opt2
move computerinput, al
invoke placeColor, computerinput, offset fullcolumn, boolBoard, colorchoice
jmp nextturn

opt2:
cmp al, 2
jne opt3
move computerinput, al
invoke placeColor, computerinput, offset fullcolumn, boolBoard, colorchoice
jmp nextturn

opt3:
cmp al, 3
jne opt4
move computerinput, al
invoke placeColor, computerinput, offset fullcolumn, boolBoard, colorchoice
jmp nextturn

opt4:
cmp al, 4
jne oops
move computerinput, al
invoke placeColor, computerinput, offset fullcolumn, boolBoard, colorchoice
jmp nextturn

oops:
move edx, offset invalidchoice
call writestring
jmp playergoes

nextturn:											;//setting up the color for the next turn
cmp colorchoice, 1
je goyellow
dec colorchoice
jmp keepgoing
goyellow:
inc colorchoice

keepgoing:											;//checking to make sure that the column isn't full
cmp fullcolumn, 1
jne notfull
xor colorchoice, 11b
cmp theturn, 0
je player

move fullcolumn, 0
move theturn, 0
jmp skip

player:	
move theturn, 1
move edx, offset columnisfull
call writestring
move fullcolumn, 0
jmp goagain
	
notfull:											;//if not full, check to see if there is a winner
invoke checkWin, boolBoard, offset whowins
cmp whowins, 0
jne gameover
call clrscr
jmp goagain

gameover:											;//computer wins, player wins, or tie
call clrscr
invoke displayBoard, 0, 0, boolBoard
cmp theturn, 0
jne compwins
cmp whowins, 3
je tiegame
move edx, offset playerwins
call writestring
move edi, wins
add byte ptr[edi], 1
jmp endit

compwins:
cmp whowins, 3
je tiegame
move edx, offset computerwins
call writestring
move edi, loss
add byte ptr[edi], 1
jmp endit

tiegame:
move edx, offset tie
call writestring
move edi, draw
add byte ptr[edi], 1

endit:
move whowins, 0
move theturn, 0
move colorchoice, 1
call waitmsg
call clrscr
ret
playervcomputer endp


;//--------------------------------------

computervcomputer proc, boolBoard : ptr byte

;//Description: This proc is the driver for the computer vs computer game
;//Recieves: N/A
;//Returns: Winner of the game
;//Requires: The boolean board to keep track of the spaces

.data
computer1turn byte 'Computer1 turn.', 0ah, 0dh, 0h
computer2turn byte 'Computer2 turn.', 0ah, 0dh, 0h
comp1wins byte 'Computer1 wins.', 0ah, 0dh, 0h
comp2wins byte 'Computer2 wins.', 0ah, 0dh, 0h
winner byte 0
computertie byte 'Tie game.', 0ah, 0dh, 0h
colorswitch byte 1
compturn byte 1
computerinput2 byte 0
fullcolumn2 byte 0

.code 
call clrscr
goagain:												;//This follows the same algorithm of all the other procedures
invoke displayBoard, 0, 0, boolBoard					;//The exception is that there is no random selection of who goes first since both players are computer
cmp compturn, 1
je playergoes

skip :										
inc compturn
invoke computerChoice, computerinput2
move computerinput2, ah
move al, computerinput2
move edx, offset computer2turn
call writestring
push eax
move eax, 2000
call delay
pop eax
jmp takeinput

playergoes :														;//getting the computer's random selection
dec compturn
move edx, offset computer1turn
call writestring
invoke computerChoice, computerinput2
move computerinput2, ah
move al, computerinput2
push eax
move eax, 2000
call delay
pop eax

takeinput :															;//placing the color based on computer's input
cmp al, 1
jne opt2
move computerinput2, al
invoke placeColor, computerinput2, offset fullcolumn2, boolBoard, colorswitch
jmp nextturn

opt2 :
cmp al, 2
jne opt3
move computerinput2, al
invoke placeColor, computerinput2, offset fullcolumn2, boolBoard, colorswitch
jmp nextturn

opt3 :
cmp al, 3
jne opt4
move computerinput2, al
invoke placeColor, computerinput2, offset fullcolumn2, boolBoard, colorswitch
jmp nextturn

opt4 :
cmp al, 4
move computerinput2, al
invoke placeColor, computerinput2, offset fullcolumn2, boolBoard, colorswitch
jmp nextturn

nextturn :
cmp colorswitch, 1
je goyellow
dec colorswitch
jmp keepgoing
goyellow :
inc colorswitch

keepgoing :									;//checking to see if the column is full
cmp fullcolumn2, 1
jne notfull
xor colorswitch, 11b
cmp compturn, 0
je player

move fullcolumn2, 0
move compturn, 0
jmp skip

player :
move compturn, 1
move fullcolumn2, 0
jmp goagain

notfull :										;//if not full, check to see if there is a winner
invoke checkWin, boolBoard, offset winner
cmp winner, 0
jne gameover
call clrscr
jmp goagain

gameover :
call clrscr
invoke displayBoard, 0, 0, boolBoard
cmp winner, 1
jne compwins
move edx, offset comp1wins
call writestring
jmp endit

compwins :
cmp winner, 2
jne tiegame
move edx, offset comp2wins
call writestring
jmp endit

tiegame :
move edx, offset tie
call writestring

endit :
move winner, 0
move compturn, 1
move colorswitch, 1
call waitmsg
call clrscr
ret
computervcomputer endp

;//----------------------------------

computerChoice proc, compchoice : byte

;//Description: This proc gets a random move choice from the computer
;//Receives: N/A
;//Returns: The computer's random choice in the compchoice variable
;//Requires: computerinput passed to the procedure

.code
move ax, 500
call randomrange					;//getting a random selection for the computer's move choice
move bl, 4
div bl								
inc ah								;//computer's choice of 1-4 now in AH
move compchoice, ah


ret
computerChoice endp


;//----------------------------------
placeColor proc, input:byte, isfull : dword, compareboard : ptr byte, colorturn : byte

;//Description: This proc places the appropriate color into the lowest available position on the board
;//Receives: The input from the user or computer, the checkboard filled with boolean values, and the current color
;//Returns: Checkboard with updated boolean values
;//Requires: N/A
.data
increment byte 12

.code
move edi, isfull
move ecx, 4
move esi, compareboard
movzx ebx, increment

findcolumn:									;//getting the user/computer selected column
cmp input, 1
je col1
cmp input, 2
je col2
cmp input, 3
je col3
cmp input, 4
je col4

col1:														;//finding the lowest available position in the column
cmp byte ptr [esi+ebx], 0
jne goUp
move al, colorturn
move byte ptr [esi+ebx], al
jmp done

col2:
cmp byte ptr[esi+1+ebx], 0
jne goUp
move al, colorturn
move byte ptr [esi+1+ebx], al
jmp done

col3:
cmp byte ptr[esi + 2 + ebx], 0
jne goUp
move al, colorturn
move byte ptr[esi + 2 + ebx], al
jmp done

col4:
cmp byte ptr[esi + 3 + ebx], 0
jne goUp
move al, colorturn
move byte ptr[esi + 3 + ebx], al
jmp done

goUp:												;//if the bottom position is filled, go up to the next
sub ebx, 4
loop findcolumn
move byte ptr [edi], 1


done:
ret
placeColor endp
;//----------------------------------

checkwin proc, boolBoard : ptr byte, didwin : DWORD

;//Description: This proc checks all combinations where we could have three in a row
;//Receives: The board of boolean values
;//Returns: Win, tie, or neither
;//Requires: Values placed in the checkboard

.data
counter byte 0
.code
move esi, boolBoard											;//using our checkboard of boolean values to see if there is a winner
push esi
move EBX, didwin
move ecx, 0
move edi, 0

vertical:													;//checking vertically first
move al, byte ptr [esi+4]
cmp byte ptr [esi+8], al
jne nextcol
cmp al, 0
je nextcol
cmp byte ptr [esi], al
je win
cmp byte ptr[esi+12], al
je win

nextcol:													;//check the next column if a win wasn't found
inc esi
inc edi
cmp edi, 4
je gohorizontal
jmp vertical

gohorizontal:
pop esi
push esi

horizontal:													;//next we check horizontal
move al, byte ptr [esi+ecx+1]
cmp byte ptr [esi+ecx+2], al
jne nextrow
cmp al, 0
je nextrow
cmp byte ptr [esi+ecx], al
je win
cmp byte ptr [esi+ecx+3], al
je win

nextrow:													;//move to the next row, if no winner found
add ecx, 4
dec edi
cmp edi, 0
je godiag
jmp horizontal

godiag:
pop esi
push esi

diagongal:													;//there are six different potential diagonal combinations
move al, byte ptr [esi+5]
cmp byte ptr[esi+10], al
jne nextdiag
cmp al, 0
je nextdiag
cmp byte ptr [esi], al
je win
cmp byte ptr [esi+15], al
je win

nextdiag:										;//checking diag#2
move al, byte ptr [esi+4]
cmp byte ptr [esi+9], al
jne nextdiag2
cmp al, 0
je nextdiag2
cmp byte ptr[esi+14], al
je win

nextdiag2:										;//checking diag#3
move al, byte ptr [esi+1]
cmp byte ptr [esi+6], al
jne nextdiag3
cmp al, 0
je nextdiag3
cmp byte ptr [esi+11], al
je win

nextdiag3:										;//diag#4
move al, byte ptr [esi+2]
cmp byte ptr [esi+5], al
jne nextdiag4
cmp al, 0
je nextdiag4
cmp byte ptr [esi+8], al
je win

nextdiag4:										;//diag#5
move al, byte ptr [esi+6]
cmp byte ptr [esi+9], al
jne nextdiag5
cmp al, 0
je nextdiag5
cmp byte ptr [esi+3], al
je win
cmp byte ptr [esi+12], al
je win

nextdiag5:										;//final diagonal combination
move al, byte ptr [esi+7]
cmp byte ptr [esi+10], al
jne nowin
cmp al, 0
je nowin
cmp byte ptr [esi+13], al
je win

	
win:											;//if there is a winner is it player 1 or 2
move byte ptr [ebx], al
jmp finish

nowin:
move al, byte ptr [esi]
cmp al, 0
je finish
inc esi
cmp esi, 16
je tiegame
jmp nowin

tiegame:
move al, 3
move byte ptr [ebx], al

finish:
pop esi
ret
checkWin endp

;//-------------------------------

cleanBoard proc, boolBoard : ptr byte

;//Description: This proc simply cleans the board for additional games.
;//Receives: Checkboard.
;//Returns: A nice, clean board
;//Requires: N/A

.code
move esi, boolBoard
move ecx, 16

clearboard:
move byte ptr [esi], 0
inc esi
loop clearboard

ret
cleanBoard endp

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