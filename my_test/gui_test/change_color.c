#include <am.h>
#include <klib-macros.h>
#include <stdlib.h>

uint32_t target_colors[] = {
    0x000000, 0xff0000, 0x00ff00, 0x0000ff, 
    0xffff00, 0xff00ff, 0x00ffff, 0xffffff
}; 
#define COLOR_COUNT (sizeof(target_colors) / sizeof(target_colors[0]))

uint32_t current_r = 0, current_g = 0, current_b = 0;

int normal_delay = 100000;  
int fast_delay = 2000;     
int current_delay = 10000; 

volatile int should_exit = 0;

void draw(uint32_t color) {
    uint32_t color_buf[1] = {color};
    int w = io_read(AM_GPU_CONFIG).width;
    int h = io_read(AM_GPU_CONFIG).height;

    for(int y = 0; y < h; y++) {
        for(int x = 0; x < w; x++) {
            io_write(AM_GPU_FBDRAW, x, y, color_buf, 1, 1, false);
        }
    }
    io_write(AM_GPU_FBDRAW, 0, 0, NULL, 0, 0, true);
}

void decompose_color(uint32_t color, uint32_t *r, uint32_t *g, uint32_t *b) {
    *r = (color >> 16) & 0xFF;
    *g = (color >> 8) & 0xFF;
    *b = color & 0xFF;
}

uint32_t compose_color(uint32_t r, uint32_t g, uint32_t b) {
    return (r << 16) | (g << 8) | b;
}

void handle_key_events() {
    AM_INPUT_KEYBRD_T key = io_read(AM_INPUT_KEYBRD);
    
    if (key.keycode == AM_KEY_NONE) {
        return; 
    }
    
    if (key.keycode == AM_KEY_ESCAPE) {
        if (key.keydown) {
            should_exit = 1;
        }
    } else {
        if (key.keydown) {
            current_delay = fast_delay;
        } else {
            current_delay = normal_delay;
        }
    }
}

void perform_gradient(uint32_t target_color, int steps) {
    uint32_t target_r, target_g, target_b;
    decompose_color(target_color, &target_r, &target_g, &target_b);
    
    for (int i = 1; i <= steps; i++) {
        if (should_exit) {
            return;
        }
        
        handle_key_events();
        
        if (should_exit) {
            return;
        }
        
        uint32_t r = current_r + (target_r - current_r) * i / steps;
        uint32_t g = current_g + (target_g - current_g) * i / steps;
        uint32_t b = current_b + (target_b - current_b) * i / steps;
        
        uint32_t color = compose_color(r, g, b);
        draw(color);
        
        uint32_t start_time = io_read(AM_TIMER_UPTIME).us;
        while (io_read(AM_TIMER_UPTIME).us - start_time < current_delay) {
            handle_key_events();
            if (should_exit) {
                return;
            }
        }
    }
    
    current_r = target_r;
    current_g = target_g;
    current_b = target_b;
}

int main() {
    ioe_init(); 
    
    current_r = 0;
    current_g = 0;
    current_b = 0;
    
    int gradient_steps = 50;
    
    current_delay = normal_delay;
    
    while (!should_exit) {
        int random_index = rand() % COLOR_COUNT;
        uint32_t target_color = target_colors[random_index];
        
        perform_gradient(target_color, gradient_steps);
        
        handle_key_events();
    }
    
    draw(0x000000);
    
    return 0;
}
