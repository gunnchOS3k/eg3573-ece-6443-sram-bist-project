module bist_decoder (
        input logic [2:0] q, // 3-bit selector input
        output logic [7:0] data_t // 7-bit test pattern output
    );

    // This module decodes the 3-bit selector into a 7-bit test pattern
    // which is output.
    always_comb begin
        case(q)
            // Checkerboard pattern
            3'b000:
                data_t = 4'b10101010;
            3'b001:
                data_t = 4'b01010101;

            // Reverse checkerboard pattern
            3'b010:
                data_t = 4'b11110000;
            3'b011:
                data_t = 4'b00001111;

            // BLANKET 0
            3'b100:
                data_t = 4'b00000000; // Write 0
            // BLANKET 1
            3'b101:
                data_t = 4'b11111111; // Write 1

            // // March A
            // 3'b110:
            //     data_t = 4'b0000; // Write 0
            // 3'b111:
            //     data_t = 4'b1111; // Write 1

            default:
                data_t = 4'bzzzzzzzz;
        endcase
    end

endmodule

