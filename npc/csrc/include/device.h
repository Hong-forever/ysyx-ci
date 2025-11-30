#ifndef __DEVICE_H__
#define __DEVICE_H__


#define SERIAL_MMIO     0x10000000
#define RTC_MMIO        0x20000000

uint64_t get_time();

#endif