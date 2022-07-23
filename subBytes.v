////////////////////////AES ENCRYPTION SYSTEM /////////////////////////////////////////////////
//6/11/2021
//this is subBytes matrix for AES 

//`include"s_Box.v"

module subBytes(input wire[31:0]state,output wire [31:0] state_out );

// note that we use generate to can instance s_Box inside initial block//

generate
  genvar i;
   for(i=0;i<=31;i=i+8)
     begin
     s_box sbox(state[i+:8],state_out[i+:8]);  
  
  
     end

  endgenerate

endmodule




module subBytes_tb();
 reg[31:0]state;

 wire [31:0] state_out;
 subBytes  subBytes_1(.state(state),.state_out(state_out) );
 
 initial
   begin
    state=32'he9f84808;
	#5
	state=32'h9ac68d2a;
	#5
	state=32'ha0f4e22b;
	#5
	state=32'h193de3be;
	
   
   end
   
 initial
   $monitor("%h    %h",state,state_out);
endmodule