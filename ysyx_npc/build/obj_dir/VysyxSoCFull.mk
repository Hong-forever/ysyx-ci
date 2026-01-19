# Verilated -*- Makefile -*-
# DESCRIPTION: Verilator output: Makefile for building Verilated archive or executable
#
# Execute this makefile from the object directory:
#    make -f VysyxSoCFull.mk

default: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/build/ysyxSoCFull

### Constants...
# Perl executable (from $PERL, defaults to 'perl' if not set)
PERL = perl
# Python3 executable (from $PYTHON3, defaults to 'python3' if not set)
PYTHON3 = python3
# Path to Verilator kit (from $VERILATOR_ROOT)
VERILATOR_ROOT = /home/hhh/oss-cad-suite/share/verilator
# SystemC include directory with systemc.h (from $SYSTEMC_INCLUDE)
SYSTEMC_INCLUDE ?=
# SystemC library directory with libsystemc.a (from $SYSTEMC_LIBDIR)
SYSTEMC_LIBDIR ?=

### Switches...
# C++ code coverage  0/1 (from --prof-c)
VM_PROFC = 0
# SystemC output mode?  0/1 (from --sc)
VM_SC = 0
# Legacy or SystemC output mode?  0/1 (from --sc)
VM_SP_OR_SC = $(VM_SC)
# Deprecated
VM_PCLI = 1
# Deprecated: SystemC architecture to find link library path (from $SYSTEMC_ARCH)
VM_SC_TARGET_ARCH = linux

### Vars...
# Design prefix (from --prefix)
VM_PREFIX = VysyxSoCFull
# Module prefix (from --prefix)
VM_MODPREFIX = VysyxSoCFull
# User CFLAGS (from -CFLAGS on Verilator command line)
VM_USER_CFLAGS = \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/cpu/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/cpu/difftest/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/include/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/monitor/sdb/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/include/config/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/include/config/cc/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/include/config/difftest/ref/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/include/config/loop/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/include/config/mem/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/include/config/mode/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/include/config/pc/reset/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/include/config/timer/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/include/config/trace/ \
  -I/home/hhh/Desktop/ysyx/ysyx-workbench/npc/include/generated/ \
  -g \
  -O2 \
  -Wall \
  -Werror \
  -Wno-unused-result \
  -Wno-unused-variable \
  -Wno-unused-function \
  -fsanitize=address \
  -fno-omit-frame-pointer \
  -DTOP_NAME=VysyxSoCFull \
  -DWAVE_ENABLE=1 \
  -DWAVE_FORMAT=1 \

# User LDLIBS (from -LDFLAGS on Verilator command line)
VM_USER_LDLIBS = \
  -lreadline \
  -ldl \
  -lm \
  -lstdc++ \
  -lpthread \
  -lz \
  -fsanitize=address \
  -fno-omit-frame-pointer \

# User .cpp files (from .cpp's on Verilator command line)
VM_USER_CLASSES = \
  cpu_exec \
  dut \
  ref \
  isa_init \
  reg \
  init \
  paddr \
  vaddr \
  monitor \
  expr \
  sdb \
  watchpoint \
  sim_main \
  disasm \
  ftrace \
  log \
  state \
  timer \

# User .cpp directories (from .cpp's on Verilator command line)
VM_USER_DIR = \
  ../.. \
  ../../csrc \
  ../../csrc/cpu \
  ../../csrc/cpu/difftest \
  ../../csrc/engine \
  ../../csrc/memory \
  ../../csrc/monitor \
  ../../csrc/monitor/sdb \
  ../../csrc/utils \

### Default rules...
# Include list of all generated classes
include VysyxSoCFull_classes.mk
# Include global rules
include $(VERILATOR_ROOT)/include/verilated.mk

### Executable rules... (from --exe)
VPATH += $(VM_USER_DIR)

cpu_exec.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/cpu/cpu_exec.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
dut.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/cpu/difftest/dut.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
ref.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/cpu/difftest/ref.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
isa_init.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/cpu/isa_init.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
reg.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/cpu/reg.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
init.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/engine/init.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
paddr.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/memory/paddr.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
vaddr.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/memory/vaddr.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
monitor.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/monitor/monitor.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
expr.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/monitor/sdb/expr.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
sdb.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/monitor/sdb/sdb.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
watchpoint.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/monitor/sdb/watchpoint.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
sim_main.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/sim_main.cpp 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
disasm.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/utils/disasm.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
ftrace.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/utils/ftrace.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
log.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/utils/log.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
state.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/utils/state.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<
timer.o: /home/hhh/Desktop/ysyx/ysyx-workbench/npc/csrc/utils/timer.c 
	$(OBJCACHE) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(OPT_FAST)  -c -o $@ $<

### Link rules... (from --exe)
/home/hhh/Desktop/ysyx/ysyx-workbench/npc/build/ysyxSoCFull: $(VK_USER_OBJS) $(VK_GLOBAL_OBJS) $(VM_PREFIX)__ALL.a $(VM_HIER_LIBS)
	$(LINK) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) $(LIBS) $(SC_LIBS) -o $@

# Verilated -*- Makefile -*-
