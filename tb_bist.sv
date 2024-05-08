`include "bist_comparator.sv"
`include "bist_controller.sv"
`include "bist_counter.sv"
`include "bist_decoder.sv"
`include "bist_multiplexer.sv"
`include "bist_sram.sv"

module bist_tb();
  // Parameters
  localparam int size = 6;
  localparam int length = 8;
  localparam int CLK_PERIOD = 5;

  // Signals
  logic start, rst, clk, rwbarin;
  logic [size-1:0] address;
  logic [length-1:0] datain, dataout;
  logic fail, bist_done, bist_result;

  // Clock generation
  always begin
    #CLK_PERIOD clk = ~clk;
  end

  // DUT instantiation
  BIST #(
    .size(size),
    .length(length)
  ) DUT (
    .start(start),
    .rst(rst),
    .clk(clk),
    .rwbarin(rwbarin),
    .address(address),
    .datain(datain),
    .dataout(dataout),
    .fail(fail),
    .bist_done(bist_done),
    .bist_result(bist_result)
  );

  initial begin
    // initialize fsdb dump file
    $fsdbDumpfile("bist.fsdb");
    $fsdbDumpvars();

    // Initialize signals
    start = 0;
    rst = 1;
    clk = 0;
    rwbarin = 0;
    address = 0;
    datain = 0;

    // Apply reset
    #CLK_PERIOD rst = 0;

    // Perform BIST tests
    #10 start = 1;
    wait(bist_done);
    if (bist_result && !fail) begin
      $display("BIST test completed without errors.");
    end else begin
      $display("BIST test failed.");
    end
    $finish;

    // Simulation duration
    #100000 $finish;
  end
endmodule