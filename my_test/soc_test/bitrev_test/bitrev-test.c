#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define SPI_MASTER_BASE  0x10001000
#define SPI_TRX0_OFFSET 0x00
#define SPI_CTRL_OFFSET 0x10
#define SPI_DIV_OFFSET  0x14
#define SPI_SS_OFFSET   0x18

void spi_reg_write(uint32_t offset, uint32_t value) {
    *(volatile uint32_t *)(SPI_MASTER_BASE + offset) = value;
}

uint32_t spi_reg_read(uint32_t offset) {
    return *(volatile uint32_t *)(SPI_MASTER_BASE + offset);
}

void spi_transfer(uint32_t value) {
    spi_reg_write(SPI_CTRL_OFFSET, spi_reg_read(SPI_CTRL_OFFSET) & ~0x100);
    spi_reg_write(SPI_TRX0_OFFSET, value);
    spi_reg_write(SPI_CTRL_OFFSET, spi_reg_read(SPI_CTRL_OFFSET) | 0x100);
}

uint32_t spi_receive() {
    return spi_reg_read(SPI_TRX0_OFFSET);
}

void spi_bitrev_init() {
    spi_reg_write(SPI_CTRL_OFFSET, 0x00); //reset
    spi_reg_write(SPI_DIV_OFFSET, 0x04);  //set clk divider
    spi_reg_write(SPI_SS_OFFSET, 1 << 7);   //set ss, select bitrev
    spi_reg_write(SPI_CTRL_OFFSET, 0x2410); //ass, char_len=16, txneg
}

void spi_transfer_wait() {
    while(spi_reg_read(SPI_CTRL_OFFSET) & 0x100);
}


int main(const char *args) {
    spi_bitrev_init();

    spi_transfer(0x1200);
    spi_transfer_wait();
    uint32_t received = spi_receive();
    printf("Received: 0x%08x\n", received & 0x00ff);
    if((received & 0x00ff) == 0x48) {
        putstr("pass!\n");
    } else {
        putstr("fail!\n");
        return 1;
    }

    return 0;

}
