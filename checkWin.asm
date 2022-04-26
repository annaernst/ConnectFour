.data
board:      .word 0, 0, 0, 0, 0, 0, 0
        .word 0, 0, 0, 0, 0, 0, 0
        .word 0, 0, 0, 0, 0, 0, 0
        .word 0, 0, 0, 0, 0, 0, 0
        .word 0, 0, 0, 0, 0, 0, 0
        .word 0, 0, 0, 0, 0, 0, 0
tieprompt: .asciiz "It's a Tie!\n"
userwinprompt: .asciiz "You have won!\n"
compwinprompt: .asciiz "The Computer has won!\n"
.text
#register v0 would be the offset of the coin last placed starting from column 0 and register a0 is the player/comp number (1 = player, computer = 2)
checkForWin:
    addiu $sp, $sp, -4
         sw $ra, ($sp)
        li $t8, 7
        #register $t2 is used to check for coins to the left and #t5 is used to check for coins to the right
    li $t7, 1
    move $t2, $v0
    move $t5, $v0
        
           checkLeft:
         la $t0, board($t2)
         
        #If we are at the leftmost slot, skip to check right
         div $t2, $t8
         mfhi $t3
         beqz $t3, checkRight
         
         #Checking left
         lb $t1, -1($t0)
         bne $t1, $a0, checkRight    #In this Check, I would be using the value of the coin to be equal to player number
         addiu $t7, $t7, 1
         addiu $t2, $t2, -1
    bgt $t7, 3, UserWon
         j checkLeft
         
         #From start, go RIGHT as far possible
    checkRight:
    la $t0, board($t5)
    
    #If we are at rightmost slot, end horizontal checking
    div $t5, $t8
    mfhi $t3
    beq $t3, 6, endHorizontal
    
    #Checking right
    lb $t1, 1($t0)
    bne $t1, $a0, endHorizontal
    addiu $t7, $t7, 1
    addiu $t5, $t5, 1
    bgt $t7, 3, UserWon
    j checkRight
    
    endHorizontal:
    #Check vertically for win
          #register $t2 is used to check for coins to going up and #t5 is used to check for coins to going down
         li $t7, 1
    move $t2, $v0
    move $t5, $v0
        checkUp:
         la $t0, board($t2)
         
        #If we are at the top row, skip to checkDown
         bgtu $t2, 34, checkDown    #Check if offset is right ((6*7-1) - 7 = 34)
         
         #Check above
         lb $t1, 7($t0)
         bne $t1, $a0, checkDown
         addiu $t7, $t7, 1
         addiu $t2, $t2, 7
    bgt $t7, 3, UserWon
         j checkUp
         
         #From start, go DOWN as far possible
    checkDown:
    la $t0, board($t5)
    
    #If we are at bottom row, end vertical checking
    bltu $t5, 7, endVert
    
    #Else look at slot below us
    lb $t1, -7($t0)
    bne $t1, $a0, endVert
    addiu $t7, $t7, 1
    addiu $t5, $t5, -7
    bgt $t7, 3, UserWon
    j checkDown
    
    endVert:
         
         
         #Checking right diagonal (up + right) and left diagonal (left + down)
         #register $t2 is used to check for coins to going right diagonal and #t5 is used to check for coins to going left diagonal
         li $t7, 1
    move $t2, $v0
    move $t5, $v0
        checkRightDiagonal:
         la $t0, board($t2)    #Load our current chip address
         
        #If we are at the top row OR we are at the rightmost coloumn, then skip to down-left
         bgtu $t2, 34, checkLeftDiagonal    #Check if offset is right ((6*7-1) - 7 = 34)
    div $t2, $t8
    mfhi $t3
    beq $t3, 6, checkLeftDiagonal
         
         #Else look at slot above us and over to the right
         lb $t1, 8($t0)
         bne $t1, $a0, checkLeftDiagonal
         addiu $t7, $t7, 1
         addiu $t2, $t2, 8
    bgt $t7, 3, UserWon
         j checkRightDiagonal
         
         #From start, go Left Diagonal as far possible
    checkLeftDiagonal:
    la $t0, board($t5)
    
    #If we are at bottom row OR leftmost column, then end FSDiag checking
    bltu $t5, 7, endForwardDiagonal
    div $t5, $t8
    mfhi $t3
    beq $t3, 0, endForwardDiagonal
    
    #Else look at slot below us and over to the left one
    lb $t1, -8($t0)
    bne $t1, $a0, endForwardDiagonal
    addiu $t7, $t7, 1    #Else increment coutner
    addiu $t5, $t5, -8
    bgt $t7, 3, UserWon
    j checkLeftDiagonal
    
    endForwardDiagonal:

    #From start, go UP-LEFT as much as possible
    #register $t2 is used to check for coins to going up left diagonal and #t5 is used to check for coins to going down right diagonal
         li $t7, 1
    move $t2, $v0
    move $t5, $v0
        checkUpDiagonal:
         la $t0, board($t2)
         
        #If we are at the top most or left most, go check bottom right
         bgtu $t2, 34, checkDownDiagonal
    div $t2, $t8
    mfhi $t3
    beq $t3, 0, checkDownDiagonal
         
         #Check up left diagonal
         lb $t1, 6($t0)
         bne $t1, $a0, checkDownDiagonal
         addiu $t7, $t7, 1
         addiu $t2, $t2, 6
    bgt $t7, 3, UserWon
         j checkUpDiagonal
         
         #From start, go Down and right as much as possible
    checkDownDiagonal:
    la $t0, board($t5)
    
    #If we are at the bottom or the most right, then finish checking diagonals
    bltu $t5, 7, endBackwardDiagonal
    div $t5, $t8
    mfhi $t3
    beq $t3, 6, endBackwardDiagonal
    
    #Else look at the down right diagonal
    lb $t1, -6($t0)
    bne $t1, $a0, endBackwardDiagonal
    addiu $t7, $t7, 1
    addiu $t5, $t5, -6
    bgt $t7, 3, UserWon
    j checkDownDiagonal
    
    endBackwardDiagonal:
    
    #Checking entire board in case of ties
    li $t7, 35
         la $t0, board($t7)
         
         li $t2, 0
             
        checkTop:
        lb $t1, ($t0)
        beqz $t1, endTie
        addi $t0, $t0, 1
        add $t2, $t2, 1
        beq $t2, 7, gameTie    #If there are 7 chips in top row, it's a tie
        j checkTop
    
        endTie:
    
    lw $ra, ($sp)
    addiu $sp, $sp, 4
    jr $ra    #Return the game after checking board for win
    
    gameTie:
    la $a0, tieprompt
    li $v0, 4
    syscall
    
    UserWon:
    beq $a0, 1 player1Win    #If player 1 won, jump to second instruction set
    
    #Computer Won
    la $a0, compwinprompt
    li $v0, 4
    syscall
    li $v0, 10
    syscall
    
    #Player 1 Won
    player1Win:
    la $a0, userwinprompt
    li $v0, 4
    syscall
    li $v0, 10
    syscall
    
    lw	$ra, 0($sp)
    	addi	$sp, $sp, 32
	jr	$ra