module calculator(

input CLOCK_50,

output wire [10:0] inst_w,
output reg [3:0] pc, 
//output reg signed [7:0] out_stack,

output reg [2:0] overflow,

output reg [6:0] HEX0,
output reg [6:0] HEX1,
output reg [6:0] HEX2,
output reg [6:0] HEX3,
output reg [6:0] HEX4,
output reg [6:0] HEX5,

output reg [2:0] LEDR,
output reg [7:0] operand,
output reg [2:0] op_code
//output reg signed [7:0] topofstack

);



initial overflow = 0;
reg signed [7:0] b_temp;
reg signed [7:0] sum;
reg [11:0] BCD;

//initial topofstack = 0;


reg [7:0] stack[9:0];
reg [3:0] top;
//reg [7:0] operand;
//reg [2:0] op_code; 
reg signed [15:0] result;

reg signed [7:0] twoscomplement;
reg [1:0] haltmode;
reg [1:0] overflowmode;

integer j;

initial top = -1;
initial result = 0;
initial pc = 0;
initial operand = 0;
initial op_code = 0;
initial HEX0 = 7'b0000000;
initial HEX1 = 7'b0000000;
initial HEX2 = 7'b0000000;
initial HEX3 = 7'b0000000;

initial stack[0] = 0;
initial stack[1] = 0;
initial stack[2] = 0;
initial stack[3] = 0;
initial stack[4] = 0;
initial stack[5] = 0;
initial stack[6] = 0;
initial stack[7] = 0;
initial stack[8] = 0;
initial stack[9] = 0;
initial haltmode = 0;
initial overflowmode = 0; 
initial LEDR = 2'b00;

myrom myrom(.clock(CLOCK_50), .q(inst_w), .address(pc));

	always @(posedge CLOCK_50) begin
	
	pc <= pc + 1;
	
	// ROM instantiation 
	
	operand <= inst_w[7:0];
	op_code <= inst_w[10:8];	
	
	
	if (haltmode == 0) begin	
	
	case(op_code)  
	
	
		3'b101 : begin //subtract 				
								
					result = stack[top - 1] - stack[top]; // subtract top 2 of stack			
					//stack[top] = 0;
					stack[top - 1] = result;		
					top = top - 1;
					//out_stack = stack[top];
					//a = stack[top-1];
					//b = stack[top];
					//topofstack = stack[top];
					
					
					end 

       3'b100: begin 
													
					result = stack[top] + stack[top-1]; // add top 2 of stack			
					stack[top - 1] = result;		
					top = top - 1;
					//out_stack = stack[top];
					//a = stack[top-1];
					//b = stack[top];
					//topofstack = stack[top];
					
					end 
						
		 
		 3'b010: begin //multiply
					
							
					result = stack[top] * stack[top-1]; // multiply top 2 of stack
					stack[top - 1] = result;
					top = top - 1;
					//out_stack = stack[top];
					//end
					//		topofstack = stack[top] ;
					end 
					
		 3'b011: begin 					 // push
					
					
					top = top + 1;
					stack[top] = operand;
					//out_stack = stack[top];	
					//	topofstack = stack[top];	
		 
					end 
		 
		 3'b111: begin						 // halt
		 
					haltmode = 2'b01; 
					//	topofstack = stack[top]	;						  
					end 	
					
					default: result = 0;
							  
					endcase	

					
		if (overflowmode == 3'b000) begin
	 
			//changing value of b based on whether we are doing addition or subtraction
			if (op_code == 3'b101) begin //sub

					b_temp = stack[top]*-1;

			end else if (op_code == 3'b100) begin //add

					b_temp = stack[top];

			end				
			
			sum = stack[top-1] + b_temp; 


			if (((stack[top-1][7] == 1) && (b_temp[7] == 1) && (sum[7] == 0)) || ((stack[top-1][7] == 0) && b_temp[7] == 0 && sum[7] == 1) )begin

			overflow = 3'b001; 
			overflowmode = 2'b01;

			end else 

			begin
				
			overflow = 3'b000; 
				
			end 	 
		
			end
					
	end	

	end 
		
	
	 always @(*) begin 			
			

			if (stack[top][7] == 1) begin
					
						twoscomplement = ~stack[top] + 8'b00000001; 
					
			end	else if (stack[top] >= 0) begin
						
						twoscomplement = stack[top];
		
			end	 
			
			
			LEDR = overflow;
		
			BCD = 12'b000000000000;
				
				for (j = 7; j >= 0 ; j = j-1) begin 				
	
				if (BCD[3:0] > 4'b0100) begin
					BCD[11:0] = BCD[11:0] + 8'b00000011;
				end
				
				if (BCD[7:4] > 4'b0100) begin
					BCD[11:0] = BCD[11:0] + 8'b00110000;
				end
							
				
				BCD = {BCD[10:0], twoscomplement[j]};	
			
						
		end 
		
		
		//first digit
	
		begin
	
		if (BCD[3:0] == 4'b0000) begin
		
		
		  HEX0 <= 7'b1000000;  
	//	  HEX1 <= 7'b1000000; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
	
		end
	
		 else if (BCD[3:0] ==  4'b0001) begin
		
		 
		  HEX0 <= 7'b1111001;  
	//	  HEX1 <= 7'b1111111; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  
		  
		 else if (BCD[3:0] == 4'b0010) begin //2
		
		 
		  HEX0 <= 7'b0100100;  
	//	  HEX1 <= 7'b1111111; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  
		  else if (BCD[3:0] == 4'b0011) begin //3
		
		 
		  HEX0 <= 7'b0110000;  
	//	  HEX1 <= 7'b1111111; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  
		 else if (BCD[3:0] == 4'b0100) begin //4
		
		 
		  HEX0 <= 7'b0011001;  
	//	  HEX1 <= 7'b1111111; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  else if(BCD[3:0] == 4'b0101) begin //5
		
		 
		  HEX0 <= 7'b0010010;  
	//	  HEX1 <= 7'b1111111; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
	//	  HEX4 <= 7'b1111111; 
	//	  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  else if (BCD[3:0] == 4'b0110) begin //6
		
		 
		  HEX0 <= 7'b0000010;  
	//	  HEX1 <= 7'b1111111; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  else if (BCD[3:0] == 4'b0111) begin //7
		
		 
		  HEX0 <= 7'b1111000;  
	//	  HEX1 <= 7'b1111111; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  else if(BCD[3:0] == 4'b1000) begin //8
		
		 
		  HEX0 <= 7'b0000000;  
	//	  HEX1 <= 7'b1111111; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  else if (BCD[3:0] == 4'b1001) begin //9
		
		 
		  HEX0 <= 7'b0011000;  
	//	  HEX1 <= 7'b1111111; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
	 end
		 
	 	 
		 	//second digit
		begin
	
		if (BCD[7:4] == 4'b0000) begin
		
		 
		//HEX0 <= 7'b1000000;  
		  HEX1 <= 7'b1000000; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
	//	  HEX4 <= 7'b1111111; 
	//	  HEX5 <= 7'b1111111; 	  
	
		end
	
		 else if (BCD[7:4] ==  4'b0001) begin
		
		 
	//	  HEX0 <= 7'b1111111;  
		  HEX1 <= 7'b1111001; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
	//	  HEX4 <= 7'b1111111; 
	//	  HEX5 <= 7'b1111111; 	  
		  end  
		  
		 else if (BCD[7:4]== 4'b0010) begin //2
		
		 
	//	  HEX0 <= 7'b1111111;  
		  HEX1 <= 7'b0100100; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
	//	  HEX4 <= 7'b1111111; 
	//	  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  
		  else if (BCD[7:4] == 4'b0011) begin //3
		
		 
	//	  HEX0 <= 7'b1111111;  
		  HEX1 <= 7'b0110000; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
	//	  HEX4 <= 7'b1111111; 
	//	  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  else if (BCD[7:4] == 4'b0100) begin //4
		
		 
	//	  HEX0 <= 7'b0011001;  
		  HEX1 <= 7'b0011001; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  else if(BCD[7:4] == 4'b0101) begin //5
		
		 
	//	  HEX0 <= 7'b0010010;  
		  HEX1 <= 7'b0010010; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
	//	  HEX4 <= 7'b1111111; 
	//	  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  else if (BCD[7:4] == 4'b0110) begin //6
		
		 
	//	  HEX0 <= 7'b0000010;  
		  HEX1 <= 7'b0000010; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  else if (BCD[7:4] == 4'b0111) begin //7
		
		 
	//	  HEX0 <= 7'b1111000;  
		  HEX1 <= 7'b1111000; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  else if(BCD[7:4] == 4'b1000) begin //8
		
		 
	//	  HEX0 <= 7'b0000000;  
		  HEX1 <= 7'b0000000; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  else if (BCD[7:4] == 4'b1001) begin //9
		
		 
	//	  HEX0 <= 7'b0011000;  
		  HEX1 <= 7'b0011000; 
		  HEX2 <= 7'b1111111; 
		  HEX3 <= 7'b1111111; 
		  HEX4 <= 7'b1111111; 
		  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		   
		  
	 end
	 
	 	//THIRD digit
		begin
	
		if (BCD[11:8] == 4'b0000) begin
		
		 
		//HEX0 <= 7'b1000000;  
		//  HEX1 <= 7'b1000000; 
		  HEX2 <= 7'b1000000; 
		  HEX3 <= 7'b1111111; 
	//	  HEX4 <= 7'b1111111; 
	//	  HEX5 <= 7'b1111111; 	  
	
		end
	
		 else if (BCD[11:8] ==  4'b0001) begin
		
		 
	//	  HEX0 <= 7'b1111111;  
	//	  HEX1 <= 7'b1111001; 
		  HEX2 <= 7'b1111001; 
		  HEX3 <= 7'b1111111; 
	//	  HEX4 <= 7'b1111111; 
	//	  HEX5 <= 7'b1111111; 	  
		  end  
		  
		 else if (BCD[11:8]== 4'b0010) begin //2
		
		 
	//	  HEX0 <= 7'b1111111;  
	//	  HEX1 <= 7'b0100100; 
		  HEX2 <= 7'b0100100; 
		  HEX3 <= 7'b1111111; 
	//	  HEX4 <= 7'b1111111; 
	//	  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		  
		  
		  
		  else if (BCD[11:8] == 4'b0011) begin //3
		
		 
	//	  HEX0 <= 7'b1111111;  
	//	  HEX1 <= 7'b0110000; 
		  HEX2 <= 7'b0110000; 
		  HEX3 <= 7'b1111111; 
	//	  HEX4 <= 7'b1111111; 
	//	  HEX5 <= 7'b1111111; 	  
		  end  // blank display
		   
		  
	 end
	 
	 
	 	//+- sign
		begin
	
		if (stack[top][7] == 0) begin
		
		  HEX3 <= 7'b1111111;   
	
		end
	
		else if (stack[top][7] == 1) begin
		
		  HEX3 <= 7'b0111111; 
  
		end  
		  
		 
		   
		  
	 end
				
	
	
	 end 
		
		
	
		
			
			
		  
		  
		
	


endmodule 