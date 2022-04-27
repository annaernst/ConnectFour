    #Starting moves begin in center and tries to control as much of center as possible
    startingMoves:
    	li $a1, 3
    	addi $a0, $zero, 0 
    	li $a2, 2
    	jal drawPlayerPiece
    	li $a1, 3
    	addi $a0, $zero, 1
    	li $a2, 2
    	jal drawPlayerPiece
    	li $a1, 4
    	addi $a0, $zero, 0 
    	li $a2, 2
    	jal drawPlayerPiece
    	li $a1, 1
    	addi $a0, $zero, 0 
    	li $a2, 2
    	jal drawPlayerPiece
    	li $a1, 2
    	addi $a0, $zero, 0 
    	li $a2, 2
    	jal drawPlayerPiece
    	addi $a0, $zero, 0 
    computerValid:
   addi $sp, $sp, -4   
   sw $ra, 0($sp)     
        
    li $v0, 42  
    syscall
    addi $a1, $a0, 50
    li $v0, 42  
    syscall
   subu $t0, $a1, $a0  
   addiu $t0, $t0, 1  
   
   # li $v0, 42  
   # syscall
   #move $t0, $a0
   
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
                  addi $t5, $t2, -1        #decreases the value by 1 in register t5
                  blt $t2, $a0, computer #loop back if number is less than 0
                  bgt $t2, $a1, computer   #loop back if number is greater than 6
                  li $t6, 4                
                  mul $t4, $t5, $t6       
                  add $t4, $s5, $t4        
                  lw $t7, 0($t4)           
                  blt $t7, $zero, computer # if placement value less than 0, Branch to computer again
         
       #used to set the next row for the computer placement 
        mul $t3, $t7, $s3                  
        add $t3, $t3, $t2                
        add $t3, $s4, $t3   
        move $a0, $t5            
        move $a1, $t3           #a1
        li $a2, 2
        jal drawPlayerPiece
        # decrement by 1 for next placement
        addi $t7, $t7, -1                  
        sw $t7, 0($t4)                   
        lw $ra, 0($sp)                   
        addi $sp, $sp, 4                 
        
        #restores registers from stack
        lw $ra, 0($sp)                     
        addi $sp, $sp, 4 
