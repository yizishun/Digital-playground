Digital Design/verify Template
=======================
This is a template or framework include digital design and verification
# Quick Start
```shell
# Init
make init
# Elaborate RTL
make verilog DEIGN=GCD
# Create dpi-lib
make dpi-lib DEIGN=GCD TBLANG=xxx
# UVM
make sim DESIGN=GCD TBLANG=uvm SIM=vcs
make sim DESIGN=GCD TBLANG=uvm SIM=verilator #(bugs)
# SV
make sim DESIGN=GCD TBLANG=sv SIM=vcs
make sim DESIGN=GCD TBLANG=sv SIM=verilator #(bugs)
# CPP
make sim DESIGN=GCD TBLANG=cpp SIM=verilator
# COCOTB
make sim DESIGN=GCD TBLANG=cocotb SIM=icarus
make sim DESIGN=GCD TBLANG=cocotb SIM=verilator
# Chisel
make tb-verilog DEIGN=GCD
make sim DESIGN=GCD TBLANG=chisel SIM=verilator #(bugs)
make sim DESIGN=GCD TBLANG=chisel SIM=vcs
# FPGA
cd backend/fpga
make project BOARD=... #generate xpr file
# Asic
make sta
# Add module from gcd template
make addModule DEIGN=...
```

# Design
This template is originnally built from chisel-playground
So, Digital design is use chisel HDL language
## Write Chisel
* Pls use serializableModule and serializableParameter to construcr module. refer to gcd example to know(actually you can just relace `GCD` to your module name, and change the impl)
* Write in `./rtl/src`
* Write module parameter in `./config`, in json format. And the file name is corresponding module name which will be elaborated
## Elaborate Chisel
* Write corresponding(top level) module elaborate code in `./elaborateRTL`
* Naming the elaborate class `Elaborate_{module name}`(pls read the `./script/design/elaborate.mk` to know why)
* Use serializableElaborate extend your class 
* Other modify pls refer `./elaborate/Elaborate_gcd.scala` (actually you can just relace `GCD` to your module name, and change the impl)
* Finally, use `make verilog` to get the verilog, use `make fir` to get the firrtl

You can override the variable DESIGN in command line to elaborate and verify different Design

# Verify
The template support lots of testbench framework(language) and lots of simulator

For corresponding target, set `TBLANG` and `SIM`

Write TestBench in `tb/tb-{DEIGN}`
Write dpi-c in `tb/tb-{DEIGN}/{TBLANG}-tb/dpi`

(Before use vcs, make sure you already define `VCS_HOME` and `VERDI_HOME`)
