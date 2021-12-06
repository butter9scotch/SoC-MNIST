// Code your design here
module flp_adder(input logic [31:0] num1,input logic [31:0] num2,output logic [31:0] sum);

	logic [31:0] inputa;
	logic [31:0] inputb;
	logic out_sign;
	logic [7:0] out_exp;
	logic [24:0] out_mant;

        logic [7:0] norm_exp_in;
	logic [24:0] norm_mant_in;		 
  logic [7:0] norm_exp;
  logic [24:0] norm_mant0;
     
	logic A_sign;
	logic [7:0] A_exp;
	logic [23:0] A_mant;

	logic B_sign;
	logic [7:0] B_exp;
	logic [23:0] B_mant;

  logic [23:0] temp_mant;
  logic [7:0] exp_diff;			 
	
        logic sum_sign;
	logic [7:0] sum_exp;
	logic [22:0] sum_mant;
		 
        assign inputa = num1;
	assign inputb = num2;

  always @ (inputa, inputb) begin //{
		A_sign = inputa[31];
	          temp_mant = 0;
                  exp_diff = 0;
                  norm_exp = 0;
                  norm_mant = 0;
                if(inputa[30:23] == 8'h0) begin //{
      		A_exp  = 8'h1;
      		A_mant = {1'b0, inputa[22:0]};
    		end //}
    		else begin //{
      		A_exp = inputa[30:23];
      		A_mant = {1'b1, inputa[22:0]};
    		end //}

		B_sign = inputb[31];
                if(inputb[30:23] == 8'h0) begin //{
                  B_exp  = 8'h1;
                  B_mant = {1'b0, inputb[22:0]};
                end //}
                else begin //{
                  B_exp = inputb[30:23];
                  B_mant = {1'b1, inputb[22:0]};
                end //}

		if(A_exp == B_exp) begin //{ 				
			out_exp = A_exp;
			if(A_sign == B_sign) begin //{ 				
				out_mant = A_mant + B_mant;
                                out_mant[24] = 1'b1;	
				out_sign = A_sign;
			end //}
			else begin //{ 									 
				if(A_mant < B_mant) begin //{ 
                                        out_mant = B_mant - A_mant;
					out_sign = B_sign;
				end //}
				else begin //{ 
					out_mant = A_mant - B_mant;
					out_sign = A_sign;					
				end //}
			end //}
		end //}

		else begin //{ 						
			if(A_exp < B_exp) begin //{
				out_sign = B_sign;
				out_exp  = B_exp;
				exp_diff = B_exp - A_exp;
				temp_mant = A_mant >> exp_diff;
                                if(A_sign != B_sign) begin //{
                                out_mant = B_mant - temp_mant; end //}
                                else begin //{
                                out_mant = B_mant + temp_mant; end //}
			end //}
			else begin //{ 	
                                out_sign = A_sign;
				out_exp = A_exp;
				exp_diff = A_exp - B_exp;
				temp_mant = B_mant >> exp_diff;
                                if(A_sign != B_sign) begin //{
                                out_mant = A_mant - temp_mant; end //}
                                else begin //{
                                out_mant = A_mant + temp_mant; end //}
			end //}
		end //}

		norm_mant_in = out_mant;
		norm_exp_in = out_exp;
	
// genvar i;
   // generate
     // for(i = 3; i<23; i++) begin 
		if(norm_mant_in[23:3] == 21'h1) begin //{
                //if(norm_mant_in[23:i] == 1) begin
                       // norm_exp = norm_exp_in - (23-i);
                       // norm_mant = norm_mant_in << i;
			norm_exp = norm_exp_in - 20;
			norm_mant = norm_mant_in << 20;
		end //}
//  end 
  //  endgenerate
		else if(norm_mant_in[23:4] == 20'h1) begin //{
			norm_exp = norm_exp_in - 19;
			norm_mant = norm_mant_in << 19;
		end //}
		else if(norm_mant_in[23:5] == 19'h1) begin //{
			norm_exp = norm_exp_in - 18;
			norm_mant = norm_mant_in << 18;
		end //}
		else if(norm_mant_in[23:6] == 18'h1) begin //{
			norm_exp = norm_exp_in - 17;
			norm_mant = norm_mant_in << 17;
		end //}
		else if(norm_mant_in[23:7] == 17'h1) begin //{
			norm_exp = norm_exp_in - 16;
			norm_mant = norm_mant_in << 16;
		end //}
		else if(norm_mant_in[23:8] == 16'h1) begin //{
			norm_exp = norm_exp_in - 15;
			norm_mant = norm_mant_in << 15;
		end //}
		else if(norm_mant_in[23:9] == 15'h1) begin //{
			norm_exp = norm_exp_in - 14;
			norm_mant = norm_mant_in << 14;
		end //}
		else if(norm_mant_in[23:10] == 14'h1) begin //{
			norm_exp = norm_exp_in - 13;
			norm_mant = norm_mant_in << 13;
		end //}
		else if(norm_mant_in[23:11] == 13'h1) begin //{
			norm_exp = norm_exp_in - 12;
			norm_mant = norm_mant_in << 12;
		end //}
		else if(norm_mant_in[23:12] == 12'h1) begin //{
			norm_exp = norm_exp_in - 11;
			norm_mant = norm_mant_in << 11;
		end //}
		else if(norm_mant_in[23:13] == 11'h1) begin //{
			norm_exp = norm_exp_in - 10;
			norm_mant = norm_mant_in << 10;
		end //}
		else if(norm_mant_in[23:14] == 10'h1) begin //{
			norm_exp = norm_exp_in - 9;
			norm_mant = norm_mant_in << 9;
		end //}
		else if(norm_mant_in[23:15] == 9'h1) begin //{
			norm_exp = norm_exp_in - 8;
			norm_mant = norm_mant_in << 8;
		end //}
		else if(norm_mant_in[23:16] == 8'h1) begin //{
			norm_exp = norm_exp_in - 7;
			norm_mant = norm_mant_in << 7;
		end //}
		else if(norm_mant_in[23:17] == 7'h1) begin //{
			norm_exp = norm_exp_in - 6;
			norm_mant = norm_mant_in << 6;
		end //}
		else if(norm_mant_in[23:18] == 6'h1) begin //{
			norm_exp = norm_exp_in - 5;
			norm_mant = norm_mant_in << 5;
		end //}
		else if(norm_mant_in[23:19] == 5'h1) begin //{
			norm_exp = norm_exp_in - 4;
			norm_mant = norm_mant_in << 4;
		end //}
		else if(norm_mant_in[23:20] == 4'h1) begin //{
			norm_exp = norm_exp_in - 3;
			norm_mant = norm_mant_in << 3;
		end //}
		else if(norm_mant_in[23:21] == 3'h1) begin //{
			norm_exp = norm_exp_in - 2;
			norm_mant = norm_mant_in << 2;
		end //}
		else if(norm_mant_in[23:22] == 2'h1) begin //{
			norm_exp = norm_exp_in - 1;
			norm_mant = norm_mant_in << 1;
		end //}
	

		if(out_mant[24]) begin 	//{						
			out_mant = out_mant >> 1;
			out_exp = out_exp + 1;
		end //}
		else if((out_exp != 0) && (out_mant[23]!=1)) begin //{
			out_mant = norm_mant;
			out_exp = norm_exp;
		end //}

                if((A_exp == 255 && A_mant != 0) || ((B_exp == 0) && (B_mant == 0))) begin //{	
			sum_sign = A_sign;
			sum_exp  = A_exp;
			sum_mant = A_mant;
		end //}
		else if((B_exp == 255 && B_mant != 0) || ((A_exp == 0) && (A_mant == 0))) begin //{
			sum_sign = B_sign;
			sum_exp  = B_exp;
			sum_mant = B_mant;
		end //}
		else if((A_exp == 255) || (B_exp == 255)) begin //{	
          sum_sign = A_sign ^ B_sign;
			sum_exp  = 255;
			sum_mant = 0;
		end //}
		else begin //{ 		
			sum_sign = out_sign;
			sum_exp = out_exp;
			sum_mant = out_mant[22:0];
		end //}

  	end //}
    
        assign sum = {sum_sign, sum_exp, sum_mant};
endmodule 
