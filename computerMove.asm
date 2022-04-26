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
                  blt $t2, $a0, computer #loop back if number is less than 1
                  bgt $t2, $a1, computer   #loop back if number is greater than 7
                  li $t6, 4                
                  mul $t4, $t5, $t6       #$t4 = i(computer column - 1) * 4 (index times 4 bytes)
                  add $t4, $s5, $t4        # $t4 = placement of computer Column - 1 (Base + Offset)
                  lw $t7, 0($t4)           
                  
                  blt $t7, $zero, computer # if placement value less than 0, Branch to computer again
         
       #used to set the next row for the computer placement 
        mul $t3, $t7, $s3                  
        add $t3, $t3, $t2                
        add $t3, $s4, $t3              
        #instruction to place $t3 into the graphics                    
          
        # Decrement by 1 for next placement
        addi $t7, $t7, -1                  
        sw $t7, 0($t4)                   
        lw $ra, 0($sp)                   
        addi $sp, $sp, 4                 
