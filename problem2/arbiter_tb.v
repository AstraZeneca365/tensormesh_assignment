`timescale 1ns/1ps

module arbiter_tb;

    reg clk,rst;
    reg req_A,req_B;
    reg [7:0] data_A,data_B;

    wire f_grant_A, f_grant_B, f_valid;
    wire [7:0] f_data;

    wire r_grant_A, r_grant_B, r_valid;
    wire [7:0] r_data;

    integer errors = 0;
    integer b_fixed = 0;
    integer b_round = 0;
    integer i;

    arbiter_fixed uut1 (
        .rst(rst),
        .req_A(req_A), .req_B(req_B),
        .data_A(data_A), .data_B(data_B),
        .grant_A(f_grant_A), .grant_B(f_grant_B),
        .out_data(f_data), .out_valid(f_valid)
    );

    arbiter_round_robin uut2 (
        .clk(clk), .rst(rst),
        .req_A(req_A), .req_B(req_B),
        .data_A(data_A), .data_B(data_B),
        .grant_A(r_grant_A), .grant_B(r_grant_B),
        .out_data(r_data), .out_valid(r_valid)
    );

    always #5 clk = ~clk;

    task check_outputs;
        begin
            if (f_grant_A && f_grant_B) begin
                $display("FAIL: fixed arbiter granted both");
                errors = errors + 1;
            end

            if (r_grant_A && r_grant_B) begin
                $display("FAIL: round-robin granted both");
                errors = errors + 1;
            end

            if (f_valid && f_data !==
                (f_grant_A ? data_A : data_B)) begin
                $display("FAIL: fixed arbiter data mismatch");
                errors = errors + 1;
            end

            if (r_valid && r_data !==
                (r_grant_A ? data_A : data_B)) begin
                $display("FAIL: round-robin data mismatch");
                errors = errors + 1;
            end 

            if (!req_A && !req_B && (f_valid || r_valid)) begin
                $display("FAIL: valid high with no requests");
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        req_A = 0;
        req_B = 0;
        data_A = 8'hAA;
        data_B = 8'hBB;

        repeat (2) @(negedge clk);
        rst = 0;

        // A alone
        req_A = 1;
        #1;
        check_outputs();
        if (!f_grant_A || !r_grant_A) begin
            $display("FAIL: A alone not granted");
            errors = errors + 1;
        end

        // B alone
        @(negedge clk);
        req_A = 0;
        req_B = 1;
        #1;
        check_outputs();
        if (!f_grant_B || !r_grant_B) begin
            $display("FAIL: B alone not granted");
            errors = errors + 1;
        end

        // Both request together
        @(negedge clk);
        req_A = 1;
        req_B = 1;
        #1;
        check_outputs();
        if (!f_grant_A) begin
            $display("FAIL: Fixed priority did not grant A");
            errors = errors + 1;
        end

        // Hold both requests for 20 cycles
        b_fixed = 0;
        b_round = 0;

        for (i = 0; i < 20; i = i + 1) begin
            @(negedge clk);
            #1;
            check_outputs();

            if (f_grant_B)
                b_fixed = b_fixed + 1;

            if (r_grant_B)
                b_round = b_round + 1;
        end

        $display("B grants in 20 cycles: Fixed=%0d, Round-robin=%0d",
                 b_fixed, b_round);

        if (b_fixed != 0) begin
            $display("FAIL: Fixed priority count unexpected");
            errors = errors + 1;
        end

        if (b_round < 9 || b_round > 11) begin
            $display("FAIL: Round-robin did not alternate fairly");
            errors = errors + 1;
        end

        // Neither requests
        @(negedge clk);
        req_A = 0;
        req_B = 0;
        #1;
        check_outputs();

        if (errors == 0)
            $display("PASS: All arbiter tests passed.");
        else
            $display("FAIL: %0d errors detected.", errors);

        $finish;
    end

endmodule
