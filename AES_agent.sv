
//`include"AES_driver.sv"
//`include"AES_monitor.sv"


class AES_agent extends uvm_agent;
     `uvm_component_utils(AES_agent)
 
     //Analysis ports to connect the monitors to the scoreboard
     uvm_analysis_port#(AES_transaction)  agent_ap_dut;
     uvm_analysis_port#(AES_transaction) agent_ap_check;
 
         AES_sequencer sqn_1;
         AES_driver driver_1;
         AES_monitor_dut mon_dut;
         AES_monitor_check mon_check;
 
     function new(string name, uvm_component parent);
          super.new(name, parent);
     endfunction: new
 
     function void build_phase(uvm_phase phase);
          super.build_phase(phase);
 
          agent_ap_dut    = new(.name("agent_ap_dut"), .parent(this));
          agent_ap_check    = new(.name("agent_ap_check"), .parent(this));
 
          sqn_1        = AES_sequencer::type_id::create(.name("sqn_1"), .parent(this));
          driver_1     = AES_driver::type_id::create(.name("driver_1"), .parent(this));
          mon_dut      = AES_monitor_dut::type_id::create(.name("mon_dut"), .parent(this));
          mon_check    =AES_monitor_check::type_id::create(.name("mon_check"), .parent(this));
     endfunction: build_phase
 
     function void connect_phase(uvm_phase phase);
          super.connect_phase(phase);
          driver_1.seq_item_port.connect(sqn_1.seq_item_export);
          mon_dut.mon_ap_dut.connect(agent_ap_dut);
         mon_check.mon_ap_check.connect(agent_ap_check);
     endfunction: connect_phase
endclass: AES_agent




















