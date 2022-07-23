////////////////////////AES ENCRYPTION SYSTEM /////////////////////////////////////////////////
//data 5/12/2021
//this singlekeyExpantion module for AES 
// graduetion project 2022



module keyExpantion(clk,reset,enable,key_num,input_key,output_key);
input clk,reset,enable;
input [127:0]input_key;
input[3:0]key_num;
output reg [127:0]output_key;

///internal variable
wire [31:0]step1;
wire[31:0]step1_out;
wire[31:0]rcon;



/////////subword process
subBytes sb1(.state(step1),.state_out(step1_out));

///////// get rcon word for round
Rcon rc1(.round_num(key_num),.rcon_column(rcon));

/////////rotword
assign step1={input_key[23:0],input_key[31:24]};


/////////////////
initial output_key=0;
always@(posedge clk)
    begin
    if(reset==1)
	   begin
	    output_key<=128'b0;
		
	   end
	 else
      if(enable)
        begin
         
		//////////frist word = input_key[127:96]+(rotword + subword) + rcon 
		 output_key[127:96]=input_key[127:96] ^ step1_out ^ rcon;
         
		//////////////second word		 
		 output_key[95:64]=output_key[127:96] ^ input_key[95:64];
        
		//////////////thrid word		 
		 output_key[63:32]=output_key[95:64] ^ input_key[63:32];
		
		////////////// fourth word
		 output_key[31:0]=output_key[63:32] ^ input_key[31:0];
			
			
			
        end			
    end
	
	
	
	/*
     this method more delay

	wire [127:0] keyOutComb;
    assign keyOutComb[127:96] = input_key[127:96] ^ step1_out ^ rcon; 	
    assign keyOutComb[95:64] = input_key[95:64] ^ output_key[127:96];
    assign keyOutComb[63:32] = input_key[63:32] ^ output_key[95:64];
    assign keyOutComb[31:0] = input_key[31:0] ^ output_key[63:32];

    initial output_key = 0;
    
    always @(posedge clk) 
     begin
        if ( reset == 1 )
        begin 
        output_key= 0;
            // donothing 
        end 
        else 
            if(enable)
                output_key <= keyOutComb;
    end*/
	
	
endmodule



module keyExpantion_tb();
reg clk,reset,enable;
reg [127:0]input_key;
reg[3:0]key_num;
wire [127:0]output_key;



initial
 begin
   $display(" \t\ttime,clk,reset,enable,\tkey,                             \toutput ");
   $monitor("%d,\t%b,\t%b,\t%b,\t%d,\t%h,\t%h",$time,clk,reset,enable,key_num,input_key,output_key);
   clk=0;
   input_key=128'b0;
   reset=0;
   enable=0;
   key_num=0;
   #5
   reset=1;
   #7
   reset=0;
   #5
   enable=1;
   key_num=1;
   input_key=128'h2b7e151628aed2a6abf7158809cf4f3c;
   
 end

keyExpantion ke1(.clk(clk),.reset(reset),.enable(enable),.key_num(key_num),.input_key(input_key),.output_key(output_key));
always 
 #5 clk=~clk;
 
 
endmodule















