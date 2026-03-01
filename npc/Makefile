.DEFAULT_GOAL := all

-include $(NPC_HOME)/include/config/auto.conf
-include $(NPC_HOME)/include/config/auto.conf.cmd


USE_NVBOARD = 0

# ifeq ($(USE_NVBOARD),1)
# WAVE_ENABLE = 0
# else
WAVE_ENABLE = 0
# endif
# 1: vcd, 2: fst
WAVE_FORMAT = 1

iverilog = 1

GUEST_ISA = riscv32

ifeq ($(USE_NVBOARD),1)
NXDC_FILES = constr/top.nxdc

# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

endif

ifneq ($(iverilog),1)
TOPNAME = ysyxSoCFull
else
TOPNAME = top_tb
endif

remove_quote = $(patsubst "%",%,$(1))

INC_PATH += $(sort $(dir $(shell find $(abspath ./csrc) -name "*.h")))
INC_PATH += $(sort $(dir $(shell find $(abspath ./include) -name "*.h")))

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD -cc --autoflush\
				-O3 --x-assign fast --x-initial fast -j 8
VERILATOR_CFLAGS += --timescale "1ns/1ns" --no-timing 

ifeq ($(SOC),1)
VERILATOR_CFLAGS += -Dysyx_25110270_SOC=1
endif
VERILATOR_CFLAGS += -I./vsrc
VERILATOR_CFLAGS += -I$(sort $(dir $(shell find $(abspath ../ysyxSoC/perip/uart16550/rtl) -name "*.v")))
VERILATOR_CFLAGS += -I$(sort $(dir $(shell find $(abspath ../ysyxSoC/perip/spi/rtl) -name "*.v")))
# VERILATOR_CFLAGS += --build
VERILATOR_CFLAGS += --lint-only -Wall
VERILATOR_CFLAGS += -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL


ifeq ($(WAVE_FORMAT),1)
VERILATOR_CFLAGS += --trace-vcd
else
VERILATOR_CFLAGS += --trace-fst
endif

view_wave:
ifeq ($(WAVE_FORMAT),1)
	@gtkwave -o $(NPC_HOME)/build/waveform.vcd
else
	@gtkwave -o $(NPC_HOME)/build/waveform.fst
endif

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

include $(NPC_HOME)/scripts/difftest.mk

IMG ?= $(NPC_HOME)/../my_test/soc_test/char_test_soc/char-test.bin
ELF ?= $(NPC_HOME)/../my_test/soc_test/char_test_soc/char-test.elf

override ARGS ?= --log=$(abspath $(BUILD_DIR))/npc-log.txt
override ARGS += $(ARGS_DIFF)

ifneq ($(iverilog),1)

sim: $(BIN) $(IMG)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
ifeq ($(WAVE_ENABLE),1)
	-$(BIN) $(ARGS) $(IMG)
else
	$(BIN) $(ARGS) $(IMG)
endif

else

sim: $(BIN)
	$(call git_commit, "sim RTL with iverilog") # DO NOT REMOVE THIS LINE!!!
	vvp $(BIN)

endif

perf: 
	$(call git_commit, "sim RTL for perf") # DO NOT REMOVE THIS LINE!!!
	make -C $(AM_HOME)/../am-kernels/benchmarks/microbench ARCH=riscv32e-ysyxsoc run mainargs=train

test: 
	$(call git_commit, "sim RTL for perf") # DO NOT REMOVE THIS LINE!!!
	make -C $(AM_HOME)/../am-kernels/benchmarks/microbench ARCH=riscv32e-ysyxsoc run mainargs=test

$(shell mkdir -p $(BUILD_DIR))

ifeq ($(USE_NVBOARD),1)
# constraint file
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@
endif

FILELIST_MK = $(shell find -L . -name "filelist.mk")
include $(FILELIST_MK)

# project source
VSRCS-y ?= $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS-y ?= $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

VSRCS-SYM += $(shell find $(abspath ./vsrc) -name "*.v")

ifneq ($(iverilog),1)
VSRCS-y += $(shell find $(abspath ../ysyxSoC/perip) -name "*.v")
VSRCS-y += $(shell find $(abspath ../ysyxSoC/build) -name "ysyxSoCFull.v")
endif

ifeq ($(USE_NVBOARD),1)
CSRCS-y += $(SRC_AUTO_BIND)
endif

VSRCS-BLACKLIST-y += $(VSRCS-BLACKLIST)
CSRCS-BLACKLIST-y += $(CSRCS-BLACKLIST)
VSRCS := $(filter-out $(VSRCS-BLACKLIST-y),$(VSRCS-y))
CSRCS := $(filter-out $(CSRCS-BLACKLIST-y),$(CSRCS-y))


# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))

CXXFLAGS += $(INCFLAGS) 
CXXFLAGS += -g -O2 -Wall -Werror -Wno-unused-result -Wno-unused-variable -Wno-unused-function
ifeq ($(USE_NVBOARD),1)
CXXFLAGS += -Wno-sign-compare -Wno-delete-non-virtual-dtor
endif
CXXFLAGS += -fsanitize=address -fno-omit-frame-pointer
CXXFLAGS += -mcmodel=medium
CXXFLAGS += -DTOP_NAME="V$(TOPNAME)"
ifeq ($(USE_NVBOARD),1)
CXXFLAGS += -DCONFIG_USE_NVBOARD=1
endif
CXXFLAGS += -DWAVE_ENABLE=$(WAVE_ENABLE)
CXXFLAGS += -DWAVE_FORMAT=$(WAVE_FORMAT)
ifeq ($(SOC),1)
CXXFLAGS += -DSOC=1
endif

# CXXFLAGS += -fpermissive

LDFLAGS += -lreadline -ldl -lm -lstdc++ -lpthread -lz -fsanitize=address -fno-omit-frame-pointer

ifneq ($(iverilog),1)

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

else

# IVERILOG_FLAGS = -pARRAY_SIZE_LIMIT=134217728
IVERILOG_FLAGS = -DWAVE=$(WAVE_ENABLE)

$(BIN): $(VSRCS)
	riscv64-linux-gnu-objcopy --adjust-vma=-0x80000000 -O verilog $(ELF) $(BUILD_DIR)/test.data
	iverilog -s $(TOPNAME) -o $@ $^ $(IVERILOG_FLAGS)

endif


ifeq ($(WAVE_ENABLE),1)
run: sim view_wave
else
run: sim
endif

all: run

include $(NPC_HOME)/scripts/config.mk
include $(NPC_HOME)/scripts/yosys_sta.mk


clean: 
	rm -rf $(BUILD_DIR) core.*

include ../Makefile

.PHONY: sim all clean run view_wave