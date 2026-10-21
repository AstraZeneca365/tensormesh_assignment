
module prime_no_counter(
    input clk,rst,start,stop,
    output reg [1:0] state,
    output reg [3:0] count
);

// state encoding (localparam sets it to a constant value)
localparam IDLE = 2'b00,
			  ACTIVE = 2'b01,
			  DONE = 2'b10;

reg [1:0] next_state;

// state register
always @(posedge clk) begin
  if (rst)
		state <= IDLE;
  else
		state <= next_state;
end

// next state logic
always @(*) begin
  case (state)
		IDLE: begin
			 if (start)
				  next_state = ACTIVE;
			 else
				  next_state = IDLE;
		end

		ACTIVE: begin
			 if (stop)
				  next_state = DONE;
			 else
				  next_state = ACTIVE;
		end

		DONE: begin
			 next_state = IDLE;
		end

		default: begin
			 next_state = IDLE;
		end
  endcase
end

// counter block
always @(posedge clk) begin
  if (rst) 
		count <= 4'd0;
  else begin
		case (state)
			 IDLE: begin
				  if (start)
						count <= 4'd2;
			 end

			 ACTIVE: begin
				  if (stop) 
						count <= count;
				  else begin
						case (count)
							 4'd2: count <= 4'd3;
							 4'd3: count <= 4'd5;
							 4'd5: count <= 4'd7;
							 4'd7: count <= 4'd11;
							 4'd11: count <= 4'd13;
							 4'd13: count <= 4'd2;
							 default: count <= 4'd2;
						endcase
				  end
			 end

			 DONE: begin
				  count <= count;
			 end

			 default: begin
				  count <= count;
			 end
		endcase
  end
end

endmodule
