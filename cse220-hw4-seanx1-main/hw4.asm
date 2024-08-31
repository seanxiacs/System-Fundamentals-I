############## Sean Xia ##############
############## 113181409 #################
############## sexia ################

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:
.globl create_person
create_person:
	addi $sp, $sp, -8 #Make space on stack to store registers
	sw $s0, 0($sp) #Preamble
	sw $s1, 4($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (ntwrk address)
	
	lw $t0, 0($s0) #Total nodes
	lw $t1, 16($s0) #Curr num of nodes
	ble $t0, $t1, create_person_error #If total nodes is less than or equal to curr num of nodes then no space
	lw $t2, 8($s0) #$t2 has size of nodes now
	
	mul $t3, $t1, $t2 #$t3 offset
	addi $t4, $s0, 36 #$t4 beginning of nodes[]
	add $t4, $t4, $t3 #add offset
	
	move $s1, $t4
	li $t5, 0
	
	j create_person_loop
create_person_loop:
	bge $t5, $t2, create_person_success
	sb $0, 0($t4)
	addi $t4, $t4, 1
	addi $t5, $t5, 1
	j create_person_loop
create_person_success:
	lw $t6, 16($s0) # increment the current no. of nodes in the Network by 1, and return the node address.
	addi $t6, $t6, 1
	sw $t6, 16($s0)
	
	move $v0, $s1
	j create_person_finish
create_person_error:
	li $v0, -1
	j create_person_finish
create_person_finish:
	lw $s0, 0($sp) #Restore register address or postamble
	lw $s1, 4($sp)
	addi $sp, $sp, 8 #Deallocate stack
	
	jr $ra

.globl is_person_exists
is_person_exists:
	addi $sp, $sp, -8 #Make space on stack to store registers
	sw $s0, 0($sp) #Preamble
	sw $s1, 4($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (ntwrk address)
	move $s1, $a1 #Save arg1 (person)
	
	lw $t0, 16($s0) #$t0 Curr num of nodes
	lw $t1, 8($s0) #$t1 has size of nodes now
	
	#mul $t2, $t0, $t1 #$t3 offset
	addi $t2, $s0, 36 #$t2 beginning of nodes[]
	#add $t4, $t4, $t3 #add offset
	
	li $t3, 0 #Counter for number of people passed
	
	j is_person_exists_loop
is_person_exists_loop:
	beq $t2, $s1, is_person_exists_success
	add $t2, $t2, $t1
	addi $t3, $t3, 1
	
	blt $t3, $t0, is_person_exists_loop #Loop if the counter is less than the number of nodes in the ntwrk
	
	j is_person_exists_dne
is_person_exists_success:
	li $v0, 1
	#move $v0, $s1
	j is_person_exists_finish
is_person_exists_dne:
	li $v0, 0
	j is_person_exists_finish
is_person_exists_finish:
	lw $s0, 0($sp) #Restore register address or postamble
	lw $s1, 4($sp)
	addi $sp, $sp, 8 #Deallocate stack
	
 	jr $ra

.globl is_person_name_exists
is_person_name_exists:
	addi $sp, $sp, -12 #Make space on stack to store registers
	sw $s0, 0($sp) #Preamble
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (ntwrk address)
	move $s1, $a1 #Save arg1 (name)
	
	lw $t0, 16($s0) #$t0 Curr num of nodes
	lw $t1, 8($s0) #$t1 has size of nodes now
	
	#mul $t2, $t0, $t1 #$t3 offset
	addi $t2, $s0, 36 #$t2 beginning of nodes[]
	#add $t4, $t4, $t3 #add offset
	
	li $t3, 0 #Counter for number of people passed
	
	j is_person_name_exists_loop
is_person_name_exists_loop:
	move $t4, $s1 #t4 has address of string
	move $t5, $t2 #Can use $t5 as address can lb from
	move $t6, $t1 #$t6 has size of nodes as well as $t1
	li $t7, 0 #Counter for point in the string
	move $s2, $t5

	blt $t3, $t0, is_person_name_exists_check_string #Loop if the counter is less than the number of nodes in the ntwrk
	j is_person_name_exists_dne	
is_person_name_exists_loop2:
	#j is_person_name_exists_check_string
	#beq $t2, $s1, is_person_name_exists_success
	add $t2, $t2, $t1 #Look at next node
	addi $t3, $t3, 1
	
	#blt $t3, $t0, is_person_name_exists_check_string #Loop if the counter is less than the number of nodes in the ntwrk
	
	j is_person_name_exists_loop
is_person_name_exists_check_string:
	lb $t8, 0($t4) #Load character from given string
	lb $t9, 0($t5)
	beqz $t8, is_person_name_exists_terminator
	
	bne $t8, $t9, is_person_name_exists_loop2
	
	addi $t4, $t4, 1
	addi $t5, $t5, 1
	addi $t7, $t7, 1
	blt $t7, $t6, is_person_name_exists_check_string
	j is_person_name_exists_loop2
is_person_name_exists_terminator: #This is based on the size of the node, it makes sure there are null terminators after the correct string. Assumes that it may not have a null terminator sometimes.
	addi $t7, $t7, 1
	bge $t7, $t6, is_person_name_exists_success
	
	lb $t9, 0($t5)
	bnez $t9, is_person_name_exists_loop2
	
	addi $t5, $t5, 1
	j is_person_name_exists_terminator
	
	#addi $t7, $t7, 1
	#blt $t7, $t6, is_person_null_terminator
	#beqz $t9, is_person_name_exists_success
	#j is_person_name_exists_loop2
is_person_name_exists_success:
	li $v0, 1
	move $v1, $s2
	#the function also returns a reference to the person with the name
	#move $v0, $s1
	j is_person_name_exists_finish
is_person_name_exists_dne:
	li $v0, 0
	j is_person_name_exists_finish
is_person_name_exists_finish:
	lw $s0, 0($sp) #Restore register address or postamble
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12 #Deallocate stack
	
	jr $ra

.globl add_person_property
add_person_property:
	addi $sp, $sp, -20 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (ntwrk address)
	move $s1, $a1 #Save arg1 (person address)
	move $s2, $a2 #Save arg2 (property name as null terminated string)
	move $s3, $a3 #Save arg3 (property value as null terminated string)
	
	move $t0, $s0
	addi $t0, $t0, 24
	move $t1, $s2
	li $t2, 5
	
	j add_person_property_check_cond1
add_person_property_check_cond1:
	lb $t3, 0($t0)
	lb $t4, 0($t1)
	
	bne $t3, $t4, add_person_property_viocond1
	
	addi $t2, $t2, -1
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	
	bgtz $t2, add_person_property_check_cond1
	
	#Begin initializing for check cond2
	
	j add_person_property_check_cond2
add_person_property_check_cond2:
	
	move $a0, $s0
	move $a1, $s1
	jal is_person_exists
	
	beqz $v0, add_person_property_viocond2
	
	addi $v0, $v0, -1
	
	#Begin initializing for check cond3
	lb $t0, 8($s0) #$t0 has size of nodes now
	move $t1, $s3
	li $t2, 0 
	
	beqz $v0, add_person_property_check_cond3
	j add_person_property_viocond2 #It should not be reaching this line because $v0 should be zero or one
add_person_property_check_cond3:
	lb $t4, 0($t1)
	beqz $t4, add_person_property_check_cond3_confirm
	
	addi $t1, $t1, 1
	addi $t2, $t2, 1
	j add_person_property_check_cond3
	

	#lw $t0, 16($s0) #$t0 Curr num of nodes
	#lw $t1, 8($s0) #$t1 has size of nodes now
	
add_person_property_check_cond3_confirm:
	bge $t2, $t0, add_person_property_viocond3
	
	#Begin initializing for check cond4
	
	j add_person_property_check_cond4
add_person_property_check_cond4:
	move $a0, $s0
	move $a1, $s3
	jal is_person_name_exists
	
	#Begin initializing for adding
	move $t0, $s1 #(person address)
	move $t1, $s3 #(property value or name)
	
	beqz $v0, add_person_property_add
	
	addi $v0, $v0, -1
	
	beqz $v0, add_person_property_viocond4
	j add_person_property_viocond4 #It should not be reaching this line because $v0 should be zero or one
add_person_property_add:
	lb $t2, 0($t1)
	beqz $t2, add_person_property_success
	sb $t2, 0($t0)
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	
	j add_person_property_add
add_person_property_success:
	li $v0, 1
	#move $v1, $s2
	#the function also returns a reference to the person with the name
	#move $v0, $s1
	j add_person_property_finish
add_person_property_viocond1:
	li $v0, 0
	j add_person_property_finish
add_person_property_viocond2:
	li $v0, -1
	j add_person_property_finish
add_person_property_viocond3:
	li $v0, -2
	j add_person_property_finish
add_person_property_viocond4:
	li $v0, -3
	j add_person_property_finish
add_person_property_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20 #Deallocate stack
	
	jr $ra

.globl get_person
get_person:
	addi $sp, $sp, -12 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (ntwrk address)
	move $s1, $a1 #Save arg1 (name address)
	
	move $a0, $s0
	move $a1, $s1
	jal is_person_name_exists
	
	beqz $v0, get_person_fail
	addi $v0, $v0, -1
	beqz $v0, get_person_success
	
get_person_success:
	move $v0, $v1
	j get_person_finish
get_person_fail:
	li $v0, 0
	j get_person_finish
get_person_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12 #Deallocate stack
	
	jr $ra

.globl is_relation_exists
is_relation_exists:
	addi $sp, $sp, -16 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	#move $fp, $sp
	
	move $s0, $a0 #Save arg0 (ntwrk address)
	move $s1, $a1 #Save arg1 (person1 address)
	move $s2, $a2 #Save arg2 (person2 address)
	
	move $t0, $s0 #$t0 address used to load the edges
	addi $t0, $t0, 36
	lw $t1, 0($s0) #$t1 Total nodes
	lw $t2, 8($s0) #$t2 has size of nodes now
	mul $t3, $t1, $t2 #t3 offset, $t1 $t2 are free now
	add $t0, $t0, $t3 #$t0 now has base address of edges[]
	lb $t4, 20($s0) #$t4 has number of edges
	li $t5, 0 #Counter for number of edges checked
	li $t6, 1
	
	j is_relation_exists_loop
is_relation_exists_loop:
	bge $t5, $t4, is_relation_exists_fail
	
	lw $t7, 0($t0)
	lw $t8, 4($t0)
	lw $t9, 8($t0)
	
	addi $t5, $t5, 1
	addi $t0, $t0, 12
	#bne $t9, $t6, is_relation_exists_loop #If int friend not 1, then its not a friend
	
	beq $t7, $s1, is_relation_exists_case1
	beq $t7, $s2, is_relation_exists_case2
	j is_relation_exists_loop
is_relation_exists_case1:
	beq $t8, $s2, is_relation_exists_success
	j is_relation_exists_loop
is_relation_exists_case2:
	beq $t8, $s1, is_relation_exists_success
	j is_relation_exists_loop
is_relation_exists_success:
	li $v0, 1
	j is_relation_exists_finish
is_relation_exists_fail:
	li $v0, 0
	j is_relation_exists_finish
is_relation_exists_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16 #Deallocate stack
	
	jr $ra

.globl add_relation
add_relation:
	addi $sp, $sp, -16 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (ntwrk address)
	move $s1, $a1 #Save arg1 (person1 address)
	move $s2, $a2 #Save arg2 (person2 address)
	
	j add_relation_check_cond1
add_relation_check_cond1:
	move $a0, $s0
	move $a1, $s1
	jal is_person_exists
	
	beqz $v0, add_relation_viocond1
	
	move $a0, $s0
	move $a1, $s2
	jal is_person_exists
	
	beqz $v0, add_relation_viocond1
	
	#bgtz $t2, add_relation_check_cond1
	
	#Begin initializing for check cond2
	
	j add_relation_check_cond2
add_relation_check_cond2:
	lw $t0, 4($s0) #$t0 total_edges
	lw $t1, 20($s0) #$t1 curr_num_of_edges
	
	bge $t1, $t0, add_relation_viocond2
	
	#Begin initializing for check cond3
	
	j add_relation_check_cond3 
add_relation_check_cond3:
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal is_relation_exists
	
	bnez $v0, add_relation_viocond3
	
	#Begin initializing for check cond4
	
	j add_relation_check_cond4
add_relation_check_cond4:
	beq $s1, $s2, add_relation_viocond4
	
	#Begin initializing for adding
	move $t0, $s0 #$t0 address used to load the edges
	addi $t0, $t0, 36
	lw $t1, 0($s0) #$t1 Total nodes
	lw $t2, 8($s0) #$t2 has size of nodes now
	mul $t3, $t1, $t2 #t3 offset, $t1 $t2 are free now
	add $t0, $t0, $t3 #$t0 now has base address of edges[]
	lw $t1, 20($s0) #$t4 has number of edges
	li $t2, 12
	mul $t4, $t1, $t2 #t4 offset, $t1 $t2 are free now
	add $t0, $t0, $t4  #$t0 now has base address of where to add the new edge now
	
	j add_relation_add #It should not be reaching this line because $v0 should be zero or one
add_relation_add:
	sw $s1, 0($t0)
	sw $s2, 4($t0)
	sw $0, 8($t0)
	
	j add_relation_success
add_relation_success:
	lw $t5, 20($s0) # increment the current no. of edges in the Network by 1, and return the node address.
	addi $t5, $t5, 1
	sw $t5, 20($s0)

	li $v0, 1
	#move $v1, $s2
	#the function also returns a reference to the person with the name
	#move $v0, $s1
	j add_relation_finish
add_relation_viocond1:
	li $v0, 0
	j add_relation_finish
add_relation_viocond2:
	li $v0, -1
	j add_relation_finish
add_relation_viocond3:
	li $v0, -2
	j add_relation_finish
add_relation_viocond4:
	li $v0, -3
	j add_relation_finish
add_relation_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16 #Deallocate stack
	
 	jr $ra

.globl add_relation_property
add_relation_property:
	addi $sp, $sp, -16 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (ntwrk address)
	move $s1, $a1 #Save arg1 (person1 address)
	move $s2, $a2 #Save arg2 (person2 address)
	move $s3, $a3 #Save arg3 (prop_name)
	
	j add_relation_property_check_cond1
add_relation_property_check_cond1:
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal is_relation_exists
	
	beqz $v0, add_relation_property_viocond1
	
	addi $v0, $v0, -1
	
	#Begin initializing for check cond2
	move $t0, $s0
	addi $t0, $t0, 29
	move $t1, $s3
	li $t2, 7
	
	beqz $v0, add_relation_property_check_cond2
	j add_relation_property_viocond1 #It should not be reaching this line because $v0 should be zero or one
add_relation_property_check_cond2:
	lb $t3, 0($t0)
	lb $t4, 0($t1)
	
	bne $t3, $t4, add_relation_property_viocond2
	
	addi $t2, $t2, -1
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	
	bgtz $t2, add_relation_property_check_cond2
	
	#Begin initializing for add
	move $t0, $s0 #$t0 address used to load the edges
	addi $t0, $t0, 36
	lw $t1, 0($s0) #$t1 Total nodes
	lw $t2, 8($s0) #$t2 has size of nodes now
	mul $t3, $t1, $t2 #t3 offset, $t1 $t2 are free now
	add $t0, $t0, $t3 #$t0 now has base address of edges[]
	lb $t4, 20($s0) #$t4 has current number of edges
	li $t5, 0 #Counter for number of edges checked
	li $t6, 1
	
	j add_relation_property_add
add_relation_property_add:
	bge $t5, $t4, add_relation_property_finish
	
	lw $t7, 0($t0)
	lw $t8, 4($t0)
	lw $t9, 8($t0)
	
	addi $t5, $t5, 1
	addi $t0, $t0, 12
	#bne $t9, $t6, is_relation_exists_loop #If int friend not 1, then its not a friend
	
	beq $t7, $s1, add_relation_property_case1
	beq $t7, $s2, add_relation_property_case2
	j add_relation_property_add
add_relation_property_case1:
	beq $t8, $s2, add_relation_property_success
	j add_relation_property_add
add_relation_property_case2:
	beq $t8, $s1, add_relation_property_success
	j add_relation_property_add
add_relation_property_success:
	#lw $t5, 20($s0) # increment the current no. of edges in the Network by 1, and return the node address.
	#addi $t5, $t5, 1
	#sw $t5, 20($s0)
	addi $t0, $t0, -12
	sw $t6, 8($t0)

	li $v0, 1
	#li $v1, 5
	#move $v1, $s2
	#the function also returns a reference to the person with the name
	#move $v0, $s1
	j add_relation_property_finish
add_relation_property_viocond1:
	li $v0, 0
	j add_relation_property_finish
add_relation_property_viocond2:
	li $v0, -1
	j add_relation_property_finish
add_relation_property_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16 #Deallocate stack
	
	jr $ra
	
#total_nodes (bytes 0 - 3)
#total_edges (bytes 4- 7)
#size_of_node (bytes 8 - 11)
#size_of_edge (bytes 12 - 15), can assume this number is always 12
#curr_num_of_nodes (bytes 16 - 19)
#curr_num_of_edges (bytes 20 - 23)
#Name property (bytes 24 - 28)
#FRIEND property (bytes 29 - 35)
#nodes (nodes_capacity = total_num_nodes * size_of_node)
#edges (edges_capacity = Total_num_edges * size_of_edge)

.globl is_friend_of_friend
is_friend_of_friend:
	addi $sp, $sp, -36 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 20($sp)
	sw $s6, 20($sp)
	sw $s7, 20($sp)
	
	#move $fp, $sp
	move $s0, $a0 #Save arg0 (ntwrk address)
	move $s1, $a1 #Save arg1 (name1 address)
	move $s2, $a2 #Save arg2 (name2 address)
		
	j is_friend_of_friend_check_existence
is_friend_of_friend_check_existence:
	move $a0, $s0
	move $a1, $s1
	jal is_person_name_exists
	
	beqz $v0, is_friend_of_friend_dne
	move $s1, $v1 #$t0 reference to person1
	
	move $a0, $s0
	move $a1, $s2
	jal is_person_name_exists

	beqz $v0, is_friend_of_friend_dne
	move $s2, $v1 #$t1 reference to person2
	
	j is_friend_of_friend_check_friends
is_friend_of_friend_check_friends:
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	
	jal is_friend_exists
	
	#li $v0, 5
	#j is_friend_of_friend_finish
	
	bnez $v0, is_friend_of_friend_false
	
	#Initialize for search
	move $s3, $s0 #$t0 address used to load the nodes
	addi $s3, $s3, 36
	lw $s4, 16($s0) #$t1 curr num of nodes
	lw $s5, 8($s0) #$t2 has size of nodes now
	li $s6, 0 #Counter for number of edges checked
	#li $t6, 1

	j is_friend_of_friend_search
is_friend_of_friend_search:
	bge $s6, $s4, is_friend_of_friend_false1
	
	beq $s1, $s3, is_friend_of_friend_iterate
	beq $s2, $s3, is_friend_of_friend_iterate
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s3
	jal is_relation_exists #Next time you call jal remember that t registers are not saved so you should be using $s0 you dummy
	beqz $v0, is_friend_of_friend_iterate
	
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	jal is_relation_exists
	beqz $v0, is_friend_of_friend_iterate
	
	j is_friend_of_friend_true
is_friend_of_friend_iterate:
	add $s3, $s3, $s5
	addi $s6, $s6, 1
	j is_friend_of_friend_search
is_friend_of_friend_true:
	li $v0, 1
	j is_friend_of_friend_finish
is_friend_of_friend_false:
	li $v0, 0
	j is_friend_of_friend_finish
is_friend_of_friend_false1:
	li $v0, 5
	j is_friend_of_friend_finish
is_friend_of_friend_dne:
	li $v0, -1
	j is_friend_of_friend_finish
is_friend_of_friend_finish:
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



#is_friend_of_friend_find_relationship1:
#	#Begin initializing for search
#	move $t0, $s0 #$t0 address used to load the edges
#	addi $t0, $t0, 36
#	lw $t1, 0($s0) #$t1 Total nodes
#	lw $t2, 8($s0) #$t2 has size of nodes now
#	mul $t3, $t1, $t2 #t3 offset, $t1 $t2 are free now
#	add $t0, $t0, $t3 #$t0 now has base address of edges[]
#	lb $t4, 20($s0) #$t4 has current number of edges
#	li $t5, 0 #Counter for number of edges checked
#	li $t6, 1
#	
#is_friend_of_friend_search1:
#	bge $t5, $t4, is_friend_of_friend_finish_search1
#	
#	lw $t7, 0($t0)
#	lw $t8, 4($t0)
#	lw $t9, 8($t0)
#	
#	addi $t5, $t5, 1
#	addi $t0, $t0, 12
#	#bne $t9, $t6, is_relation_exists_loop #If int friend not 1, then its not a friend
#	
#	beq $t7, $s1, is_friend_of_friend_case11
#	beq $t7, $s2, is_friend_of_friend_case21
#	j add_relation_property_search1
#is_friend_of_friend_case11:
#	beq $t8, $s2, is_friend_of_friend_success1
#	j is_friend_of_friend_search1
#is_friend_of_friend_case21:
#	beq $t8, $s1, is_friend_of_friend_success1
#	j is_friend_of_friend_search1
#is_friend_of_friend_success1:
#	#$t9 has the value of relationship
#	li $v0, 1
#	j is_friend_of_friend_finish_search1
#is_friend_of_friend_fail1:
#	li $v0, 0
#	j is_friend_of_friend_finish_search1
#is_friend_of_friend

is_friend_exists:
	addi $sp, $sp, -16 #Make space on stack to store registers
	sw $ra, 0($sp) #Preamble
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	#move $fp, $sp
	
	move $s0, $a0 #Save arg0 (ntwrk address)
	move $s1, $a1 #Save arg1 (person1 address)
	move $s2, $a2 #Save arg2 (person2 address)
	
	move $t0, $s0 #$t0 address used to load the edges
	addi $t0, $t0, 36
	lw $t1, 0($s0) #$t1 Total nodes
	lw $t2, 8($s0) #$t2 has size of nodes now
	mul $t3, $t1, $t2 #t3 offset, $t1 $t2 are free now
	add $t0, $t0, $t3 #$t0 now has base address of edges[]
	lb $t4, 20($s0) #$t4 has number of edges
	li $t5, 0 #Counter for number of edges checked
	li $t6, 1
	
	j is_friend_exists_loop
is_friend_exists_loop:
	bge $t5, $t4, is_friend_exists_fail
	
	lw $t7, 0($t0)
	lw $t8, 4($t0)
	lw $t9, 8($t0)
	
	addi $t5, $t5, 1
	addi $t0, $t0, 12
	#bne $t9, $t6, is_relation_exists_loop #If int friend not 1, then its not a friend
	
	beq $t7, $s1, is_friend_exists_case1
	beq $t7, $s2, is_friend_exists_case2
	j is_friend_exists_loop
is_friend_exists_case1:
	beq $t8, $s2, is_friend_exists_check
	j is_friend_exists_loop
is_friend_exists_case2:
	beq $t8, $s1, is_friend_exists_check
	j is_friend_exists_loop
is_friend_exists_check:
	addi $t9, $t9, -1
	beqz $t9, is_friend_exists_success
	j is_friend_exists_fail
is_friend_exists_success:
	li $v0, 1
	j is_friend_exists_finish
is_friend_exists_fail:
	li $v0, 0
	j is_friend_exists_finish
is_friend_exists_finish:
	lw $ra, 0($sp) #Restore register address or postamble
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16 #Deallocate stack
	
	jr $ra
