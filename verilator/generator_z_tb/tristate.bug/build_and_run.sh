#!/bin/bash -v

# set -x or set -o xtrace expands variables and prints a little + sign before the line.
# set -v or set -o verbose does not expand the variables before printing.
# Use set +x and set +v to turn off the above settings.
# Can also do #!/bin/sh -x (or -v)


# verilator
#   -I/nobackup/steveri/github/CGRAGenerator/verilator/generator_z_tb/tristate
#   --trace -Mdir build -CFLAGS '-std=c++11 -DTRACE' -Wno-fatal --cc top
#   --exe harness.cpp --top-module top

verilator \
  -I.     \
  --trace -Mdir . -CFLAGS '-std=c++11 -DTRACE' -Wno-fatal --cc top \
  --exe harness.cpp --top-module top \
  || exit 13

# make -C build -j -f Vtop.mk Vtop
make -j -f Vtop.mk Vtop || exit 13

Vtop

