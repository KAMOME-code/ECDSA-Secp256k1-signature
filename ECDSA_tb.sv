`timescale 1ns/1ps

`define delay   10

class seq_item #();

  rand bit [255:0] rand_h, rand_p;
  constraint value_h {rand_h inside {[256'h1:256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F]};}
  constraint value_p {rand_p inside {[256'h1:256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F]};}

endclass

module ECDSA_tb;

reg clk, start;
reg [255:0] h, key;
wire [255:0] sign;
wire busy;

ECC ECDSA(clk, h, key, sign, start, busy);
seq_item #() item;

initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
  #1000000
  $finish;
end

always #50  clk = ~clk;

initial begin
  clk = 1;  // initialize clk
  item = new();
    repeat(3) begin
        start = 0;
        item.randomize();
        h = item.rand_h;
        key = item.rand_p;
        @(posedge clk)  #`delay;
        start = 1;
        @(posedge clk)  #`delay;
        while (busy==1) @(posedge clk);
        $display("private=%h hash=%h sign=%h",key,h,sign);
    end
$finish;
end

endmodule