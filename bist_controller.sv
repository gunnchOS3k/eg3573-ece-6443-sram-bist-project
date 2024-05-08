module bist_controller (
  input clk,
  input reset,
  input start,
  output reg [7:0] address,
  output reg write_en,
  output reg [3:0] data_in,
  input [3:0] data_out,
  output reg bist_done,
  output reg bist_result
);

  reg [3:0] state;
  reg [2:0] pattern;
  reg [7:0] count;
  reg direction;

  localparam IDLE = 4'b0000, WRITE = 4'b0001, READ = 4'b0010, INVERT = 4'b0011, DONE = 4'b0100;
  localparam BLANKET_0 = 3'b000, BLANKET_1 = 3'b001, CHECKERBOARD = 3'b010, CHECKERBOARD_INV = 3'b011, MARCH_C = 3'b100, MARCH_A = 3'b101;

  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      pattern <= BLANKET_0;
      count <= 0;
      address <= 0;
      write_en <= 0;
      data_in <= 0;
      bist_done <= 0;
      bist_result <= 1;
      direction <= 1;
    end else begin
      case (state)
        IDLE: begin
          if (start) begin
            state <= WRITE;
            count <= 0;
            address <= 0;
            write_en <= 1;
            case (pattern)
              BLANKET_0: data_in <= 4'h0;
              BLANKET_1: data_in <= 4'hF;
              CHECKERBOARD: data_in <= (count[0]) ? 4'h5 : 4'hA;
              CHECKERBOARD_INV: data_in <= (count[0]) ? 4'hA : 4'h5;
              MARCH_C, MARCH_A: data_in <= 4'h0;
            endcase
          end
        end
        WRITE: begin
          if (count == 255) begin
            state <= READ;
            count <= 0;
            address <= 0;
            write_en <= 0;
          end else begin
            count <= count + 1;
            address <= direction ? count + 1 : 255 - count;
            case (pattern)
              CHECKERBOARD: data_in <= (count[0]) ? 4'h5 : 4'hA;
              CHECKERBOARD_INV: data_in <= (count[0]) ? 4'hA : 4'h5;
            endcase
          end
        end
        READ: begin
          if (count == 255) begin
            case (pattern)
              BLANKET_0: pattern <= BLANKET_1;
              BLANKET_1: pattern <= CHECKERBOARD;
              CHECKERBOARD: pattern <= CHECKERBOARD_INV;
              CHECKERBOARD_INV: pattern <= MARCH_C;
              MARCH_C: begin
                if (direction) begin
                  direction <= 0;
                  state <= WRITE;
                  count <= 0;
                  address <= 255;
                  write_en <= 1;
                  data_in <= 4'h0;
                end else begin
                  pattern <= MARCH_A;
                  state <= WRITE;
                  count <= 0;
                  address <= 0;
                  write_en <= 1;
                  data_in <= 4'h0;
                end
              end
              MARCH_A: begin
                if (direction) begin
                  direction <= 0;
                  state <= WRITE;
                  count <= 0;
                  address <= 255;
                  write_en <= 1;
                  data_in <= 4'hF;
                end else begin
                  state <= DONE;
                  bist_done <= 1;
                end
              end
            endcase
            if (state != DONE && pattern != MARCH_C && pattern != MARCH_A) begin
              state <= WRITE;
              count <= 0;
              address <= 0;
              write_en <= 1;
              case (pattern)
                BLANKET_1: data_in <= 4'hF;
                CHECKERBOARD: data_in <= (count[0]) ? 4'h5 : 4'hA;
                CHECKERBOARD_INV: data_in <= (count[0]) ? 4'hA : 4'h5;
              endcase
            end
          end else begin
            if (data_out != data_in) begin
              bist_result <= 0;
            end
            case (pattern)
              MARCH_C: begin
                case (count)
                  0: begin
                    data_in <= 4'hF;
                    write_en <= 1;
                  end
                  1: begin
                    if (data_out != 4'hF) bist_result <= 0;
                    data_in <= 4'h0;
                    write_en <= 1;
                  end
                  2: begin
                    if (data_out != 4'h0) bist_result <= 0;
                    write_en <= 0;
                  end
                endcase
              end
              MARCH_A: begin
                case (count)
                  0: begin
                    if (data_out != 4'h0) bist_result <= 0;
                    data_in <= 4'hF;
                    write_en <= 1;
                  end
                  1: begin
                    if (data_out != 4'hF) bist_result <= 0;
                    write_en <= 0;
                  end
                endcase
              end
            endcase
            count <= count + 1;
            address <= direction ? count + 1 : 255 - count;
          end
        end
        DONE: begin
          // BIST completed
        end
      endcase
    end
  end

endmodule