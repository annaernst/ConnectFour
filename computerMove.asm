  .data
    increment: .word 1
      
   .text
    #Starting moves begin in center and tries to control as much of center as possible
   startingMoves:
   addi $sp, $sp, -8   
   sw $ra, 0($sp) 
   sw $s0, 4($sp)  
     
        lw $t8, increment #increment for moves
        startingPoint:
        li $t3, 1
        beq $s0, $t3, move1
        li $t3, 2
        beq $s0, $t3, move2
        li $t3, 3
        beq $s0, $t3, move3
        li $t3, 4
        beq $s0, $t3, move4
        li $t3, 5
        beq $s0, $t3, move5
        jal computerMove
    cpuTurnEnd:
        
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
       
       move1:
    	li $a0, 3
    	addi $a1, $zero, 0 
    	li $a2, 2
    	jal drawPlayerPiece
    	addi $s0, $s0, 1
    	sw $s0, increment($zero)
    	j cpuTurnEnd
       move2: 
    	li $a0, 3
    	addi $a1, $zero, 1
    	li $a2, 2
    	jal drawPlayerPiece
    	addi $s0, $s0, 1
    	sw $s0, increment($zero)
    	j cpuTurnEnd
       move3:
    	li $a0, 4
    	addi $a1, $zero, 0 
    	li $a2, 2
    	jal drawPlayerPiece
    	addi $s0, $s0, 1
    	sw $s0, increment($zero)
    	j cpuTurnEnd
      move4:
    	li $a0, 1
    	addi $a1, $zero, 0 
    	li $a2, 2
    	jal drawPlayerPiece
    	addi $s0, $s0, 1
    	sw $s0, increment($zero)
    	j cpuTurnEnd
    	move5:
    	li $a0, 2
    	addi $a1, $zero, 0 
    	li $a2, 2
    	jal drawPlayerPiece
    	addi $s0, $s0, 1
    	sw $s0, increment($zero)
    	j cpuTurnEnd
    	
    	
   lw $ra, 0($sp)
   addi $sp, $sp, 4
   jr $ra
    computerValid:
    li $v0, 42  
    syscall
    move $t0, $a1
   
   # Compute Computer's position and return
   divu $t1, $t0, 7      
   mfhi $t2            #t2 is the mod with 7 for column
   move $v0, $t2       
   jr $ra              
  computerMove:
        li $a0, 0                         
        li $a1, 6                
        addi $sp, $sp, -4                 
        sw $ra, 0($sp)                  
   
        computer: 
        	  jal computerValid    
                  move $t2, $v0            #moves the random number of $v0 to t2, which will be the column computer will choose
                  blt $t2, $a0, computer #loop back if number is less than 0
                  bgt $t2, $a1, computer   #loop back if number is greater than 6           
                  blt $t7, $zero, computer # if placement value less than 0, Branch to computer again
         
        move $a1, $t5            #y
        move $a0, $t2           #x
        li $a2, 2
        jal drawPlayerPiece
        # decrement by 1 for next placement
        addi $a1, $a1, 1                 
                           
        lw $ra, 0($sp)     #restores from stack
        addi $sp, $sp, 4                 
        
        #restores registers from stack
        lw $ra, 0($sp)                     
        addi $sp, $sp, 4 
        
