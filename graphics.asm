.data
	frameBuffer:	.align 2
			.space 0x100000	# set up space for 2d array of pixels
	colorBoard:	.word 0x000000ff# color values written as 0x00RRGGBB
	colorP1:	.word 0x00ff0000
	colorP2:	.word 0x00ffff00
	colorDarker:	.word 0x00999999
	cColmSelect:	.word 1
	
.globl drawGameOnBoot
.globl drawPlayerPiece
.globl colorColmSelect

.text
	
	
	
drawGameOnBoot:				# the initial drawing of the game board
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
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
	jal	drawInitialColmSelect	# draw colm select on colm 0
	jal	drawInitialField	# draw initial white circles on board
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
drawTop:				#draws above board full white
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)

	sw	$a2, 0($a0)
	addi	$a0, $a0, 4
	addi	$t3, $t3, 1
	bne	$a1, $t3, drawTop
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	


	
drawBoard:				#draws board full blue no circles yet
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	sw	$a2, 0($a0)
	addi	$a0, $a0, 4
	addi	$t3, $t3, 1
	bne	$a1, $t3, drawBoard
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra

	
	
drawBot:				#draws below board full white
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	sw	$a2, 0($a0)
	addi	$a0, $a0, 4
	addi	$t3, $t3, 1
	bne	$a1, $t3, drawBot
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
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
	
	
drawInitialColmSelect:
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)

	add	$a0, $zero, 51
	add	$a1, $zero, 8
	lw	$a3, colorP1
	add	$s0, $zero, 0
	add	$s1, $zero, 0
	
colmInitialLoop:
	jal drawPoint
	add	$a0, $a0, 1
	add	$s0, $s0, 1
	bne	$s0, 25, colmInitialLoop
	sub	$a0, $a0, $s0
	add	$s0, $zero, 0
	add	$a1, $a1, 1
	add	$s1, $s1, 1
	bne	$s1, 16, colmInitialLoop
	
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra
	
colorColmSelect:
	addi	$sp, $sp, -16
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	
	move	$s2, $a0
	
	lw	$a0, cColmSelect
	mul	$a0, $a0, 63
	add	$a0, $a0, -12
	add	$a1, $zero, 8
	add	$a3, $zero, 0x00ffffff
	add	$s0, $zero, 0
	add	$s1, $zero, 0
	
colmEraseLoop:
	jal drawPoint
	add	$a0, $a0, 1
	add	$s0, $s0, 1
	bne	$s0, 25, colmEraseLoop
	sub	$a0, $a0, $s0
	add	$s0, $zero, 0
	add	$a1, $a1, 1
	add	$s1, $s1, 1
	bne	$s1, 16, colmEraseLoop
	
	
	
	move	$a0, $s2
	add	$a0, $a0, 1
	mul	$a0, $a0, 63
	add	$a0, $a0, -12
	add	$a1, $zero, 8
	lw	$a3, colorP1
	add	$s0, $zero, 0
	add	$s1, $zero, 0
	
colmColorLoop:
	jal drawPoint
	add	$a0, $a0, 1
	add	$s0, $s0, 1
	bne	$s0, 25, colmColorLoop
	sub	$a0, $a0, $s0
	add	$s0, $zero, 0
	add	$a1, $a1, 1
	add	$s1, $s1, 1
	bne	$s1, 16, colmColorLoop
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	addi	$sp, $sp, 16
	jr	$ra
	
drawEndingWin:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	lw	$a3, colorP1
	
	add	$a0, $zero, 75
	add	$a1, $zero, 454	
	jal	drawY
	
	add	$a0, $zero, 127
	add	$a1, $zero, 454
	jal	drawO
	
	add	$a0, $zero, 179
	add	$a1, $zero, 454
	jal	drawU
	
	add	$a0, $zero, 265
	add	$a1, $zero, 454
	jal	drawW
	
	add	$a0, $zero, 311
	add	$a1, $zero, 454
	jal	drawI
	
	add	$a0, $zero, 363
	add	$a1, $zero, 454
	jal	drawN
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
drawEndingLose:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	lw	$a3, colorP1
	
	add	$a0, $zero, 75
	add	$a1, $zero, 454	
	jal	drawY
	
	add	$a0, $zero, 127
	add	$a1, $zero, 454
	jal	drawO
	
	add	$a0, $zero, 179
	add	$a1, $zero, 454
	jal	drawU
	
	add	$a0, $zero, 259
	add	$a1, $zero, 454
	jal	drawL
	
	add	$a0, $zero, 311
	add	$a1, $zero, 454
	jal	drawO
	
	add	$a0, $zero, 363
	add	$a1, $zero, 454
	jal	drawS
	
	add	$a0, $zero, 415
	add	$a1, $zero, 454
	jal	drawE
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
drawEndingTie:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	lw	$a3, colorP1
	
	add	$a0, $zero, 75
	add	$a1, $zero, 454	
	jal	drawY
	
	add	$a0, $zero, 127
	add	$a1, $zero, 454
	jal	drawO
	
	add	$a0, $zero, 179
	add	$a1, $zero, 454
	jal	drawU
	
	add	$a0, $zero, 259
	add	$a1, $zero, 454
	jal	drawT
	
	add	$a0, $zero, 311
	add	$a1, $zero, 454
	jal	drawI
	
	add	$a0, $zero, 363
	add	$a1, $zero, 454
	jal	drawE
	
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra


fillCircle:				# fill circle at pixel $a0, radius $a2, with color $a3

	addi	$sp, $sp, -28
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 16($sp)
	sw	$s3, 20($sp)
	sw	$a3, 24($sp)
	
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
	
	
	jal	drawPoint
	
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
	lw	$s3, 20($sp)
	lw	$a3, 24($sp)
	addi	$sp, $sp, 28
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
	
drawY:					# draw letter Y in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 24		# draw left of Y
	add	$a2, $zero, 12
drawYLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawYLoop1
	
	add	$a0, $a0, 36
	add	$a1, $a1, -24
	add	$s0, $a1, 24		# draw right of Y
	add	$a2, $zero, 12
drawYLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2 
	bne	$a1, $s0, drawYLoop2
	
	add	$a0, $a0, -36
	add	$a1, $a1, -6
	add	$s0, $a1, 12		# draw mid of Y
	add	$a2, $zero, 48
drawYLoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2 
	bne	$a1, $s0, drawYLoop3
	
	add	$a0, $a0, 18
	add	$s0, $a1, 18		# draw botmid of Y
	add	$a2, $zero, 12
drawYLoop4:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2 
	bne	$a1, $s0, drawYLoop4
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
drawO:					# draw letter O in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 48		# draw left of O
	add	$a2, $zero, 12
drawOLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawOLoop1
	
	add	$a1, $a1, -48
	add	$a0, $a0, 36
	
	add	$s0, $a1, 48		# draw right of O
	add	$a2, $zero, 12
drawOLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawOLoop2
	
	add	$a0, $a0, -36
	add	$a1, $a1, -12
	
	add	$s0, $a1, 12		# draw bot of O
	add	$a2, $zero, 48
drawOLoop3:				
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawOLoop3
	
	add	$a1, $a1, -48
	add	$s0, $a1, 12
	add	$a0, $a0, 12		# draw top of O
	add	$a2, $zero, 24
drawOLoop4:				
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawOLoop4
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
drawU:					# draw letter U in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 48		# draw left of U
	add	$a2, $zero, 12
drawULoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawULoop1
	
	add	$a1, $a1, -48
	add	$a0, $a0, 36
	
	add	$s0, $a1, 48		# draw right of U
	add	$a2, $zero, 12
drawULoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawULoop2
	
	add	$a0, $a0, -36
	add	$a1, $a1, -12
	add	$s0, $a1, 12
	add	$a2, $zero, 48
drawULoop3:				# draw bot of U
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawULoop3
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
drawW:					# draw letter W in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 48		# draw left of W
	add	$a2, $zero, 12
drawWLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawWLoop1
	
	add	$a1, $a1, -48
	add	$a0, $a0, 36
	
	add	$s0, $a1, 48		# draw right of W
	add	$a2, $zero, 12
drawWLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawWLoop2
	
	add	$a1, $a1, -44
	add	$a0, $a0, -18
	
	add	$s0, $a1, 44		# draw mid of W
	add	$a2, $zero, 8
drawWLoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawWLoop3
	
	add	$a1, $a1, -12
	add	$s0, $a1, 12
	add	$a0, $a0, -18
	add	$a2, $zero, 48
drawWLoop4:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawWLoop4
	
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
drawI:					# draw letter I in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 12		# draw top of I
	add	$a2, $zero, 48
drawILoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawILoop1
	
	add	$s0, $a1, 24		# draw mid of I
	add	$a2, $zero, 12
	add	$a0, $a0, 18
drawILoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawILoop2
	
	add	$s0, $a1, 12		# draw bot of I
	add	$a2, $zero, 48
	add	$a0, $a0, -18
drawILoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawILoop3
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
drawN:					# draw letter N in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 48		# draw left of N
	add	$a2, $zero, 12
drawNLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawNLoop1
	
	add	$a1, $a1, -48
	add	$a0, $a0, 36
	
	add	$s0, $a1, 48		# draw right of N
	add	$a2, $zero, 12
drawNLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawNLoop2
	
	add	$a1, $a1, -42
	add	$a0, $a0, -36
	
	add	$s0, $a1, 36		# draw mid of N
	add	$a2, $zero, 12
drawNLoop3:
	jal	drawLine
	add	$a1, $a1, 1
	add	$a0, $a0, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawNLoop3
	
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra

drawL:					# draw letter L in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 36		# draw top of L
	add	$a2, $zero, 12
drawLLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawLLoop1
	
	add	$s0, $a1, 12		# draw bot of L
	add	$a2, $zero, 48
drawLLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawLLoop2
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
drawS:					# draw letter S in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 12		# draw top of S
	add	$a2, $zero, 48
drawSLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawSLoop1
	
	add	$s0, $a1, 8		# draw topmid of S
	add	$a2, $zero, 12
drawSLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawSLoop2
	
	add	$s0, $a1, 8		# draw mid of S
	add	$a2, $zero, 48
drawSLoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawSLoop3
	
	add	$s0, $a1, 8		# draw botmid of S
	add	$a2, $zero, 12
	add	$a0, $a0, 36
drawSLoop4:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawSLoop4
	
	add	$s0, $a1, 12		# draw bot of S
	add	$a2, $zero, 48
	add	$a0, $a0, -36
drawSLoop5:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawSLoop5
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
drawE:					# draw letter E in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 12		# draw top E
	add	$a2, $zero, 48
drawELoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawELoop1
	
	add	$s0, $a1, 8		# draw topmid of E
	add	$a2, $zero, 12
drawELoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawELoop2
	
	add	$s0, $a1, 8		# draw mid of E
	add	$a2, $zero, 24
drawELoop3:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawELoop3
	
	add	$s0, $a1, 8		# draw botmid of E
	add	$a2, $zero, 12
drawELoop4:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawELoop4
	
	add	$s0, $a1, 12		# draw top of E
	add	$a2, $zero, 48
drawELoop5:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawELoop5
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra

drawT:					# draw letter T in 48x48 starting at x=$a0, y=$a1, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a1, 12		# draw top of T
	add	$a2, $zero, 48
drawTLoop1:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawTLoop1
	
	add	$s0, $a1, 36		# draw bot of T
	add	$a2, $zero, 12
	add	$a0, $a0, 18
drawTLoop2:
	jal	drawLine
	add	$a1, $a1, 1
	sub	$a0, $a0, $a2
	bne	$a1, $s0, drawTLoop2
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
drawLine:			# draw horizontal line from x=$a0, y=$a1, length=$a2, color=$a3
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	
	add	$s0, $a2, $a0
	jal	drawPoint
dlLoop:
	add	$a0, $a0, 1
	jal	drawPoint
	bne	$a0, $s0, dlLoop
	
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
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
	
	
	
