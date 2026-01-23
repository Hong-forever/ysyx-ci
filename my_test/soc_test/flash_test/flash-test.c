#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define SPI_MASTER_BASE 0x10001000
#define SPI_TRX0_OFFSET 0x00
#define SPI_TRX1_OFFSET 0x04
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
    spi_reg_write(SPI_TRX1_OFFSET, value);
    spi_reg_write(SPI_CTRL_OFFSET, spi_reg_read(SPI_CTRL_OFFSET) | 0x100);
}

uint32_t spi_receive() {
    return spi_reg_read(SPI_TRX0_OFFSET);
}

void spi_flash_init() {
    spi_reg_write(SPI_DIV_OFFSET, 0x04);  //set clk divider
    spi_reg_write(SPI_SS_OFFSET, 1 << 0);   //set ss, select flash 
    spi_reg_write(SPI_CTRL_OFFSET, 0x2240); //ass, char_len=64, rxneg
}

void spi_transfer_wait() {
    while(spi_reg_read(SPI_CTRL_OFFSET) & 0x100);
}

uint32_t flash_read(uint32_t addr) {
    spi_flash_init();
    spi_transfer((0x03000000 | (addr & 0x00ffffff))); //read flash cmd with address
    spi_transfer_wait();
    uint32_t data = spi_receive();
    return (((data >> 24) & 0xff) | ((data >> 8) & 0xff00) | ((data << 8) & 0xff0000) | ((data << 24) & 0xff000000));
    // return data;
}

int main(const char *args) {
    uint32_t data;
    for(int i=0; i<6; i++) {
        data = flash_read(i * 4);
        printf("Data at address 0x%08x: %x\n", i * 4, data);
    }
    return 0;
}
