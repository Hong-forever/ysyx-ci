#include <am.h>
#include <klib.h>
#include <rtthread.h>

// rtt-am realize, this is backup
 
static Context *ev_handler(Event e, Context *c)
{
    rt_thread_t ct;
    rt_ubase_t *para;
    switch (e.event) {
        case EVENT_YIELD: 
            ct = rt_thread_self();
            para = (rt_ubase_t *)(ct->user_data);
            rt_ubase_t to = para[0];
            rt_ubase_t from = para[1];
            if (from) {
                *((Context **)from) = c;
            }
            c = *(Context **)to;
            break;
        case EVENT_IRQ_TIMER:
            break;
        default:
            printf("Unhandled event ID = %d\n", e.event);
            assert(0);
    }
    
    return c;
}

void __am_cte_init()
{
    cte_init(ev_handler);
}

void rt_hw_context_switch_to(rt_ubase_t to)
{
    rt_ubase_t temp;
    rt_ubase_t ud_ct[2];
    rt_thread_t ct = rt_thread_self();
    temp = ct->user_data;

    ud_ct[0] = to;
    ud_ct[1] = 0;
    ct->user_data = (rt_ubase_t)ud_ct;

    yield();

    ct->user_data = temp;
}

void rt_hw_context_switch(rt_ubase_t from, rt_ubase_t to)
{
    rt_ubase_t temp;
    rt_ubase_t ud_ct[2];
    rt_thread_t ct = rt_thread_self();
    temp = ct->user_data;

    ud_ct[0] = to;
    ud_ct[1] = from;
    ct->user_data = (rt_ubase_t)ud_ct;

    yield();

    ct->user_data = temp;
}

void rt_hw_context_switch_interrupt(void *context, rt_ubase_t from, rt_ubase_t to, struct rt_thread *to_thread)
{
    assert(0);
}

typedef struct {
    void (*entry)(void *);
    void *parameter;
    void (*texit)(void);
} wrapper_arg_t;

static void _thread_entry(wrapper_arg_t *arg)
{
    arg->entry(arg->parameter);
    arg->texit();
    while (1)
        ;
}

rt_uint8_t *rt_hw_stack_init(void *tentry, void *parameter, rt_uint8_t *stack_addr, void *texit)
{
    stack_addr = (rt_uint8_t *)((uintptr_t)stack_addr & ~(sizeof(uintptr_t) - 1));

    stack_addr -= sizeof(wrapper_arg_t);

    wrapper_arg_t *wrp_arg = (wrapper_arg_t *)stack_addr;
    wrp_arg->entry = (void (*)(void *))tentry;
    wrp_arg->parameter = parameter;
    wrp_arg->texit = (void (*)(void))texit;

    Area stack_area = {.end = (rt_uint8_t *)stack_addr};

    Context *ctx = kcontext(stack_area, (void *)_thread_entry, (void *)wrp_arg);

    return (rt_uint8_t *)ctx;
}
