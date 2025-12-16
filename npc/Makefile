
-include $(NPC_HOME)/include/config/auto.conf
-include $(NPC_HOME)/include/config/auto.conf.cmd

ifneq ($(CONFIG_USE_NVBOARD),)
NXDC_FILES = constr/top.nxdc

# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

endif

TOPNAME = top

GUEST_ISA ?= riscv32

remove_quote = $(patsubst "%",%,$(1))

INC_PATH += $(sort $(dir $(shell find $(abspath ./csrc) -name "*.h")))
INC_PATH += $(sort $(dir $(shell find $(abspath ./include) -name "*.h")))

WAVE_FORMAT ?= 1 # 1: vcd, 2: fst
WAVE_ENABLE ?= 1

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast -j 4

VERILATOR_CFLAGS += -I./vsrc
VERILATOR_CFLAGS += -Wno-WIDTHEXPAND

ifeq ($(WAVE_ENABLE),1)
	VERILATOR_CFLAGS += --trace-vcd
# 		VERILATOR_CFLAGS += --trace-fst
endif


BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

include $(NPC_HOME)/scripts/difftest.mk

NPC_EXEC := $(BIN) $(IMG)

override ARGS ?= --log=$(abspath $(BUILD_DIR))/npc-log.txt
override ARGS += $(ARGS_DIFF)

sim: $(NPC_EXEC)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo $(BIN) $(ARGS) $(IMG)
	-$(BIN) $(ARGS) $(IMG)

$(shell mkdir -p $(BUILD_DIR))

ifneq ($(CONFIG_USE_NVBOARD),)
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
# ifeq ($(WAVE_ENABLE),1)
# 		CSRCS-y += ${VERILATOR_ROOT}/include/verilated_vcd_c.cpp
# # 		CSRCS-y += ${VERILATOR_ROOT}/include/verilated_fst_c.cpp
# endif

ifneq ($(CONFIG_USE_NVBOARD),)
CSRCS-BLACKLIST-y += $(SRC_AUTO_BIND)
endif

VSRCS-BLACKLIST-y += $(VSRCS-BLACKLIST)
CSRCS-BLACKLIST-y += $(CSRCS-BLACKLIST)
VSRCS := $(filter-out $(VSRCS-BLACKLIST-y),$(VSRCS-y))
CSRCS := $(filter-out $(CSRCS-BLACKLIST-y),$(CSRCS-y))

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))

CXXFLAGS += $(INCFLAGS) 
CXXFLAGS += -g -O2 -Wall -Werror -Wno-unused-result -Wno-unused-variable -Wno-unused-function
CXXFLAGS += -fsanitize=address -fno-omit-frame-pointer
CXXFLAGS += -DTOP_NAME="V$(TOPNAME)" 

ifeq ($(WAVE_ENABLE),1)
	CXXFLAGS += -DWAVE_ENABLE=1
	CXXFLAGS += -DWAVE_FORMAT=$(WAVE_FORMAT)
endif

# CXXFLAGS += -fpermissive

LDFLAGS += -lreadline -ldl -lm -lstdc++ -lpthread -lz -fsanitize=address -fno-omit-frame-pointer

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all: run

ifeq ($(WAVE_ENABLE),1)
run: sim view_wave
else
run: sim
endif

view_wave:
	@gtkwave ${NPC_HOME}/build/waveform.vcd
# 	@gtkwave ${NPC_HOME}/build/waveform.fst



include $(NPC_HOME)/scripts/config.mk


clean:
	rm -rf $(BUILD_DIR) core.*
	
include ../Makefile

.PHONY: sim all clean run view_wave