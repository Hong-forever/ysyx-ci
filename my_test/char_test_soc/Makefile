
all:
	riscv64-linux-gnu-gcc -march=rv32i_zicsr -mabi=ilp32 -O2 -fno-stack-protector -fomit-frame-pointer -c char-test.c
	riscv64-linux-gnu-ld -melf32lriscv -Ttext=0x20000000 -o char-test.elf char-test.o
	riscv64-linux-gnu-objcopy -O binary char-test.elf char-test.bin
    
clean:
	rm char-test.o char-test.elf char-test.bin
