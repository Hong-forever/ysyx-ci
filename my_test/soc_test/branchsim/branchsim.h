#ifndef __BRANCHSIM_H__
#define __BRANCHSIM_H__

#include <stdint.h>
#include <stdbool.h>


// 函数声明

bool branchsim_access(uint32_t inst, uint32_t pc, uint32_t target, bool br_taken);
void branchsim_print_stats();
int process_binary_trace(const char *filename);

#endif


