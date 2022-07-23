////////////////////////AES ENCRYPTION SYSTEM /////////////////////////////////////////////////
//data 19/11/2021
//this mixcolumns module for AES 
// graduetion project 2022

module mixcolumns(clk,reset,enable,data,mixcolumns_out,done);

input clk,reset,enable;
input wire[127:0]data;
output reg done;
output reg[127:0]mixcolumns_out;


//internal 
wire[127:0]mixcolumns_out_wr;

function [7:0]mul_by_2;
input[7:0]a;
  begin
     if(a[7]==1) 
	  mul_by_2=((a<<1)^8'h1b);
	  else
	  mul_by_2=(a<<1);


    end
endfunction


function [7:0]mul_by_3;
input[7:0]a;
  begin
     if(a[7]==1) 
	  mul_by_3=((a<<1)^8'h1b^a);
	  else
	  mul_by_3=((a<<1)^a);


    end
endfunction


generate
genvar i;

for(i=0;i<=3;i=i+1)
  begin
  /* assign mixcolumns_out_wr[(i*8)+:8]=mul_by_2(data[(i*8)+:8])^mul_by_3(data[((i*8)+32)+:8])^data[((i*8)+64)+:8]^data[((i*8)+96)+:8];
	assign mixcolumns_out_wr[((i*8)+32)+:8]=data[(i*8)+:8]^mul_by_2(data[((i*8)+32)+:8])^mul_by_3(data[((i*8)+64)+:8])^data[((i*8)+96)+:8];
	assign mixcolumns_out_wr[((i*8)+64)+:8]=data[(i*8)+:8]^data[((i*8)+32)+:8]^mul_by_2(data[((i*8)+64)+:8])^mul_by_3(data[((i*8)+96)+:8]);
	assign mixcolumns_out_wr[((i*8)+96)+:8]=mul_by_3(data[(i*8)+:8])^data[((i*8)+32)+:8]^data[((i*8)+64)+:8]^mul_by_2(data[((i*8)+96)+:8]);
*/
   assign mixcolumns_out_wr[i*32+:8]  = mul_by_2(data[(i*32)+:8])^(data[(i*32 + 8)+:8])^(data[(i*32 + 16)+:8])^mul_by_3(data[(i*32 + 24)+:8]);
    assign mixcolumns_out_wr[(i*32 + 8)+:8] = mul_by_3(data[(i*32)+:8])^mul_by_2(data[(i*32 + 8)+:8])^(data[(i*32 + 16)+:8])^(data[(i*32 + 24)+:8]);
    assign mixcolumns_out_wr[(i*32 + 16)+:8] = (data[(i*32)+:8])^mul_by_3(data[(i*32 + 8)+:8])^mul_by_2(data[(i*32 + 16)+:8])^(data[(i*32 + 24)+:8]);
    assign mixcolumns_out_wr[(i*32 + 24)+:8]  = (data[(i*32)+:8])^(data[(i*32 + 8)+:8])^mul_by_3(data[(i*32 + 16)+:8])^mul_by_2(data[(i*32 + 24)+:8]);
    end
endgenerate


initial
  begin
     done=1'b0;
	 mixcolumns_out=128'b0;
	
    end
always @(posedge clk)
  begin
    if(reset)
      begin
         mixcolumns_out<=128'b0;
         done<=1'b0;
        end
  else if (enable)
     begin
         mixcolumns_out<=mixcolumns_out_wr;
         done<=1'b1;

        end
     else done<=0;	 

    end


endmodule





module mixcolumns_tb();
reg clk,reset,enable;
reg [127:0]data;
wire [127:0]mixcolumns_out;
wire done;

initial
 begin
   $display(" \t\ttime,clk,reset,enable,\tdata,                             \toutput,                                         \tdone");
   $monitor("%d,\t%b,\t%b,\t%b,\t%h,\t%h,\t%b",$time,clk,reset,enable,data,mixcolumns_out,done);
   clk=0;
   data=128'b0;
   reset=0;
   enable=0;
   #5
   reset=1;
   #7
   reset=0;
   #5
   enable=1;
   #5
   data=128'hd4bf5d30e0b452aeb84111f11e2798e5;
   
 end

mixcolumns mix_1(.clk(clk),.reset(reset),.enable(enable),.data(data),.mixcolumns_out(mixcolumns_out),.done(done));
always 
 #5 clk=~clk;
 
 
endmodule
 
