#include "common.h"


void reset(int n);
void init_monitor(int argc, char *argv[]);
void engine_start();
void cleanup_ftrace();
int is_exit_status_bad();

IFDEF(CONFIG_USE_NVBOARD, void nvboard());

VerilatedContext *contextp = new VerilatedContext;
TOP_NAME *top = new TOP_NAME{contextp};
#if WAVE_ENABLE == 1
    #if WAVE_FORMAT == 1
        VerilatedVcdC *tfp = new VerilatedVcdC;
    #else
        VerilatedFstC *tfp = new VerilatedFstC;
    #endif
#endif

static const char *wave_file = WAVE_FORMAT == 1 ? "build/waveform.vcd" : "build/waveform.fst";

int main(int argc, char *argv[])
{
    IFDEF(CONFIG_USE_NVBOARD, nvboard());
    contextp->commandArgs(argc, argv);

#if WAVE_ENABLE == 1
    Verilated::traceEverOn(true);
    tfp->set_time_unit("1ns"); // time unit is 1 ns
    tfp->set_time_resolution("1ps"); // time precision is 1 ps
    top->trace(tfp, 99);
    tfp->open(wave_file);
#endif

    init_monitor(argc, argv);

    reset(10);

    engine_start();
    
    cleanup_ftrace();

#if WAVE_ENABLE == 1
    if (tfp) {
        printf("Finalizing waveforms...\n");
        tfp->close();
        delete tfp;
        tfp = NULL;
    }
#endif
    if(top) { top->final(); delete top; top = NULL; }
    if(contextp) { delete contextp; contextp = NULL; }

    return is_exit_status_bad();
}
