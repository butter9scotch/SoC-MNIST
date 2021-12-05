module sync_fifo (
				clk,
				reset,
				push,
				wdata,
				full,
				pop,
				rdata,
				empty);


parameter WIDTH = 32;
parameter DEPTH = 64;

localparam ADDR_WIDTH = $clog2(DEPTH);

input                 clk;
input                 reset;

input                 push;
input  [WIDTH -1 :0]  wdata;
output                full;

input                 pop;
output [WIDTH -1 :0]  rdata;
output                empty; 

integer ii;

reg [WIDTH-1    : 0] mem [0 : DEPTH -1];
reg [ADDR_WIDTH : 0] wr_ptr;
reg [ADDR_WIDTH : 0] rd_ptr;

always @ (posedge clk or posedge reset) begin
	if (reset == 1'b1)
		wr_ptr <= 'h0;
 	else if (push) begin
			if (wr_ptr == (DEPTH -1))
				wr_ptr <= {!wr_ptr[ADDR_WIDTH], {(ADDR_WIDTH){1'b0}}};
			else
				wr_ptr <= wr_ptr + 1;
	end

end


always @ (posedge clk or posedge reset) begin
	if (reset == 1'b1)
		rd_ptr <= 'h0;
 	else if (pop) begin
			if (rd_ptr == (DEPTH -1))
				rd_ptr <= {!rd_ptr[ADDR_WIDTH], {(ADDR_WIDTH){1'b0}}};
			else
				rd_ptr <= rd_ptr + 1;
	end

end


assign empty = (wr_ptr == rd_ptr);
assign full  = (wr_ptr[ADDR_WIDTH-1 : 0] == rd_ptr[ADDR_WIDTH-1:0]) && (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);


always @(posedge clk or posedge reset) begin
	if(reset == 1'b1) begin
		for (ii = 0; ii<DEPTH; ii=ii+1)
			mem[ii] <= 'h0;
	end
	else if (push) begin
		mem[wr_ptr[ADDR_WIDTH-1:0]] <= wdata;
	end

end

assign rdata = mem[rd_ptr];

endmodule
