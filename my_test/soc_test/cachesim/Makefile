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
	./$(TARGET) --trace test_trace.txt --size 32 --ways 4 --block 64 --policy lru --icache

test_batch: $(TARGET)
	./$(TARGET) --trace batch

.PHONY: all clean run test_batch
