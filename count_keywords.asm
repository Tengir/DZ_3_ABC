.include "macroslib.s"

.text
.globl count_letters

###############################################################
# Function: count_letters
# Counts the number of lowercase and uppercase English letters in a text.
# Parameters:
#   a0 - pointer to the text
# Returns:
#   a0 - number of lowercase English letters
#   a1 - number of uppercase English letters
###############################################################

count_letters:
    # Initialize counters
    li t0, 0                # t0 = lowercase letter counter
    li t1, 0                # t1 = uppercase letter counter
    mv t2, a0               # t2 = pointer to the current character in the text

count_loop:
    lb t3, 0(t2)            # t3 = current character
    beqz t3, count_end      # If end of string (null character) is reached, jump to end

    # Check for lowercase letter ('a' to 'z')
    li t4, 'a'              # t4 = 'a'
    li t5, 'z'              # t5 = 'z'
    blt t3, t4, check_uppercase   # If t3 < 'a', jump to uppercase letter check
    bgt t3, t5, check_uppercase   # If t3 > 'z', jump to uppercase letter check

    # Character is a lowercase letter
    addi t0, t0, 1          # Increment lowercase letter counter
    j next_char             # Jump to the next character

check_uppercase:
    # Check for uppercase letter ('A' to 'Z')
    li t4, 'A'              # t4 = 'A'
    li t5, 'Z'              # t5 = 'Z'
    blt t3, t4, next_char   # If t3 < 'A', jump to the next character
    bgt t3, t5, next_char   # If t3 > 'Z', jump to the next character

    # Character is an uppercase letter
    addi t1, t1, 1          # Increment uppercase letter counter

next_char:
    addi t2, t2, 1          # Move to the next character
    j count_loop            # Repeat the loop

count_end:
    mv a0, t0               # Return the number of lowercase letters in a0
    mv a1, t1               # Return the number of uppercase letters in a1
    ret                     # Return from the function
