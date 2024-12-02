.include "macroslib.s"

.data
    # Test strings
    test1: .asciz ""                          # Empty string for testing
    test2: .asciz "Hello World"               # String with lowercase and uppercase letters
    test3: .asciz "This is a TEST string."    # Another test string
    test4: .asciz "12345!@#$%"                # String without letters

    newline:        .asciz "\n"               # Newline character
    separator:      .asciz "\n===================================\n\n"  # Separator between tests

    test_string_msg:    .asciz "Test string: "
    small_letters_msg:  .asciz "Number of lowercase letters: "
    capital_letters_msg: .asciz "Number of uppercase letters: "

.text
###############################################################
# Function: autotest
# Sequentially performs tests for the test strings (test1, test2, test3, test4).
###############################################################

autotest:
    # Test for the first string
    la s1, test1              # s1 = pointer to the first test string
    jal test                  # Call the test function

    # Test for the second string
    la s1, test2              # s1 = pointer to the second test string
    jal test                  # Call the test function

    # Test for the third string
    la s1, test3              # s1 = pointer to the third test string
    jal test                  # Call the test function

    # Test for the fourth string
    la s1, test4              # s1 = pointer to the fourth test string
    jal test                  # Call the test function

    # End of the program
    li a7, 10                 # System call: exit
    ecall

###############################################################
# Function: test
# Counts the number of lowercase and uppercase letters in the given string,
# saves the results, and outputs them to the console.
###############################################################

test:
    PUSH(ra)                  # Save return address

    # Count letters in the test string
    mv a0, s1                 # a0 = pointer to the test string
    jal count_letters         # Call the letter counting function

    # Results are in a0 (number of lowercase letters) and a1 (number of uppercase letters)

    # Save the results in registers
    mv s2, a0                 # s2 = number of lowercase letters
    mv s3, a1                 # s3 = number of uppercase letters

    # Write the results to a file
    mv a0, s2                 # a0 = number of lowercase letters
    mv a1, s3                 # a1 = number of uppercase letters
    jal write_registers_to_file  # Call the file writing function

    # Output results to the console
    CPRINT_STR(test_string_msg)    # Print message "Test string: "
    CPRINT_STR_ADRESS(s1)          # Print the test string itself
    CPRINT_STR(newline)            # Newline

    CPRINT_STR(small_letters_msg)  # Print message "Number of lowercase letters: "
    mv a0, s2                     # Number of lowercase letters
    PRINT_INT(a0)                 # Print the number
    CPRINT_STR(newline)            # Newline

    CPRINT_STR(capital_letters_msg)  # Print message "Number of uppercase letters: "
    mv a0, s3                     # Number of uppercase letters
    PRINT_INT(a0)                 # Print the number
    CPRINT_STR(newline)            # Newline

    # Separator between tests
    CPRINT_STR(separator)

    PULL(ra)                      # Restore return address
    ret                           # Return from the function
