
set CLK_PORT_NAME clock
set CLK_FREQ_MHZ 5000

set clk_io_pct 0.2
set clk_port [get_ports $CLK_PORT_NAME]
create_clock -name core_clock -period [expr 1000.0 / $CLK_FREQ_MHZ] $clk_port
