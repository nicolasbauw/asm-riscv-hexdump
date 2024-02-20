.global print_line
.global print_offset
.text

# Hex byte conversion to ascii
# input : a0 : byte to convert
# output : a0-a1 : byte converted to ascii (two characters)
byte_convert:

    andi    t0,a0,0xF0                  # MSB nibble
    srli    t0,t0,4                     # Right shift of the MSB
    andi    t1,a0,0x0F                  # LSB nibble
    li      t2,0x0A

# Converting nibble 1 (MSB)
    blt     t0,t2,convert_09_1
    addi    t0,t0,0x07                  # Converts A-F
convert_09_1:
    addi    a0,t0,0x30                  # Converts 0-9

# Converting nibble 2 (LSB)
    blt     t1,t2,convert_09_2
    addi    t1,t1,0x07                  # Converts A-F
convert_09_2:
    addi    a1,t1,0x30                  # Converts 0-9

    ret


# Prints on stdout a line of 16 bytes converted to ascii
# input : a0 : address of the 16 lines to convert
print_line:
    addi    sp,sp,-8                    # Saving return address on stack
    sd      ra,(sp)

    li      s1,16                       # Initialize counter
    li      s2,0x20                     # ascii space
    mv      s3,a0                       # Saves input buffer address to s3
    la      s4,line_buffer              # s4 = ascii output buffer address
    li      s5,0x0a                     # Line feed
loop:
    lb      a0,(s3)                     # Loads data byte from buffer
    jal     byte_convert                # Converts this byte to ascii values
    sb      a0,(s4)                     # First character of the byte (MSB)
    sb      a1,1(s4)                    # Second character of the byte (LSB)
    sb      s2,2(s4)                    # Space
    addi    s3,s3,1                     # Incrementing buffers pointers
    addi    s4,s4,3
    addi    s1,s1,-1                    # Decrementing counter
    bne     s1,x0,loop                  # 16 bytes processed ?
    sb      s5,(s4)                     # Inserting line feed at the end of the line buffer

    li      a0, 1                       # stdout
    la      a1, line_buffer             # Printing line_buffer
    la      a2, 49                      # buffer lenght
    li      a7, 64                      # "write" syscall
    ecall

    ld      ra,(sp)                     # Retrieve return address from stack
    addi    sp,sp,8
    ret

# Prints on stdout the offset of the displayed data
# input : the offset stored at (offset)
print_offset:
    addi    sp,sp,-8                    # Saving return address on stack
    sd      ra,(sp)

    la      a3,ascii_offset
    la      a4,offset

    lb      a0,3(a4)
    jal     byte_convert
    sb      a0,(a3)
    sb      a1,1(a3)

    lb      a0,2(a4)
    jal     byte_convert
    sb      a0,2(a3)
    sb      a1,3(a3)

    lb      a0,1(a4)
    jal     byte_convert
    sb      a0,4(a3)
    sb      a1,5(a3)

    lb      a0,(a4)
    jal     byte_convert
    sb      a0,6(a3)
    sb      a1,7(a3)

    li      a0,0x20
    sb      a0,8(a3)

    li      a0, 1                       # stdout
    la      a1, ascii_offset            # Printing line_buffer
    la      a2, 9                       # buffer lenght
    li      a7, 64                      # "write" syscall
    ecall

    ld      ra,(sp)                     # Retrieve return address from stack
    addi    sp,sp,8

    ret
