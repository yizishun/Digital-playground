`ifndef TEST_SV
`define TEST_SV

`include "environment.sv"
class test;
    env e0;
    function new();
        e0 = new;
    endfunction

    task run();
        e0.run();
    endtask
endclass
`endif