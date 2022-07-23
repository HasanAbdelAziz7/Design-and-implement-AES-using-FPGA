////////////////////////AES ENCRYPTION SYSTEM /////////////////////////////////////////////////
//data 6/12/2021
//this addroundkey module for AES 
// graduetion project 2022



module addroundkey(clk,reset,enable,state,roundkey,state_out,done);

//////////////////////////////
input clk,reset,enable;
input[127:0]roundkey;
input[127:0]state;
output reg[127:0]state_out;
output reg done;


//////internal
wire [127:0]state_out_wr;
genvar i;
generate
//////////////we xor byte(key) by byte (state)
for(i=0;i<16;i=i+1)
		assign state_out_wr[(i*8)+:8]=state[(i*8)+:8] ^ roundkey[(i*8)+:8];
		
/////////////////////////////////
endgenerate
initial
   begin
    state_out=0;
    done=0;
   end
//////////////////////////////////   
    
always@(posedge clk)
    begin
      if(reset==1)
        begin
		state_out<=0;
		done<=0;
        end		
     else if(enable==1)
	    begin
		state_out<=state_out_wr;
		done<=1;
        end		
    else
	   begin
        done<=0;		
        end       
 
  
    end

endmodule





module addroundkey_tb();
reg clk,reset,enable;
reg [127:0]state;
reg[127:0]roundkey;
wire [127:0]state_out;
wire done;

initial
 begin
   $display(" \t\ttime,clk,reset,enable,\tstate,                         \troundkey                                   \toutput,                                         \tdone");
   $monitor("%d,\t%b,\t%b,\t%b,\t%h,\t%h,\t%h,\t%b",$time,clk,reset,enable,state,roundkey,state_out,done);
   clk=0;
   state=128'b0;
   reset=0;
   roundkey=0;
   enable=0;
   #5
   reset=1;
   #7
   reset=0;
   #5
   enable=1;
   roundkey=128'h2b7e151628aed2a6abf7158809cf4f3c;
   state=128'h3243f6a8885a308d313198a2e0370734;
   
 end

addroundkey addk1(.clk(clk),.reset(reset),.enable(enable),.state(state),.roundkey(roundkey),.state_out(state_out),.done(done));
always 
 #5 clk=~clk;


endmodule





























