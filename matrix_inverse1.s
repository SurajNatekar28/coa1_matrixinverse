    .data
N: .word 5                # Store the value of matrix size(order) at the label N

matrix:  # Define and initialize 9 floating-point numbers (N*N matrix)
    .float 2, 1, 3, 4, 5      # First row
    .float 1, 0, 4, 3, 2      # Second row
    .float 3, 4, 0, 1, 5      # Third row
    .float 4, 5, 1, 0, 3        #fourth row
    .float 5, 2, 1, 4, 0        #fifth row

identity:  .space 100          # Allocate space for 25 floating-point numbers (25 * 4 bytes)

matrix_cpy: .space 100

result_id: .space 100

address:    
        .float 0.0    # Reserve space in memory for storing the value  //needed for comparing zero to temp

newline_string: .asciiz "\n"
space_string: .asciiz "  "
decimal_string: .asciiz "."
existance: .asciiz "inverse of matrix does not exist"
negate: .asciiz "-"
print_zero: .asciiz "0"
print_inverse: .asciiz "inverse matrix A"
print_verify: .asciiz "verification matrix B"

    .text
    .globl _start
_start:

    lw     s11, N            #indicates working on N*N matrix          
    li     s10, 4            #needed to jump one place(next addresss) in matrix
    li     x0, 0
    mul    s9, s10, s11      #needed to jump places(one full row) in matrix       
    
    # Load the base addresses of matrix and result into registers
    la     a6, matrix        # Load the base address of matrix into a6
    la     a7, identity        # Load the base address of result into a7

    la    s8, address        # Load the address of 'address' into s8
    flw   f0, 0(s8)          #loading value 0.0 in register f0 to compare it with temp

    
 ###########################     creating identity matrix       ######################################################################
######################################################################################################################################

li     t1, 0             # Initialize loop counter t1 with 0        i=t1
loop_8:

li     t2, 0             # Initialize loop counter t2 with 0        j=t2
loop_9:

    mul t4, s9, t1              
    mul t5, s10, t2            
    add t4, t4, t5              #  effective offset
    add t5, t4, a7             # t5= effective address of identity Matrix element  //base address + effective offset of inverse matrix
    
    beq    t1, t2, store_1      #check if t1==t2 for making elements identity(1)

    li t0, 0                    # Load 0 (positive zero) into t0
    fcvt.s.w f1, t0             # Move the value in t0 to register f1
    fsw f1, 0(t5)              # Store the value in f1 into memory at the address t5
    j con_check

store_1:

    li t0, 1                    # Load 1  (one) into t0
    fcvt.s.w f1, t0             # Move the value in t0 to  register f1
    fsw f1, 0(t5)              # Store the value in f1 into memory at the address t5

con_check:
    addi    t2, t2, 1        # increment the loop counter by 1
    bne     t2, s11, loop_9    # Branch to loop if t2 is not equal to s11 (N iterations)

    addi    t1, t1, 1        # increment the loop counter by 1
    bne     t1, s11, loop_8    # Branch to loop if t1 is not equal to s11 (N iterations)


###########################     creating matrix copy      ######################################################################
#####################################################################################################################################

 # Load base addresses
    la t0, matrix               # Load address of original_matrix into t0
    la t1, matrix_cpy           # Load address of matrix_cpy into t1

    # Initialize counters
    li t2, 0                     # Initialize t2 = 0
    mul t4, s11, s11
    mv t3, t4                   # Total number of elements (N * N = t4)

copy_loop:
    beq t2, t3, end_copy         # Exit loop when all elements are copied

    flw f1, 0(t0)                # Load float from original matrix into f1
    fsw f1, 0(t1)                # Store float from f1 into matrix_cpy
    
    # Update pointers and counter
    addi t0, t0, 4               # Move to the next element in the original matrix
    addi t1, t1, 4               # Move to the next element in the matrix_cpy
    addi t2, t2, 1               # Increment element counter
    
    j copy_loop                  

end_copy:


################################################## outer loop for gaussian elemination  ############################################
####################################################################################################################################

    li     t0, 0             # Initialize loop counter t0 with 0  //for outer loop_1
   
loop_1:
   
    mul      t2, s9, t0          #	First load diagonal element into temp variable.
    mul      t3, s10, t0         
    add      t2, t2, t3              
    add      t2, t2, a6          
    flw      f1, 0(t2)           

    feq.s  s7, f1, f0       # Compare f1 with 0.0, result in s7 (1 if equal, 0 if not)   //s7=1 ->temp==0
    beq    s7, x0, endif1   # If s7 == 0, skip the if block (f0 is not equal to 0.0)  

    #code for temp==0 if condition becomes true needs to swap()
    #check for non-zero element insame column of different row
    addi s5, t0, 1         #assigning t=i+1 
    mv s6, t0              #assigning p=i
loop_condition:
    blt s5, s11, loop_body   # If s5 (t) is less than N(s11), branch to loop_body

    # Exit the while if the condition is false
    j end_loop

loop_body:
     #first load matrix[t][p] 
    mul      s4, s9, s5             # to skip one row
    mul      s3, s10, s6           #    to skip one one element in the row
    add      s4, s4, s3             
    add      s4, s4, a6          #   base address + effective offset
    flw      f11, 0(s4)           

     feq.s  s3, f11, f0         # Compare f11 with 0.0, result in s3 (1 if equal, 0 if not)   //s3=1 ->matrix[t][p]==0
    beq    s3, x0, endif3       # If s3 == 0(-->matrix[t][p]!=0) skip the if block (f11 is not equal to 0.0)


    addi s5, s5, 1           # else part of if under while loop
    # Jump back to the beginning of the loop to check the condition again
    j loop_condition

endif3:
     #write here code of swaprows() function here

    li s2,0             # Initialize loop counter s2 with 0     //for loop under swaprows() function loop_5

loop_5:
     mul a2, s9, t0           
    mul a3, s10, s2          
    add a2, a2, a3                 #  effective offset
    add a3, a2, a7             # a3 contain effective address of identity matrix element  //base address + effective offset
    add a2, a2, a6              #a2 contain effective address of matrix element   //base address + effective offset
    flw f12, 0(a2)               #loading matrix element in f12          //f12=matrix[i][j]
    flw f13, 0(a3)               #loading inverse matrix element in f13  //f13=inverse[i][j]

     mul a4, s9, s5          
    mul a5, s10, s2          
    add a4, a4, a5                 #  effective offset
    add a5, a4, a7             # a5 contain effective address of identity mtrix element    //base address + effective offset
    add a4, a4, a6              #a4 contain effective address of matrix element   //base address + effective offset
    flw f14, 0(a4)               #loading matrix element in f14          //f12=matrix[t][j]
    flw f15, 0(a5)               #loading inverse matrix element in f15  //f13=inverse[t][j]

    fsgnj.s f16, f12, f12           #temp1 = matrix[i][j];  
    fsgnj.s f12, f14, f14           # matrix[i][j] = matrix[t][j]; 
    fsgnj.s f14, f16, f16           # matrix[t][j] = temp1;  
    fsw f12, 0(a2)               #storing back the matrix element in place
    fsw f14, 0(a4)               #storing back the matrix element in place

    fsgnj.s f17, f13, f13           #temp2 = inverse[i][j];  
    fsgnj.s f13, f15, f15           # inverse[i][j] = inverse[t][j]; 
    fsgnj.s f15, f17, f17           # inverse[t][j] = temp2;  
    fsw f13, 0(a3)               #storing back the matrix element in place
    fsw f15, 0(a5)               #storing back the matrix element in place

    addi    s2, s2, 1        # increment the loop counter by 1
    bne     s2, s11, loop_5    # Branch to loop if s2 is not equal to s11 (N iterations) 
    #add break here
    j endif1  #breaks
end_loop:           #while loop ends

endif1:     #normal case temp!=0  ,,,,do loading temp operations same as above

    mul      t2, s9, t0             
    mul      t3, s10, t0         
    add      t2, t2, t3                      #  //effective offset
    add      t2, t2, a6           #   base address + effective offset
    flw      f1, 0(t2)           # loading diagonal element of matrix into temp

     feq.s  s7, f1, f0      # Compare f1 with 0.0, result in s7 (1 if equal, 0 if not)   //s7=1 ->temp==0
    beq    s7, x0, endif2   # If s7 == 0, skip the if block (f0 is not equal to 0.0)

    #code for temp==0 if condition becomes true needs to terminate program
    addi a0, x0, 4      # a0=4 to print string
    la a1, existance     #printf("inverse of matrix does not exist");
    ecall

    addi a0, x0, 4      # a0=4 to print string
    la a1, newline_string                  # Syscall code for print character
    ecall

    li     a0, 10            # Syscall for exit
    ecall                    # Make the syscall
###################################################################################################################################

endif2:

    li     t1, 0             # Initialize loop counter t1 with 0     //for inner loop_2
loop_2:
    #inner loop 2 for making diagonal elements identity

    mul t2, s9, t0           
    mul t3, s10, t1          
    add t2, t2, t3           #  effective offset

    add t3, t2, a7             #t3 contain effective address of identity matrix element    //base address + effective offset
    add t2, t2, a6             #t2 contain effective address of matrix element   //base address + effective offset
   
    flw f2, 0(t2)               #loading matrix element in f2
    flw f3, 0(t3)               #loading inverse matrix element in f3

    fdiv.s f2, f2, f1           #dividing matrix element by temp 
    fdiv.s f3, f3, f1           #dividing inverse matrix element by temp

    fsw f2, 0(t2)               #storing back the matrix element in place
    fsw f3, 0(t3)               #storing back the inverse matrix element in place

    addi    t1, t1, 1        # increment the loop counter by 1
    bne     t1, s11, loop_2    # Branch to loop if t1 is not equal to s11 (3 iterations)


    li     t1, 0             # Initialize loop counter t1 with 0     //for inner loop_3    k=t1,i=t0
loop_3:
    #one more inner loop to make remaining elements zero

    beq t1, t0, end          #comparing k and i 

    mul t2, s9, t1           #               like for temp=matrix[k][i]
    mul t3, s10, t0         
    add t2, t2, t3                      # //effective offset
    add      t2, t2, a6           #   base address + effective offset
    flw      f1, 0(t2)           # loading element of matrix into temp      temp=matrix[k][i]


    li     t2, 0             # Initialize loop counter t2 with 0     //for inner loop_4    j=t2,i=t0
loop_4:
    #one more inner loop to make remaining elements zero under loop_3

    mul t4, s9, t1              
    mul t5, s10, t2             
    add t4, t4, t5              #  effective offset

    add t5, t4, a7             # t5 contain effective address of inverse element  //base address + effective offset 
    add t4, t4, a6              #t4 contain effective address of matrix element   //base address + effective offset

    flw f2, 0(t4)               #loading matrix element in f2     //loading matirx[k][j]
    flw f3, 0(t5)                #loading inverse matrix element in f3       //loading inverse[k][j]

    mul t3, s9, t0
    mul t6, s10, t2
    add t3, t3, t6

    add t6, t3, a7
    add t3, t3, a6

    flw f4, 0(t3)               #loading matrix element in f4     //loading matirx[i][j]
    flw f5, 0(t6)                #loading matrix element in f5     //loading inverse[i][j]

    fmul.s f4, f4, f1           #multiply temp and matrix element and store it in f4 register  //matrix[i][j]*temp
    fmul.s f5, f5, f1           #multiply temp and matrix element and store it in f5 register  //inverse[i][j]*temp

    fsub.s f2, f2, f4           #substact operation on elements    //matrix[k][j]-matrix[i][j]*temp
    fsub.s f3, f3, f5           #same substract on inverse matrix   //inverse[k][j]-inverse[i][j]*temp

    fsw f2, 0(t4)               #storing back the matrix element in place
    fsw f3, 0(t5)               #storing back the inverse matrix element in place

    addi    t2, t2, 1        # increment the loop counter by 1
    bne     t2, s11, loop_4    # Branch to loop if t2 is not equal to s11 (3 iterations)

end:

    addi    t1, t1, 1        # increment the loop counter by 1
    bne     t1, s11, loop_3    # Branch to loop if t1 is not equal to s11 (3 iterations)


    addi    t0, t0, 1        # increment the loop counter by 1
    bne     t0, s11, loop_1    # Branch to loop if t0 is not equal to s11 (3 iterations)


############################################## Matrix verification ###################################################################
######################################################################################################################################
la s2, result_id
la s3, matrix_cpy

li     t1, 0             # Initialize loop counter t1 with 0     //for inner loop_3    i=t1
loop_10:

li     t2, 0             # Initialize loop counter t2 with 0     //for inner loop_4    j=t2
loop_11:

li     t3, 0
loop_12:

     mul t4, s9, t1           
    mul t5, s10, t3          
    add t4, t4, t5                
    add t4, t4, a7
    flw f1, 0(t4)           #loading element from identity

      mul t5, s9, t3           
    mul t6, s10, t2          
    add t5, t5, t6                
    add t5, t5, s3
    flw f2, 0(t5)           #loading element from original matrix           

     mul t6, s9, t1           
    mul s1, s10, t2          
    add t6, t6, s1                 
    add t6, t6, s2
    flw f3, 0(t6)

    fmul.s f1, f1, f2
    fadd.s f3, f3, f1
    fsw f3, 0(t6)           #storing element in result matrix

    addi    t3, t3, 1        # increment the loop counter by 1
    bne     t3, s11, loop_12    # Branch to loop if t3 is not equal to s11 (N iterations)
    
    addi    t2, t2, 1        # increment the loop counter by 1
    bne     t2, s11, loop_11    # Branch to loop if t2 is not equal to s11 (N iterations)

    addi    t1, t1, 1        # increment the loop counter by 1
    bne     t1, s11, loop_10    # Branch to loop if t1 is not equal to s11 (N iterations)


################################after all printing the result matrix##########################################################
##############################################################################################################################
 addi a0, x0, 4                           # a0=4 to print string
    la a1, print_inverse                  # Syscall code for print character
    ecall

 addi a0, x0, 4                            # a0=4 to print string
    la a1, newline_string                  # Syscall code for print character
    ecall


li     t1, 0             # Initialize loop counter t1 with 0     
loop_6:

li     t2, 0             # Initialize loop counter t2 with 0
loop_7:     

#now we are in for for loop for printing

    mul t4, s9, t1               
    mul t5, s10, t2             
    add t4, t4, t5              #  effective offset

    add t5, t4, a7             # t5 contain effective address of inverse element  

    flw f3, 0(t5)                #loading inverse matrix element in f3       

    
flt.s t6, f3, f0            #initially check number is negative or positive f0==0
# If f3 is less than 0.0
    bnez t6, initial_less_than_zero  # Branch if t6 is not zero (f3 < 0.0)

    #code if initial value f3>0 than zero
    fcvt.w.s a2, f3             # Convert f3 (float) to a2 (integer)
    fcvt.s.w f4, a2             #again take value into float register(f4)

    fsub.s f5, f3, f4          #subtracting to check

    feq.s s2, f5, f0            # Set s2 to 1 if f5 == 0.0, otherwise 0
    bnez s2, is_equal_int1       # If s2 is not zero (f5 == 0.0), branch to 'is_equal_int'

    flt.s t0, f5, f0        # t0 = (f5 < 0.0) ? 1 : 0

#condition checking for rounded off or not

# If f5 is less than 0.0
    bnez t0, less_than_zero1  # Branch if t0 is not zero (f5 < 0.0)

# Code if f5 >= 0.0
is_equal_int1:
    mv a1, a2                #do nothing just load into a1 to print

    fcvt.s.w f6, a1            #load integer value to float
    fsub.s f6, f3, f6           #take difference and store back to f6

    #going for value after decimal point
    # Multiply the fractional part by 10000 (for 4 decimal places)
    li a3, 10000
    fcvt.s.w f7, a3             # Convert 10000 to float in f7
    fmul.s f7, f7, f6           # f7 = fractional part * 10000

    # Convert the fractional part to integer
    fcvt.w.s a3, f7             # Convert the fractional part to integer in a3 

    li s7, 10000
    bne s7,a3 not_equal4        #checking for 9999 and 10000
    addi a3, a3, -1

not_equal4:

    j end_less_than_zero1_cond
    
less_than_zero1:
# Code if f5 < 0.0
    addi a1, a2, -1          #subtracting 1 to get correct integer

    fcvt.s.w f6, a1            #load integer value to float
    fsub.s f6, f3, f6           #take difference and store back to f6

    #going for value after decimal point
    # Multiply the fractional part by 10000 (for 3 decimal places)
    li a3, 10000
    fcvt.s.w f7, a3             # Convert 10000 to float in f6
    fmul.s f7, f7, f6           # f0 = fractional part * 10000

    # Convert the fractional part to integer
    fcvt.w.s a3, f7             # Convert the fractional part to integer in a3

    li s7, 10000
    bne s7,a3 not_equal1        #checking for 9999 and 10000
    addi a3, a3, -1

not_equal1:

    j end_initial_less_than_zero_cond

initial_less_than_zero:
 #so if the number obtain in register f3 is a negative number then

    fcvt.w.s a2, f3             # Convert f3 (float) to a2 (integer)
    fcvt.s.w f4, a2             #again take value into float register

    fsub.s f5, f3, f4          #subtracting to check
 
     feq.s s2, f5, f0           # Set s2 to 1 if f5 == 0.0, otherwise 0
    bnez s2, is_equal_int2       # If s2 is not zero (f5 == 0.0), branch to 'is_equal_int'

    flt.s t0, f5, f0        # t0 = (f5 < 0.0) ? 1 : 0

#condition checking for rounded off or not

# If f5 is less than 0.0
    bnez t0, less_than_zero2  # Branch if t0 is not zero (f5 < 0.0)

# Code if f5 >= 0.0
   addi a1, a2, 1          #adding 1 to get correct integer
  
    fcvt.s.w f6, a1            #load integer value to float
    fsub.s f6, f3, f6           #take difference and store back to f6

    #going for value after decimal point
    # Multiply the fractional part by 10000 (for 4 decimal places)
    li a3, 10000
    fcvt.s.w f7, a3             # Convert 10000 to float in f7
    fmul.s f7, f7, f6           # f7 = fractional part * 10000

    # Convert the fractional part to integer
    fcvt.w.s a3, f7             # Convert the fractional part to integer in a3

    li t5, -1        # Load -1 into register t5
    mul a3, a3, t5   # a3 = a3 * -1

    li s7, 10000
    bne s7,a3 not_equal2        #checking for 9999 and 10000
    addi a3, a3, -1

not_equal2:

 # Check if a1 is zero
    beq a1, x0, is_zero1  # If a1 == 0, branch to is_zero

    j end1

is_zero1:  
    # Print the minus sign
    addi a0, x0, 4                 # a0=4 to print string
    la a1, negate                  # Syscall code for print character
    ecall
    li a1, 0            #again load zero into register for printing
    end1:

    j end_less_than_zero2_cond
    
less_than_zero2:
# Code if f5 < 0.0
is_equal_int2:
    mv a1, a2                #do nothing just load into a1 to print

    fcvt.s.w f6, a1            #load integer value to float
    fsub.s f6, f3, f6           #take difference and store back to f6

    #going for value after decimal point
    # Multiply the fractional part by 10000 (for 4 decimal places)
    li a3, 10000
    fcvt.s.w f7, a3             # Convert 10000 to float in f7
    fmul.s f7, f7, f6           # f7 = fractional part * 10000

    # Convert the fractional part to integer
    fcvt.w.s a3, f7             # Convert the fractional part to integer in a3

    li t5, -1        # Load -1 into register t5
    mul a3, a3, t5   # a3 = a3 * -1

    li s7, 10000
    bne s7,a3 not_equal3        #checking for 9999 and 10000
    addi a3, a3, -1

not_equal3:
     # Check if a1 is zero
    beq a1, x0, is_zero2  # If a1 == 0, branch to is_zero

    j end2

is_zero2:
     # Print the minus sign
    addi a0, x0, 4      # a0=4 to print string
    la a1, negate                  # Syscall code for print character
    ecall
    li a1, 0            #again load zero into register for printing
    end2:

    j end_initial_less_than_zero_cond


end_less_than_zero1_cond:
end_less_than_zero2_cond:
end_initial_less_than_zero_cond:
    li a0, 1                    # Syscall number for print integer
    ecall                       # Print the integer part

    # Print the decimal point
    addi a0, x0, 4      # a0=4 to print string
    la a1, decimal_string                  # Syscall code for print character
    ecall

## Print the fractional part

#conditions for padding zeros to left
li s7, 10              # Load 10 into register s7
    blt a3, s7, less_than_10  # If a3 < s7, branch to 'less_than_10'
    j end_10

less_than_10:
     # Print the zero
    addi a0, x0, 4      # a0=4 to print string
    la a1, print_zero                  # Syscall code for print character
    ecall
    
end_10:
    li s7, 100              # Load 100 into register s7
    blt a3, s7, less_than_100  # If a3 < s7, branch to 'less_than_100'
    j end_100

less_than_100:
     # Print the zero
    addi a0, x0, 4      # a0=4 to print string
    la a1, print_zero                  # Syscall code for print character
    ecall

end_100:
     li s7, 1000              # Load 1000 into register s7
    blt a3, s7, less_than_1000  # If a3 < s7, branch to 'less_than_1000'
    j end_1000

less_than_1000:
     # Print the zero
    addi a0, x0, 4      # a0=4 to print string
    la a1, print_zero                  # Syscall code for print character
    ecall

end_1000: 
    mv a1, a3                   # Move the fractional part to a1
    li a0, 1                    # Syscall code for print integer
    ecall                       # Print the fractional part 

 # Print a space after each value
    addi a0, x0, 4      # a0=4 to print string
    la a1, space_string    # Load address of space string
    ecall

     addi    t2, t2, 1        # increment the loop counter by 1
    bne     t2, s11, loop_7    # Branch to loop if t2 is not equal to s11 (N iterations)

     # Print a newline after each row
    addi a0, x0, 4      # a0=4 to print string
    la a1, newline_string    # Load address of newline string
    ecall

    addi    t1, t1, 1        # increment the loop counter by 1
    bne     t1, s11, loop_6    # Branch to loop if t1 is not equal to s11 (N iterations)

################################ printing the verification matrix ##################################################################
####################################################################################################################################
addi a0, x0, 4      # a0=4 to print string
    la a1, newline_string                  # Syscall code for print character
    ecall

addi a0, x0, 4      # a0=4 to print string
    la a1, print_verify                  # Syscall code for print character
    ecall

 addi a0, x0, 4      # a0=4 to print string
    la a1, newline_string                  # Syscall code for print character
    ecall

la s5, result_id

li     t1, 0             # Initialize loop counter t1 with 0    
loop_13:

li     t2, 0             # Initialize loop counter t2 with 0     
loop_14:

#now we are in for for loop for printing

    mul t4, s9, t1              
    mul t5, s10, t2             
    add t4, t4, t5              #  effective offset

    add t5, t4, s5             # t5 contains (base address + effective offset) of result_id matrix

    flw f3, 0(t5)                #loading matrix element in f3     

    
flt.s t6, f3, f0            #initially check number is negative or positive f0==0
# If f0 is less than 0.0
    bnez t6, initial_less_than_zero_c  # Branch if t0 is not zero (f0 < 0.0)

    #code if initial value f3>0 than zero
    fcvt.w.s a2, f3             # Convert f3 (float) to a2 (integer)
  
# Code if f0 >= 0.0
    mv a1, a2                #do nothing just load into a1 to print

    fcvt.s.w f6, a1            #load integer value to float
    fsub.s f6, f3, f6           #take difference and store back to f6

    #going for value after decimal point
    # Multiply the fractional part by 10000 (for 4 decimal places)
    li a3, 10000
    fcvt.s.w f7, a3             # Convert 10000 to float in f7
    fmul.s f7, f7, f6           # f7 = fractional part * 10000

    # Convert the fractional part to integer
    fcvt.w.s a3, f7             # Convert the fractional part to integer in a3 

    j end_initial_less_than_zero_cond_c

initial_less_than_zero_c:
 #so if the number obtain in register f3 is a negative number then

    fcvt.w.s a2, f3             # Convert f2 (float) to a1 (integer)

# Code if f0 >= 0.0
    mv a1, a2                #do nothing just load into a1 to print

    fcvt.s.w f6, a1            #load integer value to float
    fsub.s f6, f3, f6           #take difference and store back to f6

    #going for value after decimal point
    # Multiply the fractional part by 10000 (for 4 decimal places)
    li a3, 10000
    fcvt.s.w f7, a3             # Convert 10000 to float in f7
    fmul.s f7, f7, f6           # f7 = fractional part * 10000

    # Convert the fractional part to integer
    fcvt.w.s a3, f7             # Convert the fractional part to integer in a3

    li t5, -1        # Load -1 into register t5
    mul a3, a3, t5   # a3 = a3 * -1

    j end_initial_less_than_zero_cond_c

end_initial_less_than_zero_cond_c:
    li a0, 1                    # Syscall number for print integer
    ecall                       # Print the integer part

    # Print the decimal point
    addi a0, x0, 4      # a0=4 to print string
    la a1, decimal_string                  # Syscall code for print character
    ecall

## Print the fractional part
#conditions for padding zeros to left
li s7, 10                               # Load 10 into register s7
    blt a3, s7, less_than_10_c          # If a3 < s7, branch to 'less_than_10'
    j end_10_c

less_than_10_c:                        # Print the zero
    
    addi a0, x0, 4                      # a0=4 to print string
    la a1, print_zero                  # Syscall code for print character
    ecall
    
end_10_c:
    li s7, 100                           # Load 100 into register s7
   blt a3, s7, less_than_100_c          # If a3 < s7, branch to 'less_than_100'
    j end_100_c

less_than_100_c:                         #  Print the zero
   
    addi a0, x0, 4                       # a0=4 to print string
    la a1, print_zero                    # Syscall code for print character
    ecall
      
end_100_c:
     li s7, 1000                        # Load 1000 into register s7
    blt a3, s7, less_than_1000_c        # If a3 < s7, branch to 'less_than_1000'
    j end_1000_c

less_than_1000_c:                        # Print the zero
    
    addi a0, x0, 4                       # a0=4 to print string
    la a1, print_zero                    # Syscall code for print character
    ecall

end_1000_c: 
    mv a1, a3                   # Move the fractional part to a1
    li a0, 1                    # Syscall code for print integer
    ecall                       # Print the fractional part 

    j end_is_equal_int_c
#print as it is integer
is_equal_int_c:
    mv a1, a2
    li a0, 1
    ecall

end_is_equal_int_c:
 # Print a space after each value
    addi a0, x0, 4      # a0=4 to print string
    la a1, space_string    # Load address of space string
    ecall

     addi    t2, t2, 1        # increment the loop counter by 1
    bne     t2, s11, loop_14    # Branch to loop if t2 is not equal to s11 (N iterations)

     # Print a newline after each row
    addi a0, x0, 4      # a0=4 to print string
    la a1, newline_string    # Load address of newline string
    ecall

    addi    t1, t1, 1        # increment the loop counter by 1
    bne     t1, s11, loop_13    # Branch to loop if t1 is not equal to s11 (N iterations)

   
    li     a0, 10            # Syscall for exit
    ecall                    # Make the syscall
