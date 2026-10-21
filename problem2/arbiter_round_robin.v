
module arbiter_round_robin (
    input clk,rst,req_A,req_B,
    input [7:0] data_A,data_B,
    output reg grant_A,grant_B,
    output reg [7:0] out_data,
    output reg out_valid
);

reg last_grant; // 0 -> A was requested last, 1 -> B was requested last

always @(posedge clk) begin
    if (rst)
        last_grant <= 1'b1; // first tie goes to A
    else if (grant_A)
        last_grant <= 1'b0;
    else if (grant_B)
        last_grant <= 1'b1;
end


always @(*) begin
    grant_A = 0;
    grant_B = 0;
    out_data = 0;
    out_valid = 0;

    if (req_A && req_B) begin
        if (last_grant == 0) begin
            grant_B = 1;
            out_data = data_B;
        end
        else begin
            grant_A = 1;
            out_data = data_A;
        end
        out_valid = 1;
    end
    else if (req_A) begin
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
