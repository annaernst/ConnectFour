.data 

board:      
		.word 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0
		.word 0, 0, 0, 0, 0, 0, 0
		
ROW_SIZE:	.word 6
COL_SIZE:	.word 7
.eqv DATA_SIZE 4
		 
printInE:	.asciiz "Invalid Move! Try Again!\n"

colIndex:    	.word 0





.text
	jal drawGameOnBoot
     
inputLoop:
# Take WASD input    
	li $v0, 12            
     	syscall
     
     	beq $v0, 'a', colLeft		# select column left
     	beq $v0, 'd', colRight		# select column right
     	beq $v0, 's' 			# play in current column
     	j inputLoop
     	returnWASD:
              
# Check for invalid input (column full?)
     	la  $a0, board				# base address of board into $a0
     	lw  $a1, COL_SIZE			# num of coloumns into 	     $a1
     	lw $a3, colIndex	
     	jal validInput	   
# Upload to Array
     	la $a0, board
     	addi $a2, $0, -1			# row index set to -1
     	lw  $a1, COL_SIZE			# num of coloumns into 	     $a1
     	jal addValUser				# add to board(next available row)	

# HEREEEEEEEEEEEEEEEEEEEEEEEE

addValUser:	#$a0 -> base addr, $a1 -> COL_SIZE,  $a2 -> row index,  $a3 -> coloumn index, 	
	addi $a2, $a2, 1
	move $s0, $ra
	jal getAt		#result in $v0, address in $v1
	bne $v0, $0, addValUser
	move $ra, $s0
	# set arguments before call
	addi $t0, $0, 1    
	sw $t0, ($v1)
	jr $ra

# Check Valid Input
validInput:			
# Check if coloumn is full		(getAt function) $a0 -> base addr, $a1 -> COL_SIZE,  $a2 -> row index,  $a3 -> coloumn index
    	addi $a2, $0, 5			# row index into $a2
     	move $s0, $ra
     	jal getAt
     	# result in $v0
     	move $ra, $s0
     	bnez $v0, inputError		# if value is not ZERO (empty), then retake input
     	jr $ra				# else continue program
     
    
getAt:	#$a0 -> base addr, $a1 -> COL_SIZE,  $a2 -> row index,  $a3 -> coloumn Index
	move $s1, $t0
	add $t0, $t0, $0
     	lw  $a3, colIndex
     	mul $t0, $a1, $a2 		        # row index * COL_SIZE
     	add $t0, $t0, $a3			# + coloumnIndex
     	mul $t0, $t0, DATA_SIZE		# * Data Size
     	add $t0, $t0, $a0			# + base addr
     	lw  $v0, ($t0)				# value in $v0
     	la  $v1, ($t0)
	move $t0, $s1
     	jr  $ra				

     
inputError:
     li $v0, 4
     la $a0, printInE
     syscall
     j inputLoop
     
#------------------
# COLUMN SELECTION
#------------------

# decrement colIndex
colLeft:
	lw $t9, colIndex
	li $t8, 0
	beq $t9, $t8, colLast 		# if first column, select last
	li $t8, 1
	sub $t9, $t9, $t8		# otherwise, move one left
	sw $t9, colIndex
	j returnWASD
# increment colIndex
colRight:
	lw $t9, colIndex
	lw $t8, COL_SIZE
	sub $t8, $t8, 1			# zero index adjustment
	beq $t9, $t8, colFirst		# if last column, select first
	li $t8, 0
	add $t9, $t9, $t8		# otherwise, move one right
	sw $t9, colIndex
	j returnWASD
# set colIndex to the last column
colLast:
	li $t9, COL_SIZE
	sub $t9, $t9, 1			# zero index adjustment
	sw $t9, colIndex
	j returnWASD
# set colIndex to 0
colFirst:
	li $t9, 0
	sw $t9, colIndex
	j returnWASD
    
# HEREEEEEEEEEEEEEEEEEEEEEEEEEEE
    
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
        j exit              

#---------------
# SOUND EFFECTS
#---------------

errorSound:
li $a0, 72 # pitch (0-127) - this is the C an octave above middle C
li $a1, 1000 # duration of each sound in milliseconds (1000 = 1 second)
li $a3, 100 # volume (0-127)
li $a2, 55
li $v0, 33
jr $ra

dropSound:
li $a0, 67 # pitch (0-127) 
li $a1, 1000 # duration of each sound in milliseconds (1000 = 1 second)
li $a3, 100 # volume (0-127)
li $a2, 117 # instrument 
li $v0, 33
syscall
jr $ra

lostSound:
li $a0, 70 # pitch (0-127)
li $a1, 400 # duration of each sound in milliseconds (1000 = 1 second)
li $a3, 100 # volume (0-127)
li $a2, 14 # instrument 
li $t0, 67 # ending pitch
lostSoundLoop:
li $v0, 33
syscall
sub $a0, $a0, 1
bne $a0, $t0, lostSoundLoop
sub $a0, $a0, 2
li $a1, 1000 # duration of each sound in milliseconds (1000 = 1 second)
li $v0, 33
syscall
jr $ra

wonSound:
li $a0, 67 # pitch (0-127) 
li $a1, 400 # duration of each sound in milliseconds (1000 = 1 second)
li $a3, 100 # volume (0-127)
li $a2, 14 # instrument 
li $t0, 70 # ending pitch
lostSoundLoop:
li $v0, 33
syscall
addi $a0, $a0, 1
bne $a0, $t0, lostSoundLoop
sub $a0, $a0, 2
li $a1, 1000 # duration of each sound in milliseconds (1000 = 1 second)
li $v0, 33
syscall
jr $ra

# Terminate Program
exit:
     li $v0, 10
     syscall
