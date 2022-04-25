.text

select column:
	li $v0, 12
	syscall #pauses to wait for input
	
	move $t1, $a0 #result character in $t1

