CC = gcc
CFLAGS = -Wall -O2 -g
LDFLAGS = -lm -lz

TARGET = cachesim
SRCS = main.c cachesim.c trace.c
OBJS = $(SRCS:.c=.o)
HEADERS = cachesim.h

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJS)

run: $(TARGET)
	./$(TARGET) --trace /tmp/nemu_itrace_pc.bin --size 64 --ways 1 --block 4 --policy lru --icache

.PHONY: all clean run
