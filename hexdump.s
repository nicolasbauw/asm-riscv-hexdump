.global _start
.global line_buffer
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

    mv      t5,a0               # we save the file descriptor in t5
    li      a1,0                # offset
    li      a2,2                # SEEK_END
    li      a7,62               # "lseek" system call
    ecall
    blt     a0,x0,close_exit    # Error ? we close the FD and exit
    mv      t6,a0               # we save the file size in t6

    mv      a0,t5               # first argument : the file descriptor (saved in t5)
    li      a1,0                # offset
    li      a2,0                # SEEK_SET
    li      a7,62               # "lseek" system call
    ecall
    blt     a0,x0,close_exit    # Error ? we close the FD and exit

    mv      a0,t5               # Opened FD
    la      a1,buffer
    li      a2,64               # we read 64 bytes and store them to the buffer
    li      a7,63               # "read" system call
    ecall

    la      a0,buffer
    jal     print_line          # Print test line

close_exit:
    mv      a0,t5               # file descriptor was saved in t5
    li      a7,57               # "close" system call
    ecall

exit:
    li  a7,93                   # "exit" system call
    ecall


.lcomm line_buffer,48
.lcomm buffer,64
