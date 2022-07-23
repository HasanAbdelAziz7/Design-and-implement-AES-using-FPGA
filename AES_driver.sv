// driver component for uvm
//import uvm_pkg::*;
//`include "uvm_macros.svh"
//`include"AES_sequencer.sv"
class AES_driver extends uvm_driver#(AES_transaction);

`uvm_component_utils(AES_driver)

function new (string name,uvm_component parent);
   super.new(name,parent);
   
 endfunction: new
 
 
 virtual AES_if vif;
 
 function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	
	if (!uvm_config_db#(virtual AES_if)::get(this, "", "vif", vif)) begin
           `uvm_fatal(get_type_name(), "No virtual interface specified for this driver instance")
    end
 endfunction: build_phase

task run_phase(uvm_phase phase);
   AES_transaction aes_ts;
   super.run_phase(phase);
  forever begin
     seq_item_port.get_next_item(aes_ts);
     drive_task(aes_ts);
    
   end

endtask: run_phase


virtual task drive_task(AES_transaction aes_ts);

integer fsmstate = 0,i = 0;
vif.data_byte = 8'b0;
vif.key_byte = 8'b0;
vif.enable_sig = 1'b0;
vif.reset_sig = 1'b1; 



@(posedge  vif.clk_sig)
  begin
     if(vif.reset_sig == 1)
	 begin
	  seq_item_port.item_done();
	  fsmstate = 0;
	 end
	else
   begin	
	case(fsmstate)
       0:begin
         vif.enable_sig = 1'b0;
          vif.reset_sig = 1'b1; 
           fsmstate = 1;  
        end
      1:begin
          vif.enable_sig = 1'b1;
          vif.reset_sig = 1'b0; 
           i=128;
		  fsmstate = 2; 
         
        end

      2:if(i > 0)
	     begin
		     vif.data_byte = aes_ts.data[i-1 -:8];
		      vif.key_byte = aes_ts.key[i-1 -:8];
		     vif.load_sig = 1'b1;
		     i=i-8;
		   end
		else
		  begin
		     vif.load_sig=1'b0;
		     i= 0;
			 fsmstate=3;
		   end
      3:if(vif.ready_sig)
	    begin
	      i=i+8;
		  if(i>127)
		    begin
	         fsmstate=4;
		   end
	   end
	   else 
	    begin
		fsmstate = 3;
	    end
	  4:begin
	     seq_item_port.item_done();
		 fsmstate = 0;
        end	  
	   
	   
    endcase
 end
end


endtask: drive_task










endclass

