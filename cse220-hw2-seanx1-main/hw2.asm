################# Sean Xia #################
################# sexia #################
################# 113181409 #################

################# DO NOT CHANGE THE DATA SECTION #################

.text
.globl to_upper
to_upper:
	lbu $t0, 0($a0)
	bnez $t0, to_upper_check_valid_char
	jr $ra
to_upper_check_valid_char:
	li $t1, 'a'
	li $t2, 'z'
	blt $t0, $t1, to_upper_iterate
	ble $t0, $t2, to_upper_convert
	j to_upper_iterate
to_upper_convert:
	addi $t0, $t0, -32
	sb $t0, 0($a0)
	j to_upper_iterate
to_upper_iterate:
	addi $a0, $a0, 1
	j to_upper

.globl remove
remove:
	li $v0, -1 #Initialize to fail and change to success if successful
	bltz $a1, remove_finish
	li $t0, 0 #Counter
	j remove_loop
remove_loop:
	lbu $t1, 0($a0) #Load character
	beqz, $t1, remove_finish
	beq $t0, $a1, remove_shift_loop
	addi $a0, $a0, 1
	addi $t0, $t0, 1
	j remove_loop
remove_shift_loop:
	lbu $t1, 0($a0) #Replaced
	lbu $t2, 1($a0) #Replacer
	sb $t2, 0($a0)
	addi $a0, $a0, 1
	bnez $t2, remove_shift_loop
	li $v0, 1 #Initialize to one to indicate success
	j remove_finish
remove_finish:
	jr $ra

.globl getRandomInt
getRandomInt:
	blez $a0, getRandomInt_fail
	move $a1, $a0
	li $v0, 42 #Not sure why we move 42 into $v0 before we even do the random generating but it is what is given in the instructions, nevermind
	syscall
	move $v0, $a0
	li $v1, 1
	jr $ra
getRandomInt_fail:
	li $v0, -1
	li $v1, 0
	jr $ra

.globl cpyElems
cpyElems:
	add $a0, $a0, $a1
	lbu $t0, 0($a0) #Load character
	sb $t0, 0($a2)
	addi $a2, $a2, 1
	sb $0, 0($a2)
	move $v0, $a2
	jr $ra

#These are functions as well right, should I be preserving the $s registers before I use them? Do I also save $fp everytime at the beginning of a function call
.globl genKey
genKey:
	addi $sp, $sp, -20 #Make space on stack to store registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	#move $fp, $sp
	li $s0, 26 #Number of characters in our alphabet that can be chosen from
	move $s1, $a0 #Save arg0 (alphabet string)
	move $s2, $a1 #Save arg1 (cipher string)
	#addi $sp, $sp, -4 #Make space on stack to store registers
	#sw $ra, 0($sp) #Save register address or preamble
	j genKey_loop	
genKey_loop:
	beqz $s0, genKey_finish
	move $a0, $s0
	jal getRandomInt #Now $v0 has random int in [0, $t0]
	#move $a1, $v0 #a0 has base address, nvm
	move $s3, $v0
	
	move $a0, $s1
	move $a1, $s3
	move $a2, $s2
	jal cpyElems #Now $v0 has next address for cipher key needed to be copied to
	move $s2, $v0
	
	move $a0, $s1
	move $a1, $s3
	jal remove #Returns 1 if pass or -1 if fail, not going to be used because assumed to work
	
	addi $s0, $s0, -1
	j genKey_loop
genKey_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20 #Deallocate stack
	jr $ra

.globl contains
contains:
	move $v0, $0 #Initialize to -1 + 1 (fail) and change to success if successful
	li $t0, 0 #Counter
	j contains_loop
contains_loop:
	lbu $t1, 0($a0)
	beqz $t1, contains_finish
	addi $a0, $a0, 1
	addi $t0, $t0, 1
	bne $t1, $a1, contains_loop
	move $v0, $t0 #Initialize to index + 1 to indicate success
	j contains_finish
contains_finish:
	addi $v0, $v0, -1
	jr $ra

.globl pair_exists
pair_exists:
	addi $sp, $sp, -28 #Make space on stack to store registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	move $s0, $a0 #Save arg0 (char1)
	move $s1, $a1 #Save arg1 (char2)
	move $s2, $a2 #Save arg2 (cipherkey string)
	
	li $t0, 'A'
	li $t1, 'Z'
	blt $s0, $t0, pair_exists_dne #Checks to see if char1 less than A
	bgt $s0, $t1, pair_exists_dne #Checks to see if char1 greater than Z
	blt $s1, $t0, pair_exists_dne #Checks to see if char2 less than A
	bgt $s1, $t1, pair_exists_dne #Checks to see if char2 greater than Z
	
	move $a0, $s2 #Move arg2 (cipherkey string) to arg0 for contains
	move $a1, $s0 #Move arg0 (char1) to arg1 for contains
	jal contains #Now $v0 has index where char1 was found or -1 if char1 was not found
	bltz $v0, pair_exists_dne
	move $s3, $v0
	
	move $a0, $s2 #Move arg2 (cipherkey string) to arg0 for contains
	move $a1, $s1 #Move arg1 (char2) to arg1 for contains
	jal contains #Now $v0 has index where char1 was found or -1 if char1 was not found
	bltz $v0, pair_exists_dne
	move $s4, $v0
	
	andi $s5, $s3, 1
	beqz $s5, pair_exists_char1_even
	addi $s3, $s3, -1
	j pair_exists_check
pair_exists_char1_even:
	addi $s3, $s3, 1
	j pair_exists_check
pair_exists_check:
	bne $s3, $s4, pair_exists_dne
	li $v0, 1
	j pair_exists_finish
pair_exists_dne:
	move $v0, $0
	j pair_exists_finish
pair_exists_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28 #Deallocate stack
	jr $ra
	
.globl encrypt
encrypt:
	addi $sp, $sp, -28 #Make space on stack to store registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	move $s0, $a0 #Save arg0 (plaintext string)
	move $s1, $a1 #Save arg1 (cipherkey string)
	move $s2, $a2 #Save arg2 (ciphertext)
	move $s3, $s2
	
	move $a0, $s0
	jal to_upper
	
	j encrypt_loop
encrypt_loop:
	li $t0, ' '
	li $t1, 'A'
	li $t2, 'Z'
	lbu $s4, 0($s0)
	beqz $s4, encrypt_pass
	beq $s4, $t0, encrypt_space
	blt $s4, $t1, encrypt_fail #Checks to see if char1 less than A
	bgt $s4, $t2, encrypt_fail #Checks to see if char1 greater than Z
	
	move $a0, $s1 #Move arg1 (cipher key string) to arg0 for contains
	move $a1, $s4 #Move plaintext character to arg1 for contains
	jal contains #Now $v0 has index where char1 was found or -1 if char1 was not found
	bltz $v0, encrypt_fail
	move $s5, $v0
	andi $v0, $v0, 1
	beqz $v0, encrypt_even
	addi $s5, $s5, -1
	j encrypt_letter 
encrypt_even:
	addi $s5, $s5, 1
	j encrypt_letter
encrypt_letter:
	move $a0, $s1
	move $a1, $s5
	move $a2, $s2
	jal cpyElems #Now $v0 has next address for cipher text needed to be copied to
	
	lbu $s5, 0($s2)
	beqz $s5, encrypt_fail
	
	addi $s0, $s0, 1
	move $s2, $v0
	j encrypt_loop
encrypt_space:
	li $t0, ' '
	sb $t0, 0($s2)
	addi $s0, $s0, 1
	addi $s2, $s2, 1
	j encrypt_loop
encrypt_fail:
	sb $0, 0($s3)
	move $v0, $0
	j encrypt_finish
encrypt_pass:
	sb $0, 0($s2)
	li $v0, 1
	j encrypt_finish
encrypt_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28 #Deallocate stack
	jr $ra

.globl decipher_key_with_chosen_plaintext
decipher_key_with_chosen_plaintext:
	addi $sp, $sp, -28 #Make space on stack to store registers
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	move $s0, $a0 #Save arg0 (plaintext string)
	move $s1, $a1 #Save arg1 (ciphertext)
	move $s2, $a2 #Save arg2 (cipherkey)
	move $s3, $s2 #Unchanging cipherkey address to do contains with
	
	move $a0, $s0
	jal to_upper
	
	move $a0, $s1
	jal to_upper
	
	j decipher_key_with_chosen_plaintext_loop
decipher_key_with_chosen_plaintext_loop:
	li $t0, ' '
	lbu $s4, 0($s0)
	beqz $s4, decipher_key_with_chosen_plaintext_finish
	beq $s4, $t0, decipher_key_with_chosen_plaintext_space
	lbu $s5, 0($s1)
	beqz $s5, decipher_key_with_chosen_plaintext_finish
	
	move $a0, $s4 #Move char0 to arg0 for pair_exists
	move $a1, $s5 #Move char1 to arg1 for pair_exists
	move $a2, $s3 #Move cipherkey to arg2 for pair_exists
	jal pair_exists #Now $v0 has 1 if pair was found or 0 if pair was not found
	bgtz $v0, decipher_key_with_chosen_plaintext_already_added #If $v0 is 1 then the character was already found in the cipherkey so look at next plaintext character
	
	sb $s4, 0($s2)
	sb $s5, 1($s2)
	addi $s2, $s2, 2
	sb $0, 0($s2)
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	
	j decipher_key_with_chosen_plaintext_loop
decipher_key_with_chosen_plaintext_space:
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	j decipher_key_with_chosen_plaintext_loop
decipher_key_with_chosen_plaintext_already_added:
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	j decipher_key_with_chosen_plaintext_loop
decipher_key_with_chosen_plaintext_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28 #Deallocate stack
	jr $ra
