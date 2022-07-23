//`include"AES_agent.sv"
//`include"AES_scoreboard.sv"

class AES_env extends uvm_env;
     `uvm_component_utils( AES_env)
 
     AES_agent aes_agt;
     AES_scoreboard aes_score;
 
     function new(string name, uvm_component parent);
          super.new(name, parent);
     endfunction: new
 
     function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          aes_agt    = AES_agent::type_id::create(.name("aes_agt"), .parent(this));
          aes_score       = AES_scoreboard::type_id::create(.name("aes_score"), .parent(this));
     endfunction: build_phase
 
     function void connect_phase(uvm_phase phase);
          super.connect_phase(phase);
          aes_agt.agent_ap_dut.connect(aes_score.sb_export_dut);
          aes_agt.agent_ap_check.connect(aes_score.sb_export_check);
     endfunction: connect_phase
endclass: AES_env
