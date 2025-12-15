#include "common.h"

void reset(int n);
void init_monitor(int argc, char *argv[]);
void engine_start();
void cleanup_ftrace();
int is_exit_status_bad();

IFDEF(CONFIG_USE_NVBOARD, void nvboard());

VerilatedContext* contextp = new VerilatedContext;
TOP_NAME* top = new TOP_NAME{contextp};
IFDEF(WAVE_ENABLE,VerilatedVcdC* tfp);

int main(int argc, char *argv[])
{
    IFDEF(CONFIG_USE_NVBOARD, nvboard());
    contextp->commandArgs(argc, argv);

#ifdef WAVE_ENABLE
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("build/waveform.vcd");
#endif

    init_monitor(argc, argv);

    reset(10);

    engine_start();
    
    cleanup_ftrace();

    top->final(); delete top; top = NULL;
    delete contextp; contextp = NULL;

    return is_exit_status_bad();
}
