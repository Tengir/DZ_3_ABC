.include "macroslib.s"

.eqv PATH_SIZE, 256               # Buffer size for the file name
.eqv TEXT_SIZE, 512               # Buffer size for the text

.text
.globl read_file

###############################################################
# Function: read_file
# Reads text from a file specified by the user via the console.
# Input:
#   a0 - pointer to the buffer for the file name
#   a1 - pointer to the buffer for the text
# Output:
#   a0 - pointer to the filled buffer
###############################################################

read_file:
    PUSH(s1)
    PUSH(s5)
    PUSH(s6)
    
    mv t0, a0                    # t0 = pointer to the buffer for the file name
    mv t1, a1                    # t1 = pointer to the buffer for the text

    # Input file name from the console
    READ_STR("Input file path: ", t0)

    # Remove newline ('\n') from the file name
    li t4, '\n'                  # t4 = newline character
    mv t5, t0                    # t5 = pointer to the start of the string

remove_newline:
    lb t6, (t5)                  # Read the current byte from the string
    beq t4, t6, replace_newline  # If it's '\n', replace with null terminator
    addi t5, t5, 1               # Otherwise, move to the next character
    b remove_newline

replace_newline:
    sb zero, (t5)                # Replace '\n' with null terminator (0)

    # Open the file
    li a7, 1024                  # syscall: open
    mv a0, t0                    # a0 = file name
    li a1, 0                     # Flag: open for reading
    ecall                        # Result: file descriptor in a0

    li t6, -1                    # t6 = error code (-1)
    beq a0, t6, path_error       # If opening failed, jump to path_error
    mv t5, a0                    # Save the file descriptor in t5

    ###########################################################
    # Reading file content into dynamic memory
    ###########################################################

    # Allocate dynamic memory for storing the text
    li a7, 9                     # syscall: sbrk (allocate memory)
    li a0, TEXT_SIZE             # Request memory of size TEXT_SIZE
    ecall
    mv s1, a0                    # s1 = start of allocated memory
    mv s5, a0                    # s5 = current pointer within memory
    li s6, 0                     # s6 = counter for bytes read

read:
    li a7, 63                    # syscall: read
    mv a0, t5                    # a0 = file descriptor
    mv a1, s5                    # a1 = current address for writing
    li a2, TEXT_SIZE             # a2 = maximum read size
    ecall
    li t1, -1                    # t1 = error code (-1)
    beq a0, t1, read_error       # If reading failed, jump to read_error
    beqz a0, end_read            # If 0 bytes read, end reading
    add s5, s5, a0               # Update memory pointer (s5 += a0)
    add s6, s6, a0               # Increase total byte counter (s6 += a0)
    j read                       # Continue reading

end_read:
    ###########################################################
    # Close the file
    ###########################################################
    li a7, 57                    # syscall: close
    mv a0, t5                    # a0 = file descriptor
    ecall                        # Close the file

    ###########################################################
    # Finalize the buffer
    ###########################################################
    add t0, s1, s6               # t0 = address of end of data (s1 + s6)
    sb zero, (t0)                # Write null terminator at the end of text

    # Print the address of the buffer for verification
    PRINT_STR_ADRESS(s1)
    mv a0, s1
    PULL(s6)
    PULL(s5)
    PULL(s1)
    ret                          # Return from function

###############################################################
# Error handlers
###############################################################

path_error:
    # Message for file opening error
    PRINT_STR("Incorrect file path\n")
    li a7, 10                    # Terminate the program
    ecall

read_error:
    # Message for file reading error
    PRINT_STR("Incorrect read operation\n")
    li a7, 10                    # Terminate the program
    ecall