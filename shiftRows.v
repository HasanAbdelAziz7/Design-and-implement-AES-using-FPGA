////////////////////////AES ENCRYPTION SYSTEM /////////////////////////////////////////////////
//data 13/11/2021
//this is shiftRows module for AES 
// graduetion project 2022

`timescale 1ns/1ps

module shiftRows(clk,reset,enable,data,shiftrows_out,done); 
input clk,enable,reset;
input wire [127:0]data;
output reg [127:0]shiftrows_out;
output reg done;


//internal reg
wire [127:0]shiftrows_out_wr;

 /*// how we will shift matrix of data
//first row no change
assign shiftrows_out_wr[31:0]= data[31:0];
//second row once shift to left
assign shiftrows_out_wr[63:32]={data[39:32],data[63:40]};
//third row twice shift to left
assign shiftrows_out_wr[95:64]={data[79:64],data[95:80]};
// fourth row three times to left
assign shiftrows_out_wr[127:96]={data[119:96],data[127:120]};
*/

//assign shiftrows_out_wr={data[119:96],data[127:120],data[79:64],data[95:80],data[39:32],data[63:40],data[31:0]};

assign shiftrows_out_wr[7:0]=data[39:32];
assign shiftrows_out_wr[39:32]=data[71:64];
assign shiftrows_out_wr[71:64]=data[103:96];
assign shiftrows_out_wr[103:96]=data[7:0];

assign shiftrows_out_wr[15:8]=data[79:72];
assign shiftrows_out_wr[47:40]=data[111:104];
assign shiftrows_out_wr[79:72]=data[15:8];
assign shiftrows_out_wr[111:104]=data[47:40];

assign shiftrows_out_wr[23:16]=data[119:112];
assign shiftrows_out_wr[55:48]=data[23:16];
assign shiftrows_out_wr[87:80]=data[55:48];
assign shiftrows_out_wr[119:112]=data[87:80];

assign shiftrows_out_wr[31:24]=data[31:24];
assign shiftrows_out_wr[63:56]=data[63:56]; 
assign shiftrows_out_wr[95:88]=data[95:88];
assign shiftrows_out_wr[127:120]=data[127:120];
/*
assign shiftrows_out_wr[7:0]=data[7:0];
assign shiftrows_out_wr[39:32]=data[39:32];
assign shiftrows_out_wr[71:64]=data[71:64];
assign shiftrows_out_wr[103:96]=data[103:96];

assign shiftrows_out_wr[15:8]=data[47:40];
assign shiftrows_out_wr[47:40]=data[79:72];
assign shiftrows_out_wr[79:72]=data[111:104];
assign shiftrows_out_wr[111:104]=data[15:8];

assign shiftrows_out_wr[23:16]=data[87:80];
assign shiftrows_out_wr[55:48]=data[119:112];
assign shiftrows_out_wr[87:80]=data[22:16];
assign shiftrows_out_wr[119:112]=data[55:48];

assign shiftrows_out_wr[31:24]=data[127:120];
assign shiftrows_out_wr[63:56]=data[31:24]; 
assign shiftrows_out_wr[95:88]=data[63:56];
assign shiftrows_out_wr[127:120]=data[95:88];
*/

initial
  begin
     done=1'b0;
	 shiftrows_out=128'b0;
	
    end
always @(posedge clk)
  begin
    if(reset)
      begin
         shiftrows_out<=128'b0;
         done<=1'b0;
        end
  else if (enable)
     begin
         shiftrows_out<=shiftrows_out_wr;
         done<=1'b1;

        end
     else done<=0;	 

    end

endmodule




module shiftRows_tb();
reg clk,reset,enable;
reg [127:0]data;
wire [127:0]shiftrows_out;
wire done;

initial
 begin
   $display(" \t\ttime,clk,reset,enable,\tdata,                             \toutput,                                         \tdone");
   $monitor("%d,\t%b,\t%b,\t%b,\t%h,\t%h,\t%b",$time,clk,reset,enable,data,shiftrows_out,done);
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
   data=128'hd42711aee0bf98f1b8b45de51e415230;
  // data=128'h3052411ee55db4b8f198bfe0ae1127d4;
 end

shiftRows sh_1(.clk(clk),.reset(reset),.enable(enable),.data(data),.shiftrows_out(shiftrows_out),.done(done));
always 
 #5 clk=~clk;


 
 
   
 
endmodule


























