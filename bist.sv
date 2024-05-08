module BIST #(
  parameter int size = 6,
  parameter int length = 8
) (
  input logic start, rst, clk, rwbarin,
  input logic [size-1:0] address,
  input logic [length-1:0] datain,
  output logic [length-1:0] dataout,
  output logic fail,
  output logic bist_done,
  output logic bist_result
);
  logic cout, ld, NbarT, rwbar, gt, eq, lt;
  logic [11:0] q;
  logic [3:0] data_t;
  logic [length-1:0] ramin, ramout;
  logic [size-1:0] ramaddr;
  logic zero = 12'b0;

  //Counter
  bist_counter CNT (
    .d_in(zero),
    .clk(clk),
    .ld(ld),
    .u_d(1'b1),
    .cen(1'b1),
    .q(q),
    .cout(cout)
  );

  //Decoder
  bist_decoder DEC (
    .q(q[11:9]),
    .data_t(data_t)
  );

  // Instantiate the bist_multiplexer for both address and data
  bist_multiplexer #(
    .ADDR_WIDTH(size),
    .DATA_WIDTH(length)
  ) MUX (
    .normal_addr(address),
    .normal_data(datain),
    .bist_addr(q[7:0]),
    .bist_data(data_t),
    .NbarT(NbarT),
    .mem_addr(ramaddr),
    .mem_data(ramin)
  );

  //BIST Controller
  bist_controller CNTRL (
    .clk(clk),
    .reset(rst),
    .start(start),
    .address(q[7:0]),
    .write_en(~rwbar),
    .data_in(data_t),
    .data_out(ramout),
    .bist_done(bist_done),
    .bist_result(bist_result)
  );

  assign rwbar = (~NbarT) ? rwbarin : q[8];

  //RAM
  bist_sram MEM (
    .ramaddr(ramaddr),
    .ramin(ramin),
    .we(~rwbar),
    .clk(clk),
    .ramout(ramout)
  );

  //Comparator
  bist_comparator CMP (
    .data_t(data_t),
    .ramout(ramout),
    .eq(eq),
    .gt(gt),
    .lt(lt)
  );

  always_ff @(posedge clk) begin
    if (NbarT && rwbar && ~eq) begin
      fail <= 1'b1;
    end else begin
      fail <= 1'b0;
    end
  end

  assign dataout = ramout;
endmodule