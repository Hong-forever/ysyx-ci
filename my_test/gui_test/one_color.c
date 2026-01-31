#include <am.h>
#include <klib.h>
#include <klib-macros.h>

void draw(uint32_t color) {
  int w = io_read(AM_GPU_CONFIG).width;
  int h = io_read(AM_GPU_CONFIG).height;

  uint32_t blank_line[w];
  for (int i = 0; i < w; i++)
    blank_line[i] = color;

  // printf("Draw full screen with color 0x%x, w=%d h=%d\n", color, w, h);

  for(int y=0; y<h; y++) {
      io_write(AM_GPU_FBDRAW, 0, y, blank_line, w, 1, false);
  }

  io_write(AM_GPU_FBDRAW, 0, 0, NULL, 0, 0, true);
}


int main() {
  ioe_init(); // initialization for GUI
  while (1) {
    draw(0x000000ff);
  }
  return 0;
}
