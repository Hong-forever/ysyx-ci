
DESIGN = ysyx_25110270

PDK = nangate45
# PDK = icsprout55

RESOURCE_DIR = $(NPC_HOME)/resource
RESULT = $(abspath $(RESOURCE_DIR)/sta-result)
O = $(RESULT)/$(DESIGN)-$(PDK)
RTL_FILES = $(VSRCS-SYM)
SDC_FILE = ${NPC_HOME}/scripts/sta/npc.sdc

CLK_FREQ_MHZ = 1200
CLK_PORT_NANE = clock

msta:
	$(MAKE) -C $(YOSYS_HOME) sta DESIGN=$(DESIGN) O=$(O) RTL_FILES="$(RTL_FILES)" SDC_FILE=$(SDC_FILE) CLK_FREQ_MHZ=$(CLK_FREQ_MHZ) CLK_PORT_NANE=$(CLK_PORT_NANE) PDK=$(PDK)

msta-clean:
	rm -rf $(RESULT)

.PHONY: msta msta-clean