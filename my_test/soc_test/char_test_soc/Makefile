
all:
	riscv64-linux-gnu-gcc -march=rv32i_zicsr -mabi=ilp32 -O2 -fno-stack-protector -fomit-frame-pointer -c char-test.c
	riscv64-linux-gnu-ld -melf32lriscv -Ttext=0x30000000 -o char-test.elf char-test.o
	riscv64-linux-gnu-objcopy --only-section=.text -O binary char-test.elf char-test.bin
	riscv64-linux-gnu-objdump -d char-test.elf > char-test.txt
    
clean:
	rm char-test.o char-test.elf char-test.bin
