.data 
# User messages and prompts
prompt:        .asciiz "Enter the filename: "               # Prompt message for filename input
fin:           .space 100                                   # Space for filename input
output_filename:    .asciiz "temp.txt"   # Filename for input file
buffer:        .space 1024                                   # Buffer for storing file contents
outout_file_buffer: .space 1024                               # Space for reading each line
output_file_buffer_2: .space 1024                               # Space for reading each line
read_input:.space 10
line:		.space 100
coff_stored:   .word 0		       #store the value to pass it to coff stored
system:		.space 1024					#contain three or two equation 
index:        .word 0                                       # Variable to track the current position in the buffer
str:        .space 50               # Space for the resulting string

zero:       .float 0.0              # Floating-point zero
EOF:    .word 0                  # Define EOF with a value of 0 (or another value representing end of file)
coff_x:        .word 0, 0, 0                   # Space for storing x coefficients
coff_y:        .word 0, 0, 0                   # Space for storing y coefficients
coff_z:        .word 0, 0, 0                   # Space for storing z coefficients
result:        .word 0, 0, 0                   # Space for result
determinant:   .word 0                         # Determinant of A
det_Ax:        .word 0                         # Determinant of A_x
det_Ay:        .word 0                         # Determinant of A_y
det_Az:        .word 0                         # Determinant of A_z
precision:  .word 3                 # Precision (number of digits after decimal)
scale_factor: .float 1000.0         # Scale factor (1000.0)
#########################################################################################################
increamnt_for_plus_minus: .asciiz "\nincreamnt + and -...\n"
empty_line_msg: .asciiz "Empty line detected\n"  # Message to print when empty line is detected
open_error_msg: .asciiz "Error: Could not open the file.\n"
read_error_msg: .asciiz "Error: Could not read the file or file is too large.\n"
open_success: .asciiz "File opened successfully.\n"
reach_new_line:	.asciiz "\nReached new line...\n"
open_error: .asciiz "Error: Unable to open file.\n"  # Error message for file open failure
solving_msg:   .asciiz "\nSolving system...\n"
done_msg:      .asciiz "\nSolution complete.\n"
error_msg:     .asciiz "\nError: Could not open the file.\n"
error_msg_unvalid:  .asciiz "\nError we have unvlaid line"
success_msg:   .asciiz "File opened successfully.\n"
EOF_msg:       .asciiz "\nEnd of file reached.\n"
menu_msg:      .asciiz "Enter 'f' for file output or 's' for screen output: "
results_saved_msg: .asciiz "Results saved to file.\n"  # Message when results are saved to file
X_equal:       .asciiz "X = "                            # Label for displaying X
Y_equal:       .asciiz "Y = "                            # Label for displaying Y
Z_equal:       .asciiz "Z = "                            # Label for displaying Z
Resulat_equal:  .asciiz "result = " 
det_label: .asciiz "Determinants:\n"             # Label for printing "Determinants:"
det_x_label: .asciiz "det(x): "                  # Label for det(x)
det_y_label: .asciiz "det(y): "                  # Label for det(y)
det_z_label: .asciiz "det(z): "                  # Label for det(z)
solution_label: .asciiz "Solution:\n"            # Label for solution
invalid_msg:   .asciiz "Invalid choice. Please enter 'f' or 's'.\n"
valid_msg:	.asciiz "\nValid\n"
readErrorMsg: .asciiz "\nError in reading file\n"
buffer_display: .asciiz "Buffer contents: "
message: .asciiz "there are infinity solutions\n"  # The message to print
error_message:.asciiz "it doesn't open correctly"
bloack:    .asciiz "\n-----------------------------------------------------------------------------------------\n"
prompt_msg: .asciiz "\nChoose how to display results (f/F for file, s/S for screen, e/E to exit):\n "
output_file_name: .asciiz "output.txt"
result_msg: .asciiz "This is the result to be displayed or saved.\n"
emptyLine: .asciiz "\n"
exit_msg: .asciiz "Exiting the program. Goodbye!\n"

.text
.globl main
main:
    # Prompt for filename
    li $v0, 4
    la $a0, prompt
    syscall
    # Read the filename into fin
    li $v0, 8
    la $a0, fin
    li $a1, 100
    syscall

    # Remove newline character from filename input
    la $t0, fin
remove_newline_loop:
    lb $t1, 0($t0)
    beq $t1, 0, end_remove
    beq $t1, 10, remove_newline
    addi $t0, $t0, 1
    j remove_newline_loop

remove_newline:
    sb $zero, 0($t0)

end_remove:
# Open the file for reading
    # Open the file (system call 13)
    li $v0, 13                  # syscall for opening a file
    la $a0, fin            # Load address of the filename
    li $a1, 0                   # Mode: 0 for read
    syscall

    # Store file descriptor in $v0
    move $s0, $v0               # Save file descriptor in $s0

    # Read from the file (system call 14)
    li $v0, 14                  # syscall for reading from a file
    move $a0, $s0               # File descriptor in $a0
    la $a1, buffer              # Address of buffer to store read data
    li $a2, 1024                # Max number of bytes to read
    syscall

    # Close the file (system call 16)
    li $v0, 16                  # syscall for closing a file
    move $a0, $s0               # File descriptor in $a0
    syscall
 # Loop through each element in the buffer
    la $t0, buffer              # Load address of buffer into $t0 (pointer)
    li $t6, 0                       # Initialize counter for number of lines in loop
    li $t7, 0                       # Initialize counter for minus signs (=)
    la $t9,line
####################################################################################################
loop:
    lb $t2, 0($t0)              # Load byte at address $t0 into $t2
    blez $t2, end_loop          # If byte value is less than or equal to EOF (0), exit loop
    
    # Increment the buffer pointer
    addi $t0, $t0, 1            # Increment buffer pointer by 1
    # Check for empty line
    li $t3, '\n'                  # ASCII value for newline character ('\n')
    beq $t2, $t3, check_next_char # If current char is '\n', check next char
    
    sb $t2, 0($t9)         # Store the byte in $t2 into 'line' at the address in $t9
    addi $t9, $t9, 1       # Increment $t9 to point to the next position in the line
    # Add a condition here if you need to stop after a certain count or a specific byte value
    # For example:
    # bne $t2, $zero, load_loop   # Continue until $t2 holds a zero byte
    li $t3, 61                      # ASCII value for '='
    beq $t2, $t3, increment_equl    # If current char is '=', increment equal counter

back_from_incremant_equal:
    
    j loop                      # Jump to the start of the loop
####################################################################################################
end_loop:
    ###############
menu_loop:
    # Prompt the user
    li $v0, 4                   # syscall for print string
    la $a0, prompt_msg
    syscall

    # Read the user input (a single character)
    li $v0, 8                   # syscall for read string
    la $a0, read_input # Read input into buffer
    li $a1, 2                   # Read one character + newline
    syscall

    # Check the first character of input
    lb $t1, read_input # Load the first character
    li $t2, 'f'
    li $t3, 'F'
    li $t4, 's'
    li $t5, 'S'
    li $t6, 'e'
    li $t7, 'E'

    beq $t1, $t2, write_to_file  # If 'f', write to file
    beq $t1, $t3, write_to_file  # If 'F', write to file
    beq $t1, $t4, print_to_screen # If 's', print to screen
    beq $t1, $t5, print_to_screen # If 'S', print to screen
    beq $t1, $t6, exit_program   # If 'e', exit the program
    beq $t1, $t7, exit_program   # If 'E', exit the program

    # Invalid input
    li $v0, 4                   # syscall for print string
    la $a0, invalid_msg
    syscall
    j menu_loop                 # Restart the menu loop

write_to_file:
    # Open file for writing
    li $v0, 13                  # syscall for open file
    la $a0, output_file_name    # Filename
    li $a1, 1                   # Mode: write
    li $a2, 0                   # No permissions needed
    syscall
    move $t0, $v0               # File descriptor

    # Write result to file
    li $v0, 15                  # syscall for write to file
    move $a0, $t0               # File descriptor
    la $a1, result_msg          # Result message
    li $a2, 29                  # Length of the message
    syscall

    # Close file
    li $v0, 16                  # syscall for close file
    move $a0, $t0               # File descriptor
    syscall
    j menu_loop                 # Restart the menu loop

print_to_screen:
    # Print result on screen
    li $v0, 4                   # syscall for print string
    la $a0,output_file_buffer_2
    syscall
    j menu_loop                 # Restart the menu loop

exit_program:
    # Exit the program
    li $v0, 4                   # syscall for print string
    la $a0, exit_msg
    syscall
    li $v0, 10                  # syscall for exit
    syscall
####################################################################################################
exit:
    li $v0, 11         # Syscall number for printing a character
    li $a0, 10         # ASCII value of newline (0xA)
    syscall            # Make the syscall

    # Close the file (system call 16)
    li $v0, 16                  # syscall for closing a file
    move $a0, $s0               # File descriptor in $a0
    syscall

    # Exit the program
    li $v0, 10                  # syscall for exit
    syscall
####################################################################################################
increment_equl:
    addi $t7, $t7, 1                # Increment the number of lines by 1
    j back_from_incremant_equal                          # Jump back to the loop

####################################################################################################
check_next_char:
    ###################################################
    lb $t2, 1($t0)              # Load next byte (character) in the buffer
    li $t3, 10                  # ASCII value for newline character ('\n')
    blez $t2, empty_line          # If byte value is less than or equal to EOF (0), exit loop
    beq $t2, $t3, empty_line    # If next byte is a newline, it's an empty line
    j end_of_line                # Otherwise, continue normal loop
####################################################################################################
end_of_line:
addi $t6, $t6, 1                # t6 contain the line of each systme if it 2 or 3
#we can reach the first lines here add\n end of each lin
li $t2, 10        # Load ASCII value of newline '\n' into $t2
sb $t2, 0($t9)    # Store the byte in $t2 at the address in $t9
# Print the entire line without a loop
    li $v0, 4                  # syscall code for print_string
    la $a0, line               # load address of 'line' to print it
    syscall
# Compare t6 with 1

    li    $t3, 1          # Load immediate 1 into temporary register t0
    beq   $t7, $t3, decode_line	# If t6 == 1 the line valid eles the line invalid
    # If t6 != 1, skip to the end
####################################################################################################
unvalied_line:
    li $v0, 4
    la $a0, error_msg_unvalid
    syscall
    j exit
####################################################################################################
decode_line:
    la $t9, line           # Load the address of 'line' into $t9
    la $t1,coff_stored
    li $t4,1
###########################
decode_loop:
    lb $t7, 0($t9)         # Load the current byte in 'line' into $t7
    li $t3, 10             # Load the ASCII value for '\n' into $t3
    beq $t7, $t3, clean_line # If the byte is '\n', exit the loop
    addi $t9, $t9, 1       # Move to the next byte in 'line'
    #$$$$$$$$#
    sb $t7, 0($t1)         # Store the current byte into 'coff_stored'
    addi $t1, $t1, 1       # Move to the next byte in 'coff_stored'
    
    ###################################################################################
    beq  $t7, '=', constant_mode        # if '=', jump to constant handling mode
    #%%%%%%%%%%%%%%%%%%%%%%%%#
    beq  $t7, 'x', x_coff           # if 'x', handle x coefficient
    beq  $t7, 'y', y_coff           # if 'y', handle y coefficient
    beq  $t7, 'z', z_coff           # if 'z', handle z coefficient
    #%%%%%%%%%%%%%%%%%%%%%%%%#
    
    ###################################################################################
    j decode_loop             
##########################<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
x_coff:
    #////////////
    li $t4, 1            # Initialize $t4 for handling negative numbers
    li $t1, 0            # Initialize $t1 for storing the parsed number
    la $t8,coff_stored  
loop_x_store:
    lb $t7, 0($t8)          # Load the next character
    beq $t7, 'x', end_loop_x_coff # Exit if 'x' is reached
    addi $t8, $t8, 1        # Move to the next character
    beq $t7, '-',negt_mod_x # Handle negative sign
    beq $t7, '+',loop_x_store # Handle negative sign
    # Convert ASCII digit to integer and update $t1
    subi $t7, $t7, '0'       # Convert ASCII to integer
    mul $t1, $t1, 10         # Multiply current value in $t1 by 10
    add $t1, $t1, $t7        # Add the new digit to $t1
    j loop_x_store           # Continue parsing
    #############    end of the coff store      #######33

end_loop_x_coff:
    beq $t1, $zero, coff_x_equla_one  # If $t1 == 0, jump to the label coff_1
    back_from_coff_x_equla_one:
    
    mul $t1, $t1, $t4        # Apply the sign (positive/negative)
    move $t2, $t1            # Store the final value in $t2
    move $t3, $t6            # Copy the value of $t6 into $t3
    # Store the result in the appropriate position in 'x_coff'
    subi $t3, $t3, 1         # Convert line number to zero-based index
    la $t8, coff_x           # Load the base address of 'result'
    sll $t3, $t3, 2          # Multiply the index by 4 (word size)
    add $t8, $t8, $t3        # Calculate the address for the current line
    sw $t1, 0($t8)           # Store the result in the calculated address

clean_coff_store_x:

    la $t8, coff_stored             # Load address of coff_stored
    sw $zero, 0($t8)                # Store 0 (from $zero) into coff_stored
    li $t8,0
    la $t1,coff_stored
    j decode_loop
#$$$$$$$$#
negt_mod_x:
li $t4, -1           # Set $t4 to -1 for negative numbers
j loop_x_store
#$$$$$$$#
coff_x_equla_one:
    li $t1,1
    j back_from_coff_x_equla_one
##########
    
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
y_coff:
    #////////////
    li $t4, 1            # Initialize $t4 for handling negative numbers
    li $t1, 0            # Initialize $t1 for storing the parsed number=
    la $t8,coff_stored  
loop_y_store:
    lb $t7, 0($t8)          # Load the next character
    beq $t7, 'y', end_loop_y_coff # Exit if 'y' is reached
    addi $t8, $t8, 1        # Move to the next character
    beq $t7, '-',negt_mod_y # Handle negative sign
    beq $t7, '+',loop_y_store # Handle negative sign
    # Convert ASCII digit to integer and update $t1
    subi $t7, $t7, '0'       # Convert ASCII to integer
    mul $t1, $t1, 10         # Multiply current value in $t1 by 10
    add $t1, $t1, $t7        # Add the new digit to $t1
    j loop_y_store           # Continue parsing
    #############    end of the coff store      #######33

end_loop_y_coff:
    beq $t1, $zero, coff_y_equla_one  # If $t1 == 0, jump to the label coff_1
    back_from_coff_y_equla_one:
    mul $t1, $t1, $t4        # Apply the sign (positive/negative)
    move $t2, $t1            # Store the final value in $t2
    move $t3, $t6            # Copy the value of $t6 into $t3
    # Store the result in the appropriate position in'y-coff'
    subi $t3, $t3, 1         # Convert line number to zero-based index
    la $t8, coff_y           # Load the base address of 'result'
    sll $t3, $t3, 2          # Multiply the index by 4 (word size)
    add $t8, $t8, $t3        # Calculate the address for the current line
    sw $t1, 0($t8)           # Store the result in the calculated addres
clean_coff_store_y:
    la $t8, coff_stored             # Load address of coff_stored
    sw $zero, 0($t8)                # Store 0 (from $zero) into coff_stored
    li $t8,0
    la $t1,coff_stored
    j decode_loop
#$$$$$$$$#
negt_mod_y:
li $t4, -1           # Set $t4 to -1 for negative numbers
j loop_y_store
#$$$$$$$#
coff_y_equla_one:
    li $t1,1
    j back_from_coff_y_equla_one
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
z_coff:
    #////////////
    li $t4, 1            # Initialize $t4 for handling negative numbers
    li $t1, 0            # Initialize $t1 for storing the parsed number=
    la $t8,coff_stored  
loop_z_store:
    lb $t7, 0($t8)          # Load the next character
    beq $t7, 'z', end_loop_z_coff # Exit if 'z' is reached
    addi $t8, $t8, 1        # Move to the next character
    beq $t7, '-',negt_mod_z # Handle negative sign
    beq $t7, '+',loop_z_store # Handle negative sign
    # Convert ASCII digit to integer and update $t1
    subi $t7, $t7, '0'       # Convert ASCII to integer
    mul $t1, $t1, 10         # Multiply current value in $t1 by 10
    add $t1, $t1, $t7        # Add the new digit to $t1
    j loop_z_store           # Continue parsing
    #############    end of the coff store      #######33

end_loop_z_coff:
    beq $t1, $zero, coff_z_equla_one  # If $t1 == 0, jump to the label coff_1
    back_from_coff_z_equla_one:
    mul $t1, $t1, $t4        # Apply the sign (positive/negative)
    move $t2, $t1            # Store the final value in $t2
    move $t3, $t6            # Copy the value of $t6 into $t3
    # Store the result in the appropriate position in'z-coff'
    subi $t3, $t3, 1         # Convert line number to zero-based index
    la $t8, coff_z           # Load the base address of 'result'
    sll $t3, $t3, 2          # Multiply the index by 4 (word size)
    add $t8, $t8, $t3        # Calculate the address for the current line
    sw $t1, 0($t8)           # Store the result in the calculated address
clean_coff_store_z:
    la $t8, coff_stored             # Load address of coff_stored
    sw $zero, 0($t8)                # Store 0 (from $zero) into coff_stored
    li $t8,0
    la $t1,coff_stored
    j decode_loop
#$$$$$$$$#
negt_mod_z:
li $t4, -1           # Set $t4 to -1 for negative numbers
j loop_z_store
#$$$$$$$#
coff_z_equla_one:
    li $t1,1
    j back_from_coff_z_equla_one
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##

##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
constant_mode:
    li $t4, 1            # Initialize $t4 for handling negative numbers
    li $t1, 0            # Initialize $t1 for storing the parsed number
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
constant_loop:
    lb $t7, 0($t9)       # Load the current byte from 'line' into $t7
    addi $t9, $t9, 1     # Move to the next byte in 'line'
    li $t3, 10           # Load the ASCII value for '\n'
    beq $t7, $t3, end_constant_mod # If the byte is '\n', exit the loop

    beq $t7, '-', negt_constant # Handle negative sign
    subi $t7, $t7, 48    # Convert ASCII digit to numerical value (if digit)
    bltz $t7, constant_loop # Skip non-digit characters

    mul $t1, $t1, 10     # Shift the current value left by multiplying by 10
    add $t1, $t1, $t7    # Add the new digit to the value

    b constant_loop      # Continue the loop
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
negt_constant:
    li $t4, -1           # Set $t4 to -1 for negative numbers
    j constant_loop      # Return to the loop
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
end_constant_mod:
    mul $t1, $t1, $t4    # Apply the sign (positive/negative)
    move $t2, $t1        # Store the final value in $t2
    move $t3, $t6   # Copy the value of $t6 into $t3

    # Store the result in the appropriate position in 'result'
    subi $t3, $t3, 1     # Convert line number to zero-based index
    la $t8, result       # Load the base address of 'result'
    sll $t3, $t3, 2      # Multiply the index by 4 (word size)
    add $t8, $t8, $t3    # Calculate the address for the current line
    sw $t1, 0($t8)       # Store the result in the calculated address
    j clean_line         # Jump to clean_line

########################
end_decode_line:#reach \n in the current line
    sb $v0, 0($a0)     # Store the character in the line
    addi $a0, $a0, 1   # Move to the next position in line
    addi $t3, $t3, 1   # Increment index
    j decode_loop        # Repeat the loop
####################################################################
 #when we reach the end of the line detect the line and then clean it
 	j clean_line           # Make the syscall
####################################################################################################

clean_line:
################3
    la $t3, line           # Load the address of 'line' into $t3
    li $t7, 0              # Load the value 0 into $t7 (for clearing the bytes)
    li $t5, 100            # Set the buffer size (100 bytes in this case)
clear_loop_line:
    sb $t7, 0($t3)         # Store the value 0 into the current byte of 'line'
    addi $t3, $t3, 1       # Increment the address to the next byte in 'line'
    subi $t5, $t5, 1       # Decrease the counter by 1
    bgtz $t5, clear_loop_line   # Continue the loop until we've cleared all bytes
    # The buffer 'line' is now cleared (all bytes set to 0)
    li $t7, 0	#equal counter back to 0
    la $t9, line    #pointer of line space to 0
    j loop
   
####################################################################################################
empty_line:
    addi $t6,$t6,1
    #we can reach the first lines here add\n end of each lin
    li $t2, 10        # Load ASCII value of newline '\n' into $t2
    sb $t2, 0($t9)    # Store the byte in $t2 at the address in $t9
    ##################
    #t6 contain the number of line in system #numof equation
    addi $t0, $t0, 2            # Increment buffer pointer by 1
    
    #################
    # Print the entire line without a loop
    li $v0, 4                  # syscall code for print_string
    la $a0, line               # load address of 'line' to print it
    syscall
    li    $t3, 1          # Load immediate 1 into temporary register t0
    beq   $t7, $t3, decode_line_bf	# If t6 == 1 the line valid eles the line invalid
    # If t6 != 1, skip to the end
####################################################################################################
unvalied_line_2:
    li $v0, 4
    la $a0, error_msg_unvalid
    syscall
    j exit
back_decode_bf: 

    #################
# Print the 'result' array in order
    li $t3, 10        # Load the ASCII value of newline '\n' into $t3
    move $a0, $t3     # Move the value of $t3 to $a0 (argument for syscall)
    li $v0, 11        # Load syscall code for printing a character
    syscall           # Make the syscall
    li $v0, 4
    la $a0, Resulat_equal
    syscall

    la $t7, result       # Load the base address of 'result' into $t0
    li $t1, 3            # Number of elements in the 'result' array
    li $t2, 0            # Initialize the loop counter to 0

print_loop:
    beq $t2, $t1, end_print # If counter equals size, exit the loop
    lw $t3, 0($t7)          # Load the current element into $t3
    li $v0, 1               # System call for print integer
    move $a0, $t3           # Load the value into $a0
    syscall                 # Perform the system call

    # Print a comma and space, except after the last element
    addi $t2, $t2, 1        # Increment the counter
    bge $t2, $t1, skip_comma # Skip comma after the last element
    li $a0, ','             # ASCII value of ','
    li $v0, 11              # System call for print character
    syscall
    li $a0, ' '             # ASCII value of space
    li $v0, 11              # System call for print character
    syscall

skip_comma:
    addi $t7, $t7, 4        # Move to the next element in the array
    j print_loop            # Repeat the loop

end_print:
    # Print a newline after the array
    li $a0, 10              # ASCII value of '\n'
    li $v0, 11              # System call for print character
    syscall
    ##########print x_coff###############
 # Print the 'coff_x' array in order
    li $v0, 4
    la $a0, X_equal
    syscall

    la $t7, coff_x       # Load the base address of 'result' into $t0
    li $t1, 3            # Number of elements in the 'result' array
    li $t2, 0            # Initialize the loop counter to 0

print_loop_coff_x:
    beq $t2, $t1, end_print_coff_x # If counter equals size, exit the loop
    lw $t3, 0($t7)          # Load the current element into $t3
    li $v0, 1               # System call for print integer
    move $a0, $t3           # Load the value into $a0
    syscall                 # Perform the system call

    # Print a comma and space, except after the last element
    addi $t2, $t2, 1        # Increment the counter
    bge $t2, $t1, skip_comma_coff_x # Skip comma after the last element
    li $a0, ','             # ASCII value of ','
    li $v0, 11              # System call for print character
    syscall
    li $a0, ' '             # ASCII value of space
    li $v0, 11              # System call for print character
    syscall

skip_comma_coff_x:
    addi $t7, $t7, 4        # Move to the next element in the array
    j print_loop_coff_x            # Repeat the loop

end_print_coff_x:
    # Print a newline after the array
    li $a0, 10              # ASCII value of '\n'
    li $v0, 11              # System call for print character
    syscall   
    ##########print y_coff###############
 # Print the 'coff_y' array in order
    li $v0, 4
    la $a0, Y_equal
    syscall

    la $t7, coff_y       # Load the base address of 'result' into $t0
    li $t1, 3            # Number of elements in the 'result' array
    li $t2, 0            # Initialize the loop counter to 0

print_loop_coff_y:
    beq $t2, $t1, end_print_coff_y # If counter equals size, exit the loop
    lw $t3, 0($t7)          # Load the current element into $t3
    li $v0, 1               # System call for print integer
    move $a0, $t3           # Load the value into $a0
    syscall                 # Perform the system call

    # Print a comma and space, except after the last element
    addi $t2, $t2, 1        # Increment the counter
    bge $t2, $t1, skip_comma_coff_y # Skip comma after the last element
    li $a0, ','             # ASCII value of ','
    li $v0, 11              # System call for print character
    syscall
    li $a0, ' '             # ASCII value of space
    li $v0, 11              # System call for print character
    syscall

skip_comma_coff_y:
    addi $t7, $t7, 4        # Move to the next element in the array
    j print_loop_coff_y            # Repeat the loop

end_print_coff_y:
    # Print a newline after the array
    li $a0, 10              # ASCII value of '\n'
    li $v0, 11              # System call for print character
    syscall   
##########print z_coff###############
 # Print the 'coff_z' array in order
    li $v0, 4
    la $a0, Z_equal
    syscall

    la $t7, coff_z       # Load the base address of 'result' into $t0
    li $t1, 3            # Number of elements in the 'result' array
    li $t2, 0            # Initialize the loop counter to 0

print_loop_coff_z:
    beq $t2, $t1, end_print_coff_z # If counter equals size, exit the loop
    lw $t3, 0($t7)          # Load the current element into $t3
    li $v0, 1               # System call for print integer
    move $a0, $t3           # Load the value into $a0
    syscall                 # Perform the system call

    # Print a comma and space, except after the last element
    addi $t2, $t2, 1        # Increment the counter
    bge $t2, $t1, skip_comma_coff_z # Skip comma after the last element
    li $a0, ','             # ASCII value of ','
    li $v0, 11              # System call for print character
    syscall
    li $a0, ' '             # ASCII value of space
    li $v0, 11              # System call for print character
    syscall

skip_comma_coff_z:
    addi $t7, $t7, 4        # Move to the next element in the array
    j print_loop_coff_z            # Repeat the loop

end_print_coff_z:
    # Print a newline after the array
    li $a0, 10              # ASCII value of '\n'
    li $v0, 11              # System call for print character
    syscall   
    ##################
    li $a0, 10       # ASCII code for newline (\n)
    li $v0, 11       # Syscall code for printing a character
    syscall          # Execute the syscall to print \n
    ###############		here we decode the line		######################################
    
    li $t3, 2             # Load the value 2 into $t0
    beq $t6, $t3, solve_system_with_two_Variable # If $t6 == 2, jump to solve_system_with_two_Variable
    li $t3, 3             # Load the value 2 into $t0
    beq $t6, $t3, solve_system_with_three_Variable # If $t6 == 2, jump to solve_system_with_two_Variable
    back_from_solve:
    ########### here we will clear the memory ######################333
    ########################
	#after solve system we need to clean coff of x, y, z, and resulat ,and each determin
	# Call the clear_memory function for each array
    la   $a0, coff_x      # Load base address of coff_x into $a0
    jal  clear_memory     # Clear coff_x

    la   $a0, coff_y      # Load base address of coff_y into $a0
    jal  clear_memory     # Clear coff_y

    la   $a0, coff_z      # Load base address of coff_z into $a0
    jal  clear_memory     # Clear coff_z

    la   $a0, result      # Load base address of result into $a0
    jal  clear_memory     # Clear result
    #########################end decode last line and solve the systme#########################3
    li $t6, 0  # Set $t6 to 0 t6 contain the number of line in each system
    li $t7,0 #set t7 to 0 to cheack number of equal in 
     li $v0, 4
    la $a0, bloack	  #print block between the systems
    syscall
    ####@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#######################
    # put \n under each system
    li $v0, 13                # Syscall for open
    la $a0, output_filename       # File name
    li $a1, 0                  # Open for reading (O_RDONLY)
    syscall
    move $t1, $v0             # Save file descriptor

    # Check if file opened successfully
    bltz $t1, open_error      # If $t1 < 0, handle error (file does not exist)
    # Step 2: Read the entire content of the file into the buffer
    li $v0, 14                # Syscall for read
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer        # Address of buffer to store file content
    li $a2, 1024              # Number of bytes to read (adjust buffer size if needed)
    syscall
    # Save the number of bytes read (this will be used when writing back the data)
    move $t8, $v0             # Number of bytes read
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
     li $v0, 13                # Syscall for open
    la $a0, output_filename          # File name
    li $a1, 1                 # Open for writing
    syscall
    move $t1, $v0             # Save file descriptor
    # Step 4: Write the existing content (from buffer) back to the file
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer          # Address of the buffer (previous file content)
    move $a2, $t8             # Number of bytes read (from previous syscall)
    syscall
    # Step 5: Write an empty line to separate previous content from new content
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, emptyLine         # Address of the empty line string
    li $a2, 1                 # Length of the empty line
    syscall                   # Perform the write

    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
####@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#######################
    j loop                      # Jump back to the loop
####################################################################################################
clear_memory:
    li   $t5, 3           # Number of words to clear
    li   $t2, 0           # Value to store (0)
clear_loop:
    sw   $t2, 0($a0)      # Store 0 at the current address
    addi $a0, $a0, 4      # Move to the next word
    subi $t5, $t5, 1      # Decrement counter
    bgtz $t5, clear_loop  # Repeat until counter is zero
    jr   $ra              # Return from function
####################################################################################################
decode_line_bf:
    la $t9, line           # Load the address of 'line' into $t9
    la $t1, coff_stored
    li $t4, 1
###########################
decode_loop_bf:
    lb $t7, 0($t9)         # Load the current byte in 'line' into $t7
    li $t3, 10             # Load the ASCII value for '\n' into $t3
    beq $t7, $t3, clean_line_bf # If the byte is '\n', exit the loop
    addi $t9, $t9, 1       # Move to the next byte in 'line'
    #$$$$$$$$#
    sb $t7, 0($t1)         # Store the current byte into 'coff_stored'
    addi $t1, $t1, 1       # Move to the next byte in 'coff_stored'
    
    ###################################################################################
    beq  $t7, '=', constant_mode_bf        # if '=', jump to constant handling mode
    #%%%%%%%%%%%%%%%%%%%%%%%%#
    beq  $t7, 'x', x_coff_bf           # if 'x', handle x coefficient
    beq  $t7, 'y', y_coff_bf           # if 'y', handle y coefficient
    beq  $t7, 'z', z_coff_bf           # if 'z', handle z coefficient
    #%%%%%%%%%%%%%%%%%%%%%%%%#
    
    ###################################################################################
    j decode_loop_bf              # Continue looping
##########################<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
x_coff_bf:
    #////////////
    li $t4, 1            # Initialize $t4 for handling negative numbers
    li $t1, 0            # Initialize $t1 for storing the parsed number
    la $t8, coff_stored  
loop_x_store_bf:
    lb $t7, 0($t8)          # Load the next character
    beq $t7, 'x', end_loop_x_coff_bf # Exit if 'x' is reached
    addi $t8, $t8, 1        # Move to the next character
    beq $t7, '-', negt_mod_x_bf # Handle negative sign
    beq $t7, '+', loop_x_store_bf # Handle negative sign
    # Convert ASCII digit to integer and update $t1
    subi $t7, $t7, '0'       # Convert ASCII to integer
    mul $t1, $t1, 10         # Multiply current value in $t1 by 10
    add $t1, $t1, $t7        # Add the new digit to $t1
    j loop_x_store_bf           # Continue parsing
    #############    end of the coff store      #######33

end_loop_x_coff_bf:
    beq $t1, $zero, coff_x_equla_one_bf  # If $t1 == 0, jump to the label coff_1
    back_from_coff_x_equla_one_bf:
    
    mul $t1, $t1, $t4        # Apply the sign (positive/negative)
    move $t2, $t1            # Store the final value in $t2
    move $t3, $t6            # Copy the value of $t6 into $t3
    # Store the result in the appropriate position in 'x_coff'
    subi $t3, $t3, 1         # Convert line number to zero-based index
    la $t8, coff_x           # Load the base address of 'result'
    sll $t3, $t3, 2          # Multiply the index by 4 (word size)
    add $t8, $t8, $t3        # Calculate the address for the current line
    sw $t1, 0($t8)           # Store the result in the calculated address

clean_coff_store_x_bf:

    la $t8, coff_stored             # Load address of coff_stored
    sw $zero, 0($t8)                # Store 0 (from $zero) into coff_stored
    li $t8, 0
    la $t1, coff_stored
    j decode_loop_bf

#$$$$$$$$#
negt_mod_x_bf:
    li $t4, -1           # Set $t4 to -1 for negative numbers
    j loop_x_store_bf

#$$$$$$$#
coff_x_equla_one_bf:
    li $t1, 1
    j back_from_coff_x_equla_one_bf
##########
    
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
y_coff_bf:
    #////////////
    li $t4, 1            # Initialize $t4 for handling negative numbers
    li $t1, 0            # Initialize $t1 for storing the parsed number
    la $t8, coff_stored  
loop_y_store_bf:
    lb $t7, 0($t8)          # Load the next character
    beq $t7, 'y', end_loop_y_coff_bf # Exit if 'y' is reached
    addi $t8, $t8, 1        # Move to the next character
    beq $t7, '-', negt_mod_y_bf # Handle negative sign
    beq $t7, '+', loop_y_store_bf # Handle negative sign
    # Convert ASCII digit to integer and update $t1
    subi $t7, $t7, '0'       # Convert ASCII to integer
    mul $t1, $t1, 10         # Multiply current value in $t1 by 10
    add $t1, $t1, $t7        # Add the new digit to $t1
    j loop_y_store_bf           # Continue parsing
    #############    end of the coff store      #######33

end_loop_y_coff_bf:
    beq $t1, $zero, coff_y_equla_one_bf  # If $t1 == 0, jump to the label coff_1
    back_from_coff_y_equla_one_bf:
    mul $t1, $t1, $t4        # Apply the sign (positive/negative)
    move $t2, $t1            # Store the final value in $t2
    move $t3, $t6            # Copy the value of $t6 into $t3
    # Store the result in the appropriate position in 'y-coff'
    subi $t3, $t3, 1         # Convert line number to zero-based index
    la $t8, coff_y           # Load the base address of 'result'
    sll $t3, $t3, 2          # Multiply the index by 4 (word size)
    add $t8, $t8, $t3        # Calculate the address for the current line
    sw $t1, 0($t8)           # Store the result in the calculated address

clean_coff_store_y_bf:
    la $t8, coff_stored             # Load address of coff_stored
    sw $zero, 0($t8)                # Store 0 (from $zero) into coff_stored
    li $t8, 0
    la $t1, coff_stored
    j decode_loop_bf

#$$$$$$$$#
negt_mod_y_bf:
    li $t4, -1           # Set $t4 to -1 for negative numbers
    j loop_y_store_bf

#$$$$$$$#
coff_y_equla_one_bf:
    li $t1, 1
    j back_from_coff_y_equla_one_bf
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
z_coff_bf:
    #////////////
    li $t4, 1            # Initialize $t4 for handling negative numbers
    li $t1, 0            # Initialize $t1 for storing the parsed number
    la $t8, coff_stored  
loop_z_store_bf:
    lb $t7, 0($t8)          # Load the next character
    beq $t7, 'z', end_loop_z_coff_bf # Exit if 'z' is reached
    addi $t8, $t8, 1        # Move to the next character
    beq $t7, '-', negt_mod_z_bf # Handle negative sign
    beq $t7, '+', loop_z_store_bf # Handle negative sign
    # Convert ASCII digit to integer and update $t1
    subi $t7, $t7, '0'       # Convert ASCII to integer
    mul $t1, $t1, 10         # Multiply current value in $t1 by 10
    add $t1, $t1, $t7        # Add the new digit to $t1
    j loop_z_store_bf           # Continue parsing
    #############    end of the coff store      #######33

end_loop_z_coff_bf:
    beq $t1, $zero, coff_z_equla_one_bf  # If $t1 == 0, jump to the label coff_1
    back_from_coff_z_equla_one_bf:
    mul $t1, $t1, $t4        # Apply the sign (positive/negative)
    move $t2, $t1            # Store the final value in $t2
    move $t3, $t6            # Copy the value of $t6 into $t3
    # Store the result in the appropriate position in 'z_coff'
    subi $t3, $t3, 1         # Convert line number to zero-based index
    la $t8, coff_z           # Load the base address of 'result'
    sll $t3, $t3, 2          # Multiply the index by 4 (word size)
    add $t8, $t8, $t3        # Calculate the address for the current line
    sw $t1, 0($t8)           # Store the result in the calculated address

clean_coff_store_z_bf:
    la $t8, coff_stored             # Load address of coff_stored
    sw $zero, 0($t8)                # Store 0 (from $zero) into coff_stored
    li $t8, 0
    la $t1, coff_stored
    j decode_loop_bf

#$$$$$$$$#
negt_mod_z_bf:
    li $t4, -1           # Set $t4 to -1 for negative numbers
    j loop_z_store_bf

#$$$$$$$#
coff_z_equla_one_bf:
    li $t1, 1
    j back_from_coff_z_equla_one_bf
###################################################################################
constant_mode_bf:
    li $t4, 1            # Initialize $t4 for handling negative numbers
    li $t1, 0            # Initialize $t1 for storing the parsed number
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
constant_loop_bf:
    lb $t7, 0($t9)       # Load the current byte from 'line' into $t7
    addi $t9, $t9, 1     # Move to the next byte in 'line'
    li $t3, 10           # Load the ASCII value for '\n'
    beq $t7, $t3, end_constant_mod_bf # If the byte is '\n', exit the loop

    beq $t7, '-', negt_constant_bf # Handle negative sign
    subi $t7, $t7, 48    # Convert ASCII digit to numerical value (if digit)
    bltz $t7, constant_loop_bf # Skip non-digit characters

    mul $t1, $t1, 10     # Shift the current value left by multiplying by 10
    add $t1, $t1, $t7    # Add the new digit to the value

    b constant_loop_bf      # Continue the loop
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
negt_constant_bf:
    li $t4, -1           # Set $t4 to -1 for negative numbers
    j constant_loop_bf      # Return to the loop
##<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>##
end_constant_mod_bf:
    mul $t1, $t1, $t4    # Apply the sign (positive/negative)
    move $t2, $t1        # Store the final value in $t2
    move $t3, $t6        # Copy the value of $t6 into $t3

    # Store the result in the appropriate position in 'result'
    subi $t3, $t3, 1     # Convert line number to zero-based index
    la $t8, result    # Load the base address of 'result'
    sll $t3, $t3, 2      # Multiply the index by 4 (word size)
    add $t8, $t8, $t3    # Calculate the address for the current line
    sw $t1, 0($t8)       # Store the result in the calculated address
    j clean_line_bf      # Jump to clean_line

########################
end_decode_line_bf:   # reach \n in the current line
    sb $v0, 0($a0)      # Store the character in the line
    addi $a0, $a0, 1    # Move to the next position in line
    addi $t3, $t3, 1    # Increment index
    j decode_loop_bf    # Repeat the loop
####################################################################
# When we reach the end of the line, detect the line and then clean it
    j clean_line_bf     # Make the syscall
####################################################################################################

clean_line_bf:
################3
    la $t3, line      # Load the address of 'line' into $t3
    li $t7, 0            # Load the value 0 into $t7 (for clearing the bytes)
    li $t5, 100          # Set the buffer size (100 bytes in this case)
clear_loop_line_bf:
    sb $t7, 0($t3)       # Store the value 0 into the current byte of 'line'
    addi $t3, $t3, 1     # Increment the address to the next byte in 'line'
    subi $t5, $t5, 1     # Decrease the counter by 1
    bgtz $t5, clear_loop_line_bf  # Continue the loop until we've cleared all bytes
    # The buffer 'line' is now cleared (all bytes set to 0)
    li $t7, 0            # Equal counter back to 0
    la $t9, line      # Pointer of line space to 0
    j back_decode_bf
##############################################################################################################



solve_system_with_two_Variable:
#==========================solve system with two variables========================================
    # Load coefficient base addresses
    la $s0, coff_x  # Base address of coff_x (a11, a21)
    la $s1, coff_y  # Base address of coff_y (a12, a22)
    la $s3, result  # Base address of result (d1, d2)

    # Calculate det(A)
    lw $s4, 0($s0)   # a11
    lw $s5, 4($s1)   # a22
    mul $t7, $s4, $s5  # t7 = a22 * a11    
    
    lw $s4, 0($s1)   # a12
    lw $s5, 4($s0)   # a21
    mul $t5, $s4, $s5  # t5 = a12 * a21
    sub $s7, $t7, $t5  # s7 = (a22 * a11 - a12 * a21) (det(A))
    beq $s7,0,infinity_solutions

#=======================================det(X)====================================================
    lw $t7, 0($s3)       # d1
    lw $t5, 4($s1)       # a22
    mul $t7, $t7, $t5    # t7 = a22 * d1

    lw $t5, 4($s3)       # d2
    lw $s4, 0($s1)       # a12
    mul $s4, $t5, $s4    # s4 = d2 * a12
    sub $s5, $t7, $s4    # t7 = (a22 * d1 - d2 * a12)

  #========= Calculate det(x) / det(A) ==========
    mtc1 $s5, $f0       # Move det(x) to $f0 (float)
    mtc1 $s7, $f1       # Move det(A) to $f1 (float)
    cvt.s.w $f0, $f0    # Convert det(x) to float
    cvt.s.w $f1, $f1    # Convert det(A) to float
    div.s $f2, $f0, $f1 # f2 = det(x) / det(A)
    jal Reverse_function 
     #+++++++++++++++++++++++++++++++++++++#
    # Step 1: Open file for reading to check if it exists
    li $v0, 13                # Syscall for open
    la $a0, output_filename       # File name
    li $a1, 0                  # Open for reading (O_RDONLY)
    syscall
    move $t1, $v0             # Save file descriptor

    # Check if file opened successfully
    bltz $t1, open_error      # If $t1 < 0, handle error (file does not exist)

    # Step 2: Read the entire content of the file into the buffer
    li $v0, 14                # Syscall for read
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer        # Address of buffer to store file content
    li $a2, 1024              # Number of bytes to read (adjust buffer size if needed)
    syscall

    # Save the number of bytes read (this will be used when writing back the data)
    move $t8, $v0             # Number of bytes read

    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
     li $v0, 13                # Syscall for open
    la $a0, output_filename          # File name
    li $a1, 1                 # Open for writing 
    syscall
    move $t1, $v0             # Save file descriptor
    
    # Step 4: Write the existing content (from buffer) back to the file
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer          # Address of the buffer (previous file content)
    move $a2, $t8             # Number of bytes read (from previous syscall)
    syscall
    
     # Step 6: Write the converted string to the file
      li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1,X_equal         # Address of the x_lAabel
    li $a2, 3             # Length of the empty line
    syscall                   # Perform the write
   
    li $v0, 15          # Syscall for write
    move $a0, $t1       # File descriptor
    la $a1, str            # Address of the string to write
    li $a2, 9            # Length of the string 
    syscall             # Perform the write syscall
    # Step 5: Write an empty line to separate previous content from new content
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, emptyLine         # Address of the empty line string
    li $a2, 1                 # Length of the empty line
    syscall                   # Perform the write
   
    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
    #+++++++++++++++++++++++++++++++++++++#
    
    # ========== Calculate det(y) ==========
    lw $t7, 0($s0)       # a11
    lw $t5, 4($s3)       # d2
    mul $t7, $t7, $t5    # t7 = d2 * a11

    lw $t5, 0($s3)       # d1
    lw $s4, 4($s0)       # a21
    mul $s4, $t5, $s4    # s4 = d1 * a21
    sub $s5, $t7, $s4    # t7 = (d2 * a11 - d1 * a21)

    # ==================== Calculate det(y) / det(A) ===================
    mtc1 $s5, $f0       # Move det(y) to $f0 (float)
    mtc1 $s7, $f1       # Move det(A) to $f1 (float)
    cvt.s.w $f0, $f0    # Convert det(y) to float
    cvt.s.w $f1, $f1    # Convert det(A) to float
    div.s $f2, $f0, $f1 # f2 = det(y) / det(A)
    jal Reverse_function
     #+++++++++++++++++++++++++++++++++++++#
    # Step 1: Open file for reading to check if it exists
    li $v0, 13                # Syscall for open
    la $a0, output_filename       # File name
    li $a1, 0                  # Open for reading (O_RDONLY)
    syscall
    move $t1, $v0             # Save file descriptor

    # Check if file opened successfully
    bltz $t1, open_error      # If $t1 < 0, handle error (file does not exist)
    # Step 2: Read the entire content of the file into the buffer
    li $v0, 14                # Syscall for read
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer        # Address of buffer to store file content
    li $a2, 1024              # Number of bytes to read (adjust buffer size if needed)
    syscall

    # Save the number of bytes read (this will be used when writing back the data)
    move $t8, $v0             # Number of bytes read

    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
     li $v0, 13                # Syscall for open
    la $a0, output_filename          # File name
    li $a1, 1                 # Open for writing 
    syscall
    move $t1, $v0             # Save file descriptor
    
    # Step 4: Write the existing content (from buffer) back to the file
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer          # Address of the buffer (previous file content)
    move $a2, $t8             # Number of bytes read (from previous syscall)
    syscall
    
     # Step 6: Write the converted string to the file
      li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1,Y_equal         # Address of the x_lAabel
    li $a2, 3             # Length of the empty line
    syscall                   # Perform the write
   
    li $v0, 15          # Syscall for write
    move $a0, $t1       # File descriptor
    la $a1, str            # Address of the string to write
    li $a2, 9            # Length of the string 
    syscall             # Perform the write syscall
    # Step 5: Write an empty line to separate previous content from new content
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, emptyLine         # Address of the empty line string
    li $a2, 1                 # Length of the empty line
    syscall                   # Perform the write
   
    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
    #+++++++++++++++++++++++++++++++++++++# 
    
   j back_from_solve

infinity_solutions:
    # Print "there are infinity solutions"
    la $a0, message       # Load address of message string
    li $v0, 4             # syscall for print string
    syscall               # Print the message

file_error:
    li $v0, 4
    la $a0, error_message  # Error message
    syscall
    li $v0, 10         # Exit system call
    syscall
#####################################################################################################
solve_system_with_three_Variable:
    # Load coefficient base addresses
    la $s0, coff_x  # Base address of coff_x
    la $s1, coff_y  # Base address of coff_y
    la $s2, coff_z  # Base address of coff_z
    la $s3, result  # Base address of result
    

    
    # Calculate det(A)
    lw $s4, 4($s1)   # a22
    lw $s5, 8($s2)   # a33
    mul $t7, $s4, $s5  # t7 = a22 * a33

    lw $s4, 8($s1)   # a23
    lw $s5, 4($s2)   # a32
    mul $t5, $s4, $s5  # t5 = a23 * a32
    sub $t7, $t7, $t5  # t7 = (a22 * a33 - a23 * a32)

    lw $s4, 0($s0)   # a11
    mul $s6, $s4, $t7  # s6 = a11 * (a22 * a33 - a23 * a32)

    lw $s4, 4($s0)   # a21
    lw $s5, 8($s2)   # a33
    mul $t7, $s4, $s5  # t7 = a21 * a33

    lw $s4, 4($s2)   # a23
    lw $s5, 8($s0)   # a31
    mul $t5, $s4, $s5  # t5 = a23 * a31
    sub $t7, $t7, $t5  # t7 = (a21 * a33 - a23 * a31)

    lw $s4, 0($s1)   # a12
    mul $t7, $s4, $t7  # t7 = a12 * (a21 * a33 - a23 * a31)
    sub $s6, $s6, $t7  # s6 -= a12 * (a21 * a33 - a23 * a31)

    lw $s4, 4($s0)   # a21
    lw $s5, 8($s1)   # a32
    mul $t7, $s4, $s5  # t7 = a21 * a32

    lw $s4, 4($s1)   # a22
    lw $s5, 8($s0)   # a31
    mul $t5, $s4, $s5  # t5 = a22 * a31
    sub $t7, $t7, $t5  # t7 = (a21 * a32 - a22 * a31)

    lw $s4, 0($s2)   # a13
    mul $t7, $s4, $t7  # t7 = a13 * (a21 * a32 - a22 * a31)
    add $s7, $s6, $t7  # det(A)
    beq $s7,0,infinity_solutions_2

    # ========== Calculate det(x) ==========
    # First term of det(x)
    lw $t7, 4($s1)       # a22
    lw $t5, 8($s2)       # a33
    mul $t7, $t7, $t5    # t7 = a22 * a33

    lw $t5, 4($s2)       # a23
    lw $s4, 8($s1)       # a32
    mul $s4, $t5, $s4    # s4 = a23 * a32
    sub $t7, $t7, $s4    # t7 = (a22 * a33 - a23 * a32)

    lw $s4, 0($s3)       # d1
    mul $s6, $s4, $t7    # s6 = d1 * (a22 * a33 - a23 * a32)

    # Second term of det(x)
    lw $s5, 4($s3)       # d2
    lw $t7, 8($s2)       # a33
    mul $s4, $s5, $t7    # s4 = d2 * a33

    lw $t7, 4($s2)       # a23
    lw $s5, 8($s3)       # d3
    mul $t7, $t7, $s5    # t7 = d3 * a23
    sub $t7, $s4, $t7    # t7 = (d2 * a33 - d3 * a23)

    lw $s4, 0($s1)       # a12
    mul $t7, $s4, $t7    # t7 = a12 * (d2 * a33 - d3 * a23)
    sub $s6, $s6, $t7    # s6 -= (second term)

    # Third term of det(x)
    lw $s5, 4($s3)       # d2
    lw $s4, 8($s1)       # a32
    mul $t7, $s5, $s4    # t7 = d2 * a32

    lw $s5, 8($s3)       # d3
    lw $s4, 4($s1)       # a22
    mul $s4, $s5, $s4    # s4 = d3 * a22
    sub $t7, $t7, $s4    # t7 = (d2 * a32 - d3 * a22)

    lw $s4, 0($s2)       # a13
    mul $s4, $s4, $t7    # s4 = a13 * (d2 * a32 - d3 * a22)
    add $s5, $s6, $s4    # det(x) = first term + second term + third term

    # ========== Calculate det(x) / det(A) ==========
    # Assume det(A) is stored in $s7
    mtc1 $s5, $f0       # Move det(x) to $f0 (float)
    mtc1 $s7, $f1       # Move det(A) to $f1 (float)
    cvt.s.w $f0, $f0    # Convert det(x) to float
    cvt.s.w $f1, $f1    # Convert det(A) to float
    div.s $f2, $f0, $f1 # f2 = det(x) / det(A)
    jal Reverse_function 
    #+++++++++++++++++++++++++++++++++++++#
    # Step 1: Open file for reading to check if it exists
    li $v0, 13                # Syscall for open
    la $a0, output_filename       # File name
    li $a1, 0                  # Open for reading (O_RDONLY)
    syscall
    move $t1, $v0             # Save file descriptor

    # Check if file opened successfully
    bltz $t1, open_error      # If $t1 < 0, handle error (file does not exist)
    # Step 2: Read the entire content of the file into the buffer
    li $v0, 14                # Syscall for read
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer        # Address of buffer to store file content
    li $a2, 1024              # Number of bytes to read (adjust buffer size if needed)
    syscall

    # Save the number of bytes read (this will be used when writing back the data)
    move $t8, $v0             # Number of bytes read

    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
     li $v0, 13                # Syscall for open
    la $a0, output_filename          # File name
    li $a1, 1                 # Open for writing 
    syscall
    move $t1, $v0             # Save file descriptor
    
    # Step 4: Write the existing content (from buffer) back to the file
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer          # Address of the buffer (previous file content)
    move $a2, $t8             # Number of bytes read (from previous syscall)
    syscall
    
     # Step 6: Write the converted string to the file
      li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1,X_equal         # Address of the x_lAabel
    li $a2, 3             # Length of the empty line
    syscall                   # Perform the write
   
    li $v0, 15          # Syscall for write
    move $a0, $t1       # File descriptor
    la $a1, str            # Address of the string to write
    li $a2, 9            # Length of the string 
    syscall             # Perform the write syscall
    # Step 5: Write an empty line to separate previous content from new content
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, emptyLine         # Address of the empty line string
    li $a2, 1                 # Length of the empty line
    syscall                   # Perform the write
   
    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
    #+++++++++++++++++++++++++++++++++++++#
    
      # ========== Calculate det(y) ==========

    # First term of det(y)
    lw $t7, 4($s3)       # d2
    lw $t5, 8($s2)       # a33
    mul $t7, $t7, $t5    # t7 = d2 * a33

    lw $t5, 4($s2)       # a23
    lw $s4, 8($s3)       # d3
    mul $s4, $t5, $s4    # s4 = d3 * a23
    sub $t7, $t7, $s4    # t7 = (d2 * a33 - d3 * a23)

    lw $s4, 0($s0)       # a11
    mul $s6, $s4, $t7    # s6 = a11 * (d2 * a33 - d3 * a23)

    # Second term of det(y)
    lw $s5, 4($s0)       # a21
    lw $t7, 8($s2)       # a33
    mul $s4, $s5, $t7    # s4 = d2 * a33

    lw $t7, 8($s0)       # a31
    lw $s5, 4($s2)       # a23
    mul $t7, $t7, $s5    # t7 = d3 * a23
    sub $t7, $s4, $t7    # t7 = (d2 * a33 - d3 * a23)

    lw $s4, 0($s3)       # d1
    mul $t7, $s4, $t7    # t7 = a12 * (d2 * a33 - d3 * a23)
    sub $s6, $s6, $t7    # s6 -= (second term)
    # Third term of det(y)
    lw $s5, 8($s3)       # d3
    lw $s4, 4($s0)       # a21
    mul $t7, $s5, $s4    # t7 = d2 * a32

    lw $s5, 4($s3)       # d2
    lw $s4, 8($s0)       # a22
    mul $s4, $s5, $s4    # s4 = d3 * a22
    sub $t7, $t7, $s4    # t7 = (d2 * a32 - d3 * a22)

    lw $s4, 0($s2)       # a13
    mul $s4, $s4, $t7    # s4 = a13 * (d2 * a32 - d3 * a22)
    add $s5, $s6, $s4    # det(y) = first term + second term + third term
    # ========== Calculate det(y) / det(A) ==========

    # Assume det(y) is stored in $s5 (integer), det(A) is in $s7 (integer)
    mtc1 $s5, $f0       # Move det(y) to $f0 (float)
    mtc1 $s7, $f1       # Move det(A) to $f1 (float)
    cvt.s.w $f0, $f0    # Convert det(y) to float
    cvt.s.w $f1, $f1    # Convert det(A) to float

    div.s $f2, $f0, $f1 # f2 = det(y) / det(A)
    jal Reverse_function 
     #+++++++++++++++++++++++++++++++++++++#
    # Step 1: Open file for reading to check if it exists
    li $v0, 13                # Syscall for open
    la $a0, output_filename       # File name
    li $a1, 0                  # Open for reading (O_RDONLY)
    syscall
    move $t1, $v0             # Save file descriptor

    # Check if file opened successfully
    bltz $t1, open_error      # If $t1 < 0, handle error (file does not exist)
    # Step 2: Read the entire content of the file into the buffer
    li $v0, 14                # Syscall for read
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer        # Address of buffer to store file content
    li $a2, 1024              # Number of bytes to read (adjust buffer size if needed)
    syscall

    # Save the number of bytes read (this will be used when writing back the data)
    move $t8, $v0             # Number of bytes read

    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
     li $v0, 13                # Syscall for open
    la $a0, output_filename          # File name
    li $a1, 1                 # Open for writing 
    syscall
    move $t1, $v0             # Save file descriptor
    
    # Step 4: Write the existing content (from buffer) back to the file
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer          # Address of the buffer (previous file content)
    move $a2, $t8             # Number of bytes read (from previous syscall)
    syscall
     # Step 6: Write the converted string to the file
      li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1,Y_equal         # Address of the x_lAabel
    li $a2, 3             # Length of the empty line
    syscall                   # Perform the write
   
    li $v0, 15          # Syscall for write
    move $a0, $t1       # File descriptor
    la $a1, str            # Address of the string to write
    li $a2, 9            # Length of the string 
    syscall             # Perform the write syscall
    # Step 5: Write an empty line to separate previous content from new content
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, emptyLine         # Address of the empty line string
    li $a2, 1                 # Length of the empty line
    syscall                   # Perform the write
   
    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
    #+++++++++++++++++++++++++++++++++++++#
  # ========== Calculate det(z) ==========


# First term of det(z)
lw $t7, 4($s1)       # a22
lw $t5, 8($s3)       # d3
mul $t7, $t7, $t5    # t7 = a22 * d3

lw $t5, 4($s3)       # d2
lw $s4, 8($s1)       # a32
mul $s4, $t5, $s4    # s4 = a32 * d2
sub $t7, $t7, $s4    # t7 = (a22 * d3 - a32 * d2)

lw $s4, 0($s0)       # a11
mul $s6, $s4, $t7    # s6 = a11 * (a22 * d3 - a32* d2)

# Second term of det(z)
lw $s5, 4($s0)       # a21
lw $t7, 8($s3)       # d3
mul $s4, $s5, $t7    # s4 = a21 * d3

lw $t7, 4($s3)       # d2
lw $s5, 8($s0)       # a31
mul $t7, $t7, $s5    # t7 = d1 * a31
sub $t7, $s4, $t7    # t7 = (a21 * d3 - d1 * a31)

lw $s4, 0($s1)       # a12
mul $t7, $s4, $t7    # t7 = a12 *(a21 * d3 - d1 * a31)
sub $s6, $s6, $t7    # s6 -= second term

# Third term of det(z)1
lw $s5, 4($s0)       # a21
lw $s4, 8($s1)       # a32
mul $t7, $s5, $s4    # t7 = a32* d2

lw $s5, 8($s0)       # a31
lw $s4, 4($s1)       # a22
mul $s4, $s5, $s4    # s4 = a31 * a22
sub $t7, $t7, $s4    # t7 = (a32* d2 - a31 * a22)

lw $s4, 0($s3)       # d1
mul $s4, $s4, $t7    # s4 = d1* (a32* d2 - a31 * a22)
add $s5, $s6, $s4    # det(z) = first term + second term + third term

# Calculate Z = det(z) / det(A)
# Assume det(z) is stored in $s5 (integer), det(A) is in $s7 (integer)

# Convert det(z) (integer in $s5) and det(A) (integer in $s7) to float
mtc1 $s5, $f0       # Move det(z) to $f0 (float)
mtc1 $s7, $f1       # Move det(A) to $f1 (float)

# Convert the integers to floating-point
cvt.s.w $f0, $f0    # Convert det(z) to float
cvt.s.w $f1, $f1    # Convert det(A) to float

# Perform the division: Z = det(z) / det(A)
div.s $f2, $f0, $f1 # f2 = det(z) / det(A)
jal Reverse_function 
 #+++++++++++++++++++++++++++++++++++++#
    # Step 1: Open file for reading to check if it exists
    li $v0, 13                # Syscall for open
    la $a0, output_filename       # File name
    li $a1, 0                  # Open for reading (O_RDONLY)
    syscall
    move $t1, $v0             # Save file descriptor

    # Check if file opened successfully
    bltz $t1, open_error      # If $t1 < 0, handle error (file does not exist)
    # Step 2: Read the entire content of the file into the buffer
    li $v0, 14                # Syscall for read
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer        # Address of buffer to store file content
    li $a2, 1024              # Number of bytes to read (adjust buffer size if needed)
    syscall

    # Save the number of bytes read (this will be used when writing back the data)
    move $t8, $v0             # Number of bytes read

    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
     li $v0, 13                # Syscall for open
    la $a0, output_filename          # File name
    li $a1, 1                 # Open for writing 
    syscall
    move $t1, $v0             # Save file descriptor
    
    # Step 4: Write the existing content (from buffer) back to the file
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, outout_file_buffer          # Address of the buffer (previous file content)
    move $a2, $t8             # Number of bytes read (from previous syscall)
    syscall

    ##############################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        la $t1, Z_equal           # Load address of Z_equal
    la $t9, output_file_buffer_2
    li $t6, 3                 # Number of bytes to copy from Z_equal
    add $t9, $t9, $t8         # Adjust $t9 by the number of bytes in $t8

copy_loop:
    lb $t5, 0($t1)            # Load byte from Z_equal
    sb $t5, 0($t9)            # Store byte to output_file_buffer_2
    addi $t1, $t1, 1          # Increment pointer to Z_equal
    addi $t9, $t9, 1          # Increment pointer to output_file_buffer_2
    subi $t6, $t6, 1          # Decrement counter
    bnez $t6, copy_loop       # Repeat until all bytes copied

    # Copy from str to the buffer
    la $t1, str               # Load address of str
    li $t6, 9                 # Number of bytes to copy from str
    add $t9, $t9, $t8         # Adjust $t9 by the number of bytes in $t8

copy_loop_2:
    lb $t5, 0($t1)            # Load byte from str
    sb $t5, 0($t9)            # Store byte to output_file_buffer_2
    addi $t1, $t1, 1          # Increment pointer to str
    addi $t9, $t9, 1          # Increment pointer to output_file_buffer_2
    subi $t6, $t6, 1          # Decrement counter
    bnez $t6, copy_loop_2     # Repeat until all bytes copied

    # Store newline character
    li $t5, 10                # Load newline character (\n)
    sb $t5, 0($t9)            # Store newline at next position in buffer

    ##############################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     # Step 6: Write the converted string to the file
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1,Z_equal         # Address of the x_lAabel
    li $a2, 3             # Length of the empty line
    syscall                   # Perform the write
   
    li $v0, 15          # Syscall for write
    move $a0, $t1       # File descriptor
    la $a1, str            # Address of the string to write
    li $a2, 9            # Length of the string 
    syscall             # Perform the write syscall
    # Step 5: Write an empty line to separate previous content from new content
    li $v0, 15                # Syscall for write
    move $a0, $t1             # File descriptor
    la $a1, emptyLine         # Address of the empty line string
    li $a2, 1                 # Length of the empty line
    syscall                   # Perform the write
   
    # Close the file after reading
    li $v0, 16                # Syscall for close
    move $a0, $t1             # File descriptor
    syscall
    #+++++++++++++++++++++++++++++++++++++#
j back_from_solve
    
infinity_solutions_2:
    # Print "there are infinity solutions"
    la $a0, message       # Load address of message string
    li $v0, 4             # syscall for print string
    syscall               # Print the message

    # Optionally, you can stop the program here by exiting.
    li $v0, 10            # Exit syscall
    syscall
    
    file_error_2_:
    li $v0, 4
    la $a0, error_message  # Error message
    syscall
    li $v0, 10         # Exit system call
    syscall
######################################################################33
 # Load the floating-point number into $f0
Reverse_function:
      mov.s   $f0, $f2                 # Input number already in $f12, move to $f0

    # Load precision into $a1
    la      $a1, precision
    lw      $a1, 0($a1)

    # Prepare address for the output string
    la      $a2, str

    # Load 0.0 into $f1 for comparison
    la      $a0, zero                # Load address of 0.0 into $a0
    lwc1    $f1, 0($a0)              # Load 0.0 from memory to $f1

    # Check if the number is negative
    c.lt.s  $f0, $f1                 # Compare if number is negative
    bc1f    positive_case            # If positive, skip the negative handling

    # If the number is negative, store '-' at the beginning of the string
    li      $t8, 45                  # ASCII for '-'
    sb      $t8, 0($a2)              # Store '-' at the start of the string
    addi    $a2, $a2, 1              # Move pointer to the next position
    neg.s   $f0, $f0                 # Make the number positive

positive_case:
    # Step 1: Extract integer part
    cvt.w.s $f2, $f0                 # Convert the float to integer in $f2
    mfc1    $t1, $f2                 # Move the integer part to $t1
    move    $t3, $a2                 # Save the address of the string for later

    # Step 2: Convert integer part to string (stored in reverse order)
    beqz    $t1, handle_zero

convert_integer:
    divu    $t4, $t1, 10             # Divide integer part by 10
    mfhi    $t8                      # Get remainder (last digit)
    addi    $t8, $t8, 48             # Convert digit to ASCII ('0' + digit)
    sb      $t8, 0($a2)              # Store the digit in reverse order
    addi    $a2, $a2, 1              # Move pointer to next position
    move    $t1, $t4                 # Update the integer part
    bnez    $t1, convert_integer     # Repeat until all digits are processed

    j       reverse_integer

handle_zero:
    li      $t8, 48                  # ASCII for '0'
    sb      $t8, 0($a2)              # Store '0'
    addi    $a2, $a2, 1              # Move pointer to next position

reverse_integer:
    # Reverse the integer part of the string
    move    $t4, $a2                 # Save address of end of string
    subi    $t4, $t4, 1              # Move to the last character (one position before the null terminator)
    move    $t5, $t3                 # Pointer to the start of the string

reverse_integer_loop:
    bge     $t5, $t4, reverse_integer_done  # Stop when the pointers meet or cross
    lb      $t8, 0($t5)              # Load character from the start
    lb      $t1, 0($t4)              # Load character from the end
    sb      $t1, 0($t5)              # Swap: Store end character at the start
    sb      $t8, 0($t4)              # Swap: Store start character at the end
    addi    $t5, $t5, 1              # Move forward pointer
    subi    $t4, $t4, 1              # Move backward pointer
    j       reverse_integer_loop

reverse_integer_done:
    nop                               # Reversal complete

    # Step 3: Add decimal point if precision is greater than zero
    lw      $t8, precision
    beqz    $t8, no_fraction         # If no precision, skip the fraction part
    li      $t1, 46                  # ASCII for '.'
    sb      $t1, 0($a2)              # Store '.' in the string
    addi    $a2, $a2, 1              # Move pointer

    # Step 4: Extract the fractional part
    sub.s   $f2, $f0, $f1            # Subtract integer part from the original float to get the fractional part
    l.s     $f3, scale_factor        # Load scale factor (1000.0) into $f3
    mul.s   $f2, $f2, $f3            # Multiply the fractional part by 1000.0 to shift the decimal
    trunc.w.s  $f2, $f2              # Truncate the scaled fractional part to integer
    mfc1    $a0, $f2                 # Move the fractional part to $a0 (general-purpose register)

    # Step 5: Convert the fractional part to string (only 3 digits after the decimal)
    li      $t7, 3                   # Limit to 3 digits for the fractional part
    move    $t6, $a2                 # Save the pointer to the start of the fractional part
fraction_convert:
    divu    $a0, $a0, 10            # Divide fractional part by 10
    mfhi    $t2                      # Get remainder (last digit)
    addi    $t2, $t2, 48             # Convert digit to ASCII
    sb      $t2, 0($a2)              # Store the digit in the string
    addi    $a2, $a2, 1              # Move to next position
    mflo    $a0                      # Update $a0 with the quotient (integer part)
    subi    $t7, $t7, 1              # Decrease the number of remaining digits
    bnez    $t7, fraction_convert    # Repeat if we haven't reached 3 digits

    # Reverse the fractional part
    move    $t4, $a2                 # Pointer to end of the fractional part
    subi    $t4, $t4, 1              # Move to the last digit of the fractional part
    move    $t5, $t6                 # Pointer to the start of the fractional part

reverse_fraction_loop:
    bge     $t5, $t4, reverse_fraction_done  # Stop when the pointers meet or cross
    lb      $t8, 0($t5)              # Load character from the start
    lb      $t1, 0($t4)              # Load character from the end
    sb      $t1, 0($t5)              # Swap: Store end character at the start
    sb      $t8, 0($t4)              # Swap: Store start character at the end
    addi    $t5, $t5, 1              # Move forward pointer
    subi    $t4, $t4, 1              # Move backward pointer
    j       reverse_fraction_loop

reverse_fraction_done:
    nop                               # Reversal complete

no_fraction:
    sb      $zero, 0($a2)            # Null-terminate the string
  jr $ra
####################################################################################  
