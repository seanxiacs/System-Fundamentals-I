################# Sean Xia #################
################# sexia #################
################# 113181409 #################

################# DO NOT CHANGE THE DATA SECTION #################


.data
arg1_addr: .word 0
arg2_addr: .word 0
num_args: .word 0
invalid_arg_msg: .asciiz "One of the arguments is invalid\n"
args_err_msg: .asciiz "Program requires exactly two arguments\n"
zero: .asciiz "Zero\n"
nan: .asciiz "NaN\n"
inf_pos: .asciiz "+Inf\n"
inf_neg: .asciiz "-Inf\n"
mantissa: .asciiz ""

.text
.globl hw_main
hw_main:
    sw $a0, num_args
    sw $a1, arg1_addr
    addi $t0, $a1, 2
    sw $t0, arg2_addr
    j start_coding_here

start_coding_here:
	li $t1, 2 #The number of arguments required
	bne $a0, $t1, args_err #Check to see if num_args is 2. $t0 is loaded with 2 from the hw_main
	
	lw $s0, arg1_addr #Load the address of the first argument
	lbu $s1, 0($a1) ##This should be D, F, L, or X
	lbu $s2, 1($a1) #This should be a null terminator
	
	li $t0, 68 #D
	li $t1, 70 #F
	li $t2, 76 #L
	li $t3, 88 #X
	
	bnez $s2, invalid_arg_err #This checks if the $s2 is a null terminator
	
	beq $s1, $t0, part_two #D -> Part 2
	beq $s1, $t1, part_four #F -> Part 4
	beq $s1, $t2, part_five #L -> Part 5
	beq $s1, $t3, part_three #X -> Part 3
	j invalid_arg_err

#PART_2
part_two:
	lw $s1, arg2_addr #Load the address of the second argument
	li $t0, 0 #Counter
	li $t1, 32 #Number of iterations
	li $t2, 48 #0
	li $t3, 57 #9
	#li $t8, 0 #Decimal Cannot use $0 for this because immediate I assume
	j string_check_loop
	
string_check_loop:
	lbu $t4, 0($s1)
	beqz $t4, begin_convert_s_to_d
	addi $s1, $s1, 1 #Get address of next character
	addi $t0, $t0, 1 #Append to counter to know what character we are at
	blt $t4, $t2, invalid_arg_err #Checks to see if the ASCII is less than 0
	bgt $t4, $t3, invalid_arg_err #Checks to see if the ASCII is greater than 9
	ble $t0, $t1, string_check_loop #Loops as long as we have not made it through the whole string
	j invalid_arg_err

begin_convert_s_to_d:
	li $t2, 0 #Accumulator for decimal value
	li $t3, 10 #Load 10 to use for multiplication
	lw $s1, arg2_addr #Load the address of the second argument
	j convert_s_to_d_loop
	
convert_s_to_d_loop:
	lbu $t4, 0($s1)
	beqz $t4, invalid_arg_err
	addi $s1, $s1, 1
	lbu $t5, 0($s1)
	beqz $t5, print_s_to_d
	addi $t4, $t4, -48
	add $t2, $t2, $t4
	j convert_s_to_d_loop 

print_s_to_d:
	addi $t4, $t4, -48
	add $t2, $t2, $t4
	move $a0, $t2
	li $v0, 1 #Print int
	syscall
	j terminate

#PART_3
part_three:
	lw $s1, arg2_addr #Load the address of the second argument
	li $t0, 0 #Accumulator for length of the hex string
	li $t1, 3 #Min number of iterations
	li $t2, 10 #Max number of iterations
	li $t3, 120 #x
	li $t4, 48 #0
	li $t5, 57 #9
	li $t6, 65 #A
	li $t7, 70 #F
	li $s2, 0 #Accumulator for binary
	j begin_check_hs_to_d_characters
	
begin_check_hs_to_d_characters:
	lbu $t8, 0($s1)
	bne $t8, $t4, invalid_arg_err #If not 0, error
	addi $s1, $s1, 1
	addi $t0, $t0, 1 #Add to length counter of string
	lbu $t8, 0($s1)
	bne $t8, $t3, invalid_arg_err #If not x, error
	addi $s1, $s1, 1
	addi $t0, $t0, 1 #Add to length counter of string
	j hs_to_d_check_loop

hs_to_d_check_loop:
	lbu $t8, 0($s1)
	beqz $t8, check_if_hs_to_d_length_valid
	
	blt $t8, $t4, invalid_arg_err #Checks to see if the ASCII is less than 0
	ble $t8, $t5, hs_to_d_valid_digit #Checks to see if the ASCII is less than or equal 9
	blt $t8, $t6, invalid_arg_err #Checks to see if the ASCII is less than A
	ble $t8, $t7, hs_to_d_valid_letter #Checks to see if the ASCII is less than or equal F
	
	j invalid_arg_err
	
hs_to_d_valid_digit:
	sll $s2, $s2, 4
	sub $t8, $t8, $t4
	or $s2, $s2, $t8
	j hs_to_d_iterate

hs_to_d_valid_letter:
	sll $s2, $s2, 4
	sub $t8, $t8, $t6
	addi $t8, $t8, 10
	or $s2, $s2, $t8
	j hs_to_d_iterate

hs_to_d_iterate:
	addi $s1, $s1, 1 #Get address of next character
	addi $t0, $t0, 1 #Append to counter to know what character we are at
	
	ble $t0, $t2, hs_to_d_check_loop #Loops as long as the string is not longer than 10 characters *Might be a problem here, not sure if ble or blt is better
	j invalid_arg_err

check_if_hs_to_d_length_valid:
	blt $t0, $t1, invalid_arg_err
	j print_hs_to_d
	
print_hs_to_d:
	move $a0, $s2
	li $v0, 1 #Print int
	syscall
	j terminate

#PART_4
part_four:
	lw $s1, arg2_addr #Load the address of the second argument
	li $t0, 0 #Accumulator for length of the hex string
	li $t1, 8 #Max number of iterations
	li $t2, 48 #0
	li $t3, 57 #9
	li $t4, 65 #A
	li $t5, 70 #F
	li $s2, 0 #Accumulator for binary
	j hs_to_f_check_loop
	
hs_to_f_check_loop:
	lbu $t6, 0($s1)
	beqz $t6, check_if_hs_to_f_length_valid
	
	blt $t6, $t2, invalid_arg_err #Checks to see if the ASCII is less than 0
	ble $t6, $t3, hs_to_f_valid_digit #Checks to see if the ASCII is less than or equal 9
	blt $t6, $t4, invalid_arg_err #Checks to see if the ASCII is less than A
	ble $t6, $t5, hs_to_f_valid_letter #Checks to see if the ASCII is less than or equal F
	
	j invalid_arg_err
	
hs_to_f_valid_digit:
	sll $s2, $s2, 4
	sub $t6, $t6, $t2
	or $s2, $s2, $t6
	j hs_to_f_iterate

hs_to_f_valid_letter:
	sll $s2, $s2, 4
	sub $t6, $t6, $t4
	addi $t6, $t6, 10
	or $s2, $s2, $t6
	j hs_to_f_iterate

hs_to_f_iterate:
	addi $s1, $s1, 1 #Get address of next character
	addi $t0, $t0, 1 #Append to counter to know what character we are at
	
	ble $t0, $t1, hs_to_f_check_loop #Loops as long as the string is not longer than 8 characters *Might be a problem here, not sure if ble or blt is better
	j invalid_arg_err

check_if_hs_to_f_length_valid:
	bne $t0, $t1, invalid_arg_err
	j check_if_hs_to_f_special_float
	
check_if_hs_to_f_special_float:
	li $t7, 0x00000000 #Zero
	li $t8, 0x80000000 #Zero
	li $t9, 0xFF800000 #Neg_inf
	li $s3, 0x7F800000 #Pos_inf
	li $s4, 0x7F800001 #Nan
	li $s5, 0x7FFFFFFF #Nan
	li $s6, 0xFF800001 #Nan
	li $s7, 0xFFFFFFFF #Nan
	
	beq $s2, $t7, hs_to_f_print_zero
	beq $s2, $t8, hs_to_f_print_zero
	beq $s2, $t9, hs_to_f_print_inf_neg
	beq $s2, $s3, hs_to_f_print_inf_pos
	
	blt $s2, $s6, hs_to_f_not_special_float #Checks to see if the ASCII is less than 0
	ble $s2, $s7, hs_to_f_print_nan #Checks to see if the ASCII is less than or equal 9
	blt $s2, $s4, hs_to_f_not_special_float #Checks to see if the ASCII is less than A
	ble $s2, $s5, hs_to_f_print_nan #Checks to see if the ASCII is less than or equal F
	
	j hs_to_f_not_special_float
	
hs_to_f_print_zero:
	la $a0, zero
	li $v0, 4 #Print string
	syscall
	j terminate
	
hs_to_f_print_inf_neg:
	la $a0, inf_neg
	li $v0, 4 #Print string
	syscall
	j terminate

hs_to_f_print_inf_pos:
	la $a0, inf_pos
	li $v0, 4 #Print string
	syscall
	j terminate

hs_to_f_print_nan:
	la $a0, nan
	li $v0, 4 #Print string
	syscall
	j terminate
	
hs_to_f_not_special_float:
	la $s3, mantissa
	move $s4, $s2 #Copy of the binary representation
	li $t0, -127 #bias for the exponent
	
	j b_to_f_get_and_store_exponent
	
b_to_f_get_and_store_exponent:
	sll $s4, $s4, 1 #Shift left by one to get rid of the signed bit, leaves a 0 in the lsb of the register
	srl $s4, $s4, 24 #Shift right by 24 = 23 + 1 to get rid of the mantissa + 0 left after the shift left logical
	add $s4, $s4, $t0 #Convert to real exponent, also unsure about doing the add with the register with -127 in it.
	move $a0, $s4
	j b_to_f_sign_bit

b_to_f_sign_bit:
	move $s4, $s2
	srl $s4, $s4, 31
	bnez $s4, b_to_f_is_negative
	j b_to_f_normalize
	
b_to_f_is_negative:
	li $t1, 45 #- 
	sb $t1, 0($s3) #Adding the negative (-) into the string if the number is negative
	addi $s3, $s3, 1
	j b_to_f_normalize

b_to_f_normalize:
	li $t1, 49 #1
	sb $t1, 0($s3)
	addi $s3, $s3, 1
	li $t1, 46 #.
	sb $t1, 0($s3)
	addi $s3, $s3, 1
	j b_to_f_begin_get_and_store_mantissa

b_to_f_begin_get_and_store_mantissa:
	li $t2, 22 #Anti-Counter for how many iterations were done
	li $t3, 9 #Counter for how much to move to the left so the previous bits before can be removed
	
convert_b_to_f_loop:
	move $s4, $s2
	sllv $s4, $s4, $t3 #Shifts the bits to the right, removing the sign bit (1) and the exponent part (8)
	srlv $s4, $s4, $t3 #Now all the 0s are at the left side, near the msb
	srlv $s4, $s4, $t2
	beqz $s4, b_to_f_next_bit_zero
	j b_to_f_next_bit_one
	
b_to_f_next_bit_zero:
	li $t1, 48
	j b_to_f_iterate

b_to_f_next_bit_one:
	li $t1, 49
	j b_to_f_iterate

b_to_f_iterate:
	sb $t1, 0($s3)
	addi $s3, $s3, 1 #Mantissa address
	addi $t2, $t2, -1
	addi $t3, $t3, 1
	bgez $t2, convert_b_to_f_loop
	sb $zero, 0($s3)
	
	j b_to_f_store_mantissa
	
b_to_f_store_mantissa:
	la $a1, mantissa
	
	j terminate	
	
part_five:
	lw $s1, arg2_addr #Load the address of the second argument
	li $t0, 0 #Accumulator for length of the hand we stored
	li $t1, 6 #Max number of iterations
	li $t2, 49 #1
	li $t3, 57 #9
	li $t4, 77 #M for merchant ships
	li $t5, 80 #P for pirate ships
	li $s2, 0 #Total points
	
	j lcg_check_digit #lcg stands for loot card game

lcg_check_digit:
	lbu $t6, 0($s1)
	addi $s1, $s1, 1
	blt $t6, $t2, invalid_arg_err #Checks to see if the ASCII is less than 1
	ble $t6, $t3, lcg_check_letter #Checks to see if the ASCII is less than or equal 9
	j invalid_arg_err

lcg_check_letter:
	lbu $t7, 0($s1)
	addi $s1, $s1, 1
	beq $t7, $t4, lcg_letter_M #Checks to see if the ASCII is M
	beq $t7, $t5, lcg_letter_P #Checks to see if the ASCII is P
	j invalid_arg_err

lcg_letter_M:
	addi $t6, $t6, -48
	add $s2, $s2, $t6
	addi $t0, $t0, 1
	blt $t0, $t1, lcg_check_digit
	j lcg_print_points

lcg_letter_P:
	addi $t6, $t6, -48
	sub $s2, $s2, $t6
	addi $t0, $t0, 1
	blt $t0, $t1, lcg_check_digit
	j lcg_print_points

lcg_print_points:
	move $a0, $s2
	li $v0, 1 #Print int
	syscall
	j terminate

args_err:
	la $a0, args_err_msg
	li $v0, 4 #Print string
	syscall
	j terminate

invalid_arg_err:
	la $a0, invalid_arg_msg
	li $v0, 4 #Print string
	syscall
	j terminate
	
terminate:
	li $v0, 10 #Exit
	syscall


