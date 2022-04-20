	.data
beep:		.byte 72
duration: 	.byte 100
volume: 	.byte 127
	
	.text
# iterates through all 128 (0-127) instruments
li $a2, 0 # instrument start
li $t2, 127 # instrument end
la $t1, loop # loop address to be used by jr

li $a1, 1000 # duration of each sound in milliseconds (1000 = 1 second)
li $a3, 100 # volume (0-127)

loop:
# print sound number
li $v0, 1
move $a0, $a2
syscall

# play sound & sleep for the duration of the sound
li $v0, 33
li $a0, 72 # pitch (0-127) - this is the C an octave above middle C (need to reset in loop b/c print also uses $a0)
syscall

# looping logistics
add $a2, $a2, 1 # increment instrument
beq $a2, $t2, exit # exit condition (when instrument reaches 127)
jr $t1

exit:
li $v0, 10
syscall
