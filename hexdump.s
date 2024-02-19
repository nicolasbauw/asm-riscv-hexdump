.global _start
.global line_buffer

.equ BUF_SIZE,4096

.text

_start:
    ld      t0,(sp)             # argc
    li      t1,2
    li      a0,-1               # Error code if less than 2 args
    blt     t0,t1,exit          # Less than 2 args ? we exit

    li      a0,-100             # AT_FDCWD
    ld      a1,16(sp)           # argv[1]
    li      a2,0                # flags
    li      a3,0                # mode
    li      a7,56               # "openat" system call
    ecall
    blt     a0,x0,exit          # Error ? we exit

    mv      s7,a0               # we save the file descriptor in s7
    li      a1,0                # offset
    li      a2,2                # SEEK_END
    li      a7,62               # "lseek" system call
    ecall
    blt     a0,x0,close_exit    # Error ? we close the FD and exit
    mv      t6,a0               # we save the file size in t6

    mv      a0,s7               # first argument : the file descriptor (saved in s7)
    li      a1,0                # offset
    li      a2,0                # SEEK_SET
    li      a7,62               # "lseek" system call
    ecall
    blt     a0,x0,close_exit    # Error ? we close the FD and exit

hexdump:
    mv      a0,s7               # Opened FD
    la      a1,buffer
    li      a2,BUF_SIZE         # we read 4096 bytes and store them to the buffer
    li      a7,63               # "read" system call
    ecall
    mv      t4,a0               # Saving number of read bytes to t4

    la      t5,buffer           # t5 = Pointer to the bytes buffer
print_all_lines:
    mv      a0,t5               # a0 = argument for print_lines function
    jal     print_line          # Prints a 16 bytes line
    addi    t4,t4,-16           # Decrementing number of bytes to process
    blt     t4,x0,close_exit    # EOF ? close FD and exit
    beq     t4,x0,hexdump       # End of buffer ? We read the next 4096 bytes
    
    addi    t5,t5,16            # Preparing buffer pointer for next 16 bytes
    j       print_all_lines     # Continue processing lines until the end of the 4096-bytes buffer

close_exit:
    mv      a0,s7               # file descriptor was saved in s7
    li      a7,57               # "close" system call
    ecall

exit:
    li  a7,93                   # "exit" system call
    ecall


.lcomm line_buffer,49
.lcomm buffer,BUF_SIZE
