module bist_sram
(
    input logic [5:0] ramaddr,
    input logic [7:0] ramin,
    input logic we, clk,
    output logic [7:0] ramout
);

    /* Declare the RAM variable */
    logic [7:0] ram[63:0];

    /* Variable to hold the registered read address */
    logic [7:0] addr_reg;

    always_ff @(posedge clk)
    begin
        /* Write */
        if (we)
            ram[ramaddr] <= ramin;
        addr_reg <= ramaddr;
    end

    /* Continuous assignment implies read returns NEW data.
    This is the natural behavior of the TriMatrix memory
    blocks in Single Port mode*/
    assign ramout = ram[addr_reg];

endmodule

