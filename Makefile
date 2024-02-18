all:
	as -g -o hexdump.o hexdump.s
	as -g -o ascii.o ascii.s
	ld -g -o hexdump hexdump.o ascii.o

clean:
	rm hexdump hexdump.o ascii.o
