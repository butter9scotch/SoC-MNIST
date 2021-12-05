module ieee754_fp_mul (
						dataa,
						datab,
						result
						);



input       [31:0] dataa;
input       [31:0] datab;
output wire [31:0] result;


wire        in1_sign;
wire [7: 0] in1_exponent;
wire [23:0] in1_mantissa;

wire        in2_sign;
wire [7: 0] in2_exponent;
wire [23:0] in2_mantissa;


wire [47:0] temp_mantissa;
wire [47:0] final_mantissa;


wire [8: 0] sum_of_exponents;

wire        out_sign;
wire [8: 0] out_exponent;
wire [22:0] out_mantissa;


reg         mult_sign;
reg  [7: 0] mult_exponent;
reg  [22:0] mult_mantissa;


reg         result_sign;
reg  [7: 0] result_exponent;
reg  [22:0] result_mantissa;


assign in1_sign     = dataa[31];
assign in1_exponent = (dataa[30:23] == 8'h0) ? 8'h1 : dataa[30:23]; // Handling exponent = 0 numbers
assign in1_mantissa = (dataa[30:23] == 8'h0) ? {1'b0,dataa[22:0]} : {1'b1,dataa[22:0]}; // If exponent if not zero, number is of the form 1.m where m is mantissa

assign in2_sign     = datab[31];
assign in2_exponent = (datab[30:23] == 8'h0) ? 8'h1 : datab[30:23];
assign in2_mantissa = (datab[30:23] == 8'h0) ? {1'b0,datab[22:0]} : {1'b1,datab[22:0]};


assign temp_mantissa = in1_mantissa * in2_mantissa ; // multiplying mantissas including their leading bits. so total 24 bits * 24 bits
assign final_mantissa = temp_mantissa [47] ? temp_mantissa : (temp_mantissa << 1) ; //left shifting to adjust mantissa according to algorithm

assign sum_of_exponents = in1_exponent + in2_exponent;

assign out_sign = in1_sign ^ in2_sign ;
assign out_exponent = in1_exponent + in2_exponent - 127 + temp_mantissa[47];
assign out_mantissa = final_mantissa[46:24] + (final_mantissa[23] & (final_mantissa[22] | (|final_mantissa[21:0]))) ;

always @(*) begin
		
		mult_mantissa = out_mantissa;
		mult_exponent = out_exponent[7:0];
		mult_sign     = out_sign;

		if(out_exponent >= 255) begin //overflow
				if(sum_of_exponents <= 127) begin
					mult_mantissa = 23'h0;
		            mult_exponent = 8'h0;	
				end
				else begin
					mult_mantissa = 23'h0;
		            mult_exponent = 8'hFF;	
				end
		end
		else if (sum_of_exponents <= 127) begin
					mult_mantissa = 23'h0;
		            mult_exponent = 8'h0;	
		end

		//Now to check for inf and Not a number (Nan) conditions

		if(dataa[30:0] == 31'h7F800000) begin //infinity condition
				result_sign = dataa[31];
				result_exponent = 8'hFF;
				result_mantissa = 23'h0;
		end
		else if (datab[30:0] == 31'h7F800000) begin 
				result_sign = datab[31];
				result_exponent = 8'hFF;
				result_mantissa = 23'h0;
	    end
		else if (in1_exponent == 8'hFF && (in1_mantissa != 'h0)) begin //Not a number Nan format
				result_sign = dataa[31];
				result_exponent = 8'hFF;
				result_mantissa = 23'h0;
		end
		else if (in2_exponent == 8'hFF && (in2_mantissa != 'h0)) begin //Not a number Nan format
				result_sign = datab[31];
				result_exponent = 8'hFF;
				result_mantissa = 23'h0;
		end
		else if ((dataa[30:0] == 'h0) | (datab[30:0] == 'h0)) begin
				result_sign = dataa[31] ^ datab[31];
				result_exponent = 8'h0;
				result_mantissa = 23'h0;
		end
		else begin
				result_sign     = mult_sign;
				result_exponent = mult_exponent;
				result_mantissa = mult_mantissa;
		end

end		


assign result = {result_sign, result_exponent, result_mantissa} ;

endmodule
