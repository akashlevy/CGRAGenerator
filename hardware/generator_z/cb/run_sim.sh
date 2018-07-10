#!/bin/tcsh
set RTL_FOLDER="./genesis_verif"
rm -rf INCA_libs irun.*
irun -sv -top top -timescale 1ns/1ps -l irun.log -access +rwc -notimingchecks -input cmd.tcl test_cb_10_16_const.v $RTL_FOLDER/cb.v

