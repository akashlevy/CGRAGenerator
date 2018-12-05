#include "Vtop.h"
#include "verilated.h"
#include <iostream>
#include "stdint.h"
#include <fstream>
#include "printf.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vtop* top = new Vtop;
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99); // What is 99?  I don't know!  FIXME
    top->clk = 0;

    //tfp->open("/nobackup/steveri/github/CGRAGenerator/verilator/generator_z_tb/tmp.vcd");
    tfp->open("tmp.vcd");
    uint32_t time_step = 0;

        // bus1 as output; should read 13333
        std::cout << "  bus1=OUTPUT, bus1 should equal internal id 13333" << std::endl;
        top->en1 = 1; // bus1 = OUTPUT

        for (int i = 1; i <= 5; i++) {
            top->clk ^= 1; top->eval(); tfp->dump(time_step); time_step++;
            printf("    i=%d en1=%1d bus1=%05d res=%05d\n",
                        i, top->en1, top->bus1, top->result);
        }
        printf("\n");

        ////////////////////////////////////////////////////////////////////////
        // bus1 = INPUT, bus1 should count to five
        std::cout << "  bus1=INPUT, should count to five" << std::endl;
        top->en1 = 0; // bus1 = INPUT

        for (int i = 1; i <= 5; i++) {
            top->bus1 = i;
            top->clk ^= 1; top->eval(); tfp->dump(time_step); time_step++;
            printf("    i=%d en1=%1d bus1=%05d res=%05d\n",
                        i, top->en1, top->bus1, top->result);
        }

    tfp->close();

    //delete top; // What's this??
}
