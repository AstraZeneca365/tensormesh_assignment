`timescale 1ns/1ps

module prime_no_counter_tb;

    reg clk,rst,start,stop;
    wire [1:0] state;
    wire [3:0] count;

    integer errors = 0;

    localparam IDLE   = 2'b00,
               ACTIVE = 2'b01,
               DONE   = 2'b10;

    prime_no_counter dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .stop(stop),
        .state(state),
        .count(count)
    );

    always #5 clk = ~clk;

    task check;
        input [1:0] expected_state;
        input [3:0] expected_count;
        begin
            if (state !== expected_state ||
                count !== expected_count) begin
                $display("FAIL");
                errors = errors + 1;
            end
        end
    endtask

    task tick;
        input [1:0] expected_state;
        input [3:0] expected_count;
        begin
            @(posedge clk);
            #1;
            check(expected_state, expected_count);
        end
    endtask

    initial begin
        clk   = 0;
        rst   = 0;
        start = 0;
        stop  = 0;

        // reset
        rst = 1;
        tick(IDLE, 0);
        rst = 0;

        // hold in IDLE
        tick(IDLE, 0);
        tick(IDLE, 0);

        // start counting
        start = 1;
        tick(ACTIVE, 2);
        start = 0;

        // check complete prime sequence and wraparound
        tick(ACTIVE, 3);
        tick(ACTIVE, 5);
        tick(ACTIVE, 7);
        tick(ACTIVE, 11);
        tick(ACTIVE, 13);
        tick(ACTIVE, 2);

        // stop while ACTIVE
        stop = 1;
        tick(DONE, 2);
        stop = 0;

        // DONE lasts one cycle, then IDLE
        tick(IDLE, 2);

        // hold count in IDLE
        tick(IDLE, 2);

        // restart -> count must reload to 2
        start = 1;
        tick(ACTIVE, 2);
        start = 0;

        tick(ACTIVE, 3);

        // checking stop has a greator priority over start
        start = 1;
        stop  = 1;
        tick(DONE, 3);

        tick(IDLE, 3);

        if (errors == 0)
            $display("PASS");
        else
            $display("FAIL");

        $finish;
    end

endmodule
