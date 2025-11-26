
ifeq ($(CONFIG_ITRACE)$(CONFIG_IQUEUE),)
SRCS-BLACKLIST-y += src/utils/disasm.c
else
LIBCAPSTONE = tools/capstone/repo/libcapstone.so.5
CFLAGS += -I tools/capstone/repo/include
src/utils/disasm.c: $(LIBCAPSTONE)
$(LIBCAPSTONE):
	$(MAKE) -C tools/capstone
endif
