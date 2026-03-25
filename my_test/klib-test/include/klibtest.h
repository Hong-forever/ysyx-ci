#ifndef __KLIBTEST_H__
#define __KLIBTEST_H__

#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define IOE ({ ioe_init();  })
#define CTE(h) ({ Context *h(Event, Context *); cte_init(h); })
#define VME(f1, f2) ({ void *f1(int); void f2(void *); vme_init(f1, f2); })
#define MPE ({ mpe_init(entry); })

#define NR 32
#define STR_SIZE 64
extern uint8_t data[NR];
extern char str_data[STR_SIZE*3];
extern char str_cpm[STR_SIZE];


extern void (*entry)();
extern void check_seq(int l, int r, int val);
extern void check_eq(int l, int r, int val);
extern void reset();
extern void reset_str_data();
extern void check_str_eq(const char *actual, const char *expected, int max_len);
extern void check_str_len(const char *str, int expected_len);
extern void check_rg_unchanged(int start, int end, char expected_char);

#define CASE(id, entry_, ...) \
    case id: { \
        void entry_(); \
        entry = entry_; \
        __VA_ARGS__; \
        entry(); \
        break; \
    }

#endif
