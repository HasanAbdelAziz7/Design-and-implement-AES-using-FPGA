////////////////////////AES ENCRYPTION SYSTEM /////////////////////////////////////////////////
//10/30/2021
//this is rcon matrix for AES 



module Rcon(input[3:0]round_num,output reg [31:0]rcon_column);
 always@(round_num)
   begin
     case(round_num)
          1:rcon_column=32'h01000000;
		  2:rcon_column=32'h02000000;
		  3:rcon_column=32'h04000000;
		  4:rcon_column=32'h08000000;
		  5:rcon_column=32'h10000000;
		  6:rcon_column=32'h20000000;
		  7:rcon_column=32'h40000000;
		  8:rcon_column=32'h80000000;
		  9:rcon_column=32'h1b000000;
		  10:rcon_column=32'h36000000;
		 default rcon_column=32'h00000000;
     endcase
   end
endmodule
module Rcon_tb();
reg [3:0]round_num;
wire[31:0]rcon_column;
initial
begin
round_num=1;
#5
round_num=2;
#5
round_num=3;
#5
round_num=4;
#5
round_num=5;
#5
round_num=6;
#5
round_num=7;
#5
round_num=8;
#5
round_num=9;
#5
round_num=10;

end
initial
$monitor("%d   %h",round_num,rcon_column);

Rcon r1(.round_num(round_num),.rcon_column(rcon_column));


endmodule