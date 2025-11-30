#include <npc.h>

void __am_timer_init()
{
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime)
{
    uint32_t time_hi = inl(RTC_PORT+ 4);
    uint32_t time_lo = inl(RTC_PORT);

    uptime->us = ((uint64_t)time_hi << 32) | (uint64_t)time_lo;
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc)
{
    uint32_t time_hi = inl(RTC_PORT + 4);
    uint32_t time_lo = inl(RTC_PORT);

    uint64_t us = ((uint64_t)time_hi << 32) | (uint64_t)time_lo;
    uint64_t s = us / 1000000ULL;
    uint64_t day = s / 86400ULL;
    rtc->second = s % 60;
    rtc->minute = (s / 60) % 60;
    rtc->hour   = (s / 3600) % 24;
    rtc->day    = day % 30 + 1;
    rtc->month  = day / 30 % 12 + 1;
    rtc->year   = 19700 + day / 365;
}
