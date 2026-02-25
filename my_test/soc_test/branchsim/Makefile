.DEFAULT_GOAL := all
CC = gcc
CFLAGS = -Wall -O2 -g -MMD -I.
LDFLAGS = -lm -lz

TARGET = build/branchsim
SRCS = main.c branchsim.c trace.c
OBJS = $(addprefix build/, $(SRCS:.c=.o))
DEPS = $(OBJS:.o=.d)
HEADERS = branchsim.h

$(shell mkdir -p build)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

build/%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

-include $(DEPS)

clean:
	rm -rf build

run: $(TARGET)
# 	./$(TARGET) --trace /home/hhh/Templates/branchsim.bin --size 64 --ways 1 --block 4 --policy lru --icache

.PHONY: all clean run