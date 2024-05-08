module bist_counter
#(parameter int length = 10)
    (input logic [length-1:0] d_in, // input data
     input logic clk, ld, u_d, cen, // control signals
     output logic [length-1:0] q, // output data
     output logic cout); // carry-out

    logic [length:0] cnt_reg; // counter register

    always_ff @(posedge clk) begin // clocked process
        if (cen) begin // count enable
            if (ld) begin // load
                cnt_reg <= {1'b0, d_in};
            end
            else if (u_d) begin // up/
                cnt_reg <= cnt_reg + 1;
            end
            else begin // down
                cnt_reg <= cnt_reg - 1;
            end
        end
    end

    assign q = cnt_reg[length-1:0]; // output data
    assign cout = cnt_reg[length]; // carry-out

endmodule

