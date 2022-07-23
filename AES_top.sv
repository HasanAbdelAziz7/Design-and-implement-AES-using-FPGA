`include "top_encryption.v"
`include "AES_if.sv"


module AES_top();

import uvm_pkg::*;
import AES_pkg::*;

AES_if vif ();




//generate clock

initial
   begin
    vif.clk_sig = 1;
	end

always #5 vif.clk_sig = ~vif.clk_sig;

//connect  dut to interface 
   top_encryption  top_encrypt(.clk(vif.clk_sig),
            .enable(vif.enable_sig),
			.reset(vif.reset_sig),
			.data(vif.data_byte),
			.key(vif.key_byte),
			.data_out(vif.data_byte_out),
			.load(vif.load_sig),
			.ready(vif.ready_sig));


initial
 begin
		uvm_config_db#(virtual AES_if)::set(null, "", "vif", vif);

		run_test();

  end
  
  
 

 


endmodule



