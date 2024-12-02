# Reading text from a file specified by the prompt

.include "macroslib.s"        # Include the macros library

.eqv PATH_SIZE, 256           # Buffer size for the file name
.eqv TEXT_SIZE, 512           # Buffer size for text

.data
    file_name:      .space PATH_SIZE      # Buffer for the file name
    strbuf:         .space TEXT_SIZE      # Buffer for text
    prompt:         .asciz "Enter the file path: "  # Prompt for file path input
    ends:           .asciz "Display results in console? Y or N: " # Prompt for console output choice
    small_letters_msg: .asciz "Number of lowercase letters: "
    capital_letters_msg: .asciz "Number of uppercase letters: "
    newline:        .asciz "\n"                     # Newline character
    incorrect_input_msg: .asciz "Invalid input!\n"

.text
.globl main

###############################################################
# Main program
###############################################################

main:
    # Initialize pointers
    la s0, file_name          # s0 = pointer to file name buffer
    la s1, strbuf             # s1 = pointer to text buffer

    # File reading
    mv a0, s0                 # Pass pointer to file name
    mv a1, s1                 # Pass pointer to reading buffer
    jal read_file             # Call file reading function

    # Counting lowercase and uppercase letters
    jal count_letters         # Call the letter counting function
    mv s2, a0                 # Save lowercase count in s2
    mv s3, a1                 # Save uppercase count in s3

    jal write_registers_to_file  # Call function to save results in a file

    # Display results
    # Offer user a choice
    CPRINT_STR(ends)               # a0 = pointer to the prompt message

    # Input character
    li a7, 12                 # System call: read a character
    ecall
    mv t0, a0                 # t0 = character entered by user

    # Check entered character
    li t1, 'Y'
    li t2, 'y'
    beq t0, t1, display_results   # If 'Y', go to result display
    beq t0, t2, display_results   # If 'y', go to result display

    li t1, 'N'
    li t2, 'n'
    beq t0, t1, end               # If 'N', end the program
    beq t0, t2, end               # If 'n', end the program

    # Message for invalid input
    CPRINT_STR(incorrect_input_msg)    # a0 = invalid input message
    j end                              # Jump to program termination

display_results:
    # Display results in the console
    CPRINT_STR(newline)
    CPRINT_STR(small_letters_msg)

    mv a0, s2                     # Get lowercase letter count from s2
    PRINT_INT(a0)                 # Print the number

    CPRINT_STR(newline)
    CPRINT_STR(capital_letters_msg)

    mv a0, s3                     # Get uppercase letter count from s3
    PRINT_INT(a0)                 # Print the number
    CPRINT_STR(newline)

end:
    li a7, 10                     # Exit the program
    ecall
