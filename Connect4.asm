li $t9, 1		
	move $t2, $v0		
	move $t4, $v0		
        checkLeft:
     	la $t0, boardArray($t2)	
     	
        #If we are at the leftmost slot, skip to check right
     	div $t2, $t8
     	mfhi $t3		
     	beqz $t3, checkRight	
     	
     	#Else look at slot to our left
     	lb $t1, -1($t0)			
     	bne $t1, $a0, checkRight	
     	addiu $t9, $t9, 1		
     	addiu $t2, $t2, -1
	bgt $t9, 3, PlayerWon		
     	j checkLeft
     	
     	#From start, go RIGHT as far possible
	checkRight:
	la $t0, boardArray($t4)
	
	#If we are at rightmost slot, end horizontal checking
	div $t4, $t8
	mfhi $t3
	beq $t3, 6, endHorz	
	
	#Else look at slot to our right
	lb $t1, 1($t0)		
	bne $t1, $a0, endHorz	
	addiu $t9, $t9, 1	
	addiu $t4, $t4, 1	
	bgt $t9, 3, PlayerWon	
	j checkRight
	
	endHorz:
	
	#Check vertically for win
     	#From start, go UP as far possible
     	li $t9, 1		
	move $t2, $v0		
	move $t4, $v0		
        checkUp:
     	la $t0, boardArray($t2)	
     	
        #If we are at the top row, skip to checkDown
     	bgtu $t2, 34, checkDown	
     	
     	#Else look at slot above us
     	lb $t1, 7($t0)			
     	bne $t1, $a0, checkDown		
     	addiu $t9, $t9, 1		
     	addiu $t2, $t2, 7
	bgt $t9, 3, PlayerWon		
     	j checkUp
     	
     	#From start, go DOWN as far possible
	checkDown:
	la $t0, boardArray($t4)
	
	#If we are at bottom row, end vertical checking
	bltu $t4, 7, endVert
	
	#Else look at slot below us
	lb $t1, -7($t0)		
	bne $t1, $a0, endVert	
	addiu $t9, $t9, 1	
	addiu $t4, $t4, -7	
	bgt $t9, 3, PlayerWon	
	j checkDown
	
	endVert:  
     	