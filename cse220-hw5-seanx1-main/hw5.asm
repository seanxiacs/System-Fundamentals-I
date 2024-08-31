############## Sean Xia ##############
############## 113181409 #################
############## sexia ################

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:
.globl create_term
create_term:
	addi $sp, $sp, -12 #Make space on stack to store registers
	sw $s0, 0($sp) #Preamble
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	move $s0, $a0 #Save arg0 (int coeff)
	move $s1, $a1 #Save arg1 (int exp)
	
	beqz $s0, create_term_error
	bltz $s1, create_term_error
	
	li $a0, 12
	li $v0, 9
	syscall
	move $s2, $v0
	
	sw $s0, 0($s2)
	sw $s1, 4($s2)
	sw $0, 8($s2)

	move $v0, $s2
	j create_term_finish
create_term_error:
	li $v0, -1
	j create_term_finish
create_term_finish:
	lw $s0, 0($sp) #Restore register address or postamble
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12 #Deallocate stack
	
	jr $ra











.globl create_polynomial
create_polynomial:
	addi $sp, $sp, -36 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (int[] terms)
	move $s1, $a1 #Save arg1 (N)
	
	move $s3, $s0 #Address for where in array we are looking at
	li $s4, 0 #Counter/ Num Elements in List
	
	j create_polynomial_count
create_polynomial_count:
	lw $s5, 0($s3)
	bnez $s5, create_polynomial_count_iterate
	
	lw $s5, 4($s3)
	addi $s5, $s5, 1
	bnez $s5, create_polynomial_count_iterate
	
	j create_polynomial_sort
create_polynomial_count_iterate:
	addi $s3, $s3, 8
	addi $s4, $s4, 1
	
	j create_polynomial_count
create_polynomial_sort:
	move $a0, $s0
	move $a1, $s4
	jal selection_sort
	
	j create_polynomial_counted
create_polynomial_counted:
	blez $s1, create_polynomial_all
	bgt $s1, $s4, create_polynomial_all
	move $s5, $s1
	
	j create_polynomial_begin_simplify
create_polynomial_all:
	move $s5, $s4 #$s5 has num elements that we want to look at in list
	
	j create_polynomial_begin_simplify
create_polynomial_begin_simplify:
	move $s3, $s0 #Address for where in array we are looking at
	li $t0, 0 #Counter
	
	j create_polynomial_remove_duplicates
create_polynomial_remove_duplicates:
	bge $t0, $s4, create_polynomial_begin_reduce #Can also do bge $t0, $s5 since $s5 is number we are looking at but $s4 is total size
	lw $t1, 0($s3)
	lw $t2, 4($s3)
	
	move $t3, $s0 #Address for where in array we are looking at
	li $t4, 0 #Inner Counter
	
	j create_polynomial_remove_duplicates_before
create_polynomial_remove_duplicates_before:
	bge $t4, $t0, create_polynomial_remove_duplicates_iterate
	
	lw $t5, 0($t3)
	lw $t6, 4($t3)
	
	bne $t1, $t5, create_polynomial_remove_duplicates_before_iterate
	bne $t2, $t6, create_polynomial_remove_duplicates_before_iterate
	
	li $t7, -1
	sw $0, 0($s3)
	sw $t7, 4($s3)
	
	j create_polynomial_remove_duplicates_iterate
create_polynomial_remove_duplicates_before_iterate:
	addi $t3, $t3, 8
	addi $t4, $t4, 1
	
	j create_polynomial_remove_duplicates_before
create_polynomial_remove_duplicates_iterate:
	addi $s3, $s3, 8
	addi $t0, $t0, 1
	
	j create_polynomial_remove_duplicates
create_polynomial_begin_reduce:
	addi $sp, $sp, -32 #Make space on stack to t registers
	sw $t0, 0($sp) #Preamble 
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s4
	move $a3, $s5
	jal combine_like_terms
	
	lw $t0, 0($sp) #Restore register address or postamble
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	addi $sp, $sp, 32 #Deallocate stack
	
	j create_polynomial_begin_store
create_polynomial_begin_store:
	move $s3, $s0 #Address for where in array we are looking at
	li $s6, 0 #Counter
	
	li $a0, 8 #Create polynomial struct
	li $v0, 9
	syscall
	move $s7, $v0
	move $t0, $s7
	li $t1, 0 #Counter for nomber of terms
	
	j create_polynomial_store
create_polynomial_store:
	bge $s6, $s5, create_polynomial_store_finish
	lw $a0, 0($s3)
	lw $a1, 4($s3)
	
	addi $sp, $sp, -8 #Make space on stack to t registers
	sw $t0, 0($sp) #Preamble 
	sw $t1, 4($sp)
	
	jal create_term #Now $v0 returns the address of the term in $v0. If the coefficient is 0 or the exponent is negative, then return -1 in $v0.
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8 #Deallocate stack
	
	addi $v0, $v0, 1
	beqz $v0, create_polynomial_store_iterate
	addi $v0, $v0, -1
	
	sw $v0, 0($t0) #Save the pointer
	addi $t0, $v0, 8 #Save the address of the term in $t0 so we can use to repoint.
	addi $t1, $t1, 1
	
	j create_polynomial_store_iterate
create_polynomial_store_iterate:
	addi $s3, $s3, 8
	addi $s6, $s6, 1
	
	j create_polynomial_store
create_polynomial_store_finish:
	move $v0, $s7
	sw $t1, 4($s7)
	bgtz $t1, create_polynomial_finish
	li $v0, 0
	
	j create_polynomial_finish
create_polynomial_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36 #Deallocate stack
	
	jr $ra








.globl add_polynomial
add_polynomial:
	addi $sp, $sp, -36 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (Polynomial* p)
	move $s1, $a1 #Save arg1 (Polynomial* q)
	
	beqz $s0, add_polynomial_check_q
	beqz $s1, add_polynomial_p
	
	j add_polynomial_begin_add
add_polynomial_check_q:
	beqz $s1, add_polynomial_null
	
	j add_polynomial_q
add_polynomial_begin_add:
	move $s2, $s0 #$s2, address p
	move $s3, $s1 #$s3, address q
	li $s4, 0 #Counter
	
	lw $s5, 4($s0) #$s5 number of terms in p
	lw $s6, 4($s1) #$s6 number of terms in q
	
	lw $s2, 0($s2)
	lw $s3, 0($s3)
	
	li $a0, 8 #Create polynomial struct
	li $v0, 9
	syscall
	move $s7, $v0 #$s7 address of polynomial struct
	move $t0, $s7
	
	j add_polynomial_add
add_polynomial_add:

	#bge $s6, $s5, create_polynomial_store_finish
	beqz $s5, add_polynomial_compare_check_q
	beqz $s6, add_polynomial_p_big
	
	lw $t1, 0($s2)
	lw $t2, 4($s2)
	
	lw $t3, 0($s3)
	lw $t4, 4($s3)
	
	j add_polynomial_compare
add_polynomial_compare:
	#beq #This method is going to do the heavy lifting.
	#beqz $s5, add_polynomial_compare_check_q
	#beqz $s6, add_polynomial_q_big
	
	beq $t2, $t4, add_polynomial_equal
	bgt $t2, $t4, add_polynomial_p_big
	blt $t2, $t4, add_polynomial_q_big
	
	j add_polynomial_add_finish #This should not be reaching here, all the cases should go into equal, p_big, or q_big
add_polynomial_compare_check_q:
	beqz $s6, add_polynomial_add_finish 
	
	j add_polynomial_q_big
add_polynomial_equal:
	add $a0, $t1, $t3
	move $a1, $t2 #move $a1, $t2 works as well
	lw $s2, 8($s2)
	lw $s3, 8($s3)
	addi $s5, $s5, -1
	addi $s6, $s6, -1
	
	j add_polynomial_store
add_polynomial_p_big:
	lw $t1, 0($s2)
	lw $t2, 4($s2)
	
	move $a0, $t1
	move $a1, $t2
	lw $s2, 8($s2)
	addi $s5, $s5, -1
	
	j add_polynomial_store
add_polynomial_q_big:
	lw $t3, 0($s3)
	lw $t4, 4($s3)
	
	move $a0, $t3
	move $a1, $t4
	lw $s3, 8($s3)
	addi $s6, $s6, -1
	
	j add_polynomial_store
add_polynomial_store:
	addi $sp, $sp, -24 #Make space on stack to t registers
	sw $t0, 0($sp) #Preamble 
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	
	jal create_term #Now $v0 returns the address of the term in $v0. If the coefficient is 0 or the exponent is negative, then return -1 in $v0.
	
	lw $t0, 0($sp) #Restore register address or postamble
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	addi $sp, $sp, 24 #Deallocate stack
	
	addi $v0, $v0, 1
	beqz $v0, add_polynomial_add
	addi $v0, $v0, -1
	
	sw $v0, 0($t0) #Save the pointer
	addi $t0, $v0, 8 #Save the address of the term in $t0 so we can use to repoint.
	addi $s4, $s4, 1
	
	j add_polynomial_add
add_polynomial_add_finish:
	move $v0, $s7
	sw $s4, 4($s7)
	bgtz $s4, add_polynomial_finish
	li $v0, 0
	
	j add_polynomial_finish
add_polynomial_p:
	move $v0, $s0
	
	j add_polynomial_finish
add_polynomial_q:
	move $v0, $s1
	
	j add_polynomial_finish
add_polynomial_null:
	li $v0, 0
	
	j add_polynomial_finish
add_polynomial_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36 #Deallocate stack
	
	jr $ra







.globl mult_polynomial
mult_polynomial:
	addi $sp, $sp, -36 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (Polynomial* p)
	move $s1, $a1 #Save arg1 (Polynomial* q)
	
	beqz $s0, mult_polynomial_null
	beqz $s1, mult_polynomial_null
	
	j mult_polynomial_begin_mult
mult_polynomial_begin_mult:
	move $s2, $s0 #$s2, address p
	move $s3, $s1 #$s3, address q
	li $s4, 0 #Counter
	
	lw $s5, 4($s0) #$s5 number of terms in p
	lw $s6, 4($s1) #$s6 number of terms in q
	
	lw $s2, 0($s2)
	lw $s3, 0($s3)
	
	mul $s7, $s5, $s6 #$s7 is the number of terms after foil
	addi $s7, $s7, 1
	sll $s7, $s7, 3
	subu $s7, $0, $s7
	add $sp, $sp, $s7
	
	move $t0, $s5 #Number of p terms left
	move $t1, $s6 #Number of q terms left, will be reset after every loop
	move $t6, $sp #Where we are storing in the $sp*
	
	j mult_polynomial_mult
mult_polynomial_mult:
	beqz $t0, mult_polynomial_mult_finish
	
	lw $t2, 0($s2)
	lw $t3, 4($s2)

	lw $s2, 8($s2)
	addi $t0, $t0, -1
	
	#Reinitializing for q loop
	move $s3, $s1 #$s3, address q
	lw $s3, 0($s3) #Getting start of q back into $s3 after each run
	move $t1, $s6
	
	j mult_polynomial_mult_foil
mult_polynomial_mult_foil:
	beqz $t1, mult_polynomial_mult
	
	lw $t4, 0($s3)
	lw $t5, 4($s3)
	
	lw $s3, 8($s3)
	addi $t1, $t1, -1
	
	mul $t7, $t2, $t4
	add $t8, $t3, $t5
	
	sw $t7, 0($t6)
	sw $t8, 4($t6)
	addi $t6, $t6, 8
	
	j mult_polynomial_mult_foil
mult_polynomial_mult_finish:
	sw $0, 0($t6)
	li $t9, -1
	sw $t9, 4($t6)
	


	move $a0, $sp #Need $a0, which is the stack pointer
	move $a1, $0
	jal create_polynomial1 #It wants int[] terms, N
	
	subu $s7, $0, $s7
	add $sp, $sp, $s7
	
	j mult_polynomial_finish
mult_polynomial_null:
	li $v0, 0
	
	j add_polynomial_finish
mult_polynomial_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36 #Deallocate stack
	
	jr $ra


# Implementation of selection sort.
# Kevin McDonnell
# 1/20/2016

# $s0: base address of array
# $s1: number of elements in the array
# $s2: address array[i]
# $s3: array[j]
# $s4: currentMin
# $s5: array[currentMinIndex]
# $t0: i
# $t1: j
# $t2: upper bound on outer loop
# $t3: value of array[i]
# $t4: value of array[j]
# $t5: register used to swap

selection_sort:
	addi $sp, $sp, -28 #Make space on stack to store registers
	sw $s0, 0($sp) #Preamble
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	#move $s0, $a0 #Save arg0 (int coeff)
	#move $s1, $a1 #Save arg1 (int size)
	
	move $s0, $a0	# $s0: base address of array
	move $s1, $a1	# number of elements in the array
	
	# initialize outer for-loop variables
	li $t0, 0		# $t0: i = 0	
	addi $t2, $s1, -1	# $t2 is upper bound on outer loop

outer_loop:
	bge $t0, $t2, end_outer_loop	# repeat until i >= length-1

	sll $s2, $t0, 3			# $s2 = 8*i
	add $s2, $s2, $s0		# $s2 is address of array[i]
	lw $s4, 4($s2)			# $s4 is currentMin; currentMin = array[i]
	lw $t5, 0($s2)			# $t5 is coefficient
	move $s5, $s2			# $s5 is address of currentMin
	
	addi $t1, $t0, 1		# j = i + 1
inner_loop:
	beq $t1, $s1, end_inner_loop	# repeat until j == length

	sll $s3, $t1, 3			# $s3 = 3*j
	add $s3, $s3, $s0		# $s3 is address of array[j]

	# do we have a new minimum?
	lw $t4, 4($s3)		# $t4 is value at array[j]
	bge $s4, $t4, element_not_smaller # element not smaller than current minimum
	lw $s4, 4($s3)		# we have a new minimum: currentMin = array[j];
	lw $t5, 0($s3)		# $t5 is coefficient
	move $s5, $s3		# save address of new minimum
		
element_not_smaller:		

	addi $t1, $t1, 1	# j++
	j inner_loop
end_inner_loop:

	# swap array[i] with array[currentMinIndex] if necessary
	beq $s5, $s2, dont_swap # addr of minimum is still addr of array[i], so don't swap
	lw $t3, 4($s2)		# $t3 = array[i] exp
	lw $t6, 0($s2)		# $t5 = array[i] coeff
	sw $t3, 4($s5)		# array[currentMinIndex] = array[i] exp
	sw $t6, 0($s5)		# array[currentMinIndex] = array[i] coeff
	sw $s4, 4($s2)		# array[i] = currentMin	 	exp
	sw $t5, 0($s2)		# array[i] = currentMin	 	coeff
dont_swap:

	addi $t0, $t0, 1	# i++
	j outer_loop
end_outer_loop:	
	lw $s0, 0($sp) #Restore register address or postamble
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28 #Deallocate stack
	
	jr $ra

	
	
	
	
	
	
	
	
combine_like_terms:
	addi $sp, $sp, -28 #Make space on stack to store registers
	sw $s0, 0($sp) #Preamble
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	move $s0, $a0 #Save arg0 (int[] terms)
	move $s1, $a1 #Save arg1 (N)
	move $s4, $a2
	move $s5, $a3
	
combine_like_terms_begin_reduce:
	move $s3, $s0 #Address for where in array we are looking at
	li $t0, 0 #Counter
	
	j combine_like_terms_remove_coefficients
combine_like_terms_remove_coefficients:
	bge $t0, $s5, combine_like_terms_finish
	lw $t1, 0($s3)
	lw $t2, 4($s3)
	
	bltz $t2, combine_like_terms_remove_coefficients_iterate
	
	move $t3, $s0 #Address for where in array we are looking at
	li $t4, 0 #Inner Counter
	
	j combine_like_terms_remove_coefficients_before
combine_like_terms_remove_coefficients_before:
	bge $t4, $t0, combine_like_terms_remove_coefficients_iterate
	
	lw $t5, 0($t3)
	lw $t6, 4($t3)
	
	bne $t2, $t6, combine_like_terms_remove_coefficients_before_iterate
	
	add $t5, $t5, $t1
	sw $t5, 0($t3)
	
	li $t7, -1
	sw $0, 0($s3)
	sw $t7, 4($s3)
	
	j combine_like_terms_remove_coefficients_iterate
combine_like_terms_remove_coefficients_before_iterate:
	addi $t3, $t3, 8
	addi $t4, $t4, 1
	
	j combine_like_terms_remove_coefficients_before
combine_like_terms_remove_coefficients_iterate:
	addi $s3, $s3, 8
	addi $t0, $t0, 1
	
	j combine_like_terms_remove_coefficients
combine_like_terms_finish:
	lw $s0, 0($sp) #Restore register address or postamble
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28 #Deallocate stack
	
	jr $ra





create_polynomial1:
	addi $sp, $sp, -36 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (int[] terms)
	move $s1, $a1 #Save arg1 (N)
	
	move $s3, $s0 #Address for where in array we are looking at
	li $s4, 0 #Counter/ Num Elements in List
	
	j create_polynomial1_count
create_polynomial1_count:
	lw $s5, 0($s3)
	bnez $s5, create_polynomial1_count_iterate
	
	lw $s5, 4($s3)
	addi $s5, $s5, 1
	bnez $s5, create_polynomial1_count_iterate
	
	j create_polynomial1_sort
create_polynomial1_count_iterate:
	addi $s3, $s3, 8
	addi $s4, $s4, 1
	
	j create_polynomial1_count
create_polynomial1_sort:
	move $a0, $s0
	move $a1, $s4
	jal selection_sort
	
	j create_polynomial1_counted
create_polynomial1_counted:
	blez $s1, create_polynomial1_all
	bgt $s1, $s4, create_polynomial1_all
	move $s5, $s1
	
	j create_polynomial1_begin_reduce
create_polynomial1_all:
	move $s5, $s4 #$s5 has num elements that we want to look at in list
	
	j create_polynomial1_begin_reduce
create_polynomial1_begin_reduce:
	addi $sp, $sp, -32 #Make space on stack to t registers
	sw $t0, 0($sp) #Preamble 
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s4
	move $a3, $s5
	jal combine_like_terms
	
	lw $t0, 0($sp) #Restore register address or postamble
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	addi $sp, $sp, 32 #Deallocate stack
	
	j create_polynomial1_begin_store
create_polynomial1_begin_store:
	move $s3, $s0 #Address for where in array we are looking at
	li $s6, 0 #Counter
	
	li $a0, 8 #Create polynomial struct
	li $v0, 9
	syscall
	move $s7, $v0
	move $t0, $s7
	li $t1, 0 #Counter for nomber of terms
	
	j create_polynomial1_store
create_polynomial1_store:
	bge $s6, $s5, create_polynomial1_store_finish
	lw $a0, 0($s3)
	lw $a1, 4($s3)
	
	addi $sp, $sp, -8 #Make space on stack to t registers
	sw $t0, 0($sp) #Preamble 
	sw $t1, 4($sp)
	
	jal create_term #Now $v0 returns the address of the term in $v0. If the coefficient is 0 or the exponent is negative, then return -1 in $v0.
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8 #Deallocate stack
	
	addi $v0, $v0, 1
	beqz $v0, create_polynomial1_store_iterate
	addi $v0, $v0, -1
	
	sw $v0, 0($t0) #Save the pointer
	addi $t0, $v0, 8 #Save the address of the term in $t0 so we can use to repoint.
	addi $t1, $t1, 1
	
	j create_polynomial1_store_iterate
create_polynomial1_store_iterate:
	addi $s3, $s3, 8
	addi $s6, $s6, 1
	
	j create_polynomial1_store
create_polynomial1_store_finish:
	move $v0, $s7
	sw $t1, 4($s7)
	bgtz $t1, create_polynomial1_finish
	li $v0, 0
	
	j create_polynomial1_finish
create_polynomial1_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36 #Deallocate stack
	
	jr $ra
