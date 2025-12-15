#include "common.h"

void reset(int n);
void init_monitor(int argc, char *argv[]);
void engine_start();
void cleanup_ftrace();
int is_exit_status_bad();

TOP_NAME dut;

IFDEF(CONFIG_USE_NVBOARD, void nvboard());

IFDEF(WAVE_ENABLE,VerilatedVcdC* tfp);
IFDEF(WAVE_ENABLE,VerilatedContext* contextp = nullptr);

int main(int argc, char *argv[])
{
    IFDEF(CONFIG_USE_NVBOARD, nvboard());
    if(WAVE_FORMAT==0) printf("NPC starts running...\n");

#ifdef WAVE_ENABLE
    Verilated::traceEverOn(true);
    contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    tfp = new VerilatedVcdC;
    dut.trace(tfp, 99);
    tfp->open("waveform.vcd");
#endif

    init_monitor(argc, argv);

    reset(10);

    engine_start();
    
    cleanup_ftrace();

    return is_exit_status_bad();
}
