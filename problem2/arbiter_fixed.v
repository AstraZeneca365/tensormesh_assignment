
module arbiter_fixed (
    input rst,req_A,req_B,
    input [7:0] data_A,data_B,
    output reg grant_A,grant_B,
    output reg [7:0] out_data,
    output reg out_valid
);

always @(*) begin
    grant_A = 0;
    grant_B = 0;
    out_data = 0;
    out_valid = 0;

    if (req_A) begin
        grant_A = 1;
        out_data = data_A;
        out_valid = 1;
    end
    else if (req_B) begin
        grant_B = 1;
        out_data = data_B;
        out_valid = 1;
    end
end

endmodule
