.data
	frameBuffer:	.space 0x100000	# set up space for 2d array of pixels
	colorBoard:	.word 0x000000ff# color values written as 0x00RRGGBB
	colorP1:	.word 0x00ff0000
	colorP2:	.word 0x00ffff00
	colorDarker:	.word 0x00999999
.text
main:
drawGameOnBoot:				# the initial drawing of the game board
	li	$t3, 0
	la	$a0, frameBuffer	# array position
	li	$a1, 16383		# stop point for this draw section
	li	$a2, 0x00ffffff		# color
	jal	drawTop			# draw top white section
	li	$a1, 229376
	lw	$a2, colorBoard
	jal	drawBoard		# draw middle blue board section
	li	$a1, 262144
	li	$a2, 0x00ffffff
	jal	drawBot			# draw bottom white section
	jal	drawInitialField	# draw initial white circles on board
	
	addi	$v0, $zero, 17
	syscall
	
drawTop:				#draws above board full white
	sw	$a2, 0($a0)
	addi	$a0, $a0, 4
	addi	$t3, $t3, 1
	bne	$a1, $t3, drawTop
	jr	$ra
	


	
drawBoard:				#draws board full blue no circles yet
	sw	$a2, 0($a0)
	addi	$a0, $a0, 4
	addi	$t3, $t3, 1
	bne	$a1, $t3, drawBoard
	jr	$ra

	
	
drawBot:				#draws below board full white
	sw	$a2, 0($a0)
	addi	$a0, $a0, 4
	addi	$t3, $t3, 1
	bne	$a1, $t3, drawBot
	jr	$ra


drawInitialField:			# draw 7x6 white circles of radius 17 in the board
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	li	$t4, 46655		# hardcoded start point for first circle
	li	$a2, 17			# circle radius
	li	$a3, 0x00ffffff		# circle color (white)
	li	$t5, 7			# circles per row
	li	$t6, 6			# circles per colm
initialCircleLoop:
	move	$a0, $t4		# match memory position to next circle
	jal	fillCircle		# draw circle at currect memory position
	addi	$t5, $t5, -1
	addi	$t4, $t4, 63		# hard coded value to move to space radius 17 circles (x)
	bnez	$t5, initialCircleLoop	# end of loop for row
	li	$t5, 7			# reset num circles for row on new row
	addi	$t4, $t4, 29767		# hard coded value to move to space radius 17 circles (y)
	addi	$t6, $t6, -1
	bnez	$t6, initialCircleLoop	# end of loop for colm
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
drawPlayerPiece:			# Use to fill circle on board at x = $a0, y = $a1, from player $a2
					# (x, y) refers to board 7x6, with top left being (0, 0)
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)		# setup stack point
	
	mul	$a0, $a0, 63
	mul	$a1, $a1, 30208
	add	$a0, $a0, 46655
	add	$a0, $a0, $a1		# set $a0 to pixel number of circle location
	
	lw	$a3, colorP1
	bne	$a2, 2, colorEqual	#decide color of circle
	
	lw	$a3, colorP2
colorEqual:
	add	$a2, $zero, 17
	jal	fillCircle
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
fillCircle:				# fill circle at pixel $a0, radius $a2, with color $a3

	addi	$sp, $sp, -20
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 16($sp)
	sw	$s3, 20($sp)
	sw	$a3, 20($sp)
	
	add	$s0, $a2, $zero		# needed for keeping the initial radius saved between func calls
	li	$t0, 512		# hard coded value to seperate x and y values in the memory address
	div	$a0, $t0
	mfhi	$a0			# remainder = x cord = $a0
	mflo	$a1			# quotient  = y cord = $a1
	
	
	
	

fillCircleLoop:
	jal	drawCircle		# draw circle at x,y cords, (just outline, not filled!
	addi	$a2, $a2, -1		# reduce radius by 1 and loop to fill in circle
	bnez	$a2, fillCircleLoop
	
fillStrayPixels:
	lw	$s3, colorDarker
	and	$a3, $a3, $s3
	add	$s1, $zero, $a0
	add	$s2, $zero, $a1
	
	
	jal	drawPoint		# start drawing stray pixels
	
					# next set of pixels
	add	$a0, $s1, 1
	add	$a1, $s2, 1
	jal	drawPoint
		
	add	$a0, $s1, -1
	add	$a1, $s2, 1
	jal	drawPoint
	
	add	$a0, $s1, 1
	add	$a1, $s2, -1
	jal	drawPoint

	add	$a0, $s1, -1
	add	$a1, $s2, -1
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 2
	add	$a1, $s2, 4
	jal	drawPoint
		
	add	$a0, $s1, -2
	add	$a1, $s2, 4
	jal	drawPoint
	
	add	$a0, $s1, 2
	add	$a1, $s2, -4
	jal	drawPoint

	add	$a0, $s1, -2
	add	$a1, $s2, -4
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 4
	add	$a1, $s2, 2
	jal	drawPoint
		
	add	$a0, $s1, -4
	add	$a1, $s2, 2
	jal	drawPoint
	
	add	$a0, $s1, 4
	add	$a1, $s2, -2
	jal	drawPoint

	add	$a0, $s1, -4
	add	$a1, $s2, -2
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 4
	add	$a1, $s2, 5
	jal	drawPoint
		
	add	$a0, $s1, -4
	add	$a1, $s2, 5
	jal	drawPoint
	
	add	$a0, $s1, 4
	add	$a1, $s2, -5
	jal	drawPoint

	add	$a0, $s1, -4
	add	$a1, $s2, -5
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 5
	add	$a1, $s2, 4
	jal	drawPoint
		
	add	$a0, $s1, -5
	add	$a1, $s2, 4
	jal	drawPoint
	
	add	$a0, $s1, 5
	add	$a1, $s2, -4
	jal	drawPoint

	add	$a0, $s1, -5
	add	$a1, $s2, -4
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 6
	add	$a1, $s2, 6
	jal	drawPoint
		
	add	$a0, $s1, -6
	add	$a1, $s2, 6
	jal	drawPoint
	
	add	$a0, $s1, 6
	add	$a1, $s2, -6
	jal	drawPoint

	add	$a0, $s1, -6
	add	$a1, $s2, -6
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 5
	add	$a1, $s2, 8
	jal	drawPoint
		
	add	$a0, $s1, -5
	add	$a1, $s2, 8
	jal	drawPoint
	
	add	$a0, $s1, 5
	add	$a1, $s2, -8
	jal	drawPoint

	add	$a0, $s1, -5
	add	$a1, $s2, -8
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 8
	add	$a1, $s2, 5
	jal	drawPoint
		
	add	$a0, $s1, -8
	add	$a1, $s2, 5
	jal	drawPoint
	
	add	$a0, $s1, 8
	add	$a1, $s2, -5
	jal	drawPoint

	add	$a0, $s1, -8
	add	$a1, $s2, -5
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 3
	add	$a1, $s2, 9
	jal	drawPoint
		
	add	$a0, $s1, -3
	add	$a1, $s2, 9
	jal	drawPoint
	
	add	$a0, $s1, 3
	add	$a1, $s2, -9
	jal	drawPoint

	add	$a0, $s1, -3
	add	$a1, $s2, -9
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 9
	add	$a1, $s2, 3
	jal	drawPoint
		
	add	$a0, $s1, -9
	add	$a1, $s2, 3
	jal	drawPoint
	
	add	$a0, $s1, 9
	add	$a1, $s2, -3
	jal	drawPoint

	add	$a0, $s1, -9
	add	$a1, $s2, -3
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 7
	add	$a1, $s2, 9
	jal	drawPoint
		
	add	$a0, $s1, -7
	add	$a1, $s2, 9
	jal	drawPoint
	
	add	$a0, $s1, 7
	add	$a1, $s2, -9
	jal	drawPoint

	add	$a0, $s1, -7
	add	$a1, $s2, -9
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 9
	add	$a1, $s2, 7
	jal	drawPoint
		
	add	$a0, $s1, -9
	add	$a1, $s2, 7
	jal	drawPoint
	
	add	$a0, $s1, 9
	add	$a1, $s2, -7
	jal	drawPoint

	add	$a0, $s1, -9
	add	$a1, $s2, -7
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 6
	add	$a1, $s2, 11
	jal	drawPoint
		
	add	$a0, $s1, -6
	add	$a1, $s2, 11
	jal	drawPoint
	
	add	$a0, $s1, 6
	add	$a1, $s2, -11
	jal	drawPoint

	add	$a0, $s1, -6
	add	$a1, $s2, -11
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 11
	add	$a1, $s2, 6
	jal	drawPoint
		
	add	$a0, $s1, -11
	add	$a1, $s2, 6
	jal	drawPoint
	
	add	$a0, $s1, 11
	add	$a1, $s2, -6
	jal	drawPoint

	add	$a0, $s1, -11
	add	$a1, $s2, -6
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 8
	add	$a1, $s2, 12
	jal	drawPoint
		
	add	$a0, $s1, -8
	add	$a1, $s2, 12
	jal	drawPoint
	
	add	$a0, $s1, 8
	add	$a1, $s2, -12
	jal	drawPoint

	add	$a0, $s1, -8
	add	$a1, $s2, -12
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 12
	add	$a1, $s2, 8
	jal	drawPoint
		
	add	$a0, $s1, -12
	add	$a1, $s2, 8
	jal	drawPoint
	
	add	$a0, $s1, 12
	add	$a1, $s2, -8
	jal	drawPoint

	add	$a0, $s1, -12
	add	$a1, $s2, -8
	jal	drawPoint
	

					# next set of pixels
	add	$a0, $s1, 9
	add	$a1, $s2, 10
	jal	drawPoint
		
	add	$a0, $s1, -9
	add	$a1, $s2, 10
	jal	drawPoint
	
	add	$a0, $s1, 9
	add	$a1, $s2, -10
	jal	drawPoint

	add	$a0, $s1, -9
	add	$a1, $s2, -10
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 10
	add	$a1, $s2, 9
	jal	drawPoint
		
	add	$a0, $s1, -10
	add	$a1, $s2, 9
	jal	drawPoint
	
	add	$a0, $s1, 10
	add	$a1, $s2, -9
	jal	drawPoint

	add	$a0, $s1, -10
	add	$a1, $s2, -9
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 11
	add	$a1, $s2, 11
	jal	drawPoint
		
	add	$a0, $s1, -11
	add	$a1, $s2, 11
	jal	drawPoint
	
	add	$a0, $s1, 11
	add	$a1, $s2, -11
	jal	drawPoint

	add	$a0, $s1, -11
	add	$a1, $s2, -11
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 10
	add	$a1, $s2, 13
	jal	drawPoint
		
	add	$a0, $s1, -10
	add	$a1, $s2, 13
	jal	drawPoint
	
	add	$a0, $s1, 10
	add	$a1, $s2, -13
	jal	drawPoint

	add	$a0, $s1, -10
	add	$a1, $s2, -13
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 13
	add	$a1, $s2, 10
	jal	drawPoint
		
	add	$a0, $s1, -13
	add	$a1, $s2, 10
	jal	drawPoint
	
	add	$a0, $s1, 13
	add	$a1, $s2, -10
	jal	drawPoint

	add	$a0, $s1, -13
	add	$a1, $s2, -10
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 4
	add	$a1, $s2, 16
	jal	drawPoint
		
	add	$a0, $s1, -4
	add	$a1, $s2, 16
	jal	drawPoint
	
	add	$a0, $s1, 4
	add	$a1, $s2, -16
	jal	drawPoint

	add	$a0, $s1, -4
	add	$a1, $s2, -16
	jal	drawPoint
	
					# next set of pixels
	add	$a0, $s1, 16
	add	$a1, $s2, 4
	jal	drawPoint
		
	add	$a0, $s1, -16
	add	$a1, $s2, 4
	jal	drawPoint
	
	add	$a0, $s1, 16
	add	$a1, $s2, -4
	jal	drawPoint

	add	$a0, $s1, -16
	add	$a1, $s2, -4
	jal	drawPoint
	
		
	add	$a2, $s0, $zero		# reset $a2 to initial radius before moving to next circle
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 16($sp)
	lw	$a3, 20($sp)
	addi	$sp, $sp, 16
	jr	$ra
	
drawCircle:				#draw circle at x = $a0, y = $a1, radius $a2, using color $a3
	
	addi	$sp, $sp, -32
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)
	sw	$s0, 12($sp)
	sw	$s1, 16($sp)
	sw	$s2, 20($sp)
	sw	$s3, 24($sp)
	sw	$s4, 28($sp)
	
	move $s3, $a0
	move $s4, $a1
	
	li	$s0, 1			# setup intial circle algorithm variables
	sub	$s0, $s0, $a2		
	
	li	$s1, 0
	
	mul	$s2, $a2, -2
	
	li	$t8, 0
	
	move	$t9, $a2
	
	add	$a0, $s3, $zero
	add	$a1, $s4, $a2
	jal	drawPoint		# draw initial 4 points (top bottem left right)
	add	$a0, $s3, $zero
	sub	$a1, $s4, $a2
	jal	drawPoint
	add	$a0, $s3, $a2
	add	$a1, $s4, $zero
	jal	drawPoint
	sub	$a0, $s3, $a2
	add	$a1, $s4, $zero
	jal	drawPoint
	
theCircleLoop:
	bge	$t8, $t9, exitCircleLoop
	bltz	$s0, circleSkip
	addi	$t9, $t9, -1
	addi	$s2, $s2, 2
	add	$s0, $s0, $s2
circleSkip:
	addi	$t8, $t8, 1		# update circle algorithm variables
	addi	$s1, $s1, 2
	add	$s0, $s0, $s1
	addi	$s0, $s0, 1
	
	add	$a0, $s3, $t8
	add	$a1, $s4, $t9
	jal	drawPoint		# draw next point and mirror it into other 7 symetrical sections of the circle
	
	sub	$a0, $s3, $t8
	add	$a1, $s4, $t9
	jal	drawPoint
	
	add	$a0, $s3, $t8
	sub	$a1, $s4, $t9
	jal	drawPoint
	
	sub	$a0, $s3, $t8
	sub	$a1, $s4, $t9
	jal	drawPoint
	
	add	$a0, $s3, $t9
	add	$a1, $s4, $t8
	jal	drawPoint
	
	sub	$a0, $s3, $t9
	add	$a1, $s4, $t8
	jal	drawPoint
	
	add	$a0, $s3, $t9
	sub	$a1, $s4, $t8
	jal	drawPoint
	
	sub	$a0, $s3, $t9
	sub	$a1, $s4, $t8
	jal	drawPoint
	
	j	theCircleLoop
	
exitCircleLoop:
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	lw	$s0, 12($sp)
	lw	$s1, 16($sp)
	lw	$s2, 20($sp)
	lw	$s3, 24($sp)
	lw	$s4, 28($sp)
	addi	$sp, $sp, 32
	jr	$ra
drawPoint:				# fills point at x = $a0, y = $a1, with color $a3
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	add	$t2, $a0, $zero		# add y cord to total
	sll	$t1, $a1, 9		# mult y cord by 512 to revert back into 1d array of pixels
	add	$t2, $t2, $t1		# add x cord to total
	sll	$t2, $t2, 2		# align total to word address
	la	$t0, frameBuffer	# setup initial memory address of pixels
	add	$t0, $t0, $t2		# add memory address to total to get to final positon
	sw	$a3, 0($t0)		# draw the pixel with color $a3
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
	
	
