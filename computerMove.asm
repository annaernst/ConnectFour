  .data 

board: .word 0, 0, 0, 0, 0, 0, 0
	    .word 0, 0, 0, 0, 0, 0, 0
	    .word 0, 0, 0, 0, 0, 0, 0
	    .word 0, 0, 0, 0, 0, 0, 0
	    .word 0, 0, 0, 0, 0, 0, 0
	    .word 0, 0, 0, 0, 0, 0, 0
 
.text
  computerValid:
   addi $sp, $sp, -4   # Adjust Stack Pointer
   sw $ra, 0($sp)      # Save current $ra (Return Address of main)
        
   subu $t8, $a5, $a0  
   addiu $t8, $t8, 1  
        
  
   jal getComputer    
   move $t1, $v0      
   
   
   lw $ra, 0($sp)      
   addi $sp, $sp, 4    
   
   # Compute Computer's position and return
   divu $t1, $t8       
   mfhi $t2            
   addu $t2, $t2, $a0  
   move $v0, $t2       
   jr $ra              
        
   getComputer:
       
        li $t3, 46655         
        li $t4, 30208    
        
        andi $t5, $s1, 81293  #Using random number as a seed to generate computer position
        srl $t6, $s1, 16      
        mul $s1, $t3, $t5     
        addu $s1, $s1, $t6   
        andi $t5, $s0, 78597 
        srl $t6, $s0, 16     
        mul $s0, $t4, $t5    
        addu $s0, $s0, $t6    
        sll $t7, $s1, 16      
        addu $t9, $t7, $s0  
        move $v0, $t9         
        jr $ra                
        
  computerMove:
        li $a0, 1                         
        li $a5, 7                   
        addi $sp, $sp, -4                 
        sw $ra, 0($sp)                  
   
        computer: 
        	  jal computerValid    
                  move $t2, $v0            
                  addi $t5, $t2, -1        
                  blt $t2, $a0, computer 
                  bgt $t2, $a5, computer   
                  li $t6, 4                
                  mul $t4, $t5, $t6        
                  add $t4, $s5, $t4        
                  lw $t7, 0($t4)           
                  
                  blt $t7, $zero, computer # if placement value less than 0, Branch to computer again
         
       
        mul $t3, $t7, $s3                  
        add $t3, $t3, $t2                
        add $t3, $s4, $t3              
        #instruction to place $t3 into the graphics, it would be array[row][$t3].                    
          
        # Decrement by 1 for next placement
        addi $t7, $t7, -1                  
        sw $t7, 0($t4)                   
        lw $ra, 0($sp)                   
        addi $sp, $sp, 4                 
