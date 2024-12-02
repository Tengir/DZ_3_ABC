.include "macroslib.s"

.data
    output:     .space 512       # Buffer for output strings
    nl:         .asciz "\n"      # Newline character
    res_file:   .space 256       # Buffer for output file name
    end_buff:   .space 12        # Buffer for converted numbers (max 10 digits + null terminator)

.text
.globl write_registers_to_file

###############################################################
# Function: write_registers_to_file
# Writes the values of two registers to a file.
# Parameters:
#   a0 - value of the first register
#   a1 - value of the second register
###############################################################

write_registers_to_file:
    PUSH(ra)                     # Save return address to stack
    PUSH(a0)
    PUSH(a1)
    PUSH(a2)
    PUSH(a3)
    PUSH(s0)
    PUSH(s1)
    PUSH(s2)
    PUSH(s3)

    # Save register values
    mv s0, a0                    # s0 = value of the first register (lowercase)
    mv s1, a1                    # s1 = value of the second register (uppercase)

    # Request output file name
    la s2, res_file              # s2 = buffer for file name
    READ_STR("Enter output file name: ", s2)
    mv t5, s2                    # t5 = pointer to file name

    # Remove newline character ('\n') from the file name
remove_newline:
    lb t6, 0(t5)                 # Read current byte
    beqz t6, open_file           # If end of string, proceed to open file
    li t3, '\n'                  # t3 = newline character
    beq t6, t3, replace_null     # If '\n' is found, replace with null terminator
    addi t5, t5, 1               # Move to the next character
    j remove_newline

replace_null:
    sb zero, 0(t5)               # Replace '\n' with null terminator

open_file:
    # Open file for writing
    li a7, 1024                 # syscall: open
    mv a0, s2                   # File name
    li a1, 1                    # Flag: open for writing
    ecall
    mv s3, a0                   # Save file descriptor

    # Convert the first number to a string
    la a3, end_buff             # a3 = pointer to buffer for the number
    li a2, 0                    # a2 = character count
    mv a0, s0                   # a0 = number to convert
    INT_TO_STR(a0, a3, a2, a0)  # Convert number, result in a0 (string address), length in a2

    # Write the first number to the file
    mv a1, a0                   # Pointer to the number string
    mv a2, a2                   # Length of the number string
    li a7, 64                   # syscall: write
    mv a0, s3                   # File descriptor
    ecall

    # Write newline character
    la a1, nl                   # Pointer to newline character
    li a2, 1                    # String length
    li a7, 64                   # syscall: write
    mv a0, s3                   # File descriptor
    ecall

    # Convert the second number to a string
    la a3, end_buff             # a3 = pointer to buffer for the number
    li a2, 0                    # a2 = character count
    mv a0, s1                   # a0 = number to convert
    INT_TO_STR(a0, a3, a2, a0)  # Convert number, result in a0 (string address), length in a2

    # Write the second number to the file
    mv a1, a0                   # Pointer to the number string
    mv a2, a2                   # Length of the number string
    li a7, 64                   # syscall: write
    mv a0, s3                   # File descriptor
    ecall

    # Write newline character
    la a1, nl                   # Pointer to newline character
    li a2, 1                    # String length
    li a7, 64                   # syscall: write
    mv a0, s3                   # File descriptor
    ecall

    # Close the file
    li a7, 57                   # syscall: close
    mv a0, s3                   # File descriptor
    ecall
    
    PULL(s3)
    PULL(s2)
    PULL(s1)
    PULL(s0)
    PULL(a3)
    PULL(a2)
    PULL(a1)
    PULL(a0)
    PULL(ra)                    # Restore return address
    ret                         # Return from function
