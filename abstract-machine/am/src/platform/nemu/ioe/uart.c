#include <nemu.h>
#include <klib.h>


void __am_uart_tx(AM_UART_TX_T *uart) {
    putch(uart->data);
}


void __am_uart_rx(AM_UART_RX_T *uart) {
    uint8_t ch = inb(SERIAL_PORT);

    if(ch) {
        printf("Received (uart): %d\n", ch);
        uart->data = ch;
    } else {
        uart->data = (char)-1;
    }
}
