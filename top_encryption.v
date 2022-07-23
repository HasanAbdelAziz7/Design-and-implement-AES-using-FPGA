////////////////////////AES ENCRYPTION SYSTEM /////////////////////////////////////////////////
//data 19/12/2021
//this top module for AES 
// graduetion project 2022
//language  verilog 
//  thanks to eng ahmed hagazy because his matrials are very helpful for my in my graduetion project.
// by hasan abdel aziz ,mansoura university
//////////////////////////////////////////////////////////////////////////////



module top_encryption(clk,enable,reset,data,key,data_out,load,ready);

//////////////////////////////////////////                global input & output for top module

input clk,reset,enable;                                                 //input signal
input [7:0]data;                          //data byte by byte
input [7:0]key;                           //key byte by byte
output reg[7:0]data_out;                  // output
output reg load,ready;

/////////////////////////////////////////          internal parameter for design 
   
	reg [1:0] fsm1;                 //for input & output finite state machine 
	reg [1:0] fsm2;                  //for encryption rounds  finite state machine 
	reg [127:0] key_reg;            // 128 bits for key
	reg [127:0]data_reg;            // 128 bits for input data
	reg addroundkey_en,shiftRows_en,mixcolumns_en,keyExpantion_en;              // enable signals for sub modules in encryption fsm2
	wire done_addkey,done_shift,done_mix;                                      // done signals for  sub modules inside rounds
	reg  finish;                                                                // finish signal for encryption process
	reg [127:0] modulesStateIn, stateOutput;                                    // input & output for sub modules
	reg [127:0] modulesKeyIn;                                                   //input  for keyExpantion, addroundkey
	wire [127:0] keyExpantion_out,roundKeyStateOut,subBytes_out,shiftrows_out,mixcolumns_out;    // wires between sub modules
	reg [3:0] round_num;                                                  // counter for encryption 11 rounds
	reg startround;                                                     // if set go and start rounds
    integer j,k;                                                       // counters

//////////////////////////////////////// instance of sub modules inside top module//////////////////////////////////////////////////////////////////////////////

addroundkey adkey(.clk(clk),.reset(reset),.enable(addroundkey_en),.state(modulesStateIn),.roundkey(modulesKeyIn),.state_out(roundKeyStateOut),.done(done_addkey));
shiftRows shift(.clk(clk),.reset(reset),.enable(shiftRows_en),.data(modulesStateIn),.shiftrows_out(shiftrows_out),.done(done_shift));
mixcolumns mix(.clk(clk),.reset(reset),.enable(mixcolumns_en),.data(modulesStateIn),.mixcolumns_out(mixcolumns_out),.done(done_mix));
keyExpantion keyexp (.clk(clk),.reset(reset),.enable(keyExpantion_en),.key_num(round_num),.input_key(modulesKeyIn),.output_key(keyExpantion_out));


////////// subBytes process/////
generate
  genvar i;
     for(i=0;i<=127;i=i+32)
     begin
     
         subBytes subb(.state(roundKeyStateOut[i+:32]),.state_out(subBytes_out[i+:32]) );
  
        end

  endgenerate
  
////////////////////////////////////////////////////////////////////////////

//////initial values for input & output finite state machine

 
  initial
  begin
	  ready<=0;
	  load<=0; 
	  data_out<=0;
  end
 ///////////////////////
//////////////////////////////////////////////////////////////////input & output finite state machine ////////////////////////////////////////////
 always  @(posedge clk)
 begin
     if(reset)
	 begin
	 //////reset all input& output&signals & set   counters
	 data_reg<=128'b0;
	 key_reg<=128'b0;
	 data_out<=8'b0;
	 load<=1'b0;
	 ready<=1'b0;
	 startround<=0;            
	 j<=127;                    //   note  that frist byte is MSB 
	 k<=127;
	 fsm1<=0;
	 
	 
    end 
    else if(enable==1)
	begin
	 case(fsm1)
	  0:begin                // start state
	   startround<=0;
		fsm1<=1;
		j<=127;
	    end
	  
	  1:begin                 //input  state
		 if(j>0)
		   begin
		     load<=1'b1;              // while data,key still load , set this bits
		     data_reg[j-:8]<=data;   // 127>>>>> 0 byte by byte
		     key_reg[j-:8]<=key;     // 127>>>>> 0 byte by byte
		     key_reg[j-:8]<=key;
		     j<=j-8;              //decrement counter
			 startround<=0;
		   end
		 else             //  load finish
		   begin
		     startround<=1;      // go to encryption fsm2
		     load<=1'b0;         // load finish
		     fsm1<=2;   
		   end
	    end
	 
	 2:begin               // encryption  state
	     if(finish)             // encryption fsm2 finish
		   begin
		     ready<=1;         // encryption finish and start output , note still set until all byte output
		     startround<=0;   
		     fsm1<=3;
			 k<=127;           // set counter for output 
		   end
		 else             // still inside  encryption fsm2
            begin
			 ready<=0;
			 fsm1<=2;      // still in state 2
            end			
	    end
	 
	 3:begin            // output state
	     if(k>0)
	      begin
	         ready<=1;                   //note still set until all byte output
             data_out<=stateOutput[k-:8];    //output  byte by byte  frist byte is MSB 
             k<=k-8;                       // decrement counter
	      end
	    else              // all process are finish start again for next 128 bits 
	       begin
	         fsm1<=0;              //  go to state start
	         ready<=0;
	       end
	     startround<=0;
	 
	 
	   end
	 
	 
	 endcase
	
	
	
	
	end
	
	   else               //  if not enable set get here
	    begin
		fsm1<=0;
		end
	
end	
	
	
	
////////////////////////////////////////////	
	
/////////////////////////////////////////////////initial values for encryption fsm2	
	
initial
 begin
	addroundkey_en<=0;
	mixcolumns_en<=0;
	shiftRows_en<=0;
	keyExpantion_en<=0;
	finish<=0;
	round_num<=0;
	fsm2<=0;
	stateOutput<=128'b0;
 
 end	
 ////////////////////////////////////////////////////////////////encryption finite state machine (11 rounds )///////////////////////////////////////////////////////
	
always@(posedge clk)
  begin	
	 if(reset)    //////reset all input& output&signals & set   counters
	 begin
	    round_num<=0;
		finish<=0;
		addroundkey_en<=0;
		mixcolumns_en<=0;
		shiftRows_en<=0;
		keyExpantion_en<=0;
		stateOutput<=0;
	    fsm2<=0;
	  end
	  else if( (enable==1) && (startround==1) )    //both enable and startround signal
	
	    begin
	     if(round_num<=11)
		 begin
		 case(fsm2)
	       2'b00:begin                 //start state 
		     modulesStateIn<=data_reg;    // input data to addroundkey              >>
			 modulesKeyIn<=key_reg;       // input the input key for addroundkey      >>>>>>> initial round         
			 addroundkey_en<=1;            // enable addroundkey                    >>
			 keyExpantion_en<=1;            // enable key   keyExpantion
			 round_num<=1;                 // start frist round  
			 mixcolumns_en<=0;
			 shiftRows_en<=0;
		     finish<=0;
			 fsm2<=2'b01;                //next state            //note that the design do subBytes actully to the output of addroundkey
		    end
			
			
			
		   
		    2'b01:begin           // shiftRows state
		      if( done_addkey == 1)                   // wait until addroundkey finish 
			  begin
				modulesStateIn<=subBytes_out;            // input output of subBytes to shiftRows
				modulesKeyIn<=keyExpantion_out;           // but keyExpantion as a new input to keyExpantion
				shiftRows_en<=1;                            // enable shiftRows
				addroundkey_en<=0;
				keyExpantion_en<=0;
				if( round_num < 10) fsm2<=2;              //if we reach to the ten rounds go to addroundkey without mixcolumns
				else fsm2<=2'b10;                          
			  
			  end
			   
		     finish<=0;
		    end
		
		
		
		    2'b10:begin      //mixcolumns state
		      if(done_shift==1)            //wait until shiftRows finish
			   begin
			   modulesStateIn<=shiftrows_out;    // input shiftRows output to mixcolumns
			   mixcolumns_en<=1;                 // enable mixcolumns
			   shiftRows_en<=0;
			   fsm2<=2'b11;
					
		       end
			 finish<=0;
			end
		   
		   
		   
		   
		    2'b11:begin                      //addroundkey state
		      if((done_mix==1)||((done_shift==1)&&(round_num>=10)))         
			  begin
			   if(round_num<10) modulesStateIn<=mixcolumns_out;
			   else modulesStateIn<=shiftrows_out;              //if we in the ten round only
			   addroundkey_en<=1;      // enable mixcolumns
			   keyExpantion_en<=1;     // enable keyExpantion
			   mixcolumns_en<=0;
			   shiftRows_en<=0;
			   round_num<=round_num+1;       // increment rounds counter
			  	fsm2<=2'b01;              //return to shiftRows     //note that the design do subBytes actully to the output of addroundkey
			  end
			  finish<=0;
		    end
	     endcase
	     end
		 else     // we finish all rounds
		  begin
		  stateOutput<=roundKeyStateOut;     // get output in stateOutput reg
		  finish<=1;                         // send  set finish 
		  fsm2<=2'b00;                       // return to start state in fsm2
		  round_num<=0;
		  shiftRows_en<=0;                        //  >
		  mixcolumns_en<=0;                     //   >>>>   disable all signals
		  addroundkey_en<=0;                     //  >
		  keyExpantion_en<=0;                
		  end
	   end
	   
	    else
	    begin                   //we not enable or not startround
			round_num<=0;
			finish<=0;
			addroundkey_en<=0;
			mixcolumns_en<=0;
			shiftRows_en<=0;
			keyExpantion_en<=0;
			fsm2<=2'b00;
	     
        end
		
end
///////////////////////////////////////////////////////////////////////////////////////

endmodule









////////////////////////////////////testbench for top module


//`timescale 1ns/1ps

`timescale 10ns/1ns
module top_encryption_tb();
/*
reg clk,enable,reset;
reg [7:0]data;
reg[7:0]key;
wire [7:0]data_out;
wire load,ready;
reg [127:0]data_reg;
reg [127:0]key_reg;

integer i;
top_encryption top1(.clk(clk),.enable(enable),.reset(reset),.data(data),.key(key),.data_out(data_out),.load(load),.ready(ready));
initial 
  begin
     clk=0;
	 enable=0;
	 reset=0;
	 data=0;
	 key=0;
	 key_reg=0;
	 data_reg=0;
	 i<=127;
	 #2
	 reset=1;
	 #2
	 reset=0;
	 enable=1;
	 #2
	 data_reg=128'h3243f6a8885a308d313198a2e0370734;
	 key_reg=128'h2b7e151628aed2a6abf7158809cf4f3c;
		
	
   end
always
 #1 clk=~clk;

 initial
    begin
	 $display(" \t\ttime,clk,reset,enable,\tdata,               \tkey                       \tdata_out,                      \tload               \tready");
     $monitor("%d,\t%b,\t%b,\t%b,\t%h,\t%h,\t%h,\t%b,\t%b",$time,clk,reset,enable,data,key,data_out,load,ready);
	
	
	end
 
 always @(posedge clk)
  begin
         if(enable==1)
		 begin
	        if(i>0)
				 begin
				   data<=data_reg[i-:8];
			       key<=key_reg[i-:8];
				   i=i-8;
				  end
			end	  
   end

*/

reg [7:0] key_byte, state_byte;
reg clk,rst,enable;

/* OUTPUTS */
wire [7:0] state_out_byte;
wire load,ready;

/* instance */

//AES_encryption AES_TB(key_byte, state_byte,clk,rst,enable,state_out_byte,load,ready);
top_encryption top1(.clk(clk),.enable(enable),.reset(rst),.data(state_byte),.key(key_byte),.data_out(state_out_byte),.load(load),.ready(ready));
reg startSend;

/*Initializing inputs*/
initial 
begin 
 //initialize here 
	clk = 0;
	rst = 0;
  key_byte = 0;
  state_byte =0;
	enable = 0;
	startSend=0;
end 


/*Monitor values*/
initial 
begin 
  $display ("\t\ttime,\tkey_Byte,\tdata_Byte,\tload,\tready,\tdata_out_byte");
  $monitor ("%d,\t%h,\t%h,\t%b,\t%b,\t%h",$time,key_byte,state_byte,load,ready,state_out_byte);
end

//Generate clock 
always 
#1 clk = ~clk;

event reset_done;
/*Generating input values */
task reset();
  begin
  @(negedge clk);
    rst = 1;
	#5
  @(negedge clk);
		begin 
		rst = 0;
		->reset_done;
		end
	
	

end 
endtask


reg [127:0] full_key,full_state;
integer i;

always @(negedge clk)
begin 
	if ( startSend && (i > 0) )
	begin 
		key_byte <= full_key[i-:8];
		state_byte <= full_state[i-:8];
		i = i-8;
	end 
end 


initial 
begin 
/*
		 // 16 cycle  key = 54 68 61 74 73 20 6D 79 20 4B 75 6E 67 20 46 75 
				// ;data = 54 77 6F 20 4F 6E 65 20 4E 69 6E 65 20 54 77 6F 
				
									 54 77 6F 20
									 4F 6E 65 20
									 4E 69 6E 65
									 20 54 77 6F 
*/
	//full_key <= 128'h5468617473206D79204B756E67204675;
	//full_state <= 128'h54776F204F6E65204E696E652054776F;
	///////////////////////////////////////////////////////////
	full_key <=128'h2b7e151628aed2a6abf7158809cf4f3c;
	full_state <=128'h3243f6a8885a308d313198a2e0370734 ;

  i <= 127;
	#1 reset();
end

initial
begin 
  @(reset_done)
  begin
	#2;
		enable = 1;
	#2; /*wait one cycle because datsa is recieved in the design after one cycle of the enable signal is set*/
		startSend = 1;
		@(ready) 
			begin 
				#35;
				$stop;
			end 
  end
end 


endmodule















