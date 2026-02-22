.DEFAULT_GOAL := all
CC = gcc
CFLAGS = -Wall -O2 -g -MMD -I.
LDFLAGS = -lm -lz

TARGET = build/cachesim
SRCS = main.c cachesim.c trace.c
OBJS = $(addprefix build/, $(SRCS:.c=.o))
DEPS = $(OBJS:.o=.d)
HEADERS = cachesim.h

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
# 	./$(TARGET) --trace /home/hhh/Templates/cachesim.bin --size 64 --ways 1 --block 4 --policy lru --icache
	./$(TARGET) --trace /tmp/dcachesim.bin --size 64 --ways 1 --block 4 --policy lru -y dcache --write-back --write-allocate

.PHONY: all clean run