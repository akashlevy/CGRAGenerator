DESCRIPTION of the bug:
Top level has bidirectional port bus1 and direction bit en1.  When
en1==0, bus1 is used as an input port, else it is an output port.
When bus1 is an output it reads an internal id code (13333).
A result port emits the value (bus1+10000).

Then test harness sets en1==1 for five clock cycles, hoping to see
result 23333, which succeeds.

Then test harness sets en1==0 and writes sequential values (1,2,3,4,5) to
bus1, hoping to see result (10001,10002,10003,10004,10005).
This fails, we see only zeroes on bus1 (below).
Why?

Vtop
  en1=1=>bus1=OUTPUT, bus1 should equal internal id 13333
    i=1 en1=1 bus1=13333 res=23333
    i=2 en1=1 bus1=13333 res=23333
    i=3 en1=1 bus1=13333 res=23333
    i=4 en1=1 bus1=13333 res=23333
    i=5 en1=1 bus1=13333 res=23333
    OKAY

  en1=0=>bus1=INPUT, should count to five
    i=1 en1=0 bus1=00000 res=10000
    i=2 en1=0 bus1=00000 res=10000
    i=3 en1=0 bus1=00000 res=10000
    i=4 en1=0 bus1=00000 res=10000
    i=5 en1=0 bus1=00000 res=10000
    FAIL!

------------------------------------------------------------------------
MANIFESTATION of the bug:

Need: top.v, harness.cpp

Do: ./build_and_run.sh

...which does something like this:

    verilator -I.  --trace -Mdir . \
      -CFLAGS '-std=c++11 -DTRACE' -Wno-fatal --cc top \
      --exe harness.cpp --top-module top \
      || exit 13
    make -j -f Vtop.mk Vtop || exit 13
    Vtop

------------------------------------------------------------------------
NOTES on the bug:

This combo (below), in Vtop.cpp, overwrites values trying to come in on port
"inout bus1" via the harness.

// NOTE THIS OVERWRITES HARNESS VALUE OF bus1 WITH ZERO!
VL_INLINE_OPT void Vtop::_combo__TOP__1(Vtop__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vtop::_combo__TOP__1\n"); );
    Vtop* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->bus1 = (0xffffU & ((((IData)(vlTOPp->en1)
                                  ? 0x3415U : 0U) & 
                                ((IData)(vlTOPp->en1)
                                  ? 0xffffffffU : 0xffff0000U)) 
                               & ((IData)(vlTOPp->en1)
                                   ? 0xffffffffU : 0xffff0000U)));
}
...
void Vtop::_eval(Vtop__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vtop::_eval\n"); );
    Vtop* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body

    // NOTE THIS (combo1) OVERWRITES HARNESS VALUE OF bus1 WITH ZERO!
    vlTOPp->_combo__TOP__1(vlSymsp);
    vlTOPp->_combo__TOP__3(vlSymsp);
}






==============================================================================
OLD

Top level has two (inout) data ports bus1 and bus2 and two bus enable
bins en1 and en2.  Test harness sets en1=0 and en2=1 so that data will
come IN through bus1 and OUT through bus2.  Test harness clocks the
following values into bus1: (1,2,3,4,5) and then reads them out from
bus2, hoping to see (1,2,3,4,5).  Instead, zeroes.

Why?

Top-level circuit "top.v":
Harness:
Build:
Run:
