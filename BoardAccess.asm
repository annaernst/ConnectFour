.data 

board:      .word 0, 0, 0, 0, 0, 0, 0
	    .word 0, 0, 0, 0, 0, 0, 0
	    .word 0, 0, 0, 0, 0, 0, 0
	    .word 0, 0, 0, 0, 0, 0, 0
	    .word 0, 0, 0, 0, 0, 0, 0
	    .word 0, 0, 0, 0, 0, 0, 0

ROW_SIZE:   .word 6
COL_SIZE:   .word 7
.eqv DATA_SIZE 4
		 
userInput:    .asciiz "Enter column number (1-7)\n"
welcome:    .asciiz "Welcome to Connect Four!\n"
printInE:   .asciiz "Invalid Move! Try Again!\n"

colIndex:    .word 0

.text
#Print Welcome Message
li $v0, 4
la $a0, welcome
syscall
     
inputLoop:
# Print input prompt
     li $v0, 4
     la $a0, userInput
     syscall  
                
# Take input    
     li $v0, 5            
     syscall
     
     
# Adjust input and save --> coloumn
     addi $v0, $v0, -1    
     sw   $v0, colIndex              
# Check for invalid input
     la  $a0, board			# base address of board into $a0
     lw  $a1, COL_SIZE			# num of coloumns into 	     $a1
     lw $a3, colIndex	
     jal validInput	   
# Upload to Array
     la $a0, board
     addi $a2, $0, -1			# row index set to -1
     lw  $a1, COL_SIZE			# num of coloumns into 	     $a1
     jal addValUser				# add to board(next available row)	



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
# If input <1 or >7, try again
     bgt  $a3, 6, inputError
     blt  $a3, 0, inputError
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
     mul $t0, $t0, DATA_SIZE			# * Data Size
     add $t0, $t0, $a0			# + base addr
     lw  $v0, ($t0)			# value in $v0
     la  $v1, ($t0)
move $t0, $s1
     jr  $ra				

     
inputError:
     li $v0, 4
     la $a0, printInE
     syscall
     j inputLoop

# Terminate Program
Exit:
     li $v0, 10
     syscall
