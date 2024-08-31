######### Sean Xia ##########
######### 113181409 ##########
######### sexia ##########

.text
.globl initialize
initialize:
	#Need to account for windows and unix \r\n and \n alone
	addi $sp, $sp, -28 #Make space on stack to store registers
	sw $s0, 4($sp) #Preamble
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (fileName string)
	move $s1, $a1 #Save arg1 (Buffer address)
	
	#Open file
	move $a0, $s0
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall #$v0 file descriptor or negative if error 
	
	#Check if error
	bltz $v0, initialize_error
	
	#Read file
	move $t7, $v0
	move $a0, $v0
	move $a1, $sp
	li $a2, 1 #Want to read one character at a time
	li $v0, 14
	
	li $t0, '\r'
	li $t1, '\n'
	li $t2, '0'
	li $t3, '9'
	li $t4, 0 #Counter for number of integers read
	li $t5, 1 #For the col in the row col of the .txt file
	move $t6, $s1 #Address in buffer that needs to be added to

	j initialize_read_loop
initialize_read_loop:
	li $v0, 14
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, initialize_error
	beqz $v0, initialize_success
	lb $s5, 0($sp) #Should or can this be lb?
	beq $s5, $t0, initialize_read_loop
	beq $s5, $t1, initialize_read_loop
	blt $s5, $t2, initialize_error
	bgt $s5, $t3, initialize_error
	
	beqz $t4, initialize_row
	beq $t4, $t5, initialize_col
	
	j initialize_matrix
initialize_row:
	addi $s2, $s5, -48
	beqz $s2, initialize_error
	
	sw $s2, 0($t6)
	addi $t6, $t6, 4
	addi $t4, $t4, 1
	
	j initialize_read_loop
initialize_col:
	addi $s3, $s5, -48
	beqz $s3, initialize_error
	
	sw $s3, 0($t6)
	addi $t6, $t6, 4
	addi $t4, $t4, 1
	
	mul $t8, $s2, $s3
	addi $t8, $t8, 2
	
	j initialize_read_loop
initialize_matrix:
	addi $s5, $s5, -48
	sw $s5, 0($t6)
	addi $t6, $t6, 4
	addi $t4, $t4, 1
	
	j initialize_read_loop
initialize_error:
	move $a0, $t7
	li $v0, 16
	syscall
	
	li $v0, -1
	j initialize_reset
initialize_reset:
	bltz $t4, initialize_finish
	sw $0, 0($t6)
	addi $t6, $t6, -4
	addi $t4, $t4, -1
	j initialize_reset
initialize_success:
	bgt $t4, $t8, initialize_error
	
	move $a0, $t7
	li $v0, 16
	syscall
	
	li $v0, 1
	j initialize_finish
initialize_finish:
	lw $s0, 4($sp) #Restore register address or postamble
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28 #Deallocate stack
	jr $ra

.globl write_file
write_file:
	#Need to account for windows and unix \r\n and \n alone
	addi $sp, $sp, -20 #Make space on stack to store registers
	sw $s0, 4($sp) #Preamble
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (fileName string)
	move $s1, $a1 #Save arg1 (Buffer address)
	
	#Open file
	move $a0, $s0
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall #$v0 file descriptor or negative if error 
	
	#Check if error
	bltz $v0, write_error
	
	#Write file
	move $t8, $v0 #Make a copy of the file descriptor so we can close file later
	move $a0, $v0
	move $a1, $sp #Using sp as the input buffer
	li $a2, 1 #Want to read one character at a time
	li $v0, 15
	
	li $t1, '\r'
	li $t2, '\n'
	li $t3, 0 #Counter for number of integers written
	move $t4, $s1 #Location in buffer we are looking at
	li $t5, 0 #Column counter
	
	j write_row_col
write_row_col:
	lw $t6, 0($t4)
	move $s2, $t6 #row
	addi $t6, $t6, 48
	sb $t6, 0($sp)
	addi $t4, $t4, 4
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, write_error
	
	sb $t1, 0($sp) #\r
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, write_error
	
	sb $t2, 0($sp) #\n
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, write_error
	
	lw $t6, 0($t4)
	move $s3, $t6 #col
	addi $t6, $t6, 48
	sb $t6, 0($sp)
	addi $t4, $t4, 4
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, write_error
	
	sb $t1, 0($sp) #\r
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, write_error
	
	sb $t2, 0($sp) #\n
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, write_error
	
	addi $t3, $t3, 2
	
	mul $t7, $s2, $s3
	addi $t7, $t7, 2
	
	j write_loop
write_loop:
	beq $t3, $t7, write_finish
	lw $t6, 0($t4)
	addi $t6, $t6, 48
	sb $t6, 0($sp)
	addi $t4, $t4, 4
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, write_error
	addi $t3, $t3, 1 #Entire counter
	addi $t5, $t5, 1 #Column counter
	
	beq $t5, $s3, write_new_line
	
	j write_loop
write_new_line:
	li $t5, 0

	sb $t1, 0($sp) #\r
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, write_error
	
	sb $t2, 0($sp) #\n
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, write_error
	
	j write_loop
write_error:
	j write_finish
write_finish:
	#Close file
	move $a0, $t8
	li $v0, 16
	syscall
	
	lw $s0, 4($sp) #Restore register address or postamble
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20 #Deallocate stack
	jr $ra

.globl rotate_clkws_90
rotate_clkws_90:
	#Need to account for windows and unix \r\n and \n alone
	addi $sp, $sp, -32 #Make space on stack to store registers
	sw $ra, 4($sp) #Preamble
	sw $s0, 8($sp)
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	sw $s3, 20($sp)
	sw $s4, 24($sp)
	sw $s5, 28($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (Buffer address)
	move $s1, $a1 #Save arg1 (fileName string)
	
	#Open file
	move $a0, $s1
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall #$v0 file descriptor or negative if error 
	
	#Check if error
	bltz $v0, rotate_clkws_90_error
	
	#Write file
	move $t9, $v0 #Make a copy of the file descriptor so we can close file later
	move $a0, $v0
	move $a1, $sp #Using sp as the input buffer
	li $a2, 1 #Want to read one character at a time
	li $v0, 15
	
	li $t1, '\r'
	li $t2, '\n'
	li $t3, 0 #Counter for number of integers written
	move $t4, $s0 #Location in buffer we are looking at
	
	j rotate_clkws_90_get_row_col
rotate_clkws_90_get_row_col:
	lw $t5, 0($t4)
	move $s2, $t5 #row
	
	lw $t5, 4($t4)
	move $s3, $t5 	
	
	move $t5, $s3
	addi $t5, $t5, 48
	sb $t5, 0($sp) #Store col
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, rotate_clkws_90_error
	sb $t1, 0($sp) #\r
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, rotate_clkws_90_error
	sb $t2, 0($sp) #\n
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, rotate_clkws_90_error
	
	move $t5, $s2
	addi $t5, $t5, 48
	sb $t5, 0($sp) #Store row
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, rotate_clkws_90_error
	sb $t1, 0($sp) #\r
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, rotate_clkws_90_error
	sb $t2, 0($sp) #\n
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, rotate_clkws_90_error
	
	addi $t3, $t3, 2
	
	mul $t6, $s2, $s3
	addi $t6, $t6, 2
	
	addi $s4, $s2, -1 #row
	li $s5, 0 #col
	#addi $s5, $s3, -1 #col
	
	j rotate_clkws_90_loop #s2 row, s3 col, s4 i, s5 j 
rotate_clkws_90_loop: #Use $t4 as address while $s0 is the base buffer addr
	beq $t3, $t6, rotate_clkws_90_finish
	
	#Update t4 to correct number
	mul $t7, $s4, $s3
	add $t7, $t7, $s5
	sll $t7, $t7, 2
	add $t4, $s0, $t7
	addi $t4, $t4, 8
	
	lw $t5, 0($t4)
	addi $t5, $t5, 48
	sb $t5, 0($sp) #Store row
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, rotate_clkws_90_error
	
	addi $t3, $t3, 1 #Entire counter
	addi $s4, $s4, -1
	
	bltz $s4, rotate_clkws_90_new_line
	j rotate_clkws_90_loop
rotate_clkws_90_new_line:
	addi $s4, $s2, -1
	addi $s5, $s5, 1
	
	sw $t1, 0($sp) #\r
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, rotate_clkws_90_error
	
	sw $t2, 0($sp) #\n
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, rotate_clkws_90_error
	
	j rotate_clkws_90_loop
rotate_clkws_90_error:
	j rotate_clkws_90_finish
rotate_clkws_90_finish:
	#Close file
	move $a0, $t9
	li $v0, 16
	syscall
	
	move $a0, $s1
	move $a1, $s0
	jal initialize
	
	lw $ra, 4($sp) #Restore register address or postamble
	lw $s0, 8($sp)
	lw $s1, 12($sp)
	lw $s2, 16($sp)
	lw $s3, 20($sp)
	lw $s4, 24($sp)
	lw $s5, 28($sp)
	addi $sp, $sp, 32 #Deallocate stack
	jr $ra

.globl rotate_clkws_180
rotate_clkws_180:
	addi $sp, $sp, -12 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	move $s0, $a0
	move $s1, $a1
	jal rotate_clkws_90
	
	move $a0, $s0
	move $a1, $s1
	jal rotate_clkws_90
	
	j rotate_clkws_180_finish
rotate_clkws_180_finish:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12 #Deallocate stack
	jr $ra

.globl rotate_clkws_270
rotate_clkws_270:
	addi $sp, $sp, -12 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	move $s0, $a0
	move $s1, $a1
	jal rotate_clkws_180
	
	move $a0, $s0
	move $a1, $s1
	jal rotate_clkws_90
	
	j rotate_clkws_270_finish
rotate_clkws_270_finish:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12 #Deallocate stack
	jr $ra

.globl mirror
mirror:
	#Need to account for windows and unix \r\n and \n alone
	addi $sp, $sp, -32 #Make space on stack to store registers
	sw $ra, 4($sp) #Preamble
	sw $s0, 8($sp)
	sw $s1, 12($sp)
	sw $s2, 16($sp)
	sw $s3, 20($sp)
	sw $s4, 24($sp)
	sw $s5, 28($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (Buffer address)
	move $s1, $a1 #Save arg1 (fileName string)
	
	#Open file
	move $a0, $s1
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall #$v0 file descriptor or negative if error 
	
	#Check if error
	bltz $v0, mirror_error
	
	#Write file
	move $t9, $v0 #Make a copy of the file descriptor so we can close file later
	move $a0, $v0
	move $a1, $sp #Using sp as the input buffer
	li $a2, 1 #Want to read one character at a time
	li $v0, 15
	
	li $t1, '\r'
	li $t2, '\n'
	li $t3, 0 #Counter for number of integers written
	move $t4, $s0 #Location in buffer we are looking at
	
	j mirror_get_row_col
mirror_get_row_col:
	lw $t5, 0($t4)
	move $s2, $t5 #row
	
	lw $t5, 4($t4)
	move $s3, $t5 	
	
	move $t5, $s2
	addi $t5, $t5, 48
	sb $t5, 0($sp) #Store col
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, mirror_error
	sb $t1, 0($sp) #\r
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, mirror_error
	sb $t2, 0($sp) #\n
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, mirror_error
	
	move $t5, $s3
	addi $t5, $t5, 48
	sb $t5, 0($sp) #Store row
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, mirror_error
	sb $t1, 0($sp) #\r
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, mirror_error
	sb $t2, 0($sp) #\n
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, mirror_error
	
	addi $t3, $t3, 2
	
	mul $t6, $s2, $s3
	addi $t6, $t6, 2
	
	li $s4, 0 #row
	addi $s5, $s3, -1 #row
	
	#addi $s4, $s2, -1 #row
	#li $s5, 0 #col
	#addi $s5, $s3, -1 #col
	
	j mirror_loop #s2 row, s3 col, s4 i, s5 j 
mirror_loop: #Use $t4 as address while $s0 is the base buffer addr
	beq $t3, $t6, mirror_finish
	
	#Update t4 to correct number
	mul $t7, $s4, $s3
	add $t7, $t7, $s5
	sll $t7, $t7, 2
	add $t4, $s0, $t7
	addi $t4, $t4, 8
	
	lw $t5, 0($t4)
	addi $t5, $t5, 48
	sb $t5, 0($sp) #Store row
	li $v0, 15
	syscall #$v0 no. char. written or neg if error
	bltz $v0, mirror_error
	
	addi $t3, $t3, 1 #Entire counter
	addi $s5, $s5, -1
	
	bltz $s5, mirror_new_line
	j mirror_loop
mirror_new_line:
	addi $s5, $s3, -1
	addi $s4, $s4, 1
	
	sw $t1, 0($sp) #\r
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, mirror_error
	
	sw $t2, 0($sp) #\n
	li $v0, 15
	syscall #$v0 0 if end of file and negative if error
	bltz $v0, mirror_error
	
	j mirror_loop
mirror_error:
	j mirror_finish
mirror_finish:
	#Close file
	move $a0, $t9
	li $v0, 16
	syscall
	
	move $a0, $s1
	move $a1, $s0
	jal initialize
	
	lw $ra, 4($sp) #Restore register address or postamble
	lw $s0, 8($sp)
	lw $s1, 12($sp)
	lw $s2, 16($sp)
	lw $s3, 20($sp)
	lw $s4, 24($sp)
	lw $s5, 28($sp)
	addi $sp, $sp, 32 #Deallocate stack
	jr $ra

.globl duplicate
duplicate:
	#Need to account for windows and unix \r\n and \n alone
	addi $sp, $sp, -32 #Make space on stack to store registers
	sw $s0, 4($sp) #Preamble
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (Buffer address)
	
	#li $t0, 0 #Counter for number of integers written
	#move $t1, $s0 #Location in buffer we are looking at
	
	j duplicate_get_row_col
duplicate_get_row_col:
	lw $t0, 0($s0) #row
 	lw $t1, 4($s0) #col 

	#addi $t0, $t0, 2
	
	#mul $t3, $s1, $s2
	#addi $t3, $t3, 2
	li $s4, 0
	li $s5, 0
	li $s6, 0
	addi $s4, $s4, 1
	addi $s5, $s5, 2
	addi $s6, $s6, 3
	sll $t2, $t1, 2 #Num bits/row
	addi $t3, $t2, -4
	addi $a0, $s0, 8 #Starting address of matrix or ith row
	move $s1, $a0
	add $s1, $s1, $t2 #$s3 = i + ith row
	move $t6, $t0
	li $t7, 0
	li $t8, 1
	li $t9, 0
	move $s2, $a0
	move $s3, $s1
	addi $s4, $s4, -1
	addi $s5, $s5, -2
	addi $s6, $s6, -3
	j duplicate_row_loop
duplicate_row_loop:
	lw $t4, 0($a0)
	addi $s4, $s4, 1
	addi $s5, $s5, 2
	addi $s6, $s6, 3
	lw $t5, 0($s1)
	addi $s4, $s4, -1
	addi $s5, $s5, -2
	addi $s6, $s6, -3
	bne $t4, $t5, duplicate_include_row
	addi $t9, $t9, 1
	beq $t9, $t1, duplicate_check
	addi $a0, $a0, 4
	addi $s1, $s1, 4
	j duplicate_row_loop
duplicate_include_row:
	addi $t8, $t8, 1
	li $t9, 0
	move $a0, $s2
	addi $s4, $s4, 1
	addi $s5, $s5, 2
	addi $s6, $s6, 3
	move $s1, $s3
	addi $s4, $s4, -1
	addi $s5, $s5, -2
	addi $s6, $s6, -3
	beq $t8, $t0, duplicate_include_first
	add $s1, $s1, $t2
	move $s3, $s1
	j duplicate_row_loop
duplicate_include_first:
	addi $t7, $t7, 1
	addi $s4, $s4, 1
	addi $s5, $s5, 2
	addi $s6, $s6, 3
	addi $t8, $t7, 1
	addi $s4, $s4, -1
	addi $s5, $s5, -2
	addi $s6, $s6, -3
	beq $t8, $t0, duplicate_return
	add $a0, $a0, $t2
	add $s1, $a0, $t2
	move $s2, $a0
	move $s3, $s1
	j duplicate_row_loop
duplicate_check:
	blt $t8, $t6, duplicate_update
	j duplicate_next_row
duplicate_update:
	move $t6, $t8
	j duplicate_next_row
duplicate_next_row:
	li $t9, 0
	move $a0, $s2
	move $s1, $s3
	j duplicate_include_first
duplicate_dne:
	li $v0, -1
	li $v1, 0
	
	j duplicate_finish
duplicate_return:
	li $s4, 0
	li $s5, 0
	li $s6, 0
	beq $t6, $t0, duplicate_dne
	
	#Load the correct values into $v0 and $v1
	li $v0, 1
	move $v1, $t6 #Put row with duplicate in register $s5 if one is found
	addi $v1, $v1, 1
	
	j duplicate_finish
duplicate_error:
	j duplicate_finish
duplicate_finish:
	lw $s0, 4($sp) #Restore register address or postamble
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	addi $sp, $sp, 32 #Deallocate stack
	jr $ra
