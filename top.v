module neural_mac_single_top(
				clk,
				reset,
				address,
				writedata,
				write,
				read,
				readdata,
		        waitrequest);

// AVALON-MM Interface signals
input clk;				// clock coming in from the Avalon bus
input reset;			// reset from the Avalon bus
input [10:0] address;  	// 11-bit address coming from the Avalon bus 
input [31:0] writedata;	// 32-bit write data line
input write;			// write request from the Avalon bus
input read;				// read request from the Avalon bus
output wire [31:0] readdata;	// 32-bit data line read by the Avalon bus
output wire        waitrequest;


parameter WEIGHT_BUFFER_SIZE = 96;
parameter IMAGE_BUFFER_SIZE = 96;

//considering word addressable address bus (not byte addressable)
//addr 0 to (WEIGHT_BUFFER_SIZE) - 1 for weight buffer
//addr (WEIGHT_BUFFER_SIZE) to (WEIGHT_BUFFER_SIZE) + (IMAGE_BUFFER_SIZE) for image buffer   
//addr WEIGHT_BUFFER_SIZE + IMAGE_BUFFER_SIZE as the MAC result register
//

wire           image_buffer_push;
wire  [31 : 0] image_buffer_wdata;
wire           image_buffer_full;
wire           image_buffer_pop;
wire  [31 : 0] image_buffer_rdata;
wire           image_buffer_empty;

wire           weight_buffer_push;
wire  [31 : 0] weight_buffer_wdata;
wire           weight_buffer_full;
wire           weight_buffer_pop;
wire  [31 : 0] weight_buffer_rdata;
wire           weight_buffer_empty;

wire  [31 : 0] fp_mult_in_A;
wire  [31 : 0] fp_mult_in_B;
wire  [31 : 0] fp_mult_out_result;

wire           fp_adder_enable;

reg   [31 : 0] reg_fp_mult_out_result;
reg   [31 : 0] reg_fp_adder_out_result;
wire  [31 : 0] fp_adder_out_result;
reg            reg_image_buffer_empty;
reg   [31 : 0] mac_result;

wire           mac_result_register_read;



assign weight_buffer_push  = (write == 1) && (address < WEIGHT_BUFFER_SIZE);
assign weight_buffer_wdata = writedata;

assign image_buffer_push   = (write == 1) && (address >= (WEIGHT_BUFFER_SIZE) && (address < (WEIGHT_BUFFER_SIZE + IMAGE_BUFFER_SIZE))) ;
assign image_buffer_wdata  = writedata;


assign weight_buffer_pop = image_buffer_pop;
assign image_buffer_pop  = !image_buffer_empty;



sync_fifo #(
.WIDTH     (32),
.DEPTH     (WEIGHT_BUFFER_SIZE)
) weight_buffer_fifo (

.clk       (clk),
.reset     (reset),
.push      (weight_buffer_push),
.wdata     (weight_buffer_wdata),
.full      (weight_buffer_full),
.pop       (weight_buffer_pop),
.rdata     (weight_buffer_rdata),
.empty     (weight_buffer_empty)

);

sync_fifo #(
.WIDTH     (32),
.DEPTH     (IMAGE_BUFFER_SIZE)
) image_buffer_fifo (

.clk       (clk),
.reset     (reset),
.push      (image_buffer_push),
.wdata     (image_buffer_wdata),
.full      (image_buffer_full),
.pop       (image_buffer_pop),
.rdata     (image_buffer_rdata),
.empty     (image_buffer_empty)

);


ieee754_fp_mul fp_mult(

.dataa     (fp_mult_in_A),
.datab     (fp_mult_in_B),
.result    (fp_mult_out_result)

);

assign fp_mult_in_A = weight_buffer_rdata;
assign fp_mult_in_B = image_buffer_rdata;

assign fp_adder_enable = !image_buffer_empty;


ieee754_fp_adder fp_adder(

.num1     (reg_fp_mult_out_result),
.num2     (reg_fp_adder_out_result),
.sum      (fp_adder_out_result)

);



always @(posedge clk or posedge reset) begin
	if (reset == 1'b1)
		reg_fp_mult_out_result <= 32'h0;
    else
		reg_fp_mult_out_result <= fp_mult_out_result;
end

always @(posedge clk or posedge reset) begin
	if (reset == 1'b1)
		reg_fp_adder_out_result <= 32'h0;
    else
		reg_fp_adder_out_result <= fp_adder_out_result;
end

always @(posedge clk or posedge reset) begin
	if (reset == 1'b1)
		reg_image_buffer_empty <= 1'h1;
    else
		reg_image_buffer_empty <= image_buffer_empty;
end

always @ (posedge clk or posedge reset) begin
	if (reset == 1'b1)
		mac_result <= 32'h0;
	else if (mac_result_register_read & !waitrequest)
		mac_result <= 32'h0;
	else if (!reg_image_buffer_empty)
		mac_result <= fp_adder_out_result;
end


assign mac_result_register_read = (read == 1) && (address == (WEIGHT_BUFFER_SIZE + IMAGE_BUFFER_SIZE));
assign readdata = mac_result;

assign waitrequest = (read == 1'b1) ? !(image_buffer_empty & reg_image_buffer_empty) : 1'b0;



endmodule
