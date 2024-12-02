###############################################################
# Macro: PRINT_INT
# Outputs an integer.
# %x - register containing the integer to be printed
###############################################################
.macro PRINT_INT(%x)
    li a7, 1          # System call for printing an integer
    mv a0, %x         # Move the integer into a0
    ecall
    li a0, 32         # ASCII space character
    li a7, 11         # System call for printing a character
    ecall
.end_macro

###############################################################
# Macro: READ_STR
# Reads a string from user input.
# %x - prompt message to display
# %y - address of the buffer for storing the input string
###############################################################
.macro READ_STR(%x, %y)
.data
str: .asciz %x        # String for the input prompt
.text
    la a0, str        # Load address of the prompt message
    mv a1, %y         # Move address of the buffer into a1
    li a2, 256        # Maximum allowed string length
    li a7, 54         # System call for reading a string
    ecall
.end_macro

###############################################################
# Macro: PRINT_STR
# Outputs a predefined string.
# %x - predefined string to be printed
###############################################################
.macro PRINT_STR(%x)
.data
empty_string: .asciz ""  # Empty string for spacing
str: .asciz %x           # String to be printed
.text
    la a1, empty_string  # Load address of the empty string
    li a7, 59            # System call for printing a string
    la a0, str           # Load address of the predefined string
    ecall
.end_macro

###############################################################
# Macro: CPRINT_STR
# Outputs a hardcoded string.
# %s - hardcoded string to be printed
###############################################################
.macro CPRINT_STR %s
    PUSH a0             # Save the current value of register a0
    la a0, %s           # Load the address of the hardcoded string
    li a7, 4            # System call for printing a string
    ecall               # Execute the system call
    PULL a0             # Restore the original value of a0
.end_macro

###############################################################
# Macro: CPRINT_STR_ADRESS
# Outputs a string stored at a specified memory address.
# %x - address of the string to be printed
###############################################################
.macro CPRINT_STR_ADRESS(%x)
.text
    li a7, 4            # System call for printing a string
    mv a0, %x            # Move the string address into a0
    ecall
.end_macro

###############################################################
# Macro: PRINT_STR_ADRESS
# Outputs a string stored at a specified memory address.
# %x - address of the string to be printed
###############################################################
.macro PRINT_STR_ADRESS(%x)
.data
empty_string: .asciz ""  # Empty string for spacing
.text
    la a1, empty_string  # Load address of the empty string
    li a7, 59            # System call for printing a string
    mv a0, %x            # Move the string address into a0
    ecall
.end_macro

###############################################################
# Macro: PUSH
# Saves a value onto the stack.
# %x - register containing the value to be saved
###############################################################
.macro PUSH(%x)
    addi sp, sp, -4      # Decrease the stack pointer
    sw %x, 0(sp)         # Store the value at the new stack position
.end_macro

###############################################################
# Macro: PULL
# Retrieves a value from the stack.
# %x - register to store the retrieved value
###############################################################
.macro PULL(%x)
    lw %x, 0(sp)         # Load the value from the top of the stack
    addi sp, sp, 4       # Increment the stack pointer
.end_macro

###############################################################
# Macro: INT_TO_STR
# Converts an integer into its string representation.
# %x - integer to be converted
# %y - buffer to store the resulting string
# %z - character counter
# %w - address of the resulting string
###############################################################
.macro INT_TO_STR(%x, %y, %z, %w)
int_to_str:
    li t0, 10            # Base of the number system (decimal)
    mv t4, %x            # Copy the integer to process
    mv t2, %y            # Pointer to the buffer's end
    sb zero, 0(t2)       # Add null terminator to the string
    addi t2, t2, -1      # Move back one position in the buffer

int_to_str_loop:
    addi %z, %z, 1       # Increment the character counter
    rem t3, t4, t0       # Get the remainder (current digit)
    addi t3, t3, '0'     # Convert digit to ASCII
    sb t3, 0(t2)         # Store the ASCII character in the buffer
    div t4, t4, t0       # Divide the number by the base
    addi t2, t2, -1      # Move back in the buffer
    bnez t4, int_to_str_loop  # Continue until no digits are left

    addi t2, t2, 1       # Adjust to the start of the string
    mv %w, t2            # Return the string address
.end_macro
