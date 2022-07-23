//`include"AES_monitor.sv"

class AES_scoreboard extends uvm_scoreboard;
     `uvm_component_utils(AES_scoreboard)
 
     uvm_analysis_export #(AES_transaction) sb_export_dut;
     uvm_analysis_export #(AES_transaction) sb_export_check;
 
     uvm_tlm_analysis_fifo #(AES_transaction) dut_fifo;
     uvm_tlm_analysis_fifo #(AES_transaction) check_fifo;
 
     AES_transaction transaction_dut;
     AES_transaction transaction_check;
 
     function new(string name, uvm_component parent);
          super.new(name, parent);
          transaction_dut    = new("transaction_dut");
          transaction_check   = new("transaction_check");
     endfunction: new
 
     function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          sb_export_dut    = new("sb_export_dut", this);
          sb_export_check        = new("sb_export_check", this);
 
          dut_fifo        = new("dut_fifo", this);
          check_fifo        = new("check_fifo", this);
     endfunction: build_phase
 
     function void connect_phase(uvm_phase phase);
          sb_export_dut.connect(dut_fifo.analysis_export);
          sb_export_check.connect(check_fifo.analysis_export);
     endfunction: connect_phase
 
     task run();
          forever begin
               dut_fifo.get(transaction_dut);
               check_fifo.get(transaction_check);
               compare();
          end
     endtask: run
 
     virtual function void compare();
          if(transaction_dut.data_out == transaction_check.data_out) begin
               `uvm_info("compare", {"Test: OK!"}, UVM_LOW);
          end else begin
               `uvm_info("compare", {"Test: Fail!"}, UVM_LOW);
          end
     endfunction: compare
endclass: AES_scoreboard
