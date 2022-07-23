

//`include"AES_sequencer.sv"
`include"AES_ENC.sv"


class AES_monitor_dut extends uvm_monitor;


`uvm_component_utils(AES_monitor_dut)

 uvm_analysis_port#(AES_transaction) mon_ap_dut;
 
 virtual AES_if vif;

function new(string name, uvm_component parent);
          super.new(name, parent);
     endfunction: new
 
 


 

 
 
  function void build_phase (uvm_phase phase);
      super.build_phase(phase);
	  
	  mon_ap_dut = new(.name("mon_ap_dut"), .parent(this));
	  
	  
	 if (!uvm_config_db#(virtual AES_if)::get(this, "", "vif", vif)) begin
           `uvm_fatal(get_type_name(), "No virtual interface specified for this driver instance")
        end
   endfunction: build_phase
   
   
  virtual task run_phase (uvm_phase phase);
       
	   integer i=128,fsm_state=0;

	   AES_transaction aes_ts;
		aes_ts = AES_transaction::type_id::create
			(.name("aes_ts"), .contxt(get_full_name()));
		 
		 
		 
		 forever begin
		 @(posedge vif.clk_sig)
		 begin
		   case(fsm_state)
		    0:begin
			   if(vif.ready_sig ==1'b1)
			    begin
			    fsm_state=1;
			    i=128;
				end
			  end
			1:begin
			    aes_ts.data_out[i-1 -:8]=vif.data_byte_out;
			    i=i-8;
			  if(i<0)
			   begin
			     fsm_state = 2;
			     mon_ap_dut.write(aes_ts);
			   end
			  end
			2:begin
			  if(vif.ready_sig ==1'b0)  fsm_state = 0;
			  
			  end
		   endcase
		 
		 end
		 end
		 
   endtask: run_phase



endclass: AES_monitor_dut


class AES_monitor_check extends uvm_monitor;

`uvm_component_utils(AES_monitor_check)

 uvm_analysis_port#(AES_transaction) mon_ap_check;
 
 virtual AES_if vif;


AES_transaction aes_ts_cg;
 AES_transaction  aes_ts;
 covergroup aes_cg;
    data_cg:    coverpoint aes_ts_cg.data; 
	key_cg:      coverpoint aes_ts_cg.key;
	  cross  data_cg,key_cg;
 endgroup: aes_cg
 
function new(string name, uvm_component parent);
          super.new(name, parent);
		  aes_cg = new;
     endfunction: new
 
 
 

 
 
 
 
 function void build_phase (uvm_phase phase);
      super.build_phase(phase);
	  
	  mon_ap_check  = new(.name("mon_ap_check"), .parent(this));
	  
	  
	  
	 if (!uvm_config_db#(virtual AES_if)::get(this, "", "vif", vif)) begin
           `uvm_fatal(get_type_name(), "No virtual interface specified for this driver instance")
        end
   endfunction: build_phase
   
   
    
  virtual task run_phase (uvm_phase phase);
         integer i=128,fsm_state=0;

	   AES_transaction aes_ts;
		aes_ts = AES_transaction::type_id::create
			(.name("aes_ts"), .contxt(get_full_name()));
       
		 
		 forever begin
		 @(negedge  vif.clk_sig )
		 begin
		  case(fsm_state)
		   0:begin
		     if(vif.enable_sig ==1'b1 & vif.reset_sig == 1'b0)
			   begin
			     fsm_state = 1;
				 i=128;
			   end
		     end
		   1:begin
		      aes_ts.data[i-1 -:8]=vif.data_byte;
			   aes_ts.key[i-1 -:8]=vif.data_byte;
			   
				     
				  if(i<120) i=128; 
				   else i=i-8;
				    if(vif.load_sig == 1'b1) 
					begin
					   i=112;
					   fsm_state =2;
					end

				if(vif.reset_sig == 1 | vif.enable_sig == 0)
                   begin
				    fsm_state=0;
                    end				   
					
				 
		    end
		   2:begin
		     
			 aes_ts.data[i-1 -:8]=vif.data_byte;
			 aes_ts.key[i-1 -:8]=vif.data_byte;
		     i=i-8;
			  if(i<0)
			    begin
				 fsm_state = 3;
			   	 aes_ts_cg=aes_ts;
				 aes_cg.sample();
				 mon_ap_check.write(aes_ts);
				 check_protocol();
				 
			   end
				
		     end
		   3:begin
		     if(vif.load_sig == 0) fsm_state=0;
		     end
		  endcase
		 
		 end
		 end
		endtask
		
		
virtual function void check_protocol();
  AES_ENC check_enc;
    check_enc= new;
    check_enc.key=aes_ts.key;
    check_enc.state=aes_ts.data;
    check_enc.encrypt();
   aes_ts.data_out =check_enc.state_out;
   
endfunction:  check_protocol

endclass: AES_monitor_check



