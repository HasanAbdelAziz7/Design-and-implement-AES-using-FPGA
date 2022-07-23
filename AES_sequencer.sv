
//import uvm_pkg::*;
//`include "uvm_macros.svh"
class AES_transaction extends uvm_sequence_item;
rand bit[127:0]data;
rand bit[127:0]key;
rand bit reset;
rand bit enable;
bit [127:0] data_out;

function new(string name=" ");
  super.new(name);

endfunction: new

`uvm_object_utils_begin(AES_transaction)
   `uvm_field_int(data,UVM_ALL_ON)
   `uvm_field_int(key,UVM_ALL_ON)
   `uvm_field_int(reset,UVM_ALL_ON)
   `uvm_field_int(enable,UVM_ALL_ON)
   `uvm_field_int(data_out,UVM_ALL_ON)
`uvm_object_utils_end


endclass: AES_transaction

class AES_sequence extends uvm_sequence#(AES_transaction);
 
 function new (string name="");
     super.new(name);
 endfunction: new
 
 `uvm_object_utils(AES_sequence)
 
 virtual task body();
    AES_transaction aes_ts;
	int unsigned times=15;
	aes_ts= AES_transaction::type_id::create(.name("aes_ts"), .contxt(get_full_name()));
	repeat(times)
	begin
	  start_item (aes_ts);
	   assert(aes_ts.randomize());
	  finish_item(aes_ts);
	
	end 
 
 
 
 endtask: body

endclass : AES_sequence



  typedef uvm_sequencer#(AES_transaction) AES_sequencer;
